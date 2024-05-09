import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:boatinstrument/log_display.dart';
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
        //TODO have a AppBar/Drawer from the top/bottom that shows ontop when swiped down/up.
        appBar: AppBar(
          title: Text(controller!.pageName(_pageNum), style: controller?.headTS) ,
          actions: [
            IconButton(icon: const Icon(Icons.edit),
                onPressed: () {
                  _editPage();
                }),
            IconButton(icon: const Icon(Icons.settings),
                onPressed: () {
                  showSettingsPage();
                }),
            IconButton(icon: const Icon(Icons.notes),
                onPressed: () {
                  showLog();
                })
          ]
        ),
        body: boatInstrumentController?.buildPage(_pageNum),
    );
  }

  showSettingsPage () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return SettingsPage(controller!);
    }));

    controller?.save();

    setState(() {});
  }

  showLog () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return LogDisplay(controller!);
    }));

    setState(() {});
  }

  _editPage () async {
    bool deleted = await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return EditPage(controller!, _pageNum);
    }));

    controller?.save();

    setState(() {
      if(deleted) {
        _pageNum = controller!.nextPageNum(_pageNum);
      }
    });
  }
}
