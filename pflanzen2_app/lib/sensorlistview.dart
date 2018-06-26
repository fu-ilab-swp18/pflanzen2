import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'mqtt.dart';
import 'thresholdview.dart';
import 'mainappview.dart';


class SensorList extends StatefulWidget {
    @override
    _SensorListState createState() {
        return new _SensorListState();
    }
}

class _SensorListState extends State{
    void updateSub(String box, bool state) {
        setState(() {
            MainAppContainer.of(context).subs[box] = state;
        });
        SharedPreferences.getInstance().then((prefs) {
            prefs.setBool(box, state);
        });
        print("New State $state");
        if(state == true) {
            print("SUBSCRIBE");
            MainAppContainer.of(context).firebaseMessaging.subscribeToTopic(box);
        } else {
            print("UNSUBSCRIBE");
            MainAppContainer.of(context).firebaseMessaging.unsubscribeFromTopic(box);
        }
    }

    @override
    void initState() {
        super.initState();
    }

    @override
    void dispose() {
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return new ListView.builder(
            padding: new EdgeInsets.all(8.0),
            itemCount: MainAppContainer.of(context).boxList.length,
            itemBuilder: (BuildContext context, int index) {
                var box = MainAppContainer.of(context).boxList[index];
                var sub = MainAppContainer.of(context).subs[box];

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
                                        value: sub,
                                        onChanged: (bool state) {
                                            updateSub(box, state);
                                        },
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