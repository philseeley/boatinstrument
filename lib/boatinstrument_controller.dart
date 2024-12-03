import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as m;

import 'package:audioplayers/audioplayers.dart';
import 'package:boatinstrument/theme_provider.dart';
import 'package:boatinstrument/widgets/anchor_box.dart';
import 'package:boatinstrument/widgets/boat_box.dart';
import 'package:boatinstrument/widgets/custom_box.dart';
import 'package:boatinstrument/widgets/date_time_box.dart';
import 'package:boatinstrument/widgets/electrical_box.dart';
import 'package:boatinstrument/widgets/environment_box.dart';
import 'package:boatinstrument/widgets/navigation_box.dart';
import 'package:boatinstrument/widgets/propulsion_box.dart';
import 'package:boatinstrument/widgets/tank_box.dart';
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

enum NotificationState {
  normal(false, null),
  nominal(false, null),
  alert(false, 'alert.mp3'),
  warn(false, 'warning.mp3'),
  alarm(true, 'alarm.mp3'),
  emergency(true, 'emergency.wav');

  final bool error;
  final String? soundFile;

  const NotificationState(this.error, this.soundFile);
}

class BoatInstrumentController {
  final CircularLogger l = CircularLogger();
  final bool _noAudio;
  final bool _noBrightnessControls;
  _Settings? _settings;
  Uri _httpApiUri = Uri();
  Uri _wsUri = Uri();
  int _boxesOnPage = 0;
  final List<_BoxData> _boxData = [];
  WebSocketChannel? _channel;
  Timer? _networkTimer;
  AudioPlayer? _audioPlayer;
  bool _showNotifications = true;

  BoatInstrumentController(this._noAudio, this._noBrightnessControls) {
    _audioPlayer = _noAudio ? null : AudioPlayer();
  }

  bool get ready => _settings != null;

  Uri get httpApiUri => _httpApiUri;
  Uri get wsUri => _wsUri;
  int get valueSmoothing => _settings!.valueSmoothing;
  bool get darkMode => _settings!.darkMode;
  bool get brightnessControl => _settings!.brightnessControl;
  bool get keepAwake => _settings!.keepAwake;
  bool get pageTimerOnStart => _settings!.pageTimerOnStart;
  DistanceUnits get distanceUnits => _settings!.distanceUnits;
  int get m2nmThreshold => _settings!.m2nmThreshold;
  SpeedUnits get speedUnits => _settings!.speedUnits;
  SpeedUnits get windSpeedUnits => _settings!.windSpeedUnits;
  DepthUnits get depthUnits => _settings!.depthUnits;
  TemperatureUnits get temperatureUnits => _settings!.temperatureUnits;
  AirPressureUnits get airPressureUnits => _settings!.airPressureUnits;
  OilPressureUnits get oilPressureUnits => _settings!.oilPressureUnits;
  CapacityUnits get capacityUnits => _settings!.capacityUnits;
  int get numOfPages => _settings!.pages.length;

  Color val2PSColor(BuildContext context, num val, {Color? none}) {
    if(_settings!.portStarboardColors == PortStarboardColors.none) {
      return none??Theme.of(context).colorScheme.onSurface;
    }
    return val < 0 ? _settings!.portStarboardColors.portColor : (val > 0) ? _settings!.portStarboardColors.starboardColor : Theme.of(context).colorScheme.onSurface;
  }

  double distanceToDisplay(double distance) {
  switch (distanceUnits) {
    case DistanceUnits.meters:
      return distance;
    case DistanceUnits.km:
      return distance * 0.001;
    case DistanceUnits.miles:
      return distance * 0.000621371;
    case DistanceUnits.nm:
      return distance * 0.000539957;
    case DistanceUnits.nmM:
      if(distance.abs() <= m2nmThreshold) {
        return distance;
      } else {
        return distance * 0.000539957;
      }
    }
  }

  String distanceUnitsToDisplay(double distance) {
    if(distanceUnits == DistanceUnits.nmM &&
        distance.abs() <= m2nmThreshold) {
      return 'm';
    }
    return distanceUnits.unit;
  }

  double speedToDisplay(double speed) {
    switch (speedUnits) {
      case SpeedUnits.mps:
        return speed;
      case SpeedUnits.kph:
        return speed * 3.6;
      case SpeedUnits.mph:
        return speed * 2.236936;
      case SpeedUnits.kts:
        return speed * 1.943844;
    }
  }

  double windSpeedToDisplay(double speed) {
    switch (windSpeedUnits) {
      case SpeedUnits.mps:
        return speed;
      case SpeedUnits.kph:
        return speed * 3.6;
      case SpeedUnits.mph:
        return speed * 2.236936;
      case SpeedUnits.kts:
        return speed * 1.943844;
    }
  }

