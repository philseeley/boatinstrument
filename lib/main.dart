import 'package:flutter/material.dart';
import 'package:nav/AutoPilotDisplay.dart';
import 'package:nav/AutoPilotControl.dart';
import 'package:nav/settings.dart';
import 'package:nav/settings_page.dart';

import 'autopilot.dart';

void main() {
  runApp(const NavApp());
}

class NavApp extends StatelessWidget {
  const NavApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  Settings? settings;
  AutoPilot autoPilot = AutoPilot();

  _MainPageState() {
    loadSettings();
  }

  loadSettings() async {
    settings = await Settings.load();

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
    if(settings == null) {
      return const Center();
    }

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
              AutoPilotDisplay(autoPilot),
              AutoPilotControl(settings!)
              ,
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
