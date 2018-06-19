import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _firebaseMessaging.requestNotificationPermissions();
    return new MaterialApp(
      title: 'Welcome to Flutter',
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Welcome to Flutter'),
        ),
        body: new Center(
          child: new Text('Hello World'),
        ),
      ),
    );
  }
}