import 'package:flutter/material.dart';
import 'package:sailingapp/sailingapp_controller.dart';
import 'package:sailingapp/widgets/auto_pilot_display.dart';
import 'package:sailingapp/widgets/auto_pilot_control.dart';
import 'package:sailingapp/settings.dart';
import 'package:sailingapp/settings_page.dart';

void main() {
  runApp(const NavApp());
}

class NavApp extends StatelessWidget {
  const NavApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    TextStyle? tsMedium = Theme.of(context).textTheme.titleMedium!.apply(fontWeightDelta: 4);
    TextStyle? tsLarge = Theme.of(context).textTheme.titleLarge!.apply(fontWeightDelta: 4).apply(fontSizeDelta: 8);

    return MaterialApp(
      home: const MainPage(),
      theme: ThemeData(textTheme: TextTheme(titleLarge: tsLarge, titleMedium: tsMedium, bodyMedium: tsMedium))
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  SailingAppController? sailingAppController;
  Settings? settings;
  late AutoPilotDisplay d;
  late AutoPilotControl c;


  _MainPageState() {
    loadSettings();
  }

  loadSettings() async {
    settings = await Settings.load();

    sailingAppController = SailingAppController(settings!);
    await sailingAppController?.connect();

    d = AutoPilotDisplay(sailingAppController!, settings!);
    sailingAppController?.addWidget(d);

    c = AutoPilotControl(sailingAppController!, settings!);
    sailingAppController?.addWidget(c);

    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state)
    {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        settings?.save();

        break;
      case AppLifecycleState.resumed:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if(sailingAppController == null) {
      return const Center();
    }

    // sailingAppController?.clear();

    // AutoPilotDisplay d = AutoPilotDisplay(sailingAppController!, settings!);
    // sailingAppController?.addWidget(d);
    //
    // AutoPilotControl c = AutoPilotControl(sailingAppController!, settings!);
    // sailingAppController?.addWidget(c);

    return Scaffold(
        appBar: AppBar(
          title: const Text("Auto Pilot"),
          actions: [IconButton(onPressed: () {
            showSettingsPage();
          }, icon: const Icon(Icons.settings))
          ],
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              d,
              c
            ],
          ),
        )
    );
  }

  showSettingsPage () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return SettingsPage(settings!);
    }));

    settings?.save();

    setState(() {});
  }
}
