import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'theme_provider.dart';

//TODO do we want different pages for landscape and portrait?
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

    // Convert the current system brightness into the closest step.
    // Note: We add the step as _setBrightness() will remove it.
    _brightness = (await ScreenBrightness().system * _brightnessMax).toInt();
    _brightness = _brightness - (_brightness % _brightnessStep) + _brightnessStep;
    _setBrightness();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if(!_controller.ready) {
      return const Center(child: _icon);
    }

    WakelockPlus.toggle(enable: _controller.keepAwake);

    _controller.clear();

    AppBar? appBar;
    if(_showAppBar) {
      appBar = AppBar(
        leading: BackButton(onPressed: () {setState(() {_showAppBar = false;});}),
        title: Text(_controller.pageName(_pageNum)),
        actions: [
          IconButton(icon: const Icon(Icons.mode_night),onPressed:  _nightMode),
          IconButton(icon: Icon(_brightnessIcons[_brightness]), onPressed:  _setBrightness),
          IconButton(icon: const Icon(Icons.web), onPressed: _showEditPagesPage),
        ]);
    }

    return Scaffold(
      appBar: appBar,
      body: GestureDetector(
        onHorizontalDragEnd: _movePage,
        onVerticalDragEnd: _displayAppBar,
        child: _controller.buildPage(_pageNum),
      ),
    ); //DragGestureRecognizer
  }

  void _setBrightness() {
    setState(() {
      _brightness = (_brightness < _brightnessStep) ? _brightnessMax : _brightness - _brightnessStep;
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

  _showEditPagesPage () async {
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
  }

  void _movePage (DragEndDetails details) {
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

        SnackBar snackBar = SnackBar(
          content: Text(_controller.pageName(_pageNum)),
          duration: const Duration(milliseconds: 500),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  void _displayAppBar (DragEndDetails details) async {
    if(details.primaryVelocity != null) {
      setState(() {
        if(details.primaryVelocity! > 0.0) {
          _showAppBar = true;
        } else {
          _showAppBar = false;
        }
      });
    }
  }
}
