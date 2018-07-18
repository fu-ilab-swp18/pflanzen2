import yaml


with open("../config.yml", 'r') as ymlfile:
    config = yaml.load(ymlfile)

def getBoxName(box_id):
    for mapping in config['mapping']:
        if mapping['boxID'] == box_id:
            return mapping['name']

def getSensors(box_id, type):
    for mapping in config['mapping']:
        if mapping['boxID'] == box_id:
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