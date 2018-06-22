import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:observable/observable.dart' as observable;
import 'mqtt_test.dart';



void main() {
    runApp(new MyApp());
    final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.subscribeToTopic('test');
}

class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
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
        setUpMqtt();
    }

    Future<int> setUpMqtt () async {
        print('test');
        final mqtt.MqttClient client = new mqtt.MqttClient("ws://test.mosquitto.org", "jlf8973hfgo54hg49g3");
        client.useWebSocket = true;
        client.port = 8080;
        client.logging(true);

        try {
            final mqtt.MqttConnectMessage connMess = new mqtt.MqttConnectMessage()
                .withClientIdentifier("jlf8973hfgo54hg49g3")
                .keepAliveFor(30) // Must agree with the keep alive set above
                .withWillTopic("willtopic")
                .withWillQos(mqtt.MqttQos.atLeastOnce);
            client.connectionMessage = connMess;

            await client.connect();

            if (client.connectionState == mqtt.ConnectionState.connected) {
                print("EXAMPLE::Mosquitto client connected");
            } else {
                print(
                    "EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, state is ${client
                        .connectionState}");
                client.disconnect();
            }

            final String topic = "test/hw";
            final observable.ChangeNotifier<observable.ChangeRecord> cn = client.listenTo(topic, mqtt.MqttQos.atMostOnce);
            print('START LISTENING 2');

            cn.changes.listen((List<observable.ChangeRecord> c) {
                print('RECEIVED SOMETHING!');
                // final mqtt.MqttPublishMessage recMess = c[0].payload as mqtt.MqttPublishMessage;
                // final String pt =
                // mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
                // print("EXAMPLE::Change notification:: payload is <$pt> for topic <$topic>");
            });
        }catch(e) {
            print(e.toString());
        }
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