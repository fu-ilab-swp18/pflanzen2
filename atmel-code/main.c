#include <stdio.h>
#include <string.h>

#include "shell.h"
#include "shell_commands.h"

#include "xtimer.h"
#include "saul_reg.h"
#include "phydat.h"
#include "random.h"

#include "fmt.h"
#include "dht.h"
#include "dht_params.h"
#include "periph/adc.h"

#include "udp.h"
#include "mqtt_client.h"
#include "rpl_node.h"

/* NODE DEFINITIONS */

#define NODE_NAME "sepp"
#define WAKEUP_INTERVAL_IN_S 5
#define RPI_ADDR "fe80::1ac0:ffee:1ac0:ffee"

/* MQTT DEFINITIONS */

#define MQTT_PORT "1885"
#define MQTT_TOPIC_NAME "data"
#define MQTT_QOS_LEVEL "1"

/* RPL DEFINITIONS */

#define RPL_NODE_MODE "std"     // valid options are "std" and "root"
#define RPL_IFACE_NO "6"

/* SENSOR DEFINITIONS */

// DHT11 temperature & air humidity sensor
#define DHT_PIN_PORT 0
#define DHT_PIN_NUM 7

// DFRobot ground moisture sensor
#define DFR_LINE_NO 0   // corresponds to pin PA06

/* OTHER DEFINITIONS */

#define MAX_MSG_LEN 512 // maximal message length for a yaml message

/* GLOBAL VARIABLES */

dht_t DHT_SENSOR;
adc_t DFR_LINE;

/* type 1 -> temperature
 * type 2 -> air humidity
 * type 3 -> ground humidity
 */
char * YAML_MSG_TEMPLATE =
"\
boxID: %s\n\
data:\n\
    - type: 1\n\
      value: %s\n\
    - type: 2\n\
      value: %s\n\
    - type: 3\n\
      value: %s\n\
";

/* SENSOR VALUES */

int16_t air_temp;
int16_t air_hum;
char air_temp_s[10];
char air_hum_s[10];

int ground_hum;
char ground_hum_s[10];

/* FUNCTION DEFINITIONS */

char led_blink_thread_stack[THREAD_STACKSIZE_MAIN];

void * led_blink_thread(void * arg) {
    
    (void) arg;

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

int init_dht11(void) {
    
    // initialize dht sensor

    DHT_SENSOR.type = (DHT11);

    dht_params_t dht_params;
    dht_params.pin = GPIO_PIN(DHT_PIN_PORT, DHT_PIN_NUM);
    dht_params.type = DHT11;
    dht_params.in_mode = DHT_PARAM_PULL;

    printf("Initializing DHT sensor...\t");
    if (dht_init(&DHT_SENSOR, &dht_params) == DHT_OK) {
        puts("ok!\n");
        return 0;
    } else {
        puts("failed!\n");
        return -1;
    }

}

int read_dht11(void) {
    
    // read air_temp and humidity

    if (dht_read(&DHT_SENSOR, &air_temp, &air_hum) != DHT_OK) {
        puts("Error reading values");
        return -1;
        
    }
        
    size_t n;
    
    n = fmt_s16_dfp(air_temp_s, air_temp, -1);
    air_temp_s[n] = '\0';

    n = fmt_s16_dfp(air_hum_s, air_hum, -1);
    air_hum_s[n] = '\0';

    printf("DHT values - air_temp: %s°C - air_hum: %s%%\n",
            air_temp_s, air_hum_s);

    return 0;

}

int init_dfr(void) {

    DFR_LINE = DFR_LINE_NO;

    printf("Initializing DFR sensor...\t");
    
    if(adc_init(DFR_LINE) == -1) {
        puts("failed!\n");
        return 1;
    } else {
        puts("ok!\n");
        return 0;
    }

}

int read_dfr(void) {

    /* the sensor value description
     * 0  ~300     dry soil
     * 300~700     humid soil
     * 700~950     in water
     */

    ground_hum = adc_sample(DFR_LINE, ADC_RES_10BIT);
    
    float ground_hum_perc = ground_hum / 1023.0f * 100.0f;

    int n = fmt_float(ground_hum_s, ground_hum_perc, 1);
    ground_hum_s[n] = '\0';

    printf("DFR value - ground_hum: %s%%\n", ground_hum_s);

    return 0;
}

int mqtt_conn(void) {

    char * mqtt_connect_opt[] = {"con", RPI_ADDR, MQTT_PORT };

    printf("Connecting to MQTT broker.. \n");

    return cmd_con(3, mqtt_connect_opt);
}

int main(void) {

    (void) puts("Welcome to RIOT!");

    // start thread for led blinking
    thread_create(led_blink_thread_stack, sizeof(led_blink_thread_stack),
                  THREAD_PRIORITY_MAIN - 1, THREAD_CREATE_STACKTEST,
                  led_blink_thread, NULL, "led_blink_thread");

    /* init sensors */
    
    init_dht11();
    init_dfr();

    /* init prng */

    random_init((uint32_t) xtimer_now().ticks32);

    /* init RPL */

    init_rpl_node(RPL_NODE_MODE, RPL_IFACE_NO);

    /* init mqtt client */

    mqtt_client_init();

    while(mqtt_conn()) {
        printf("Trying again..\n");
    }

    /* main loop */

    while(1) {

        printf("\n");
        
        /* read sensors */
        
        read_dht11();
        read_dfr();

        /* build yaml message */

        char yaml_msg[MAX_MSG_LEN];

        // put the values in the template
        sprintf(yaml_msg, YAML_MSG_TEMPLATE, NODE_NAME, air_temp_s, air_hum_s, ground_hum_s);

        printf("\n%s\n", yaml_msg);

        /* publish the constructed message via mqtt */

        char * mqtt_publish_opt[] = {"pub", MQTT_TOPIC_NAME, yaml_msg, MQTT_QOS_LEVEL };

        cmd_pub(4, mqtt_publish_opt);

        /* go to sleep for the specified time
         * (implemented here as normal sleep) */

        xtimer_usleep(WAKEUP_INTERVAL_IN_S * 1000000);

    }

    /* code after this never executes */

    /* INTERACTIVE PROMPT */

    char line_buf[SHELL_DEFAULT_BUFSIZE];
    shell_run(NULL, line_buf, SHELL_DEFAULT_BUFSIZE);

    return 0;
}
