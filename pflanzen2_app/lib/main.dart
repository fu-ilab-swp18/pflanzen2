import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:observable/observable.dart' as observable;

import 'dart:io';
import 'package:args/args.dart';
import 'package:mqtt/mqtt_shared.dart';
import 'package:mqtt/mqtt_connection_io_socket.dart';



void main() {
    runApp(new MyApp());
    final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.subscribeToTopic('test');
}

class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return new MaterialApp(
            home: new DefaultTabController(
                initialIndex: 0,
                length: 2,
                child: new Scaffold(
                    appBar: new AppBar(
                        title: new Text('Pflanzen 2'),
                        bottom: new TabBar(
                            tabs: <Widget>[
                                new Icon(Icons.style, size: 30.0,),
                                new Icon(Icons.star, size: 30.0,),
                            ],
                        )
                    ),
                    body: new TabBarView(
                        children: <Widget>[
                            new SensorList(),
                            new Text('data')
                        ],
                    )
                )
            )
        );
    }
}

class SensorList extends StatefulWidget {
    @override
    _SensorListState createState() {
        return new _SensorListState();
    }
}

class _SensorListState extends State{
    var sensors = [];

    @override
    void initState() {
        // runMqtt();
        // setUpMqtt();
        setMQTT2();
    }

    void setMQTT2() {
        var mqttCnx = new MqttConnectionIOSocket.setOptions(host: "broker.hivemq.com", port: 1883);
        MqttClient c = new MqttClient(mqttCnx, clientID: "MyClientID", qos: QOS_1);
        // c.setWill("MyWillTopic", "MyWillPayload");

        c.connect(() {
                print("Disconnected!");
            })
            .then( (c) {
                MqttClient<MqttConnectionIOSocket> client = c as MqttClient<MqttConnectionIOSocket>;
                client.subscribe('test/hw', 1, (t, d) {
                    print("[$t] $d");
                })
                .then( (s) => print("Subscription done - ID: ${s.messageID} - Qos: ${s.grantedQoS}"));
            })
            .catchError((e) => print("Error: $e"), test: (e) => e is SocketException)  
            .catchError((mqttErr) => print("Error: $mqttErr")
        );
    }

    @override
    Widget build(BuildContext context) {
        return new Column(
            children: <Widget>[
                new Text('data')
            ],
        );
    }
}