import 'dart:io';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:mqtt/mqtt_shared.dart';
import 'package:mqtt/mqtt_connection_io_socket.dart';
import 'package:yaml/yaml.dart';

const CONFIG_TOPIC = 'SWP_IK_PFL2/config';
const BROKER = 'test.mosquitto.org';
const PORT = 1883;


class OnSubscriptionSuccessfullEvent {

}

class OnBoxListEvent {
    var boxList;

    OnBoxListEvent(var boxList){
        this.boxList = boxList;
    }
}

class MqttComponent {
    MqttClient client;
    Uuid uuid;
    String clientID;

    var onConnectionChangeController = new StreamController<OnSubscriptionSuccessfullEvent>();
    Stream<OnSubscriptionSuccessfullEvent> get onConnectionChange => onConnectionChangeController.stream;
    var onBoxListUpdateChangeController = new StreamController<OnBoxListEvent>();
    Stream<OnBoxListEvent> get onBoxListChange => onBoxListUpdateChangeController.stream;

    void setUp() {
        uuid = new Uuid();
        clientID = uuid.v4();
        var mqttCnx = new MqttConnectionIOSocket.setOptions(host: BROKER, port: PORT);
        client = new MqttClient(mqttCnx, clientID: clientID, qos: QOS_0);

        client.connect(() {
            print("DISCONNECT!");
            setUp();
        })
        .then( (c) {
            MqttClient<MqttConnectionIOSocket> client = c as MqttClient<MqttConnectionIOSocket>;

            client.subscribe(CONFIG_TOPIC + '/' + clientID, QOS_0, (t, d) {
                onBoxListUpdateChangeController.add(new OnBoxListEvent(loadYaml(d)));
            })
            .then( (s) {
                onConnectionChangeController.add(new OnSubscriptionSuccessfullEvent());
            });

            // client.subscribe('', QOS_1, (t, d) {
                
            // })
            // .then( (s) => print("Subscription done - ID: ${s.messageID} - Qos: ${s.grantedQoS}"));
        })
        .catchError((e) {
            setUp();
        })
        .catchError((mqttErr) {
            setUp();
        });
    }

    void disconnect() {
        client.disconnect();
    }
    
    void sendNewThreshold(String boxname, int type, double min, double max) {
        client.publish(CONFIG_TOPIC + "/threshold", """
            responseTopic: $clientID,
            boxname: $boxname
            type: $type
            min: $min
            max: $max
        """, QOS_1)
        .then((m) {
            print("publish successfull!");
        });
    }

    void getBoxList() {
        client.publish(CONFIG_TOPIC + "/boxnames", """
            responseTopic: $clientID
        """, QOS_1)
        .then((m) {
            print("publish successfull!");
        });
    }
}
