import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as m;

import 'package:actions_menu_appbar/actions_menu_appbar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:boatinstrument/authorization.dart';
import 'package:boatinstrument/main.dart';
import 'package:boatinstrument/theme_provider.dart';
import 'package:boatinstrument/widgets/anchor_box.dart';
import 'package:boatinstrument/widgets/boat_box.dart';
import 'package:boatinstrument/widgets/compass_rose_box.dart';
import 'package:boatinstrument/widgets/custom_box.dart';
import 'package:boatinstrument/widgets/date_time_box.dart';
import 'package:boatinstrument/widgets/electrical_box.dart';
import 'package:boatinstrument/widgets/environment_box.dart';
import 'package:boatinstrument/widgets/launch_box.dart';
import 'package:boatinstrument/widgets/navigation_box.dart';
import 'package:boatinstrument/widgets/network.dart';
import 'package:boatinstrument/widgets/propulsion_box.dart';
import 'package:boatinstrument/widgets/remote_box.dart';
import 'package:boatinstrument/widgets/hardware.dart';
import 'package:boatinstrument/widgets/tank_box.dart';
import 'package:boatinstrument/widgets/vnc_box.dart';
import 'package:boatinstrument/widgets/webview_box.dart';
import 'package:boatinstrument/widgets/wind_box.dart';
import 'package:boatinstrument/widgets/wind_rose_box.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:http/http.dart' as http;
import 'package:format/format.dart' as fmt;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:markdown_widget/markdown_widget.dart';
import 'package:nanoid/nanoid.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:url_launcher/url_launcher.dart';
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
import 'package:web_socket_channel/io.dart';
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

enum NotificationState implements EnumMenuEntry {
  normal('Normal', false, 1, null),
  nominal('Nominal', false, 1, null),
  alert('Alert', false, 5, 'alert.mp3'),
  warn('Warning', false, 10, 'warning.mp3'),
  alarm('Alarm', true, 20, 'alarm.mp3'),
  emergency('Emergency', true, 30, 'emergency.wav');

  @override
  String get displayName => _displayName;
  final String _displayName;

  final bool error;
  final int count;
  final String? soundFile;

  const NotificationState(this._displayName, this.error, this.count, this.soundFile);
}

class NotificationStatus {
  NotificationState state = NotificationState.normal;
  int count = 0;
  bool mute = false;
  String message = "";
  DateTime last = DateTime.now();
}

class BoatInstrumentController {
  final CircularLogger l = CircularLogger();
  final bool _noAudio;
  final bool _noBrightnessControls;
  final bool _enableExit;
  final bool _enablePoweroff;
  final bool _enableSetTime;
  final MainPageState _mainPageState;
  bool _timeSet = false;
  _Settings? _settings;
  int _pageNum = 0;
  bool _rotatePages = false;
  Timer? _pageTimer;
  static const _brightnessStep = 4;
  static const _brightnessMax = 12;
  static final Map<int, IconData> brightnessIcons = {
    12: Icons.brightness_high,
    8: Icons.brightness_medium,
    4: Icons.brightness_low,
    0: Icons.brightness_4_outlined
  };
  int _brightness = _brightnessMax;

  Uri _httpApiUri = Uri();
  Uri _wsUri = Uri();
  int _boxesOnPage = 0;
  final List<_BoxData> _boxData = [];
  WebSocketChannel? _dataChannel;
  WebSocketChannel? _controlChannel;
  StreamSubscription? _dataStreamSubscription;
  StreamSubscription? _controlStreamSubscription;
  Timer? _networkTimer;
  AudioPlayer? _audioPlayer;
  DateTime? _time;
  DateTime _timeReceived = DateTime.now();
  final Map<String, NotificationStatus> _notifications = {};
  final Set<String> _backgroundIDs = {};
  final Set<String> _paths = {};
  final Set<String> _controlPaths = {};
  final Set<String> _staticPaths = {};


  BoatInstrumentController(this._mainPageState, this._noAudio, this._noBrightnessControls, this._enableExit, this._enablePoweroff, this._enableSetTime) {
    _audioPlayer = _noAudio ? null : AudioPlayer();
  }

