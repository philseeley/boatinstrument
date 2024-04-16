import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sailingapp/settings.dart';

class AutoPilotControl extends StatefulWidget {
  final Settings settings;

  const AutoPilotControl(this.settings, {super.key});

  @override
  State<AutoPilotControl> createState() => _AutoPilotControlState();
}

class _AutoPilotControlState extends State<AutoPilotControl> {

  bool _locked = true;
  Timer? _lockTimer;

  void _control(int direction) {
    if(widget.settings.enableLock) {
      _unlock();
    }

    print("change direction by $direction");
  }

  void _unlock() {
    if(_locked) {
      setState(() {
        _locked = false;
      });
    }

    _lockTimer?.cancel();

    _lockTimer =  Timer(Duration(seconds: widget.settings.lockSeconds), () {
      setState(() {
        _locked = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Row> controlButtons = [];

    for(int i in [1, 5, 10]) {
      controlButtons.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(iconSize: 48, onPressed: widget.settings.enableLock && _locked ? null : () {_control(-i);}, icon: const Icon(Icons.chevron_left)),
          Text("$i", style: Theme.of(context).textTheme.titleLarge),
          IconButton(iconSize: 48, onPressed: widget.settings.enableLock && _locked ? null : () {_control(i);}, icon: const Icon(Icons.chevron_right)),
        ]
      ));
    }

    List<Widget> buttons = [Column(children: controlButtons)];
    if(widget.settings.enableLock && _locked) {
      buttons.add(Center(child: IconButton(iconSize: 48, onPressed: _unlock, icon: const Icon(Icons.lock))));
    }
    return Stack(alignment: Alignment.center, children:  buttons);
  }
}
