#!/usr/bin/python
import Queue as queue
import thread
import time

import mqttClient as mqtt
import radioConnector as radio
import pushNotification as push


mqttQ = queue.Queue(100)
notificationQ = queue.Queue(100)

try:
    thread.start_new_thread(mqtt.mqttWorker, (mqttQ,))
    thread.start_new_thread(radio.radioWorker, (mqttQ, notificationQ))
    thread.start_new_thread(push.pushNotificationWorker, (notificationQ,))
except:
   print "Error: unable to start thread"

while 1:
   pass