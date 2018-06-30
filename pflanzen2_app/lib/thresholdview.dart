import 'package:flutter/material.dart';
import 'mqtt.dart';
import 'mainappview.dart';


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
    List sensors;
    MqttComponent m;
    
    @override
    void didChangeDependencies() {
        m = MainAppContainer.of(context).m;
        super.didChangeDependencies();
    }

    @override
    void initState() {
        sensors = [
            {
                'title': 'Temperature',
                'type': 1,
                'min': 0.0,
                'max': 0.0
            },
            {
                'title': 'Air humidity',
                'type': 2,
                'min': 0.0,
                'max': 0.0
            },
            {
                'title': 'Soil humidity',
                'type': 3,
                'min': 0.0,
                'max': 0.0
            },
        ];

        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return new Scaffold(
            appBar: new AppBar(
                title: new Text('Thresholds for Box $boxID'),
                automaticallyImplyLeading: false,
            ),
            body: new ListView.builder(
                itemCount: sensors.length,
                itemBuilder: (BuildContext context, int index) {
                    return new Card(
                        child: new Column(
                            
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                                new ListTile(
                                    leading: const Icon(Icons.memory),
                                    title: new Text(sensors[index]['title']),
                                ),
                                new Text('Minimum value'),
                                new Center(
                                    child: new Container(
                                        margin: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                                        child: new Slider(
                                            value: sensors[index]['min'],
                                            min: 0.0,
                                            max: 100.0,
                                            onChanged: (double val) {
                                                setState(() {
                                                    sensors[index]['min'] = val;
                                                });
                                            },
                                        )
                                    ),
                                ),
                                new Text('Maximum value'),
                                new Center(
                                    child: new Container(
                                        margin: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                                        child: new Slider(
                                            value: sensors[index]['max'],
                                            min: 0.0,
                                            max: 100.0,
                                            onChanged: (double val) {
                                                setState(() {
                                                    sensors[index]['max'] = val;
                                                });
                                            },
                                        )
                                    ),
                                ),
                                new Container(
                                    padding: new EdgeInsets.all(20.0),
                                    alignment: AlignmentDirectional.topEnd,
                                    child: new Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: <Widget>[
                                            new Container(
                                                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
                                                child: new Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                        new Text('Minimum: ${sensors[index]['min'].toStringAsPrecision(4)}'),
                                                        new Text('Maximum: ${sensors[index]['max'].toStringAsPrecision(4)}')
                                                    ],
                                                ),
                                            ),
                                            new RaisedButton(
                                                child: new Text('Submit'),
                                                onPressed: () {
                                                    m.sendNewThreshold(
                                                        boxID,
                                                        sensors[index]['type'],
                                                        sensors[index]['min'],
                                                        sensors[index]['max']);
                                                },
                                            )
                                        ],
                                    ),
                                )
                            ],
                        ),
                    );
                },
            ),
        );
    }
}
