from pyfcm import FCMNotification
import Queue as queue


def pushNotificationWorker(notificationQ):
    push_service = FCMNotification(api_key='AAAAUwNBu9o:APA91bHrtsr23vxHzcS7JN75HDiUblXhF1wCkwV6JRDwuCUk6JZBil4MAMU8cwdZoSJ4_WzXc_sLAz5_MowJL2JmRlG0CnlNFNY6O_m-wSthQhcJR3aFYcKpLx3WBwAqAe_Ak0acRI9NBJnVEI-M43PWOMxUrrIHtw')
    result = push_service.notify_topic_subscribers(topic_name="test", message_body="Huhu I bims")
    print result