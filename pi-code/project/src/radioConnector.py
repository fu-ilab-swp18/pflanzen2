import socket
import netifaces as ni
import Queue as queue


UDP_PORT = 9000

def get_ip_address(ifname):
    addrs = ni.ifaddresses(ifname)
    return addrs[ni.AF_INET6][0]['addr']

def radioWorker(mqttQ, notificationQ):
    sock = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)
    sock.bind(('::', UDP_PORT))
    while True:
        data, addr = sock.recvfrom(1024) # buffer size is 1024 bytes
        mqttQ.put((data, addr))
        notificationQ.put((data, addr))