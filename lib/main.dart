import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';

void main() {
  runApp(const NavApp());
}

class NavApp extends StatelessWidget {

  const NavApp({super.key});

  @override
  Widget build(BuildContext context) {
    //TODO find better fonts. LCD?

    ThemeData themeData = ThemeData(colorScheme: const ColorScheme.highContrastDark(), fontFamily: 'Red Hat Mono');

    TextStyle headTS = themeData.textTheme.titleMedium!.copyWith(fontSize: 20);
    TextStyle infoTS = themeData.textTheme.bodyLarge!.copyWith(fontSize: 40);

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
      return const Center(child: Text('Initialising')); //TODO splash screen
    }

    controller?.clear();

    //TODO Fullscreen.
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: _movePage,
        onVerticalDragEnd: _showSnackBar,
        child: controller?.buildPage(_pageNum),
      ),
    ); //DragGestureRecognizer
  }

  showSettingsPage () async {
     Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return SettingsPage(controller!);
    }));

    // controller?.save();
    //
    // setState(() {});
  }

  void _movePage (DragEndDetails details) {
    if(details.primaryVelocity != 0.0) {
      setState(() {
        if (details.primaryVelocity! < 0.0) {
          _pageNum = controller!.prevPageNum(_pageNum);
        } else {
          _pageNum = controller!.nextPageNum(_pageNum);
        }
      });
    }
  }

  void _showSnackBar (DragEndDetails details) {
    if(details.primaryVelocity != 0.0 && details.primaryVelocity! < 0.0) {
      setState(() {
        //TODO Would prefer a top bar.
        SnackBar snackBar = SnackBar(
          content: Text(controller!.pageName(_pageNum)),
          action: SnackBarAction(label: 'Settings >', onPressed: showSettingsPage),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar!);
      });
    }
  }
}
