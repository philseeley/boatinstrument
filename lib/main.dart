import 'dart:async';
import 'dart:io';
import 'dart:math' as m;

import 'package:actions_menu_appbar/actions_menu_appbar.dart';
import 'package:args/args.dart';
import 'package:boatinstrument/log_display.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'theme_provider.dart';

class BiDesktopKeyboardLayout extends DesktopKeyboardLayout {
  final MediaQuery _media;

  BiDesktopKeyboardLayout(this._media);

  @override
  double get aspectRatio {return _media.data.size.aspectRatio*2;}
}

void main(List<String> cmdlineArgs) {
  FlutterError.onError = logError;

  List<String> args = (Platform.environment['BOAT_INSTRUMENT_ARGS']??'').split(RegExp(r'\s+')) + cmdlineArgs;

  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(ChangeNotifierProvider(create: (context) => ThemeProvider(), child: BoatInstrumentApp(args)));
}

void logError(FlutterErrorDetails details) async {
  FlutterError.dumpErrorToConsole(details);
  String errorStr = '${details.exceptionAsString()}\n${details.stack}';
  CircularLogger().e(errorStr);
  Directory directory = await path_provider.getApplicationDocumentsDirectory();
  File('${directory.path}/boatinstrument-error.log').writeAsStringSync(
    '${DateTime.now()}\n$errorStr\n',
    mode: FileMode.append,
    flush: true);
}

class BoatInstrumentApp extends StatelessWidget {
  final List<String> args;

  const BoatInstrumentApp(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    const noAudio = 'no-audio';
    const noBrightnessCtrl = 'no-brightness-ctrl';
    const noKeepAwake = 'no-keep-awake';
    const noFullScreen = 'no-full-screen';
    const readOnly = 'read-only';
    const enableExit = 'enable-exit';
    const enableSetTime = 'enable-set-time';
    const enableKeyboard = 'enable-keyboard';
    const configFile = 'config-file';

    final p = ArgParser()
                ..addFlag(noAudio, negatable: false)
                ..addFlag(noBrightnessCtrl, negatable: false)
                ..addFlag(noKeepAwake, negatable: false)
                ..addFlag(noFullScreen, negatable: false)
                ..addFlag(readOnly, negatable: false)
                ..addFlag(enableExit, negatable: false)
                ..addFlag(enableSetTime, negatable: false)
                ..addFlag(enableKeyboard, negatable: false)
                ..addOption(configFile,
                    defaultsTo: 'boatinstrument.json',
                    valueHelp: 'filename',
                    help: 'If the <filename> does not start with a "/", it is appended to the default directory');

    try {
      ArgResults r = p.parse(args);
      if(r.rest.length > 1) {
        throw const FormatException('Too many command line arguments given.');
      }

      return MaterialApp(
        builder: (context, child) {
          var mq = MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!);
          return OnscreenKeyboard(
            layout: BiDesktopKeyboardLayout(mq),
            child: mq
          );},
        home: MainPage(
          r.flag(noAudio),
          r.flag(noBrightnessCtrl),
          r.flag(noKeepAwake),
          r.flag(noFullScreen),
          r.flag(readOnly),
          r.flag(enableExit),
          r.flag(enableSetTime),
          r.flag(enableKeyboard),
          r.option(configFile)!),
        theme:  Provider.of<ThemeProvider>(context).themeData
      );
    } catch (e) {
      debugPrint(e.toString());
      debugPrint('Usage: boatinstrument ${p.usage}');
      exit(1);
    } 
  }
}

class MainPage extends StatefulWidget {
  final bool noAudio;
  final bool noBrightnessControl;
  final bool noKeepAwake;
  final bool noFullScreen;
  final bool readOnly;
  final bool enableExit;
  final bool enableSetTime;
  final String configFile;

  MainPage(
    this.noAudio,
    this.noBrightnessControl,
    this.noKeepAwake,
    this.noFullScreen,
    this.readOnly,
    this.enableExit,
    this.enableSetTime,
    bool enableKeyboard,
    this.configFile,
    {super.key}) {
      enableEmbeddedKeyboard = enableKeyboard;
    }

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  static const Image _icon = Image(image: AssetImage('assets/icon.png'));

  late final ThemeProvider _themeProvider;

  bool _showAppBar = false;
  Offset _panStart = Offset.zero;
  bool fullScreen = (Platform.isIOS || Platform.isAndroid) ? true : false;

  late final BoatInstrumentController _controller;

