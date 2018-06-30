import yaml

yamlfile = open("../thresholds.yml", 'w+')
boxes = yaml.load(yamlfile)

def get_thresholds(box_name, sensor_type):
    global boxes

    if boxes is None:
        boxes = []

    for box in boxes:
        if box['name'] == box_name:
            for sensor in box['thresholds']:
                if sensor['type'] == sensor_type:
                    return {
                        'max': sensor['max'],
                        'min': sensor['min']
                    }

def set_threshold(box_name, sensor_type, min_t, max_t):
    global boxes

    if boxes is None:
        boxes = []

    box_exists = -1

    i = 0
    for box in boxes:
        if box['name'] == box_name:
            box_exists = i
            j = 0
            for sensor in box['thresholds']:
                if sensor['type'] == sensor_type:
                    print "SENSOR EXISTS"
                    boxes[i]['thresholds'][j]['min'] = min_t
                    boxes[i]['thresholds'][j]['max']= max_t
                    yamlfile.seek(0)
                    yamlfile.truncate()
                    yaml.dump(boxes, yamlfile)
                    print boxes
                    yamlfile.flush()
                    return
                j += 1
        i += 1

    if box_exists == -1:
        print "BOX DOES NOT EXIST"
        boxes.append({
            "name": box_name,
            "thresholds": [
                {
                    "type": sensor_type,
                    "min": min_t,
                    "max": max_t
                }
            ]
        })
    else:
        print "BOX EXISTS"
        boxes[box_exists]['thresholds'].append({
            "type": sensor_type,
            "min": min_t,
            "max": max_t
        })

    print boxes

    yamlfile.seek(0)
    yamlfile.truncate()
    yaml.dump(boxes, yamlfile)
    yamlfile.flush()