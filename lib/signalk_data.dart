import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sailingapp/settings.dart';
import 'package:sailingapp/signalk.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef OnData = Function(dynamic data);

class SignalKData {
  late String _signalKServer;
  late OnData _onData;
  WebSocketChannel? _channel;
  
  void connect(String signalKServer, OnData onData) async {
    _signalKServer = signalKServer;
    _onData = onData;
    _connect();
  }

  void _connect() async {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://$_signalKServer/signalk/v1/stream?subscribe=none'),
      );

      await _channel?.ready;

      _channel?.stream.listen(_processData, onError: (e) {print('stream error $e');}, onDone: () {print('ws closed');});

      _channel?.sink.add(
        jsonEncode(
          {
            "context": "vessels.self",
            "subscribe": [
              {
                "path": "steering.autopilot.state",
              },
              {
                "path": "navigation.courseOverGroundTrue",
              },
              {
                "path": "steering.autopilot.target.windAngleApparent",
              },
              {
                "path": "environment.wind.angleApparent",
              },
              {
                "path": "navigation.currentRoute.waypoints",
              },
              {
                "path": "navigation.courseGreatCircle.crossTrackError",
              },
              {
                "path": "steering.autopilot.target.headingMagnetic",
              },
              {
                "path": "navigation.magneticVariation",
              },
              {
                "path": "steering.rudderAngle",
              },
              {
                "path": "notifications.autopilot.*",
              },
            ]
          },
        ),
      );
    } catch (e) {
      print('Error connecting ws: $e');
      _reconnect();
    }
  }

  void _reconnect () {
    Timer(const Duration(seconds: 10), _connect);
  }

  _processData(data) {
    dynamic d = json.decode(data);

    // We can get a status message on initial connection, which we ignore.
    if(d['updates'] != null) {
      _onData(d['updates']);
    }
  }
}
