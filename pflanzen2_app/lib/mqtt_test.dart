/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 31/05/2017
 * Copyright :  S.Hamblett
 */

import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:observable/observable.dart';

/// An annotated simple subscribe/publish usage example for mqtt_client. Please read in with reference
/// to the MQTT specification. The example is runnable, also refer to test/mqtt_client_broker_test...dart
/// files for separate subscribe/publish tests.
Future<int> runMqtt() async {
  /// First create a client, the client is constructed with a broker name, client identifier
  /// and port if needed. The client identifier (short ClientId) is an identifier of each MQTT
  /// client connecting to a MQTT broker. As the word identifier already suggests, it should be unique per broker.
  /// The broker uses it for identifying the client and the current state of the client. If you don’t need a state
  /// to be hold by the broker, in MQTT 3.1.1 you can set an empty ClientId, which results in a connection without any state.
  /// A condition is that clean session connect flag is true, otherwise the connection will be rejected.
  /// The client identifier can be a maximum length of 23 characters. If a port is not specified the standard port
  /// of 1883 is used.
  /// If you want to use websockets rather than TCPO see below.
  final MqttClient client = new MqttClient("test.mosquitto.org", "");

  /// A websocket URL must start with ws:// or Dart will throw an exception, consult your websocket MQTT broker
  /// for details.
  /// To use websockets add the following lines -:
  /// client.useWebSocket = true;
  /// client.port = 80;  ( or whatever your WS port is)

  /// Set logging on if needed, defaults to off
  client.logging(true);

  /// If you intend to use a keep alive value in your connect message that is not the default(60s)
  /// you must set it here
  client.keepAlivePeriod = 30;

  /// Add the unsolicited disconnection callback
  client.onDisconnected = onDisconnected;

  /// Create a connection message to use or use the default one. The default one sets the
  /// client identifier, any supplied username/password, the default keepalive interval(60s)
  /// and clean session, an example of a specific one below.
  final MqttConnectMessage connMess = new MqttConnectMessage()
      .withClientIdentifier("Mqtt_clientUniqueId")
      .keepAliveFor(30) // Must agree with the keep alive set above
      .withWillTopic("willtopic")
      .withWillQos(MqttQos.atLeastOnce);
  client.connectionMessage = connMess;

  /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
  /// in some circumstances the broker will just disconnect us, see the spec about this, we however eill
  /// never send malformed messages.
  try {
    await client.connect();
  } catch (Exception) {
    /// Error handling.....
    client.disconnect();
  }

  /// Check we are connected
  if (client.connectionState == ConnectionState.connected) {
    print("EXAMPLE::Mosquitto client connected");
  } else {
    print(
        "EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, state is ${client
            .connectionState}");
    client.disconnect();
  }

  /// Ok, lets try a subscription
  final String topic = "test/hw";
  final ChangeNotifier<MqttReceivedMessage> cn =
  client.listenTo(topic, MqttQos.exactlyOnce);

  /// We get a change notifier object(see the Observable class) which we then listen to to get
  /// notifications of published updates to each subscribed topic, one for each topic, these are
  /// basically standard Dart streams and can be managed as you wish.
  cn.changes.listen((List<MqttReceivedMessage> c) {
    final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
    final String pt =
    MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    /// The above may seem a little convoluted for users only interested in the
    /// payload, some users however may be interested in the received publish message,
    /// lets not constrain ourselves yet until the package has been in the wild
    /// for a while.
    /// The payload is a byte buffer, this will be specific to the topic
    print("EXAMPLE::Change notification:: payload is <$pt> for topic <$topic>");
  });

  /// Sleep to read the log.....
  await MqttUtilities.asyncSleep(5);

  return 0;
}

/// The unsolicited disconnect callback
void onDisconnected() {
  print("Client unsolicited disconnection");
}