import paho.mqtt.client as mqtt
import Queue as queue
import time
import json
import yaml
import json

import config
import thresholds


CONFIG_TOPIC = 'SWP_IK_PFL2/config'
CONFIG_WILDCARD_TOPIC = CONFIG_TOPIC + '/#'
CONFIG_BOX_NAMES_TOPIC = CONFIG_TOPIC + '/boxnames'
CONFIG_THRESHOLD_TOPIC = CONFIG_TOPIC + '/threshold'
DATA_TOPIC = 'SWP_IK_PFL2/data'
BROKER = 'test.mosquitto.org'
PORT = 1883


def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))

    # client.subscribe(CONFIG_TOPIC)
    client.subscribe(CONFIG_WILDCARD_TOPIC)


def on_message(client, userdata, msg):
    print(msg.topic+" "+str(msg.payload))

    if msg.topic == CONFIG_BOX_NAMES_TOPIC:
        publishBoxList(client, msg.payload)

    if msg.topic == CONFIG_THRESHOLD_TOPIC:
        set_threshold(client, msg.payload)
        

def set_threshold(client, payload):
    message = yaml.load(payload)
    box_name = message['boxname']
    min_t = message['min']
    max_t = message['max']
    sensor_type = message['type']
    thresholds.set_threshold(box_name, sensor_type, min_t, max_t)

def publishBoxList(client, payload):
    try:
        responseString = []
        message = yaml.load(payload)
        boxes = config.getBoxNames()
        # for box in boxes:
        #     boxObject = {}
        #     boxObject['name'] = box['name']
        #     responseString.append(boxObject)
        responseString = boxes
        client.publish(CONFIG_TOPIC + "/" + message['responseTopic'], yaml.dump(responseString))
    except Exception as e: print(e)

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
        boxName = config.getBoxName(ipAddress)
        mqttMessage = []

        for sensor in requestYaml['data']:
            mqttSensor = {}
            sensorID = config.getSensors(ipAddress, sensor['type'])
            if sensorID is not None:
                mqttSensor['sensor'] = sensorID
                mqttSensor['value'] = sensor['value']
                mqttMessage.append(mqttSensor)

        mqttString = json.dumps(mqttMessage)
        print json.dumps(mqttMessage)
            
        client.publish(DATA_TOPIC + "/" + boxName, mqttString)