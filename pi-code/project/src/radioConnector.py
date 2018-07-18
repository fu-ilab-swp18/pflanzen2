import socket
import netifaces as ni
import Queue as queue
import yaml
import time
import sys
import paho.mqtt.client as mqtt

 

# UDP_PORT = 1234
BROKER = 'localhost'
PORT = 1886
TOPIC = 'data'

def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))
    client.subscribe(TOPIC)

def on_message(client, userdata, msg):
    print(msg.topic+" "+str(msg.payload))
    try:
        yamlData = yaml.load(msg.payload)

        userdata[0].put((yamlData))
        userdata[1].put((yamlData))

    except Exception as e:
        print e
        sys.stdout.flush()


def radioWorker(mqttQ, notificationQ):
    client = mqtt.Client(userdata=(mqttQ, notificationQ))
    client.on_connect = on_connect
    client.on_message = on_message

    client.connect(BROKER, PORT, 60)
    client.loop_start()