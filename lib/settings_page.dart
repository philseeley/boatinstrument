import 'package:flutter/material.dart';
import 'package:sailingapp/authorization.dart';
import 'settings.dart';

class SettingsPage extends StatefulWidget {
  final Settings settings;

  const SettingsPage(this.settings, {super.key});

  @override
  createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    Settings settings = widget.settings;

    List<Widget> list = [
      ListTile(
        leading: const Text("Value Smoothing:"),
        title: Slider(
            min: 0,
            max: 20,
            divisions: 21,
            value: settings.valueSmoothing.toDouble(),
            label: "${settings.valueSmoothing.toInt()}",
            onChanged: (double value) {
              setState(() {
                settings.valueSmoothing = value.toInt();
              });
            }),
      ),
      ListTile(
              leading: const Text("Signalk Server:"),
              title: TextFormField(
                  initialValue: settings.signalkServer,
                  onChanged: (value) => settings.signalkServer = value)
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(children: list)
    );
  }
}
