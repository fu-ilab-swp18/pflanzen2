import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'mqtt.dart';
import 'dart:async';


MqttComponent m;
FirebaseMessaging _firebaseMessaging;

void main() {
    _firebaseMessaging = new FirebaseMessaging();
    _firebaseMessaging.requestNotificationPermissions();
    
    _firebaseMessaging.subscribeToTopic("sepp");
    m = new MqttComponent();
    m.setUp();
    m.onConnectionChange.listen((event) {
        m.getBoxList();
    });

    runApp(new MyApp());
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
                                new Tab(icon: new Icon(Icons.list, size: 30.0,)),
                                new Tab(icon: new Icon(Icons.star, size: 30.0,)),
                            ],
                        )
                    ),
                    body: new TabBarView(
                        children: <Widget>[
                            new SensorList(),
                            new Text("data"),
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
    StreamSubscription<OnBoxListEvent> s;
    var boxList = [];

    @override
    void initState() {

        s = m.onBoxListChange.listen((event) {
            boxList = event.boxList;
            setState(() {
                
            });
        });
    }

    @override
    void dispose() {
        s.cancel();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return new ListView.builder(
            padding: new EdgeInsets.all(8.0),
            itemCount: boxList.length,
            itemBuilder: (BuildContext context, int index) {
                var box = boxList[index];

                return new Card(
                    child: new Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                        new ListTile(
                            leading: const Icon(Icons.developer_board),
                            title: new Text("Box ${box}"),
                        ),
                        new ButtonTheme.bar( // make buttons use the appropriate styles for cards
                            child: new ButtonBar(
                                children: <Widget>[
                                    new Switch(
                                        value: true,
                                        onChanged: (bool) {},
                                    ),
                                    new FlatButton(
                                        child: const Text('VALUES'),
                                        onPressed: () { /* ... */ },
                                    ),
                                    new FlatButton(
                                        child: const Text('THRESHOLDS'),
                                        onPressed: () {
                                            showBottomSheet(context: context, builder: (BuildContext builder) {
                                                return new ThresholdView(boxID: box);
                                            });
                                        },
                                    ),
                                ],
                            ),
                        ),
                        ],
                    ),
                    );
            },
        );
    }
}

class ThresholdView extends StatefulWidget {
    final _ThresholdViewState s = new _ThresholdViewState();

    ThresholdView({String boxID}) {
        s.boxID = boxID;
    }

    @override
    _ThresholdViewState createState() {
        return s;
    }
}

class _ThresholdViewState extends State{
    String boxID;

    @override
    Widget build(BuildContext context) {
        return new Scaffold(
            appBar: new AppBar(
                title: new Text('Thresholds for Box $boxID'),
                automaticallyImplyLeading: false,
            ),
            body: new ListView.builder(
                itemCount: 2,
                itemBuilder: (BuildContext context, int index) {
                    
                },
            ),
        );
    }
}