import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:slide_to_act/slide_to_act.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sailingapp/sailingapp_controller.dart';
import 'package:sailingapp/signalk.dart';

import '../authorization.dart';

part 'auto_pilot_control.g.dart';

@JsonSerializable()
class _Settings {
  bool enableLock;
  int lockSeconds;
  String clientID;
  String authToken;

  _Settings({
    this.enableLock = true,
    this.lockSeconds = 3,
    this.clientID = 'sailingapp-autopilot-1234',
    this.authToken = ''
  });
}

class AutoPilotControl extends StatefulWidget {
  final SailingAppController controller;

  const AutoPilotControl(this.controller, {super.key});

  @override
  State<AutoPilotControl> createState() => _AutoPilotControlState();
}

class _AutoPilotControlState extends State<AutoPilotControl> {
  _Settings _settings = _Settings();
  bool _locked = true;
  Timer? _lockTimer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _settings = _$SettingsFromJson(widget.controller.configure((AutoPilotControl).toString(), widget, null, {}));
  }

  _sendCommand(String path, String params) async {
    _error = null;

    if(_settings.enableLock) {
      _unlock();
    }

    Uri uri = Uri.http(
        widget.controller.settings.signalkServer, '/signalk/v1/api/vessels/self/$path');

    http.Response response = await http.put(
        uri,
        headers: {
          "Content-Type": "application/json",
          "accept": "application/json",
          "Authorization": "Bearer ${_settings.authToken}"
        },
        body: params
    );

    setState(() {
      _error = response.reasonPhrase;
    });
  }

  _adjustHeading(int direction) async {
    await _sendCommand("steering/autopilot/actions/adjustHeading", '{"value": $direction}');
  }

  _setState(String state) async {
    await _sendCommand("steering/autopilot/state", '{"value": "$state"}');
  }

  _unlock() {
    if(_locked) {
      setState(() {
        _locked = false;
      });
    }

    _lockTimer?.cancel();

    _lockTimer =  Timer(Duration(seconds: _settings.lockSeconds), () {
      setState(() {
        _locked = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Row> controlButtons = [];
    bool disabled = _settings.enableLock && _locked;

    for(int i in [1, 10]) {
      controlButtons.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(iconSize: 48, onPressed: disabled ? null : () {_adjustHeading(-i);}, icon: const Icon(Icons.chevron_left)),
          Text("$i", style: Theme.of(context).textTheme.titleLarge),
          IconButton(iconSize: 48, onPressed: disabled ? null : () {_adjustHeading(i);}, icon: const Icon(Icons.chevron_right)),
        ]
      ));
    }

    List<Widget> stateButtons = [];
    for(AutopilotState state in AutopilotState.values) {
      stateButtons.add(ElevatedButton(
          onPressed: disabled ? null : () {_setState(state.name);},
          child: Text(state.displayName),
      ));
    }
    controlButtons.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: stateButtons));

    //TODO
    controlButtons.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      IconButton(onPressed: _showSettingsPage, icon: const Icon(Icons.settings))
    ]));

    List<Widget> buttons = [Column(children: controlButtons)];
    if(_settings.enableLock && _locked) {
      buttons.add(Center(child: Padding(padding: const EdgeInsets.all(20),child: SlideAction(
        text: "Unlock",
        outerColor: Colors.black,
        onSubmit: () { return _unlock();},
      ))));
    }

    return Column(children: [
      Stack(alignment: Alignment.center, children:  buttons),
      Text(_error??'', style: widget.controller.headTS.apply(color: Colors.red))
    ]);
  }

  _showSettingsPage () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return _SettingsPage(widget.controller, _settings);
    }));

    widget.controller.saveWidgetSettings((AutoPilotControl).toString(), _$SettingsToJson(_settings));

    setState(() {});
  }
}

class _SettingsPage extends StatefulWidget {
  final SailingAppController _controller;
  final _Settings _settings;

  const _SettingsPage(this._controller, this._settings, {super.key});

  @override
  createState() => _SettingsState();
}

class _SettingsState extends State<_SettingsPage> {

  @override
  Widget build(BuildContext context) {
    _Settings s = widget._settings;

    List<Widget> list = [
      SwitchListTile(title: const Text("Enable Control Lock:"),
          value: s.enableLock,
          onChanged: (bool value) {
            setState(() {
              s.enableLock = value;
            });
          }),
      ListTile(
        leading: const Text("Lock Timeout:"),
        title: Slider(
            min: 2.0,
            max: 20.0,
            divisions: 18,
            value: s.lockSeconds.toDouble(),
            label: "${s.lockSeconds.toInt()}s",
            onChanged: (double value) {
              setState(() {
                s.lockSeconds = value.toInt();
              });
            }),
      ),
      ListTile(
          leading: const Text("Request Auth Token:"),
          title: IconButton(onPressed: _requestAuthToken, icon: const Icon(Icons.login))
      ),
      ListTile(
          leading: const Text("Auth token:"),
          title: Text(s.authToken)
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
    SignalKAuthorization().request(widget._controller.settings.signalkServer, widget._settings.clientID, "Sailing App - Autopilot Control",
            (authToken) {
          setState(() {
            widget._settings.authToken = authToken;
          });
        },
            (msg) {
          if (mounted) {
            setState(() {
              widget._settings.authToken = msg;
            });
          }
        });

    setState(() {
      widget._settings.authToken = 'PENDING';
    });
  }
}
