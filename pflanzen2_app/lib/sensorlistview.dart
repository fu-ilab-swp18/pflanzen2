import 'package:flutter/material.dart';
import 'dart:async';
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