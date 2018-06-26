import 'package:flutter/material.dart';


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