#include <stdio.h>

#include "shell.h"
#include "msg.h"
#include "thread.h"
#include "net/gnrc/rpl.h"
#include "net/gnrc.h"
#include "net/gnrc/netif.h"
#include "net/gnrc/ipv6.h"

#define MAIN_QUEUE_SIZE     (8)
static msg_t _main_msg_queue[MAIN_QUEUE_SIZE];

#ifdef MODULE_GNRC_SIXLOWPAN
static char _stack[THREAD_STACKSIZE_MAIN];

/* "rpl" shell command*/
extern int _gnrc_rpl(int argc, char **argv);

/* "ifconfig" shell command */
extern int _gnrc_netif_config(int argc, char **argv);

static void *_ipv6_fwd_eventloop(void *arg) {
    (void)arg;

    msg_t msg, msg_q[8];
    gnrc_netreg_entry_t me_reg = GNRC_NETREG_ENTRY_INIT_PID(GNRC_NETREG_DEMUX_CTX_ALL,
                                                            thread_getpid());

    msg_init_queue(msg_q, 8);

    gnrc_netreg_register(GNRC_NETTYPE_SIXLOWPAN, &me_reg);

    while(1) {
        msg_receive(&msg);
        gnrc_pktsnip_t *pkt = msg.content.ptr;
        if(msg.type == GNRC_NETAPI_MSG_TYPE_SND) {
            gnrc_pktsnip_t *ipv6 = gnrc_pktsnip_search_type(pkt, GNRC_NETTYPE_IPV6);
            ipv6_addr_t addrs[GNRC_NETIF_IPV6_ADDRS_NUMOF];
            int res;
            ipv6 = ipv6->data;

            ipv6_hdr_t *ipv6_hdr =(ipv6_hdr_t *)ipv6;

            /* get the first IPv6 interface and prints its address */
            gnrc_netif_t *netif = gnrc_netif_iter(NULL);
            res = gnrc_netif_ipv6_addrs_get(netif, addrs, sizeof(addrs));
            if (res < 0) {
                /* an error occurred, just continue */
                continue;
            }
            for (unsigned i = 0; i < (res / sizeof(ipv6_addr_t)); i++) {
                if ((!ipv6_addr_is_link_local(&addrs[i])) &&
                    (!ipv6_addr_is_link_local(&ipv6_hdr->src)) &&
                    (!ipv6_addr_is_link_local(&ipv6_hdr->dst)) &&
                    (!ipv6_addr_equal(&addrs[i], &(ipv6_hdr->src)))) {
                    char addr_str[IPV6_ADDR_MAX_STR_LEN];
                    printf("IPv6 ROUTER: forward from src = %s ",
                           ipv6_addr_to_str(addr_str, &(ipv6_hdr->src),
                                            sizeof(addr_str)) );
                    printf("to dst = %s\n",
                           ipv6_addr_to_str(addr_str, &(ipv6_hdr->dst),
                                            sizeof(addr_str)));
                }
            }
        }
        gnrc_pktbuf_release(pkt);
    }
    /* never reached */
    return NULL;
}
#endif

int init_rpl_node(char* RLP_NODE_MODE, char* RPL_IFACE_NO) {

    if (strcmp(RLP_NODE_MODE, "std") == 0) {

        printf("Initializing node as a RPL standard node.\n"); 

    } else if (strcmp(RLP_NODE_MODE, "root") == 0) {
       
        printf("Initializing node as a RPL root node.\n"); 

    } else {

        printf("No or wrong RPL configuration selected.\n\n");
        return 1;

    }

    /* we need a message queue for the thread running the shell in order to
     * receive potentially fast incoming networking packets */
    msg_init_queue(_main_msg_queue, MAIN_QUEUE_SIZE);
    
#ifdef MODULE_GNRC_SIXLOWPAN
    thread_create(_stack, sizeof(_stack), (THREAD_PRIORITY_MAIN - 4),
                         THREAD_CREATE_STACKTEST, _ipv6_fwd_eventloop, NULL, "ipv6_fwd");
#endif

    /*  rpl configuration. */ 

    if (strcmp(RLP_NODE_MODE, "root") == 0) {

        /* Set root IP address */
        char * cmd[] = {"ifconfig", RPL_IFACE_NO, "add","2001:db8::1"};
        _gnrc_netif_config(4, cmd);
    
    }

    /* initiate rpl for configuration */
    char * cmd2[] = {"rpl", "init", RPL_IFACE_NO};
    _gnrc_rpl(3, cmd2);

    if (strcmp(RLP_NODE_MODE, "root") == 0) {
        
        /* set rpl root node */
        char * cmd3[] = {"rpl", "root", "1", "2001:db8::1"};
        _gnrc_rpl(4 ,cmd3);
        
    }

    printf("\n");

    return 0;
}
