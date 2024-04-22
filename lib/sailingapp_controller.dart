import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sailingapp/settings.dart';
import 'package:sailingapp/signalk.dart';
import 'package:sailingapp/widgets/auto_pilot_control.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Update {
  final String path;
  final dynamic value;

  Update(this.path, this.value);
}

typedef OnUpdate = Function(List<Update> updates);

class _WidgetData {
  Widget widget;
  bool configured = false;
  OnUpdate? onUpdate;
  Set<String> paths = {};
  List<Update> updates = [];

  _WidgetData(this.widget);
}

class SailingAppController {
  final Settings settings;
  final List<_WidgetData> _widgetData = [];
  WebSocketChannel? _channel;
  final TextStyle headTS;
  final TextStyle infoTS;


  SailingAppController(this.settings, this.headTS, this.infoTS);

  void addWidget(Widget widget) {
    _widgetData.add(_WidgetData(widget));
  }

  dynamic configure(Widget widget, OnUpdate? onUpdate, Set<String> paths) {
    bool configured = true;

    for(_WidgetData wd in _widgetData) {
      if(wd.widget == widget) {
        wd.onUpdate = onUpdate;
        wd.paths = paths;
        wd.configured = true;
      } else if(!wd.configured) {
        configured = false;
      }
    }

    if(configured) {
      subscribe();
    }

    dynamic settings = {}; //TODO
    return settings;
  }

  connect() async {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://${settings.signalkServer}/signalk/v1/stream?subscribe=none'),
      );

      await _channel?.ready;

      _channel?.stream.listen(
        _processData,
        onError: (e) {
          print('stream error $e');
        },
        onDone: () {
          print('ws closed');
        }
      );
    } catch (e) {
      print('Error connecting ws: $e');
      _reconnect();
    }
  }

  void clear() {
    _widgetData.clear();
  }

  void subscribe() {
    List<Map<String, String>> subscribe = [];
    Set<String> paths = {};

    // Find all the unique paths.
    for(_WidgetData wd in _widgetData) {
      for(String path in wd.paths) {
        paths.add(path);
      }
    }

    for(String path in paths) {
      subscribe.add({"path": path});
    }

    _channel?.sink.add(
      jsonEncode(
        {
          "context": "*",
          "unsubscribe": [
            {"path": "*"}
          ]
        }
      ),
    );

    _channel?.sink.add(
      jsonEncode(
        {
          "context": "vessels.self",
          "subscribe": subscribe
        },
      ),
    );
  }

  void _reconnect () {
    Timer(const Duration(seconds: 10), connect);
  }

  _processData(data) {
    dynamic d = json.decode(data);

    // We can get a status message on initial connection, which we ignore.
    if(d['updates'] != null) {
      for(_WidgetData wd in _widgetData) {
        wd.updates.clear();
      }

      for (dynamic u in d['updates']) {
        for (dynamic v in u['values']) {
          try {
            String path = v['path'];

            for(_WidgetData wd in _widgetData) {
              for(String p in wd.paths) {
                if(path == p) {
                  wd.updates.add(Update(path, v['value']));
                }
              }
            }
          } catch (e) {
            print(v);
            print(e);
          }
        }

        for(_WidgetData wd in _widgetData) {
          if(wd.onUpdate != null && wd.updates.isNotEmpty) {
            wd.onUpdate!(wd.updates);
          }
        }
      }
    }
  }
}