  bool get ready => _settings != null;

  Uri get httpApiUri => _httpApiUri;
  Uri get wsUri => _wsUri;
  int get valueSmoothing => _settings!.valueSmoothing;
  int get realTimeDataTimeout => _settings!.realTimeDataTimeout;
  int get infrequentDataTimeout => _settings!.infrequentDataTimeout;
  bool get darkMode => _settings!.darkMode;
  bool get brightnessControl => _settings!.brightnessControl;
  bool get keepAwake => _settings!.keepAwake;
  bool get pageTimerOnStart => _settings!.pageTimerOnStart;
  bool get arePagesRotating => _rotatePages;
  IconData get brightnessIcon => brightnessIcons[_brightness]??Icons.brightness_4_outlined; // This will only do the null substitute on MacOS.
  bool get enableExperimentalBoxes => _settings!.enableExperimentalBoxes;
  DistanceUnits get distanceUnits => _settings!.distanceUnits;
  int get m2nmThreshold => _settings!.m2nmThreshold;
  SpeedUnits get speedUnits => _settings!.speedUnits;
  SpeedUnits get windSpeedUnits => _settings!.windSpeedUnits;
  DepthUnits get depthUnits => _settings!.depthUnits;
  TemperatureUnits get temperatureUnits => _settings!.temperatureUnits;
  AirPressureUnits get airPressureUnits => _settings!.airPressureUnits;
  OilPressureUnits get oilPressureUnits => _settings!.oilPressureUnits;
  CapacityUnits get capacityUnits => _settings!.capacityUnits;
  FluidRateUnits get fluidRateUnits => _settings!.fluidRateUnits;
  Map<String, NotificationStatus> get notifications => _notifications;
  bool get muted => _notifications.entries.any((element) => element.value.mute);
  Set<String> get paths => _paths;
  Set<String> get controlPaths => _controlPaths;
  Set<String> get staticPaths => _staticPaths;

  DateTime now() {
    DateTime now = DateTime.now();
    if(_time != null) return _time!.add(now.difference(_timeReceived));
    return now;
  }

  Color val2PSColor(BuildContext context, num val, {Color? none}) {
    if(_settings!.portStarboardColors == PortStarboardColors.none) {
      return none??Theme.of(context).colorScheme.onSurface;
    }
    return val < 0 ? _settings!.portStarboardColors.portColor : (val > 0) ? _settings!.portStarboardColors.starboardColor : Theme.of(context).colorScheme.onSurface;
  }

  double depthToDisplay(double depth) {
    switch (depthUnits) {
      case DepthUnits.m:
        return depth;
      case DepthUnits.ft:
        return depth * 3.28084;
      case DepthUnits.fa:
        return depth * 0.546807;
    }
  }

  double distanceToDisplay(double distance, {bool fixed = false}) {
    switch (distanceUnits) {
      case DistanceUnits.meters:
        return distance;
      case DistanceUnits.km:
        return distance * 0.001;
      case DistanceUnits.miles:
        return distance * 0.000621371;
      case DistanceUnits.nm:
        return m2nm(distance);
      case DistanceUnits.nmM:
        if(!fixed && distance.abs() <= m2nmThreshold) {
          return distance;
        } else {
          return m2nm(distance);
        }
    }
  }

  String distanceUnitsToDisplay(double distance, {bool fixed = false}) {
    if(!fixed && distanceUnits == DistanceUnits.nmM &&
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
        return ms2kts(speed);
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
        return ms2kts(speed);
    }
  }

  double windSpeedFromDisplay(double speed) {
    switch (windSpeedUnits) {
      case SpeedUnits.mps:
        return speed;
      case SpeedUnits.kph:
        return speed / 3.6;
      case SpeedUnits.mph:
        return speed / 2.236936;
      case SpeedUnits.kts:
        return kts2ms(speed);
    }
  }

  double temperatureToDisplay(double value) {
    switch (temperatureUnits) {
      case TemperatureUnits.k:
        return value;
      case TemperatureUnits.c:
        return value - kelvinOffset;
      case TemperatureUnits.f:
        return (value - kelvinOffset) * 9/5 + 32;
    }
  }

