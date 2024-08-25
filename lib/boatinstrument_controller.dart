import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as m;

import 'package:boatinstrument/theme_provider.dart';
import 'package:boatinstrument/widgets/anchor_box.dart';
import 'package:boatinstrument/widgets/boat_box.dart';
import 'package:boatinstrument/widgets/custom_box.dart';
import 'package:boatinstrument/widgets/date_time_box.dart';
import 'package:boatinstrument/widgets/environment_box.dart';
import 'package:boatinstrument/widgets/navigation_box.dart';
import 'package:boatinstrument/widgets/webview_box.dart';
import 'package:boatinstrument/widgets/wind_box.dart';
import 'package:boatinstrument/widgets/wind_rose_box.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vector_math/vector_math.dart' as vm;
import 'package:circular_buffer/circular_buffer.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:logger/logger.dart';
import 'package:resizable_widget/resizable_widget.dart';
import 'package:boatinstrument/widgets/autopilot_box.dart';
import 'package:boatinstrument/widgets/double_value_box.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'log_display.dart';

part 'boatinstrument_controller.g.dart';
part 'data.dart';
part 'settings_page.dart';
part 'edit_page.dart';
part 'help_page.dart';

class CircularLogOutput extends LogOutput {
  static final CircularBuffer<String> _buffer = CircularBuffer(100);

  static List<String> get logBuffer => _buffer.toList();
  static void clearLog() => _buffer.clear();

  @override
  void output(OutputEvent event) {
    // We can't use _buffer.addAll() as this is often called in async calls and
    // can result in a "Concurrent modification during iteration" exception.
    for(String s in event.lines) {
      _buffer.add(s);
    }
  }
}

class CircularLogger extends Logger {

  CircularLogger() : super(
        filter: ProductionFilter(),
        output: CircularLogOutput(),
        printer: PrettyPrinter(colors: false,
            errorMethodCount: 1,
            methodCount: 0,
            noBoxingByDefault: true,
            levelEmojis: {
              Level.trace: "[T]",
              Level.debug: "[D]",
              Level.info: "[I]",
              Level.warning: "[W]",
              Level.error: "[E]",
              Level.fatal: "[F]"
            }));
}

class BoatInstrumentController {
  final CircularLogger l = CircularLogger();
  _Settings? _settings;
  Uri _httpApiUri = Uri();
  Uri _wsUri = Uri();
  final List<_WidgetData> _widgetData = [];
  WebSocketChannel? _channel;
  Timer? _networkTimer;

  bool get ready => _settings != null;

  Uri get httpApiUri => _httpApiUri;
  Uri get wsUri => _wsUri;
  int get valueSmoothing => _settings!.valueSmoothing;
  bool get darkMode => _settings!.darkMode;
  bool get brightnessControl => _settings!.brightnessControl;
  bool get keepAwake => _settings!.keepAwake;
  bool get pageTimerOnStart => _settings!.pageTimerOnStart;
  int get pageChangeSeconds => _settings!.pageChangeSeconds;
  DistanceUnits get distanceUnits => _settings!.distanceUnits;
  int get m2nmThreshold => _settings!.m2nmThreshold;
  SpeedUnits get speedUnits => _settings!.speedUnits;
  SpeedUnits get windSpeedUnits => _settings!.windSpeedUnits;
  DepthUnits get depthUnits => _settings!.depthUnits;
  TemperatureUnits get temperatureUnits => _settings!.temperatureUnits;
  PressureUnits get pressureUnits => _settings!.pressureUnits;
  int get numOfPages => _settings!.pages.length;

