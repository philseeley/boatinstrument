import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as m;

import 'package:vector_math/vector_math.dart' as vm;
import 'package:circular_buffer/circular_buffer.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:logger/logger.dart';
import 'package:resizable_widget/resizable_widget.dart';
import 'package:boatinstrument/widgets/autopilot.dart';
import 'package:boatinstrument/widgets/double_value_display.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'log_display.dart';

part 'boatinstrument_controller.g.dart';
part 'data.dart';
part 'settings_page.dart';
part 'edit_page.dart';

class CircularLogger extends LogOutput {
  final CircularBuffer<String> _buffer;

  CircularLogger(this._buffer);

  @override
  void output(OutputEvent event) {
    // We can't use _buffer.addAll() as this is often called in async calls and
    // can result in a "Concurrent modification during iteration" exception.
    for(String s in event.lines) {
      _buffer.add(s);
    }
  }
}

class BoatInstrumentController {
  final CircularBuffer<String> _buffer = CircularBuffer(100);
  late final Logger l;
  _Settings? _settings;
  final List<_WidgetData> _widgetData = [];
  WebSocketChannel? _channel;
  Timer? _networkTimer;
  final TextStyle headTS;
  final TextStyle infoTS;

  List<String> get logBuffer => _buffer.toList();
  void clearLog() => _buffer.clear();

  bool get ready => _settings != null;

  String get signalkServer => _settings!.signalkServer;
  int get valueSmoothing => _settings!.valueSmoothing;

  BoatInstrumentController(this.headTS, this.infoTS) {
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

  loadSettings() async {
    try {
      _settings = await _Settings.load();
    } on Exception catch (e) {
      l.e('Exception loading Settings', error: e);
      _settings = _Settings();
    } on Error catch(e) {
      l.e('Error loading Settings', error: e);
      _settings = _Settings();
    }
  }

  Widget addWidget(Widget widget) {
    _widgetData.add(_WidgetData(widget));
    return widget;
  }

  Map<String, dynamic> getWidgetSettings(String widgetID) {
    return _settings?.widgetSettings[widgetID]??{};
  }

  Map<String, dynamic> configure(String widgetID, Widget widget, OnUpdate? onUpdate, Set<String> paths) {
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

    return getWidgetSettings(widgetID);
  }

  void saveWidgetSettings(String widgetID, Map<String, dynamic> widgetSettings) {
    _settings?.widgetSettings[widgetID] = widgetSettings;
    save();
  }

  void save() {
    _settings?._save();
  }

  Widget _buildRow(_Row row) {
    return LayoutBuilder(builder: (context, constraints) {
      List<Widget> widgets = [];
      for (var box in row.boxes) {
        widgets.add(SizedBox(
            width: constraints.maxWidth * box.percentage,
            height: double.infinity,
            child: DecoratedBox(decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2)), child: addWidget(getWidgetDetails(box.id).build(this)))));
      }
      return Row(children: widgets);
    });
  }

  Widget _buildColumn(_Column column) {
    return LayoutBuilder(builder: (context, constraints) {
      List<Widget> widgets = [];
      for (var row in column.rows) {
        widgets.add(SizedBox(
            width: double.infinity,
            height: constraints.maxHeight * row.percentage,
            child: _buildRow(row)));
      }
      return Column(children: widgets);
    });
  }

  Widget buildPage(int pageNum) {
    _Page page = _settings!.pages[pageNum];

    return LayoutBuilder(builder: (context, constraints) {
      List<Widget> widgets = [];
      for(var column in page.columns) {
        widgets.add(SizedBox(
          width: constraints.maxWidth * column.percentage,
          height: double.infinity,
          child: _buildColumn(column)));
      }

      return Row(children: widgets);
    });
  }

  int nextPageNum(int currentPage) {
    if(_settings!.pages.isEmpty) {
      _settings?.pages = [_Page._newPage()];
      return 0;
    }
    ++currentPage;
    return currentPage %= _settings!.pages.length;
  }

  int prevPageNum(int currentPage) {
    --currentPage;
    return currentPage %= _settings!.pages.length;
  }

  String pageName(int pageNum) {
    return '${pageNum+1}/${_settings!.pages.length} ${_settings!.pages[pageNum].name}';
  }

  connect() async {
    _networkTimeout();

    try {
      l.i("Connecting to: $signalkServer");

      _channel?.sink.close();

      _channel = WebSocketChannel.connect(
        Uri.parse('ws://$signalkServer/signalk/v1/stream?subscribe=none'),
      );

      await _channel?.ready;

      _channel?.stream.listen(
          _processData,
          onError: (e) {
            l.e('WebSocket stream error', error: e);
          },
          onDone: () {
            l.w('WebSocket closed');
          }
      );

      _subscribe();

      l.i("Connected to: $signalkServer");
    } catch (e) {
      l.e('Error connecting WebSocket', error: e);
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
