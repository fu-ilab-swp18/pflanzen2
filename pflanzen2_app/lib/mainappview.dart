import 'package:flutter/material.dart';
import 'dart:async';

import 'mqtt.dart';
import 'sensorlistview.dart';


class AppState{

}

class MainAppContainer extends StatefulWidget {
    final AppState state;
    final Widget child;

    MainAppContainer({
        @required this.child,
        this.state,
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
        });

        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return new _InheritedStateContainer(
            data: this,
            child: widget.child,
        );
    }

    // @override
    // Widget build(BuildContext context) {
    //     return new Scaffold(
    //         appBar: new AppBar(
    //             title: new Text('Pflanzen 2'),
    //             bottom: new TabBar(
    //                 tabs: <Widget>[
    //                     new Tab(icon: new Icon(Icons.list, size: 30.0,)),
    //                     new Tab(icon: new Icon(Icons.star, size: 30.0,)),
    //                 ],
    //             )
    //         ),
    //         body: new TabBarView(
    //             children: <Widget>[
    //                 new SensorList(),
    //                 new Text("data"),
    //             ],
    //         )
    //     );
    // }
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