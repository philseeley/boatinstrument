import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sailingapp/sailingapp_controller.dart';
import 'package:sailingapp/signalk.dart';
import 'package:slide_to_act/slide_to_act.dart';

class AutoPilotControl extends StatefulWidget {
  final SailingAppController controller;

  const AutoPilotControl(this.controller, {super.key});

  @override
  State<AutoPilotControl> createState() => _AutoPilotControlState();
}

class _AutoPilotControlState extends State<AutoPilotControl> {

  bool _locked = true;
  Timer? _lockTimer;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.controller.configure(widget, null, {});
  }

  _sendCommand(String path, String params) async {
    _error = null;

    if(widget.controller.settings.enableLock) {
      _unlock();
    }

    Uri uri = Uri.http(
        widget.controller.settings.signalkServer, '/signalk/v1/api/vessels/self/$path');

    http.Response response = await http.put(
        uri,
        headers: {
          "Content-Type": "application/json",
          "accept": "application/json",
          "Authorization": "Bearer ${widget.controller.settings.authToken}"
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

    _lockTimer =  Timer(Duration(seconds: widget.controller.settings.lockSeconds), () {
      setState(() {
        _locked = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Row> controlButtons = [];
    bool disabled = widget.controller.settings.enableLock && _locked;

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

    List<Widget> buttons = [Column(children: controlButtons)];
    if(widget.controller.settings.enableLock && _locked) {
      buttons.add(Center(child: Padding(padding: const EdgeInsets.all(20),child: SlideAction(
        text: "Unlock",
        outerColor: Colors.black,
        // animationDuration: const Duration(milliseconds: 0),
        onSubmit: () { return _unlock();},
      ))));
    }

    return Column(children: [
      Stack(alignment: Alignment.center, children:  buttons),
      Text(_error??'', style: widget.controller.headTS.apply(color: Colors.red))
    ]);
  }
}
