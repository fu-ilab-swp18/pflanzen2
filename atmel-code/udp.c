#include <stdio.h>

#include "net/sock/udp.h"
#include "net/ipv6/addr.h"

int udp_send(char * ipv6_addr, int port, char * payload)
{
    int res;
    sock_udp_ep_t remote = { .family = AF_INET6 };

    if (ipv6_addr_from_str((ipv6_addr_t *)&remote.addr, ipv6_addr) == NULL) {
        puts("Error: unable to parse destination address");
        return 1;
    }
    if (ipv6_addr_is_link_local((ipv6_addr_t *)&remote.addr)) {
        /* choose first interface when address is link local */
        gnrc_netif_t *netif = gnrc_netif_iter(NULL);
        remote.netif = (uint16_t)netif->pid;
    }
    remote.port = port;
    if((res = sock_udp_send(NULL, payload, strlen(payload), &remote)) < 0) {
        puts("Error: could not send");
    }
    else {
        printf("Success: sent %u byte to %s\n", (unsigned) res, ipv6_addr);
    }
    return 0;
}
