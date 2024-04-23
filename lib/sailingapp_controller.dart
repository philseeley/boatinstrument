import 'dart:async';
import 'dart:convert';

import 'package:circular_buffer/circular_buffer.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sailingapp/settings.dart';
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

class CircularLogger extends LogOutput {
  final CircularBuffer<String> _buffer;

  CircularLogger(this._buffer);

  @override
  void output(OutputEvent event) {
    _buffer.addAll(event.lines);
  }
}

class SailingAppController {
  final CircularBuffer<String> _buffer = CircularBuffer(100);
  late final Logger l;
  final Settings settings;
  final List<_WidgetData> _widgetData = [];
  WebSocketChannel? _channel;
  Timer? _networkTimer;
  final TextStyle headTS;
  final TextStyle infoTS;
  final TextStyle lineTS;

  List<String> get logBuffer => _buffer.toList();
  void clearLog() => _buffer.clear();

  SailingAppController(this.settings, this.headTS, this.infoTS, this.lineTS) {
    l = Logger(
        filter: ProductionFilter(),
        output: CircularLogger(_buffer),
        printer: PrettyPrinter(colors: false, errorMethodCount: 1, methodCount: 0, noBoxingByDefault: true, levelEmojis: {
          Level.trace: "[T]",
          Level.debug: "[D]",
          Level.info: "[I]",
          Level.warning: "[W]",
          Level.error: "[E]",
          Level.fatal: "[F]"
        })
    );
  }

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
      _subscribe();
    }

    dynamic settings = {}; //TODO
    return settings;
  }

  connect() async {
    try {
      l.i("Connecting to: ${settings.signalkServer}");

      _channel?.sink.close();

      _channel = WebSocketChannel.connect(
        Uri.parse('ws://${settings.signalkServer}/signalk/v1/stream?subscribe=none'),
      );

      await _channel?.ready;

      _channel?.stream.listen(
          _processData,
          onError: (e) {
            l.e('WebSocket stream error', error: e);
            _reconnect();
            return;
          },
          onDone: () {
            l.w('WebSocket closed');
            _reconnect();
            return;
          }
      );

      _subscribe();
      _networkTimeout();

      l.i("Connected to: ${settings.signalkServer}");
    } catch (e) {
      l.e('Error connecting WebSocket', error: e);
      _reconnect();
    }
  }

  void clear() {
    _widgetData.clear();
  }

  void _subscribe() {
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

    // Unsubscribe from all updates first.
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
    l.i("Reconnecting WebSocket in 5 seconds");
    Timer(const Duration(seconds: 5), connect);
  }

  void _networkTimeout () {
    _networkTimer?.cancel();
    _networkTimer = Timer(const Duration(seconds: 20), connect);
  }

  _processData(data) {
    _networkTimeout();

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
            l.e("Error converting $v", error: e);
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