  double temperatureFromDisplay(double value) {
    switch (temperatureUnits) {
      case TemperatureUnits.k:
        return value;
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

  double fluidRateToDisplay(double value) {
    switch (fluidRateUnits) {
      case FluidRateUnits.litersPerHour:
        return value * 3600000;
      case FluidRateUnits.gallonsPerHour:
        return value * 791889.293877;
      case FluidRateUnits.usGallonsPerHour:
        return value * 951019.388489;
    }
  }

  void playSoundFile(String soundFile) {
    _audioPlayer?.play(AssetSource(soundFile));
  }

  Future<void> _loadDefaultConfig(bool portrait) async {
    String config = portrait ?
      'default-config-portrait.json' :
      'default-config-landscape.json';
    String s = await rootBundle.loadString('assets/$config');
    _settings = _Settings.fromJson(jsonDecode(s));
  }

  Future<void> loadSettings(String configFile, bool portrait) async {
    try {
      _settings = await _Settings.load(configFile);
    } on Exception catch (e) {
      l.e('Exception loading Settings', error: e);
      await _loadDefaultConfig(portrait);
    } on Error catch(e) {
      l.e('Error loading Settings', error: e);
      await _loadDefaultConfig(portrait);
    }

    _configureBackgroundData();

    if(_noBrightnessControls || Platform.isLinux) {
      _settings?.brightnessControl = false;
    }
  }

  void _clear() {
    _unsubscribe();
    _boxesOnPage = 0;
    _boxData.clear();
  }

  // Call this in the Widget's State initState() to get common Box settings.
  Map<String, dynamic> getBoxSettingsJson(String boxID) {
    return _settings?.boxSettings[boxID]??{};
  }

  // Call this in the Widget's State initState() to subscribe to Signalk data.
  void configure({OnUpdate? onUpdate, Set<String>? paths, OnUpdate? onStaticUpdate, Set<String>? staticPaths, SignalKDataType dataType = SignalKDataType.realTime, bool isBox = true, bool onControlChannel = false}) {
  
    // ============= PATH MAPPING =============
    // String pathsString = '';
    // for(String p in paths??{}) pathsString='${pathsString.isNotEmpty?'$pathsString<br>':''}$p';
    // print('$pathsString|');
    // ============= PATH MAPPING =============

    if(!isBox) {
      ++_boxesOnPage;
    }

    _BoxData bd = _BoxData(onUpdate, paths??{}, onStaticUpdate, staticPaths??{}, dataType, onControlChannel);
    _boxData.add(bd);

    for(String path in bd.paths) {
      // Need to escape all the '.'s and make a wildcard character for any '*'s, otherwise
      // 'a.*.c' would match anything starting 'a' and ending 'b', e.g 'abbbbc'.
      bd.regExpPaths.add(
          RegExp('^${path.replaceAll(r'.', r'\.').replaceAll(r'*', r'.*')}\$'));
    }

    for(String path in bd.staticPaths) {
      // Need to escape all the '.'s and make a wildcard character for any '*'s, otherwise
      // 'a.*.c' would match anything starting 'a' and ending 'b', e.g 'abbbbc'.
      bd.regExpStaticPaths.add(
          RegExp('^${path.replaceAll(r'.', r'\.').replaceAll(r'*', r'.*')}\$'));
    }

    if(isBox) {
      _subscribe(false);
    }
  }

  void save() {
    _settings?._save();
    _configureBackgroundData();
  }

  void _configureBackgroundData() {
    _backgroundIDs.clear();
    
    for(var page in _settings!.pages) {
      for(var pageRow in page.pageRows) {
        for (var column in pageRow.columns) {
          for (var row in column.rows) {
            _boxesOnPage += row.boxes.length;
            for(var box in row.boxes) {
              if(getBoxDetails(box.id).background != null) {
                _backgroundIDs.add(box.id);
              }
            }
          }
        }
      }
    }
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

                  // ============= PATH MAPPING =============
                  // List<BoxWidget> stack = [];
                  // for(BoxDetails bd in boxDetails) {
                  //   print('|${bd.id}|');
                  //   stack.add(bd.build(BoxWidgetConfig(this, box.settings, constraints, false)));
                  // }
                  // return Stack(children: stack);
                  // ============= PATH MAPPING =============

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

  Widget buildPage() {
    // Sanity check
    if(_pageNum >= _settings!.pages.length) _pageNum = _settings!.pages.length-1;

    _Page page = _settings!.pages[_pageNum];

    return LayoutBuilder(builder: (context, constraints) {
      _clear();

      configure(onUpdate: (List<Update> updates) {_onNotification(context, updates);}, paths: {'notifications.*'}, isBox: false);

      _addRemoteControlSubscriptions();

      for(var id in _backgroundIDs) {
        getBoxDetails(id).background!.call(this);
      }

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

  void unmute() {
    _notifications.clear();
  }

  void _addRemoteControlSubscriptions() {
    if(_settings!.allowRemoteControl) {
      Set<String> actionPaths = {};
      if(_settings!.clientID.isNotEmpty) actionPaths.add('$bi.devices.${_settings!.clientID}.action');
      if(_settings!.groupID.isNotEmpty) actionPaths.add('$bi.groups.${_settings!.groupID}.action');
      for(var gID in _settings!.supplementalGroupIDs) {
        actionPaths.add('$bi.groups.$gID.action');
      }

      if(actionPaths.isNotEmpty) configure(onUpdate: _onRemoteControl, paths: actionPaths, isBox: false, onControlChannel: true);
    }
  }

  void _onNotification(BuildContext context, List<Update> updates) {
    DateTime now = this.now();

    _notifications.removeWhere((path, notification) {
      return now.difference(notification.last) > Duration(minutes: _settings!.notificationMuteTimeout);
    });

    for(Update u in updates) {
      if (u.value == null) {
        _audioPlayer?.release();
      } else {
        try {
          NotificationStatus notificationStatus = _notifications.putIfAbsent(u.path, () => NotificationStatus());
          NotificationState newState = NotificationState.values.byName(
              u.value['state']);

          bool playSound = (u.value['method']??[]).contains('sound');

          notificationStatus.message = u.value['message']??'"${u.path}" has no message';
          notificationStatus.last = now;

          if((newState != notificationStatus.state || notificationStatus.count < newState.count) && !notificationStatus.mute) {            
            notificationStatus.count = (newState == notificationStatus.state) ? notificationStatus.count+1 : 1;

            notificationStatus.state = newState;

            ScaffoldMessenger.of(context).clearSnackBars();

            showMessage(
                context, notificationStatus.message, error: newState.error,
                action: SnackBarAction(label: 'Mute', onPressed: () {
                  notificationStatus.mute = true;
                  _audioPlayer?.release();
                }));

            if (playSound && newState.soundFile != null) {
              playSoundFile(newState.soundFile!);
            }
          }
        } catch(e) {
          l.e('Error handling notification $u', error: e);
        }
      }
    }
  }

  void _onRemoteControl(List<Update> updates) {
    for (Update u in updates) {
      try {
        if(u.value == null) return;

        switch(u.value['id']) {
          case 'gotoPage':
            gotoPage(u.value['page']);
            break;
          case 'firstPage':
            firstPage();
            break;
          case 'decPage':
            prevPage();
            break;
          case 'incPage':
            nextPage();
            break;
          case 'lastPage':
            lastPage();
            break;
          case 'rotatePagesOn':
            toggleRotatePages(on: true);
            break;
          case 'rotatePagesOff':
            toggleRotatePages(on: false);
            break;
          case 'setBrightness':
            stepBrightness(level: u.value['level']);
            break;
          case 'nightMode':
            _mainPageState.nightMode(on: u.value['on']);
            break;
        }
      } catch (e) {
        l.e("Error converting $u", error: e);
      }
    }
  }

  void firstPage() {
    int lastPage = _pageNum;
    _pageNum = 0;    
    if (lastPage != _pageNum) _mainPageState.rebuild();
  }

  void nextPage() {
    int lastPage = _pageNum;
    if(_settings!.pages.isEmpty) {
      _settings?.pages = [_Page._newPage()];
      _mainPageState.rebuild();
      return;
    }
    ++_pageNum;
    if(_settings!.wrapPages) {
      _pageNum %= _settings!.pages.length;
    }
    _pageNum = (_pageNum >= _settings!.pages.length) ? _settings!.pages.length-1 : _pageNum;
    
    if (lastPage != _pageNum) _mainPageState.rebuild();
  }

  void prevPage() {
    int lastPage = _pageNum;
    --_pageNum;
    if(_settings!.wrapPages) {
      _pageNum %= _settings!.pages.length;
    }
    _pageNum = (_pageNum < 0) ? 0 : _pageNum;

    if (lastPage != _pageNum) _mainPageState.rebuild();
  }

  void lastPage() {
    int lastPage = _pageNum;
    _pageNum = _settings!.pages.length-1;    
    if (lastPage != _pageNum) _mainPageState.rebuild();
  }

  void gotoPage(String pageName) {
    int pageNum = _settings!.pages.indexWhere((page) {return page.name == pageName;});
    if(pageNum != -1 && pageNum != _pageNum) {
      _pageNum = pageNum;
      _mainPageState.rebuild();
    }
  }

  void toggleRotatePages({bool? on}) {
    _rotatePages = on??!_rotatePages;

    if(_rotatePages) {
      startPageTimer();
    } else {
      stopPageTimer();
    }

    _mainPageState.rebuild();
  }

  void startPageTimer({int timeout = 0}) {
    stopPageTimer();

    if(_rotatePages) {
      _pageTimer = Timer(Duration(seconds: timeout), _rotatePage);
    }
  }

  void stopPageTimer() {
    _pageTimer?.cancel();
    _pageTimer = null;
  }

  void _rotatePage() {
    if(_settings!.pages.isEmpty) {
      _settings?.pages = [_Page._newPage()];
    }
    int i = 0;
    do {
      ++_pageNum;
      _pageNum %= _settings!.pages.length;
      int? timeout = _settings!.pages[_pageNum].timeout;
      if(timeout != null) {
        _mainPageState.rebuild();
        startPageTimer(timeout: timeout);
        break;
      }
    } while (++i < _settings!.pages.length);
  }

  void stepBrightness({bool init = false, int? level}) async {

    if(brightnessControl) {
      if(init) {
        // Convert the current system brightness into the closest step, rounding up.
        // Note: We add the step as well as _setBrightness() will remove it.
        _brightness = (await ScreenBrightness().system * _brightnessMax).ceil();
        _brightness =
            _brightness - (_brightness % _brightnessStep) + (_brightnessStep * 2);
      }

      if(level == null) {
        _brightness = ((_brightness < _brightnessStep) || (_brightness > _brightnessMax)) ? _brightnessMax : _brightness - _brightnessStep;
      } else {
        _brightness = level;
      }
      if(Platform.isMacOS && _brightness == 0) {
       _brightness = 1;
      }

      ScreenBrightness().setApplicationScreenBrightness(_brightness/_brightnessMax);
      _mainPageState.rebuild();
    }
  }

  String pageName() {
    return '${_pageNum+1}/${_settings!.pages.length} ${_settings!.pages[_pageNum].name}';
  }

  Map<String, String> _httpHeaders(Map<String, String>? headers) {
    // We don't add headers in demo mode as any auth tokens will stop the
    // connection to the demo server.
    if(_settings!.demoMode) return {};

    Map<String, String> h = headers??{};

    if(_settings!.authToken.isNotEmpty) {
      h['Authorization'] = 'Bearer ${_settings!.authToken}';
    }
    
    for (var header in _settings!.httpHeaders) {
      h[header.name] = header.value;
    }

    return h;
  }

  Future<http.Response> httpGet(Uri uri, {Map<String, String>? headers}) async {
    return await http.get(uri, headers: _httpHeaders(headers));
  }

  Future<http.Response> httpPut(Uri uri, {Map<String, String>? headers, Object? body}) async {
    return await http.put(uri, headers: _httpHeaders(headers), body: body);
  }

  Future<http.Response> httpPost(Uri uri, {Map<String, String>? headers, Object? body}) async {
    return await http.post(uri, headers: _httpHeaders(headers), body: body);
  }

  Future<void> _discoverServices() async {
    try {
      Uri url = Uri.parse(_settings!.signalkUrl);
      String host = url.host;
      int port = url.port;
      String scheme = url.scheme.isEmpty ? 'http' : url.scheme;
      List<String> paths = [...url.pathSegments, 'signalk'];

      if(_settings!.demoMode) {
        host = 'demo.signalk.org';
        port = 443;
        scheme = 'https';
      }
      else if(_settings!.discoverServer) {
        host = '';
        port = 0;
        BonsoirDiscovery discovery = BonsoirDiscovery(type:  '_signalk-http._tcp');
        await discovery.initialize();
        await discovery.start();
        Timer t = Timer(const Duration(seconds: 10), () {discovery.stop();});
        try {
          await for(BonsoirDiscoveryEvent e in discovery.eventStream!) {
            if (e is BonsoirDiscoveryServiceFoundEvent) {
              e.service.resolve(discovery.serviceResolver);
            } else if (e is BonsoirDiscoveryServiceResolvedEvent) {
              host = e.service.host!;
              port = e.service.port;
              discovery.stop();
              break;
            } else if (e is BonsoirDiscoveryStoppedEvent) {
              // This should only happen if the Timer expires.
              throw Exception('Service discovery failed');
            }
           }
         } finally {
          t.cancel();
         }
      }

      Uri uri = Uri(scheme: scheme, host: host, port: port, pathSegments: paths);

      http.Response response = await httpGet(uri).timeout(const Duration(seconds: 10));

      dynamic data = json.decode(response.body);
      dynamic endPoints = data['endpoints']['v1'];

      _httpApiUri = Uri.parse(endPoints['signalk-http']);
      _wsUri = Uri.parse(endPoints['signalk-ws']);
    } catch(e) {
      l.e('Error discovering services', error: e);
      rethrow;
    }
  }

  Future<void> connect() async {
    try {
      for(_BoxData bd in _boxData) {
        if(bd.onUpdate != null) {
          bd.updates.clear();
          for(String path in bd.pathTimestamps.keys) {
            bd.updates.add(Update(path, null));
          }
          bd.pathTimestamps.clear();
          if(bd.updates.isNotEmpty) bd.onUpdate!(bd.updates);
        }
      }

      await _dataStreamSubscription?.cancel();
      await _controlStreamSubscription?.cancel();
      await _dataChannel?.sink.close();
      await _controlChannel?.sink.close();
      _dataChannel = _controlChannel = null;

      _networkTimeout();
      await _discoverServices();

      l.i("Connecting to: $wsUri");

      _dataChannel = IOWebSocketChannel.connect(wsUri.replace(query: 'subscribe=none'), headers: _httpHeaders(null));
      _controlChannel = IOWebSocketChannel.connect(wsUri.replace(query: 'subscribe=none'), headers: _httpHeaders(null));

      await _dataChannel?.ready;
      await _controlChannel?.ready;

      _dataStreamSubscription = _dataChannel?.stream.listen(
          _processData,
          onError: (e) {
            l.e('WebSocket stream error', error: e);
          },
          onDone: () {
            l.w('WebSocket closed');
          }
      );

      _controlStreamSubscription = _controlChannel?.stream.listen(
          _processData,
          onError: (e) {
            l.e('WebSocket stream error', error: e);
          },
          onDone: () {
            l.w('WebSocket closed');
          }
      );

      _publishDeviceDetails();

      _addRemoteControlSubscriptions();
      
      _subscribe(true);

      l.i("Connected to: $wsUri");
    } catch (e) {
      l.e('Error connecting WebSocket', error: e);
      _dataChannel = _controlChannel = null;
    }
  }

  void _send(Object data, {bool controlChannel = false}) {
    try {
      (controlChannel?_controlChannel:_dataChannel)?.sink.add(jsonEncode(data));
    } catch (e) {
      l.e("Error sending ${controlChannel?'control':'data'} data $data", error: e);
    }
  }

  void _unsubscribe() {
    _send(
      {
        "context": "*",
        "unsubscribe": [
          {"path": "*"}
        ]
      }
    );
  }

  void _subscribe(bool connecting) {
    // Find all the unique paths.
    _paths.clear();
    _controlPaths.clear();
    _staticPaths.clear();
    for (_BoxData bd in _boxData) {
      if(bd.onControlChannel) {
        _controlPaths.addAll(bd.paths);
      } else {
        _paths.addAll(bd.paths);
      }
      _staticPaths.addAll(bd.staticPaths);
    }

    if(_boxData.length == _boxesOnPage) {
      _paths.add('navigation.datetime'); // Keep alive test.

      _getStaticData(_staticPaths);

      _unsubscribe();

      List<Map<String, String>> subscribe = [];

      for(String path in _paths) {
        subscribe.add({
          "path": path,
          "policy": 'instant',
          "minPeriod": _settings!.signalkMinPeriod.toString()
        });
      }

      _send(
        {
          "context": "vessels.self",
          "subscribe": subscribe
        },
      );
    }

    if(connecting) {
      List<Map<String, String>> subscribe = [];

      for(String path in _controlPaths) {
        subscribe.add({
          "path": path,
          "policy": 'instant',
          "minPeriod": _settings!.signalkMinPeriod.toString()
        });
      }

      _send(controlChannel: true,
        {
          "context": "vessels.self",
          "subscribe": subscribe
        },
      );
    }
  }

  void _publishDeviceDetails() {
    if(_settings!.allowRemoteControl) {
      List<String> pageNames = [];
      for(_Page page in _settings!.pages) {
        pageNames.add(page.name);
      }

      if(_settings!.clientID.isNotEmpty) {
        // If we don't have permission, then updates are ignored.
        _send(
          {
            "updates": [{
              "values": [
                {
                  "path": "$bi.devices.${_settings!.clientID}.pages",
                  "value": pageNames
                }
              ]
            }]
          }
        );
      }

      if(_settings!.groupID.isNotEmpty) {
        _send(
          {
            "updates": [{
              "values": [
                {
                  "path": "$bi.groups.${_settings!.groupID}.pages",
                  "value": pageNames
                }
              ]
            }]
          }
        );
      }

      if(_settings!.supplementalGroupIDs.isNotEmpty) {
        List<dynamic> values = [];
        for(var groupID in _settings!.supplementalGroupIDs) {
          values.add({
            "path": "$bi.groups.$groupID",
            "value": null

          });
        }

        _send(
          {
            "updates": [{
              "values": values
            }]
          }
        );
      }
    }
  }

  void sendUpdate(String path, dynamic value) {
    _send(
      {
        "updates": [{
          "values": [
            {
              "path": path,
              "value": value
            }
          ]
        }]
      }
    );
  }

  void _networkTimeout () {
    _networkTimer?.cancel();
    _networkTimer = Timer(Duration(milliseconds: _settings!.signalkConnectionTimeout), connect);
  }

  void _processData(dynamic data) {
    _networkTimeout();

    DateTime now = this.now();
    Duration realTimeDuration = Duration(milliseconds: realTimeDataTimeout);
    Duration infrequentDuration = Duration(milliseconds: infrequentDataTimeout);

    dynamic d = json.decode(data);

    // We can get a status message on initial connection, which we ignore.
    if(d['updates'] != null) {
      for(_BoxData bd in _boxData) {
        bd.updates.clear();
      }

      for (dynamic u in d['updates']) {
        try {
          DateTime timeStamp = DateTime.parse(u['timestamp']);
          if(_time == null) {
            _timeSync(timeStamp);
            now = this.now();
          }

          for (dynamic v in u['values']) {
            String path = v['path'];
            for (_BoxData bd in _boxData) {
              for (RegExp r in bd.regExpPaths) {
                if (r.hasMatch(path)) {
                  Duration d = now.difference(timeStamp);
                  if (
                    // Note: the demo server has old timestamps on replayed data, but
                    // current timestamps on notifications.
                    _settings!.demoMode ||
                    bd.dataType == SignalKDataType.static ||
                    (
                      (bd.dataType == SignalKDataType.realTime) && d < realTimeDuration
                    ) ||
                    (
                      (bd.dataType == SignalKDataType.infrequent) && d < infrequentDuration
                    )
                  ) {
                    dynamic value = v['value'];

                    _timeSync(timeStamp);

                    if(_settings!.setTime && !_timeSet && path == 'navigation.datetime') _setTime(value);

                    bd.updates.add(Update(path,value));
                    bd.pathTimestamps[path] = now;
                  } else {
                   l.i('Discarding old data for "$u"');
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
          var pt = bd.pathTimestamps;
          for(String path in pt.keys.toSet()) { // We make a copy of the keys as we might remove some.
            Duration d = now.difference(pt[path]!);
            if (
            ((bd.dataType == SignalKDataType.realTime) && d > realTimeDuration) ||
            ((bd.dataType == SignalKDataType.infrequent) && d > infrequentDuration)
            ) {
              bd.updates.add(Update(path, null));
              bd.pathTimestamps.remove(path);
            }
          }
          if (bd.updates.isNotEmpty) {
            // Send updates to Box.
            bd.onUpdate!(bd.updates);
          }
        }
      }
    }
  }

  void _timeSync(DateTime timeStamp) {
    if(_time == null || timeStamp.isAfter(_time!)) {
      _time = timeStamp;
      _timeReceived = DateTime.now();
    }
  }

  Future<void> _processStaticData(String path, Uri uri) async {
    http.Response response = await httpGet(
        uri,
        headers: {
          "accept": "application/json",
        },
    );

    if(response.statusCode == HttpStatus.ok) {
      dynamic data = json.decode(response.body);
      try {
        String value = dynamic2String(data);
        
        for (_BoxData bd in _boxData) {
          for (RegExp r in bd.regExpStaticPaths) {
            if (r.hasMatch(path)) {
              if(bd.onStaticUpdate!=null) bd.onStaticUpdate!([Update(path, value)]);
            }
          }
        }
      } catch (e) {
        l.e('Error converting "$data" for "$path"', error: e);
      }
    }
  }

  void _getStaticData(Set<String> staticPaths) {
    Uri uri = httpApiUri;
    if(uri.host.isEmpty) return; // We're not connected.
    try {
      List<String> basePathSegments = [...uri.pathSegments]
        ..removeLast()
        ..addAll(['vessels', 'self']);

      for(String path in staticPaths) {
        List<String> pathSegments = [...basePathSegments, ...path.split('.')];

        uri = uri.replace(pathSegments: pathSegments);

        _processStaticData(path, uri);
      }
    } catch (e) {
      l.e('Failed to retrieve static path', error: e);
    }
  }

  Uri _pathUri(String path) {
    Uri uri = httpApiUri;

    List<String> basePathSegments = [...uri.pathSegments]
      ..removeLast()
      ..addAll(['vessels', 'self']);

    List<String> pathSegments = [...basePathSegments, ...path.split('.')];

    return uri.replace(pathSegments: pathSegments);
  }

  Future<double> getPathDouble(String path) async {
    Uri uri = _pathUri(path);

    http.Response response = await httpGet(
      uri,
      headers: {
        "accept": "application/json",
      },
    );

    if(response.statusCode != HttpStatus.ok) throw Exception('Failed to retrieve double for $path');

    return (json.decode(response.body)['value'] as num).toDouble();
  }

  void _setTime(String timeStr) async {
    try {
      var r = await Process.run('/usr/bin/sudo', ['/usr/bin/date', '--utc', '--set', timeStr]);

      if(r.exitCode == 0) {
        l.i('Time set to "$timeStr" UTC');
      } else {
        l.e('Failed to set time to "$timeStr", exit code ${r.exitCode} output "${r.stdout}" error "${r.stderr}"');
      }
    } catch (e) {
      l.e('Exception trying to set time to "$timeStr"', error: e);
    }

    _timeSet = true;
  }

  Future<void> showSettingsPage (BuildContext context, BoxWidget boxWidget) async {
    BoxSettingsWidget boxSettingsWidget =  boxWidget.getSettingsWidget(getBoxSettingsJson(boxWidget.id))!;

    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
          return _BoxSettingsPage(
              boxSettingsWidget,
              boxWidget.getSettingsHelp()
          );
        })
    );

    _settings?.boxSettings[boxWidget.id] = boxSettingsWidget.getSettingsJson();
  }

}