  double temperatureToDisplay(double value) {
    switch (temperatureUnits) {
      case TemperatureUnits.c:
        return value - kelvinOffset;
      case TemperatureUnits.f:
        return (value - kelvinOffset) * 9/5 + 32;
    }
  }

  double temperatureFromDisplay(double value) {
    switch (temperatureUnits) {
      case TemperatureUnits.c:
        return value + kelvinOffset;
      case TemperatureUnits.f:
        return ((value - 32) * 5/9) + kelvinOffset;
    }
  }

  double airPressureToDisplay(double value) {
    switch (airPressureUnits) {
      case AirPressureUnits.pascal:
        return value;
      case AirPressureUnits.millibar:
        return value * 0.01;
      case AirPressureUnits.atmosphere:
        return value * 9.869233e-06;
      case AirPressureUnits.mercury:
        return value * 0.007501;
    }
  }

  double oilPressureToDisplay(double value) {
    switch (oilPressureUnits) {
      case OilPressureUnits.kpa:
        return value / 1000;
      case OilPressureUnits.psi:
        return value * 0.000145038;
    }
  }

  double oilPressureFromDisplay(double value) {
    switch (oilPressureUnits) {
      case OilPressureUnits.kpa:
        return value * 1000;
      case OilPressureUnits.psi:
        return value / 0.000145038;
    }
  }

  double capacityToDisplay(double value) {
    switch (capacityUnits) {
      case CapacityUnits.liter:
        return value * 1000;
      case CapacityUnits.gallon:
        return value * 219.969248;
      case CapacityUnits.usGallon:
        return value * 264.172052;
    }
  }

  double capacityFromDisplay(double value) {
    switch (capacityUnits) {
      case CapacityUnits.liter:
        return value / 1000;
      case CapacityUnits.gallon:
        return value / 219.969248;
      case CapacityUnits.usGallon:
        return value / 264.172052;
    }
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

    if(_noBrightnessControls) {
      _settings?.brightnessControl = false;
    }
  }

  void clear() {
    _unsubscribe();
    _boxesOnPage = 0;
    _boxData.clear();
  }

  // Call this in the Widget's State initState() to get common Box settings.
  Map<String, dynamic> getBoxSettingsJson(String boxID) {
    return _settings?.boxSettings[boxID]??{};
  }

  // Call this in the Widget's State initState() to subscribe to Signalk data.
  void configure({OnUpdate? onUpdate, Set<String>? paths, bool dataTimeout = true, bool isBox = true}) {
    if(!isBox) {
      ++_boxesOnPage;
    }

    _BoxData bd = _BoxData(onUpdate, paths??{}, dataTimeout);
    _boxData.add(bd);

    for(String path in bd.paths) {
      // Need to escape all the '.'s and make a wildcard character for any '*'s, otherwise
      // 'a.*.c' would match anything starting 'a' and ending 'b', e.g 'abbbbc'.
      bd.regExpPaths.add(
          RegExp('^${path.replaceAll(r'.', r'\.').replaceAll(r'*', r'.*')}\$'));
    }

    if(isBox) {
      _subscribe();
    }
  }

  void save() {
    _settings?._save();
  }

