import yaml


with open("../config.yml", 'r') as ymlfile:
    config = yaml.load(ymlfile)


def getBoxID(ip_address):
    for mapping in config['mapping']:
        if mapping['address'] == ip_address:
            return mapping['boxID']

def getBoxName(ip_address):
    for mapping in config['mapping']:
        if mapping['address'] == ip_address:
            return mapping['name']

def getSensors(ip_address, type):
    for mapping in config['mapping']:
        if mapping['address'] == ip_address:
            for sensor in mapping['sensors']:
                if type == sensor['type']:
                    return sensor['id']

def getBoxes():
    return config['mapping']

def getBoxNames():
    boxNames = []
    for box in config['mapping']:
        boxNames.append(box['name'])
    
    return boxNames