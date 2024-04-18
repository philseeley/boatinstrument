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
      SwitchListTile(title: const Text("Enable Control Lock:"),
          value: settings.enableLock,
          onChanged: (bool value) {
            setState(() {
              settings.enableLock = value;
            });
          }),
      ListTile(
        leading: const Text("Lock Timeout:"),
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
      ListTile(
          leading: const Text("Request Auth Token:"),
          title: IconButton(onPressed: _requestAuthToken, icon: const Icon(Icons.login))
      ),
      ListTile(
          leading: const Text("Auth token:"),
          title: Text(settings.authToken)
      ),
      ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(children: list)
    );
  }

  void _requestAuthToken() async {
    SignalKAuthorization().request(widget.settings.signalkServer, widget.settings.clientID, "Sailing App",
      (authToken) {
        setState(() {
          widget.settings.authToken = authToken;
        });
      },
      (msg) {
        if (mounted) {
          setState(() {
            widget.settings.authToken = msg;
          });
        }
      });

    setState(() {
      widget.settings.authToken = 'PENDING';
    });
  }
}
