import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'theme_provider.dart';

void main() {
  runApp(ChangeNotifierProvider(create: (context) => ThemeProvider(), child: const NavApp()));
}

class NavApp extends StatelessWidget {

  const NavApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    return MaterialApp(
      home: const MainPage(),
      theme:  Provider.of<ThemeProvider>(context).themeData
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const Image _icon = Image(image: AssetImage('assets/icon.png'));

  late final ThemeProvider _themeProvider;
  static const _brightnessStep = 4;
  static const _brightnessMax = 12;
  static final Map<int, IconData> _brightnessIcons = {
    12: Icons.brightness_high,
    8: Icons.brightness_medium,
    4: Icons.brightness_low,
    1: Icons.brightness_4_outlined,
    0: Icons.brightness_4_outlined
  };

  bool _showAppBar = false;
  int _brightness = _brightnessMax;
  bool _rotatePages = false;
  Timer? _pageTimer;

  final BoatInstrumentController _controller = BoatInstrumentController();
  int _pageNum = 0;

  @override
  void initState() {
    super.initState();
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _configure();
  }

  _configure () async {
    await _controller.loadSettings();
    await _controller.connect();

    _themeProvider.setDarkMode(_controller.darkMode);

    if(_controller.brightnessControl) {
      // Convert the current system brightness into the closest step, rounding up.
      // Note: We add the step as well as _setBrightness() will remove it.
      _brightness = (await ScreenBrightness().system * _brightnessMax).ceil();
      _brightness =
          _brightness - (_brightness % _brightnessStep) + (_brightnessStep * 2);
      _setBrightness();
    }

    if(_controller.pageTimerOnStart) {
      _togglePageTimer();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if(!_controller.ready) {
      return const Center(child: _icon);
    }

    WakelockPlus.toggle(enable: _controller.keepAwake);

    _controller.clear();

    List<Widget> actions = [
      IconButton(icon: const Icon(Icons.mode_night),onPressed:  _nightMode),
      IconButton(icon: Icon(_rotatePages ? Icons.timer_outlined : Icons.timer_off_outlined), onPressed:  _togglePageTimer),
    ];

    if(_controller.brightnessControl) {
      actions.add(IconButton(icon: Icon(_brightnessIcons[_brightness]), onPressed: _setBrightness));
    }

    actions.add(IconButton(icon: const Icon(Icons.web), onPressed: _showEditPagesPage));

    AppBar? appBar;
    if(_showAppBar) {
      appBar = AppBar(
        leading: BackButton(onPressed: () {setState(() {_showAppBar = false;});}),
        title: Text(_controller.pageName(_pageNum)),
        actions: actions);
    }

    return Scaffold(
      appBar: appBar,
      body: GestureDetector(
        onHorizontalDragEnd: _movePage,
        onVerticalDragEnd: _displayAppBar,
        onHorizontalDragStart: (details) {
          print('onHorizontalDragStart with $details');
        },
        onHorizontalDragUpdate: (details) {
          print('onHorizontalDragUpdate with $details');
        },
        onHorizontalDragCancel: () {
          print('onHorizontalDragCancel');
        },
        onHorizontalDragDown: (details) {
          print('onHorizontalDragDown with $details');
        },
        onVerticalDragStart: (details) {
          print('onVerticalDragStart with $details');
        },
        onVerticalDragUpdate: (details) {
          print('onVerticalDragUpdate with $details');
        },
        onVerticalDragCancel: () {
          print('onVerticalDragCancel');
        },
        onVerticalDragDown: (details) {
          print('onVerticalDragDown with $details');
        },
        child: _controller.buildPage(_pageNum),
      ),
    ); //DragGestureRecognizer
  }

  void _setBrightness() {
    setState(() {
      _brightness = ((_brightness < _brightnessStep) || (_brightness > _brightnessMax)) ? _brightnessMax : _brightness - _brightnessStep;
      if(Platform.isMacOS && _brightness == 0) {
        _brightness = 1;
      }
    });

    ScreenBrightness().setScreenBrightness(_brightness/_brightnessMax);
  }

  void _nightMode() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleNightMode(_controller.darkMode);
  }

  void _togglePageTimer() {
    setState(() {
      _rotatePages = !_rotatePages;
    });

    _startPageTimer();
  }

  void _startPageTimer() {
    _stopPageTimer();
    if(_rotatePages) {
      _pageTimer = Timer(Duration(seconds: _controller.pageChangeSeconds), _rotatePage);
    }
  }

  void _stopPageTimer() {
    _pageTimer?.cancel();
    _pageTimer = null;
  }

  _rotatePage() {
    setState(() {
      _pageNum = _controller.nextPageNum(_pageNum, alwaysRotate: true);
    });

    _startPageTimer();
  }

  _showEditPagesPage () async {
    _stopPageTimer();

    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return EditPagesPage(_controller);
    }));

    _controller.save();

    setState(() {
      _showAppBar = false;
      if(_pageNum >= _controller.numOfPages) {
        _pageNum = _controller.numOfPages-1;
      }
    });

    _startPageTimer();
  }

  void _movePage (DragEndDetails details) {
    print('_movePage called with $details');
    _startPageTimer();

    if(details.primaryVelocity != 0.0) {
      int newPage = 0;
      if (details.primaryVelocity! > 0.0) {
        newPage = _controller.prevPageNum(_pageNum);
      } else {
        newPage = _controller.nextPageNum(_pageNum);
      }
      if(newPage != _pageNum) {
        setState(() {
          _pageNum = newPage;
        });
      }
    }
  }

  void _displayAppBar (DragEndDetails details) async {
    print('_displayAppBar called with $details');

    _startPageTimer();

    if(details.primaryVelocity != null) {
      bool showAppBar = false;
      if(details.primaryVelocity! > 0.0) {
        showAppBar = true;
      }

      if(_showAppBar != showAppBar) {
        setState(() {
          _showAppBar = showAppBar;
        });
      }
    }
  }
}