  @override
  void initState() {
    super.initState();

    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _controller = BoatInstrumentController(this, widget.noAudio, widget.noBrightnessControl, widget.enableExit, widget.enableSetTime);
  }

  Future<void> _configure () async {
    if(!widget.noFullScreen) await FullScreen.ensureInitialized();
    if(mounted) await _controller.loadSettings(widget.configFile, MediaQuery.of(context).orientation == Orientation.portrait);
    await _controller.connect();

    _themeProvider.setDarkMode(_controller.darkMode);

    _controller.stepBrightness(init: true);
    
    if(_controller.pageTimerOnStart) {
      _controller.toggleRotatePages();
    }

    rebuild();
  }

  void rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if(!_controller.ready) {
      _configure();
      return const Center(child: _icon);
    }

    if(!widget.noKeepAwake) {
      WakelockPlus.toggle(enable: _controller.keepAwake);
    }

    ActionsMenuAppBar? appBar;
    if(_showAppBar) {
      appBar = ActionsMenuAppBar(
        actionsPercent: 0.5,
        context: context,
        leading: BackButton(onPressed: () {setState(() {_showAppBar = false;});}),
        title: Text(_controller.pageName()),
        actions: [
          if(!widget.noFullScreen) IconButton(tooltip: '${fullScreen ? 'Exit ':''}Full Screen', icon: Icon(fullScreen ? Icons.fullscreen_exit : Icons.fullscreen), onPressed: _toggleFullScreen),
          if(_controller.muted) IconButton(tooltip: 'Unmute', icon: const Icon(Icons.volume_off), onPressed: _unmute),
          IconButton(tooltip: 'Night Mode', icon: const Icon(Icons.mode_night), onPressed:  nightMode),
          IconButton(tooltip: 'Auto Rotate Pages', icon: _controller.arePagesRotating ? const Icon(Icons.sync_alt) : const Stack(children: [Icon(Icons.sync_alt), Icon(Icons.close)]), onPressed:  _controller.toggleRotatePages),
          if(_controller.brightnessControl) IconButton(tooltip: 'Brightness', icon: Icon(_controller.brightnessIcon), onPressed: _controller.stepBrightness),
          if(_controller.notifications.isNotEmpty) IconButton(tooltip: 'Notifications', icon: Icon(Icons.format_list_bulleted), onPressed: _showNotifications),
          if(!widget.readOnly) IconButton(tooltip: 'Edit Pages', icon: const Icon(Icons.web), onPressed: _showEditPagesPage),
          if(widget.readOnly) IconButton(tooltip: 'Log', icon: const Icon(Icons.notes),onPressed: () {LogDisplay.show(context);})
        ]
      );
    }

    return Scaffold(
      appBar: appBar,
      body: SafeArea(child: GestureDetector(
        onPanStart: (details) {
          _panStart = details.localPosition;
        },
        onPanEnd: (details) {
          Offset diff = details.localPosition - _panStart;
          double max = m.max(diff.dx.abs(), diff.dy.abs());
          if(max < 100) {
            return;
          }
          if(diff.dx.abs() > diff.dy.abs()) {
            _movePage(diff.dx);
          } else {
            _displayAppBar(diff.dy);
          }
        },
        child: _controller.buildPage(),
      )),
    );
  }

  void nightMode({bool? on}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if(on == null) {
      themeProvider.toggleNightMode(_controller.darkMode);
    } else {
      themeProvider.setNightMode(_controller.darkMode, on);
    }
  }

  void _unmute() {
    setState(() {
      _controller.unmute();
    });
  }
  
  void _toggleFullScreen() {
    setState(() {
      fullScreen = !fullScreen;
      FullScreen.setFullScreen(fullScreen);
    });
  }

  void _showNotifications () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return NotificationLogDisplay(_controller.notifications);
    }));

    setState(() {
      _showAppBar = false;
    });
  }

  Future<void> _showEditPagesPage () async {
    _controller.stopPageTimer();

    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return EditPagesPage(_controller);
    }));

    _controller.save();

    _controller.connect();

    setState(() {
      _showAppBar = false;
    });

    _controller.startPageTimer();
  }

  void _movePage (double direction) {
    _controller.startPageTimer();

    if (direction > 0.0) {
      _controller.prevPage();
    } else {
      _controller.nextPage();
    }
  }

  void _displayAppBar (double direction) async {
    _controller.startPageTimer();

    bool showAppBar = false;
    if(direction > 0.0) {
      showAppBar = true;
    }

    if(_showAppBar != showAppBar) {
      setState(() {
        _showAppBar = showAppBar;
      });
    }
  }
}
