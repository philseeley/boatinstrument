import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'settings.dart';

class SettingsPage extends StatefulWidget {
  final Settings settings;

  const SettingsPage(this.settings, {Key? key}) : super(key: key);

  @override
  createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  Timer? _authRequestTimer;
  String? _authRequestHREF;

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
    Uri uri = Uri.http(
        widget.settings.signalkServer, '/signalk/v1/access/requests');

    http.Response response = await http.post(
        uri,
        headers: {
          "accept": "application/json",
        },
        body: {
          "clientId": "${widget.settings.clientID}",
          "description": "Sailing App"}
    );

    dynamic data = json.decode(response.body);
    _authRequestHREF = data['href'];

    setState(() {
      widget.settings.authToken = 'PENDING';
    });

    _checkAuhRequest();
  }

  void _checkAuhRequest () {
    _authRequestTimer =  Timer(const Duration(seconds: 5), _checkAuthRequestResponse);
  }

  void _checkAuthRequestResponse() async {
    String? result;

    Uri uri = Uri.http(
        widget.settings.signalkServer, _authRequestHREF!);

    http.Response response = await http.get(
      uri,
      headers: {
        "accept": "application/json",
        "Content-Type": "application/json"
      },
    );

    dynamic data = json.decode(response.body);

    if(data['state'] == 'COMPLETED') {
      if(data['statusCode'] == 200) {
        if(data['accessRequest']['permission'] == 'APPROVED') {
          setState(() {
            widget.settings.authToken = data['accessRequest']['token'];
          });
        } else {
          result = 'Failed: permission ${data['accessRequest']['permission']}';
        }
      } else {
        result = 'Failed: code ${data['statusCode']}';
      }

      if(result != null) {
        if (mounted) {
          setState(() {
            widget.settings.authToken = result!;
          });
        }
      }
    } else {
      _checkAuhRequest();
    }
  }
}
