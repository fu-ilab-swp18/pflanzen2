import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'mqtt.dart';


class MainAppContainer extends StatefulWidget {
    final Widget child;

    MainAppContainer({
        @required this.child,
    });

    static _MainAppContainerState of(BuildContext context) {
        return (context.inheritFromWidgetOfExactType(_InheritedStateContainer)
                as _InheritedStateContainer)
            .data;
    }

    @override
    State<StatefulWidget> createState() {
        return new _MainAppContainerState();
    }
}

class _MainAppContainerState extends State<MainAppContainer> {
    MqttComponent m;
    List<String> boxList = [];
    Map<String, bool> subs = {};
    FirebaseMessaging firebaseMessaging;
    
    @override
    void initState() {
        m = new MqttComponent();
        m.setUp();
        m.onConnectionChange.listen((event) {
            m.getBoxList();
        });

        m.onBoxListChange.listen((event) {
            setState(() {
                boxList = event.boxList;
            });

            SharedPreferences.getInstance().then((prefs) {
                boxList.forEach((box) {
                    bool boxSub = prefs.getBool(box);
                    if(boxSub == null) {
                        prefs.setBool(box, false);
                        subs[box] = false;
                    } else {
                        subs[box] = boxSub;
                        if(boxSub == true) {
                            firebaseMessaging.subscribeToTopic(box);
                        }
                    }
                });
            });
        });

        firebaseMessaging = new FirebaseMessaging();
        firebaseMessaging.requestNotificationPermissions();

        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return new _InheritedStateContainer(
            data: this,
            child: widget.child,
        );
    }
}

class _InheritedStateContainer extends InheritedWidget {
    final _MainAppContainerState data;

    _InheritedStateContainer({
        Key key,
        @required this.data,
        @required Widget child,
    }) : super(key: key, child: child);

    @override
    bool updateShouldNotify(_InheritedStateContainer old) => true;
}