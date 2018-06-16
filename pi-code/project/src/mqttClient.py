import paho.mqtt.client as mqtt
import Queue as queue
import time

import mapping


CONFIG_TOPIC = 'SWP_IK_PFL2/config'
DATA_TOPIC = 'SWP_IK_PFL2/data'

def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))

    client.subscribe(CONFIG_TOPIC)


def on_message(client, userdata, msg):
    print(msg.topic+" "+str(msg.payload))

def mqttWorker(mqttQ):
    client = mqtt.Client()
    client.on_connect = on_connect
    client.on_message = on_message

    client.connect("broker.hivemq.com", 1883, 60)

    client.loop_start()

    while 1:
        data = mqttQ.get()
        boxID = mapping.getBoxID(data[1][0])
        if boxID is None:
            print "boxID none"
        client.publish(DATA_TOPIC, data[0])