  void showMessage(BuildContext context, String msg, {bool error = false, int millisecondsDuration = 4000, SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: (error) ? Colors.orange : null,
            duration: Duration(milliseconds: millisecondsDuration),
            action: action,
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
      clear();

      configure(onUpdate: (List<Update>? updates) {_onNotification(context, updates);}, paths: {'notifications.*'}, dataTimeout: true, isBox: false);

      // We need to calculate the total number of boxes on the page so that we
      // know when tha last one calls configure(). As we're using LayoutBuilders
      // this will be after buildPage() returns.
      for(var pageRow in page.pageRows) {
        for (var column in pageRow.columns) {
          for (var row in column.rows) {
            _boxesOnPage += row.boxes.length;
          }
        }
      }

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

  _onNotification(BuildContext context, List<Update>? updates) {
    if (updates == null) {
      _showNotifications = true;
    } else {
      for(Update u in updates) {
        try {
          NotificationState state = NotificationState.values.byName(
              u.value['state']);

          bool playSound = false;
          dynamic method = u.value['method'];
          for(String m in method) {
            if(m == 'sound') {
              playSound = true;
            }
          }
          if ([NotificationState.normal, NotificationState.nominal].contains(state)) {
            _showNotifications = true;
            _audioPlayer?.stop();
          }

          if (_showNotifications) {
            ScaffoldMessenger.of(context).clearSnackBars();

            SnackBarAction? action;
            if ([NotificationState.normal, NotificationState.nominal].contains(state)) {
              action = SnackBarAction(label: 'Mute', onPressed: () {
                _showNotifications = false;
                _audioPlayer?.stop();
              });
            }
            showMessage(
                context, u.value['message'], error: state.error,
                action: action);

            if (playSound && state.soundFile != null) {
              _audioPlayer?.play(AssetSource(state.soundFile!));
            }
          }
        } catch(e) {
          l.e('Error handling notification $u', error: e);
        }
      }
    }
  }

  int nextPageNum(int currentPage) {
    if(_settings!.pages.isEmpty) {
      _settings?.pages = [_Page._newPage()];
      return 0;
    }
    ++currentPage;
    if(_settings!.wrapPages) {
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

  (int, int?) rotatePageNum(int currentPage) {
    if(_settings!.pages.isEmpty) {
      _settings?.pages = [_Page._newPage()];
      return (0, null);
    }
    int i = 0;
    do {
      ++currentPage;
      currentPage %= _settings!.pages.length;
      int? timeout = _settings!.pages[currentPage].timeout;
      if(timeout != null) {
        return (currentPage, timeout);
      }
    } while (++i < _settings!.pages.length);
    // There are no pages with timeouts.
    return (0, null);
  }

  String pageName(int pageNum) {
    return '${pageNum+1}/${_settings!.pages.length} ${_settings!.pages[pageNum].name}';
  }

  _discoverServices() async {
    try {
      String host = _settings!.signalkHost;
      int port = _settings!.signalkPort;

      if(_settings!.demoMode) {
        host = 'demo.signalk.org';
        port = 443;
      }
      else if(_settings!.discoverServer) {
        BonsoirDiscovery discovery = BonsoirDiscovery(type: '_signalk-http._tcp');
        await discovery.ready;
        discovery.start();
        Timer t = Timer(const Duration(seconds: 10), () {discovery.stop();});
        try {
          await for(BonsoirDiscoveryEvent e in discovery.eventStream!) {
            if (e.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
              e.service!.resolve(discovery.serviceResolver);
            } else if (e.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
              ResolvedBonsoirService r = e.service as ResolvedBonsoirService;
              host = r.host!;
              port = r.port;
              break;
            } else if (e.type == BonsoirDiscoveryEventType.discoveryStopped) {
              // This should only happen if the Timer expires.
              throw Exception('Service discovery failed');
            }
          }
        } finally {
          t.cancel();
          discovery.stop();
        }
      }

      Uri uri = Uri(scheme: _settings!.demoMode ? 'https' : 'http', host: host, port: port, path: '/signalk');

      http.Response response = await http.get(uri).timeout(const Duration(seconds: 10));
      dynamic data = json.decode(response.body);
      dynamic endPoints = data['endpoints']['v1'];

      _httpApiUri = Uri.parse(endPoints['signalk-http']);
      _wsUri = Uri.parse(endPoints['signalk-ws']);
    } catch(e) {
      l.e('Error discovering services', error: e);
      rethrow;
    }
  }

  connect() async {
    try {
      for(_BoxData bd in _boxData) {
        if(bd.onUpdate != null) {
          bd.onUpdate!(null);
        }
      }

      _channel?.sink.close();
      _channel = null;

      _networkTimeout();
      await _discoverServices();

      l.i("Connecting to: $wsUri");

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

      _subscribe();

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

  void _subscribe() {
    if(_boxData.length == _boxesOnPage) {
      Set<String> paths = {};

      // Find all the unique paths.
      for (_BoxData bd in _boxData) {
        paths.addAll(bd.paths);
      }

      _unsubscribe();

      List<Map<String, String>> subscribe = [];

      for(String path in paths) {
        subscribe.add({
          "path": path,
          "policy": 'instant',
          "minPeriod": _settings!.signalkMinPeriod.toString()
        });
      }
      _channel?.sink.add(
        jsonEncode(
          {
            "context": "vessels.self",
            "subscribe": subscribe
          },
        ),
      );
    }
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
      for(_BoxData bd in _boxData) {
        bd.updates.clear();
      }

      for (dynamic u in d['updates']) {
        try {
          String source = u[r'$source'];
          // Note: the demo server has old date/times.
          if (_settings!.demoMode ||
              source == 'defaults' ||
              source == 'derived-data' ||
              now.difference(DateTime.parse(u['timestamp'])) <=
                  Duration(milliseconds: _settings!.dataTimeout)) {
            for (dynamic v in u['values']) {
              String path = v['path'];
              for (_BoxData bd in _boxData) {
                for (RegExp r in bd.regExpPaths) {
                  if (r.hasMatch(path)) {
                    bd.updates.add(Update(path, v['value']));
                    bd.lastUpdate = now;
                  }
                }
              }
            }
          }
        } catch (e) {
          l.e("Error converting $u", error: e);
        }
      }

      for(_BoxData bd in _boxData) {
        if(bd.onUpdate != null) {
          if (bd.updates.isNotEmpty) {
            bd.onUpdate!(bd.updates);
          } else if (bd.dataTimeout && now.difference(bd.lastUpdate) >
              Duration(milliseconds: _settings!.dataTimeout)) {
            bd.onUpdate!(null);
            bd.lastUpdate = now;
          }
        }
      }
    }
  }
}
