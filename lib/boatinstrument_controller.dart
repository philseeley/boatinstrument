import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:circular_buffer/circular_buffer.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:logger/logger.dart';
import 'package:resizable_widget/resizable_widget.dart';
import 'package:sailingapp/widgets/auto_pilot_control.dart';
import 'package:sailingapp/widgets/auto_pilot_display.dart';
import 'package:sailingapp/widgets/single_value_display.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'boatinstrument_controller.g.dart';
part 'settings_page.dart';
part 'edit_page.dart';

class WidgetDetails {
  final String id;
  final String description;
  final Widget Function(BoatInstrumentController) build;

  WidgetDetails(this.id, this.description, this.build);
}

List<WidgetDetails> widgetDetails = [
  WidgetDetails('depth', 'Depth', (controller) {return DoubleValueDisplay(controller, 'Depth', 'environment.depth.belowSurface', 'm', 1, key: UniqueKey());}),
  WidgetDetails('true-wind-speed', 'True Wind Speed', (controller) {return DoubleValueDisplay(controller, 'True Wind Speed', 'environment.wind.speedTrue', 'kts', 1, key: UniqueKey());}),
  WidgetDetails('autopilot-display', 'Autopilot Display', (controller) {return AutoPilotDisplay(controller, key: UniqueKey());}),
  WidgetDetails('autopilot-control', 'Autopilot Control', (controller) {return AutoPilotControl(controller, key: UniqueKey());}),
];

WidgetDetails getWidgetDetails(String id) {
  for(WidgetDetails wd in widgetDetails) {
    if(wd.id == id) {
      return wd;
    }
  }

  throw Exception('Unknown widget with ID $id');
}
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

class _Resizable {
  double percentage;

  _Resizable(this.percentage);
}

@JsonSerializable()
class _Box extends _Resizable{
  String id;

  _Box(this.id, super.percentage);

  factory _Box.fromJson(Map<String, dynamic> json) =>
      _$BoxFromJson(json);

  Map<String, dynamic> toJson() => _$BoxToJson(this);
}

@JsonSerializable()
class _Row extends _Resizable{
  List<_Box> boxes;

  _Row(this.boxes, super.percentage);

  factory _Row.fromJson(Map<String, dynamic> json) =>
      _$RowFromJson(json);

  Map<String, dynamic> toJson() => _$RowToJson(this);
}

@JsonSerializable()
class _Column extends _Resizable{
  List<_Row> rows;

  _Column(this.rows, super.percentage);

  factory _Column.fromJson(Map<String, dynamic> json) =>
      _$ColumnFromJson(json);

  Map<String, dynamic> toJson() => _$ColumnToJson(this);
}

@JsonSerializable()
class _Page {
  String name;
  List<_Column> columns;

  _Page(this.name, this.columns);

  factory _Page.fromJson(Map<String, dynamic> json) =>
      _$PageFromJson(json);

  Map<String, dynamic> toJson() => _$PageToJson(this);
}

@JsonSerializable()
class _Settings {
  int valueSmoothing;
  String signalkServer;
  late List<_Page> pages;
  late Map<String, dynamic> widgetSettings;

  static File? _store;

  _Settings({
    this.valueSmoothing = 0,
    this.signalkServer = 'openplotter.local:3000',
    this.pages = const [],
    widgetSettings
  }) : widgetSettings = widgetSettings??{} {
    if(pages.isEmpty) {
      pages = [_Page('Page Name', [_Column([_Row([_Box(widgetDetails[0].id, 1.0)], 1)], 1)])];

    }
  }

  factory _Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  static load() async {
    Directory directory = await path_provider.getApplicationDocumentsDirectory();
    _store = File('${directory.path}/settings.json');

    try {
      String? s = _store?.readAsStringSync();
      dynamic data = json.decode(s ?? "");

      return _Settings.fromJson(data);
    } on Exception catch (e) {
      print(e); //TODO Need to log, but log is in the controller.
      return _Settings();
    } on Error catch(e) {
      print(e);
      return _Settings();
    }
  }

  _save (){
    _store?.writeAsStringSync(json.encode(toJson()));
  }
}

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
  final TextStyle lineTS;

  List<String> get logBuffer => _buffer.toList();
  void clearLog() => _buffer.clear();

  bool get ready => _settings != null;

  String get signalkServer => _settings!.signalkServer;
  int get valueSmoothing => _settings!.valueSmoothing;

  BoatInstrumentController(this.headTS, this.infoTS, this.lineTS) {
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
    _settings = await _Settings.load();
  }

  Widget addWidget(Widget widget) {
    _widgetData.add(_WidgetData(widget));
    return widget;
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

    return _settings?.widgetSettings[widgetID]??{};
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
            child: addWidget(getWidgetDetails(box.id).build(this))));
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

  connect() async {
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

      l.i("Connected to: $signalkServer");
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
