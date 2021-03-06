# name of your application
APPLICATION = atmel

# If no BOARD is found in the environment, use this default:
BOARD ?= samr21-xpro

# If no PORT is found in the environment, use this default:
PORT ?= /dev/ttyACM3

# This has to be the absolute path to the RIOT base directory:
RIOTBASE ?= $(CURDIR)/../RIOT/

# Don't fail on warnings
WERROR ?= 0

BOARD_INSUFFICIENT_MEMORY := arduino-duemilanove arduino-mega2560 arduino-uno \
                             chronos hifive1 msb-430 msb-430h nucleo-f031k6 nucleo-f042k6 \
                             nucleo-f303k8 nucleo-l031k6 nucleo-f030r8 nucleo-f070rb \
                             nucleo-f072rb nucleo-f302r8 nucleo-f334r8 nucleo-l053r8 \
                             stm32f0discovery telosb waspmote-pro wsn430-v1_3b \
                             wsn430-v1_4 z1 mega-xplained

# Include packages that pull up and auto-init the link layer.
# NOTE: 6LoWPAN will be included if IEEE802.15.4 devices are present
USEMODULE += gnrc_netdev_default
USEMODULE += auto_init_gnrc_netif
# Specify the mandatory networking modules for IPv6 and UDP
USEMODULE += gnrc_sock_udp
USEMODULE += gnrc_udp
USEMODULE += gnrc_ipv6_router_default
# Add a routing protocol
USEMODULE += gnrc_rpl
USEMODULE += auto_init_gnrc_rpl
# Include MQTT-SN
USEMODULE += emcute
# Add also the shell, some shell commands
USEMODULE += shell
USEMODULE += shell_commands
USEMODULE += ps
# For testing we also include the ping6 command and some stats
USEMODULE += gnrc_icmpv6_echo
# netstat
USEMODULE += netstats_l2
USEMODULE += netstats_ipv6
USEMODULE += netstats_rpl

USEMODULE += random
USEMODULE += dht
USEMODULE += periph_adc

USEMODULE += saul_default

# Set a custom 802.15.4 channel if needed
DEFAULT_CHANNEL ?= 26
CFLAGS += -DDEFAULT_CHANNEL=$(DEFAULT_CHANNEL)

CFLAGS += -DGNRC_RPL_LIFETIME_UNIT=1 -DGNRC_RPL_DEFAULT_LIFETIME=32
CFLAGS += -DGNRC_RPL_REGULAR_DAO_INTERVAL=13
CFLAGS += -DGNRC_RPL_DEFAULT_DIO_INTERVAL_DOUBLINGS=13

# Comment this out to disable code in RIOT that does safety checking
# which is not needed in a production environment but helps in the
# development process:
DEVELHELP ?= 1

# Comment this out to join RPL DODAGs even if DIOs do not contain
# DODAG Configuration Options (see the doc for more info)
# CFLAGS += -DGNRC_RPL_DODAG_CONF_OPTIONAL_ON_JOIN

# Change this to 0 show compiler invocation lines by default:
QUIET ?= 1

include $(RIOTBASE)/Makefile.include