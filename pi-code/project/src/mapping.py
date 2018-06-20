import yaml


with open("../config.yml", 'r') as ymlfile:
    mappings = yaml.load(ymlfile)['mapping']


def getBoxID(ip_address):
    for mapping in mappings:
        if mapping['address'] == ip_address:
            return mapping['boxID']

def getBoxName(ip_address):
    for mapping in mappings:
        if mapping['address'] == ip_address:
            return mapping['name']

def getSensors(ip_address, type):
    for mapping in mappings:
        if mapping['address'] == ip_address:
            for sensor in mapping['sensors']:
                if type == sensor['type']:
                    return sensor['id']