import yaml


with open("../config.yml", 'r') as ymlfile:
    mappings = yaml.load(ymlfile)['mapping']


def getBoxID(ip_address):
    for mapping in mappings:
        print mapping['address']
        print ip_address
        if mapping['address'] == ip_address:
            return mapping['boxID']