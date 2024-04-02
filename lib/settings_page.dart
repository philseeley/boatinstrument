import 'dart:io';

import 'package:flutter/material.dart';
import 'settings.dart';

class SettingsPage extends StatefulWidget {
  final Settings settings;

  const SettingsPage(this.settings, {Key? key}) : super(key: key);

  @override
  createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    Settings settings = widget.settings;

    List<Widget> list = [
      SwitchListTile(title: const Text("Enable Control Lock"),
          value: settings.enableLock,
          onChanged: (bool value) {
            setState(() {
              settings.enableLock = value;
            });
          }),
      ListTile(
          leading: const Text("Lock Timeout(seconds)"),
        title: Slider(
            min: 2.0,
            max: 20.0,
            divisions: 18,
            value: settings.lockSeconds.toDouble(),
            label: "${settings.lockSeconds.toInt()}s",
            onChanged: (double value) {
              setState(() {
                settings.lockSeconds = value.toInt();
              });
            }),
      ),
      ListTile(
          leading: const Text("Auth Token"),
          title: TextFormField(
              initialValue: settings.authToken,
              onChanged: (value) => settings.authToken = value)
      )
      ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actions: [
        ],
      ),
      body: ListView(children: list)
    );
  }
}