  Color val2PSColor(BuildContext context, num val, {Color? none}) {
    if(_settings!.portStarboardColors == PortStarboardColors.none) {
      return none??Theme.of(context).colorScheme.onSurface;
    }
    return val < 0 ? _settings!.portStarboardColors.portColor : (val > 0) ? _settings!.portStarboardColors.starboardColor : Theme.of(context).colorScheme.onSurface;
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

  void clear() {
    _widgetData.clear();
    _unsubscribe();
  }

  // Call this in the Widget's State initState() to get common Box settings.
  Map<String, dynamic> getBoxSettingsJson(String boxID) {
    return _settings?.boxSettings[boxID]??{};
  }

  // Call this in the Widget's State initState() to subscribe to Signalk data.
  void configure(OnUpdate onUpdate, List<String> paths, {bool dataTimeout = true}) {
    _WidgetData wd = _WidgetData(onUpdate, paths, dataTimeout);
    _widgetData.add(wd);

    for(String path in wd.paths) {
      // Need to escape all the '.'s and make a wildcard character for any '*'s, otherwise
      // 'a.*.c' would match anything starting 'a' and ending 'b', e.g 'abbbbc'.
      wd.regExpPaths.add(
          RegExp('^${path.replaceAll(r'.', r'\.').replaceAll(r'*', r'.*')}\$'));
    }

    _subscribe(wd.paths);
  }

  void save() {
    _settings?._save();
  }

  void showMessage(BuildContext context, String msg, {bool error = false, int millisecondsDuration = 4000}) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: (error) ? Colors.orange : null,
            duration: Duration(milliseconds: millisecondsDuration),
            content: Text(msg)));
  }

  Future<bool> askToConfirm(BuildContext context, String question, {bool alwaysAsk = false}) async {
    if(!alwaysAsk && _settings!.autoConfirmActions) {
      return true;
    }

    bool? answer = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(question),
            shape: Border.all(color: Colors.grey),
            actions: [
              TextButton(child: const Text('Cancel'), onPressed: () {Navigator.pop(context, false);}),
              TextButton(child: const Text('OK'), onPressed: () {Navigator.pop(context, true);}),
            ]
        );
      },
    );

    return answer??false;
  }

  Widget _buildRow(_Row row) {
    return LayoutBuilder(builder: (context, constraints) {
      List<Widget> widgets = [];
      for (var box in row.boxes) {
        widgets.add(SizedBox(
            width: constraints.maxWidth * box.percentage,
            height: double.infinity,
            child: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 2)),
                child: LayoutBuilder(builder: (context, constraints) {
                  return getBoxDetails(box.id).build(BoxWidgetConfig(this, box.settings, constraints, false));
                }))));
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

  Widget _buildPageRow(_PageRow pageRow) {
    return LayoutBuilder(builder: (context, constraints) {
      List<Widget> widgets = [];
      for (var column in pageRow.columns) {
        widgets.add(SizedBox(
            width: constraints.maxWidth * column.percentage,
            height: double.infinity,
            child: _buildColumn(column)));
      }
      return Row(children: widgets);
    });
  }

  Widget buildPage(int pageNum) {
    _Page page = _settings!.pages[pageNum];

    return LayoutBuilder(builder: (context, constraints) {
      List<Widget> widgets = [];
      for(var pageRow in page.pageRows) {
        widgets.add(SizedBox(
          width: double.infinity,
          height: constraints.maxHeight * pageRow.percentage,
          child: _buildPageRow(pageRow)));
      }

      return Column(children: widgets);
    });
  }

  int nextPageNum(int currentPage, {bool alwaysRotate = false}) {
    if(_settings!.pages.isEmpty) {
      _settings?.pages = [_Page._newPage()];
      return 0;
    }
    ++currentPage;
    if(alwaysRotate || _settings!.wrapPages) {
      return currentPage %= _settings!.pages.length;
    }
    return (currentPage >= _settings!.pages.length) ? _settings!.pages.length-1 : currentPage;
  }

  int prevPageNum(int currentPage) {
    --currentPage;
    if(_settings!.wrapPages) {
      return currentPage %= _settings!.pages.length;
    }
    return (currentPage < 0) ? 0 : currentPage;
  }

  String pageName(int pageNum) {
    return '${pageNum+1}/${_settings!.pages.length} ${_settings!.pages[pageNum].name}';
  }

  _discoverServices() async {
    try {
      String host = _settings!.signalkHost;
      int port = _settings!.signalkPort;

      if (_settings!.discoverServer) {
        BonsoirDiscovery discovery = BonsoirDiscovery(type: '_signalk-http._tcp');
        await discovery.ready;
        discovery.start();
        try {
          await for(BonsoirDiscoveryEvent e in discovery.eventStream!) {
            if (e.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
              e.service!.resolve(discovery.serviceResolver);
            } else if (e.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
              ResolvedBonsoirService r = e.service as ResolvedBonsoirService;
              host = r.host!;
              port = r.port;
              break;
            }          }
        } finally {
          discovery.stop();
        }
      }
      Uri uri = Uri(scheme: 'http', host: host, port: port, path: '/signalk');

      http.Response response = await http.get(uri);
      dynamic data = json.decode(response.body);
      dynamic endPoints = data['endpoints']['v1'];

      _httpApiUri = Uri.parse(endPoints['signalk-http']);
      _wsUri = Uri.parse(endPoints['signalk-ws']);
    } catch(e) {
      l.e('Error discovering services', error: e);
    }
  }

  connect() async {
    _networkTimeout();
    await _discoverServices();

    try {
      l.i("Connecting to: $wsUri");

      for(_WidgetData wd in _widgetData) {
        wd.onUpdate(null);
      }

      _channel?.sink.close();

      _channel = WebSocketChannel.connect(wsUri.replace(query: 'subscribe=none'));

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

      _subscribeAll();

      l.i("Connected to: $wsUri");
    } catch (e) {
      l.e('Error connecting WebSocket', error: e);
    }
  }

  void _unsubscribe() {
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
  }

  Map<String, String> _subscribeJson(String path) {
    return {
      "path": path,
      "policy": 'instant',
      "minPeriod": _settings!.signalkMinPeriod.toString()
    };
  }

  void _sendSubscribe(List<Map<String, String>> subscribe) {
    _channel?.sink.add(
      jsonEncode(
        {
          "context": "vessels.self",
          "subscribe": subscribe
        },
      ),
    );
  }

  void _subscribe(List<String> paths) {
    List<Map<String, String>> subscribe = [];

    for(String path in paths) {
      subscribe.add(_subscribeJson(path));
    }

    _sendSubscribe(subscribe);
  }

  void _subscribeAll() {
    List<String> paths = [];

    // Find all the unique paths.
    for(_WidgetData wd in _widgetData) {
      paths.addAll(wd.paths);
    }

    _unsubscribe();

    _subscribe(paths);
  }

  void _networkTimeout () {
    _networkTimer?.cancel();
    _networkTimer = Timer(Duration(milliseconds: _settings!.signalkConnectionTimeout), connect);
  }

  _processData(data) {
    _networkTimeout();

    DateTime now = DateTime.now().toUtc();

    dynamic d = json.decode(data);

    // We can get a status message on initial connection, which we ignore.
    if(d['updates'] != null) {
      for(_WidgetData wd in _widgetData) {
        wd.updates.clear();
      }

      for (dynamic u in d['updates']) {
        try {
          String source = u[r'$source'];
          if (source == 'defaults' ||
              source == 'derived-data' ||
              now.difference(DateTime.parse(u['timestamp'])) <=
                  Duration(milliseconds: _settings!.dataTimeout)) {
            for (dynamic v in u['values']) {
              String path = v['path'];

              for (_WidgetData wd in _widgetData) {
                for (RegExp r in wd.regExpPaths) {
                  if (r.hasMatch(path)) {
                    wd.updates.add(Update(path, v['value']));
                    wd.lastUpdate = now;
                  }
                }
              }
            }
          }
        } catch (e) {
          l.e("Error converting $u", error: e);
        }
      }

      for(_WidgetData wd in _widgetData) {
        if(wd.updates.isNotEmpty) {
          wd.onUpdate(wd.updates);
        } else if(wd.dataTimeout && now.difference(wd.lastUpdate) > Duration(milliseconds: _settings!.dataTimeout)) {
          wd.onUpdate(null);
        }
      }
    }
  }
}
