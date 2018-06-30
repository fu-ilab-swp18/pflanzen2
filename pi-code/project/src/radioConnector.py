import socket
import netifaces as ni
import Queue as queue
import yaml
 

UDP_PORT = 1234

def get_ip_address(ifname):
    addrs = ni.ifaddresses(ifname)
    return addrs[ni.AF_INET6][0]['addr']

def radioWorker(mqttQ, notificationQ):
    # mqttQ.put((yaml.load("""
    #     msgID:  120936
    #     data:
    #         -   type:   1
    #             value:  54.3
    #         -   type:   2
    #             value:  36
    # """), ["fe80::ff:fe00:30fa%lowpan0"]))

    notificationQ.put((yaml.load("""
        msgID:  120936
        data:
            -   type:   1
                value:  80
            -   type:   2
                value:  36
    """), ["fe80::7b68:2644:3053:30fa%lowpan0"]))
    

    sock = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)
    sock.bind(('::', UDP_PORT))
    while True:
        print "Waiting for messages!"
        data, addr = sock.recvfrom(1024)
        try:
            yamlData = yaml.load(data)

            mqttQ.put((yamlData, addr))
            notificationQ.put((yamlData, addr))
            
            # TODO: ack response

        except:
            print "Could not parse YAML"