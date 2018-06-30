from pyfcm import FCMNotification
import Queue as queue
import config
import sensor_types
import thresholds


def pushNotificationWorker(notificationQ):
    while 1:
        request = notificationQ.get()
        ipAddress = request[1][0]
        boxname = config.getBoxName(ipAddress)
        request_data = request[0]['data']

        for sensor in request_data:
            current_value = sensor['value']
            thr = thresholds.get_thresholds(boxname, sensor['type'])
            if thr is not None:
                print "current value: " + str(current_value) + " thresholds: min " + str(thr['min']) + " max " + str(thr['max'])

                if current_value < thr['min'] or current_value > thr['max']:
                    print "Current value out of valid range!"
                    push_service = FCMNotification(api_key='AAAAUwNBu9o:APA91bHrtsr23vxHzcS7JN75HDiUblXhF1wCkwV6JRDwuCUk6JZBil4MAMU8cwdZoSJ4_WzXc_sLAz5_MowJL2JmRlG0CnlNFNY6O_m-wSthQhcJR3aFYcKpLx3WBwAqAe_Ak0acRI9NBJnVEI-M43PWOMxUrrIHtw')
                    
                    result = push_service.notify_topic_subscribers(sound="default", topic_name=boxname, message_body="Oh no! The " + sensor_types.TYPES[sensor['type']] + " on box " + boxname + " is " + str(current_value) + "!")

                    print result
