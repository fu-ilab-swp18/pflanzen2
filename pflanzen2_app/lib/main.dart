import 'package:flutter/material.dart';


import 'mainappview.dart';
import 'sensorlistview.dart';




void main() {
    runApp(new MyApp());
}

class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return new MaterialApp(
            home: new DefaultTabController(
                initialIndex: 0,
                length: 2,
                child: new MainAppContainer(
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
                    ),
                )
            )
        );
    }
}