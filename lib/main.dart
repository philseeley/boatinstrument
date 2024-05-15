import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

//TODO check build for pi/ARM on Linux as cross compilation is not supported yet.
//TODO do we want different pages for landscape and portrait?
//TODO does HDMI carry sound?
void main() {
  runApp(const NavApp());
}

class NavApp extends StatelessWidget {

  const NavApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    //TODO find better fonts. LCD?
    ThemeData themeData = ThemeData(colorScheme: const ColorScheme.highContrastDark(), fontFamily: 'Red Hat Mono');

    TextStyle headTS = themeData.textTheme.titleMedium!.copyWith(height: 1.0, fontSize: 20);
    TextStyle infoTS = themeData.textTheme.bodyLarge!.copyWith(height: 1.0, fontSize: 40);

    return MaterialApp(
      home: MainPage(headTS, infoTS),
      //TODO light/dark/night mode.
      theme: themeData
    );
  }
}

class MainPage extends StatefulWidget {
  final TextStyle _headTS;
  final TextStyle _infoTS;

  const MainPage(this._headTS, this._infoTS, {super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const Image _icon = Image(image: AssetImage('assets/icon.png'));

  BoatInstrumentController? controller;
  int _pageNum = 0;

  @override
  void initState() {
    super.initState();
    _configure();
  }

  _configure () async {
    controller = BoatInstrumentController(widget._headTS, widget._infoTS);
    await controller?.loadSettings();
    await controller?.connect();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if(controller == null || !controller!.ready) {
      return const Center(child: _icon);
    }

    WakelockPlus.toggle(enable: controller!.keepAwake);

    controller?.clear();

    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: _movePage,
        onVerticalDragEnd: _showSnackBar,
        child: controller?.buildPage(_pageNum),
      ),
    ); //DragGestureRecognizer
  }

  showSettingsPage () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return SettingsPage(controller!);
    }));

    controller?.save();

    setState(() {
      if(_pageNum >= controller!.numOfPages) {
        _pageNum = controller!.numOfPages-1;
      }
    });
  }

  void _movePage (DragEndDetails details) {
    if(details.primaryVelocity != 0.0) {
      int newPage = 0;
      if (details.primaryVelocity! > 0.0) {
        newPage = controller!.prevPageNum(_pageNum);
      } else {
        newPage = controller!.nextPageNum(_pageNum);
      }
      if(newPage != _pageNum) {
        setState(() {
          _pageNum = newPage;
        });
      }
    }
  }

  void _showSnackBar (DragEndDetails details) {
    if(details.primaryVelocity != 0.0 && details.primaryVelocity! < 0.0) {
      //TODO Would prefer a top bar.
      SnackBar snackBar = SnackBar(
        content: Text(controller!.pageName(_pageNum)),
        action: SnackBarAction(label: 'Settings >', onPressed: showSettingsPage),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
