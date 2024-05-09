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
part 'settings_page.dart';
part 'edit_page.dart';

int rad2Deg(double? rad) => ((rad??0) * vm.radians2Degrees).round();
double deg2Rad(int? deg) => (deg??0) * vm.degrees2Radians;
double meters2NM(double m) => double.parse((m*0.00054).toStringAsPrecision(2));
String val2PS(num val) => val < 0 ? 'P' : 'S';

//TODO smoothing doesn't seem to be working.
double averageAngle(double current, double next, { int smooth = 0, bool relative=false }) {
  vm.Vector2 v1 = vm.Vector2(m.sin(current) * (50+smooth), m.cos(current) * (50+smooth));
  vm.Vector2 v2 = vm.Vector2(m.sin(next) * 50, m.cos(next) * 50);

  vm.Vector2 avg = (v1 + v2) / 2;

  double avga = m.atan2(avg.x, avg.y);

  return ((avga >= 0) || relative) ? avga : ((2 * m.pi) + avga);
}

abstract class BoxSettings {}

abstract class BoxWidget extends StatefulWidget {
  const BoxWidget({super.key});

  String get id;

  bool get hasSettings => false;

  Widget? getSettingsWidget(Map<String, dynamic> json) {
    return null;
  }

  Map<String, dynamic> getSettingsJson() {
    return {};
  }
}

class WidgetDetails {
  final String id;
  final String description;
  final BoxWidget Function(BoatInstrumentController) build;

  WidgetDetails(this.id, this.description, this.build);
}

//TODO need to have proper IDs for the other DoubleValueDisplay entries.
//TODO widget for web page.
List<WidgetDetails> widgetDetails = [
  WidgetDetails('depth', 'Depth', (controller) {return DoubleValueDisplay(controller, 'DPT', 'environment.depth.belowSurface', 'm', 1, key: UniqueKey());}),
  WidgetDetails('true-wind-speed', 'True Wind Speed', (controller) {return DoubleValueDisplay(controller, 'TWS', 'environment.wind.speedTrue', 'kts', 1, key: UniqueKey());}),
  WidgetDetails('apparent-wind-speed', 'Apparent Wind Speed', (controller) {return DoubleValueDisplay(controller, 'AWS', 'environment.wind.speedApparent', 'kts', 1, key: UniqueKey());}),
  WidgetDetails('autopilot-display', 'Autopilot Display', (controller) {return AutoPilotDisplay(controller, key: UniqueKey());}),
  WidgetDetails(AutoPilotControl.ID, 'Autopilot Control', (controller) {return AutoPilotControl(controller, key: UniqueKey());}),
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

  static _Page _newPage() => _Page('Page Name', [_Column([_Row([_Box(widgetDetails[0].id, 1.0)], 1)], 1)]);
}

@JsonSerializable()
class _Settings {
  int version;
  int valueSmoothing;
  String signalkServer;
  late List<_Page> pages;
  late Map<String, dynamic> widgetSettings;

  static File? _store;

  _Settings({
    this.version = 0,
    this.valueSmoothing = 0,
    this.signalkServer = 'openplotter.local:3000',
    this.pages = const [],
    widgetSettings
  }) : widgetSettings = widgetSettings??{} {
    if(pages.isEmpty) {
      pages = [_Page._newPage()];
    }
  }

  factory _Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  static load() async {
    Directory directory = await path_provider.getApplicationDocumentsDirectory();
    _store = File('${directory.path}/settings.json');

    String? s = _store?.readAsStringSync();
    dynamic data = json.decode(s ?? "");

    return _Settings.fromJson(data);
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
