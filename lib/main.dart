import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:provider/provider.dart';
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
      //TODO light/dark/night mode.
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

  BoatInstrumentController? controller;
  int _pageNum = 0;

  @override
  void initState() {
    super.initState();
    _configure();
  }

  _configure () async {
    controller = BoatInstrumentController();
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
        
        SnackBar snackBar = SnackBar(
          content: Text(controller!.pageName(_pageNum)),
          duration: const Duration(milliseconds: 500),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
