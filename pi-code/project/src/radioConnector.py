import socket
import netifaces as ni
import Queue as queue
import yaml


UDP_PORT = 1234

def get_ip_address(ifname):
    addrs = ni.ifaddresses(ifname)
    return addrs[ni.AF_INET6][0]['addr']

def radioWorker(mqttQ, notificationQ):
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