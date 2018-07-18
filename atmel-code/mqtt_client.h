#ifndef _MQTT_CLIENT_H
#define _MQTT_CLIENT_H

int mqtt_client_init(void);
int cmd_con(int argc, char **argv);
int cmd_discon(int argc, char **argv);
int cmd_pub(int argc, char **argv);
int cmd_sub(int argc, char **argv);
int cmd_unsub(int argc, char **argv);
int cmd_will(int argc, char **argv);

#endif /* _MQTT_CLIENT_H */