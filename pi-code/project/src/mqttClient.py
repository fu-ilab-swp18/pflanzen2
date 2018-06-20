import paho.mqtt.client as mqtt
import Queue as queue
import time
import json

import mapping


CONFIG_TOPIC = 'SWP_IK_PFL2/config'
DATA_TOPIC = 'SWP_IK_PFL2/data'
BROKER = 'broker.hivemq.com'
PORT = 1883

def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))

    client.subscribe(CONFIG_TOPIC)


def on_message(client, userdata, msg):
    print(msg.topic+" "+str(msg.payload))

def mqttWorker(mqttQ):
    client = mqtt.Client()
    client.on_connect = on_connect
    client.on_message = on_message

    client.connect(BROKER, PORT, 60)

    client.loop_start()

    while 1:
        request = mqttQ.get()
        requestYaml = request[0]
        ipAddress = request[1][0]
        boxName = mapping.getBoxName(ipAddress)
        print ipAddress

        mqttMessage = []
        for sensor in requestYaml['data']:
            mqttSensor = {}
            sensorID = mapping.getSensors(ipAddress, sensor['type'])
            if sensorID is not None:
                mqttSensor['sensor'] = sensorID
                mqttSensor['value'] = sensor['value']
                mqttMessage.append(mqttSensor)

        mqttString = json.dumps(mqttMessage)
        print json.dumps(mqttMessage)
            
        client.publish(DATA_TOPIC + "/" + boxName, mqttString)