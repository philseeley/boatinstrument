import 'package:flutter/material.dart';
import 'package:sailingapp/log_display.dart';
import 'package:sailingapp/boatinstrument_controller.dart';

void main() {
  runApp(const NavApp());
}

class NavApp extends StatelessWidget {

  const NavApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextStyle headTS = Theme.of(context).textTheme.titleMedium!.apply(fontFamily: 'Red Hat Mono', color: Colors.white, fontWeightDelta: 4);
    TextStyle infoTS = Theme.of(context).textTheme.titleLarge!.apply(fontFamily: 'Red Hat Mono', color: Colors.white, fontSizeDelta: 20);
    TextStyle lineTS = Theme.of(context).textTheme.bodySmall!.apply(fontFamily: 'Red Hat Mono', color: Colors.white);

    return MaterialApp(
      home: MainPage(headTS, infoTS, lineTS),
      theme: ThemeData(textTheme: TextTheme(titleLarge: infoTS, titleMedium: headTS, bodyMedium: headTS, bodySmall: lineTS))
    );
  }
}

class MainPage extends StatefulWidget {
  final TextStyle _headTS;
  final TextStyle _infoTS;
  final TextStyle _lineTS;

  const MainPage(this._headTS, this._infoTS, this._lineTS, {super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  BoatInstrumentController? boatInstrumentController;
  int _pageNum = 0;

  @override
  void initState() {
    super.initState();
    _configure();
  }

  _configure () async {
    boatInstrumentController = BoatInstrumentController(widget._headTS, widget._infoTS, widget._lineTS);
    await boatInstrumentController?.loadSettings();
    await boatInstrumentController?.connect();

    setState(() {});
  }

  //TODO is this needed as we save when we close the settings dialog?
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state)
    {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        boatInstrumentController?.save();

        break;
      case AppLifecycleState.resumed:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if(boatInstrumentController == null || !boatInstrumentController!.ready) {
      return const Center(child: Text('Initialising')); //TODO splash screen
    }

    boatInstrumentController?.clear();

    return Scaffold(
        appBar: AppBar(
          title: Text(boatInstrumentController!.pageName(_pageNum), style: boatInstrumentController?.headTS) ,
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
      return SettingsPage(boatInstrumentController!);
    }));

    boatInstrumentController?.save();

    setState(() {});
  }

  showLog () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return LogDisplay(boatInstrumentController!);
    }));

    setState(() {});
  }

  _editPage () async {
    bool deleted = await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return EditPage(boatInstrumentController!, _pageNum);
    }));

    boatInstrumentController?.save();

    setState(() {
      if(deleted) {
        _pageNum = boatInstrumentController!.nextPageNum(_pageNum);
      }
    });
  }
}
