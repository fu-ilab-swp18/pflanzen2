/*
 * Copyright (C) 2008, 2009, 2010 Kaspar Schleiser <kaspar@schleiser.de>
 * Copyright (C) 2013 INRIA
 * Copyright (C) 2013 Ludwig Knüpfer <ludwig.knuepfer@fu-berlin.de>
 *
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License v2.1. See the file LICENSE in the top level
 * directory for more details.
 */

/**
 * @ingroup     examples
 * @{
 *
 * @file
 * @brief       Default application that shows a lot of functionality of RIOT
 *
 * @author      Kaspar Schleiser <kaspar@schleiser.de>
 * @author      Oliver Hahm <oliver.hahm@inria.fr>
 * @author      Ludwig Knüpfer <ludwig.knuepfer@fu-berlin.de>
 *
 * @}
 */

#include <stdio.h>
#include <string.h>

#include "thread.h"
#include "shell.h"
#include "shell_commands.h"

#include "xtimer.h"
#include "saul_reg.h"
#include "phydat.h"

#ifdef MODULE_NETIF
#include "net/gnrc/pktdump.h"
#include "net/gnrc.h"
#endif

char led_blink_thread_stack[THREAD_STACKSIZE_MAIN];

void * led_blink_thread(void * arg)
{
    
    (void) arg;
    msg_t m;

    saul_reg_t * led = saul_reg_find_nth(0);
    
    phydat_t data;

    data.val[0] = 1;
    data.val[1] = 1;
    data.val[2] = 1;

    data.unit    = UNIT_UNDEF;
    data.scale   = 0;

    while(1) {
        
        data.val[0] = !data.val[0];
        data.val[1] = !data.val[1];
        data.val[2] = !data.val[2];
         
        saul_reg_write(led, &data);
        
        xtimer_sleep(1);

    }

    return NULL;
}

int main(void)
{
#ifdef MODULE_NETIF
    gnrc_netreg_entry_t dump = GNRC_NETREG_ENTRY_INIT_PID(GNRC_NETREG_DEMUX_CTX_ALL,
                                                          gnrc_pktdump_pid);
    gnrc_netreg_register(GNRC_NETTYPE_UNDEF, &dump);
#endif

    (void) puts("Welcome to RIOT!");

    // start thread for led blinking
    thread_create(led_blink_thread_stack, sizeof(led_blink_thread_stack),
                  THREAD_PRIORITY_MAIN - 1, THREAD_CREATE_STACKTEST,
                  led_blink_thread, NULL, "led_blink_thread");

    /*
    saul_reg_t * radio = saul_reg_find_name("AT86RF233");

    printf("Name: %s\r\n", radio->name);
    */

    char line_buf[SHELL_DEFAULT_BUFSIZE];
    shell_run(NULL, line_buf, SHELL_DEFAULT_BUFSIZE);

    return 0;
}
