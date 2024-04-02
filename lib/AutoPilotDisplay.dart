import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nav/autopilot.dart';
import 'package:nav/settings.dart';

const rad2Deg = 57.29578;

class AutoPilotDisplay extends StatefulWidget {
  final Settings settings;
  final AutoPilot autoPilot = AutoPilot();

  AutoPilotDisplay(this.settings, {super.key});

  @override
  State<AutoPilotDisplay> createState() => _AutoPilotDisplayState();
}

class _AutoPilotDisplayState extends State<AutoPilotDisplay> {
  Timer? _dataTimer;

  _AutoPilotDisplayState () {
    _startDataTimer();
  }

  @override
  void dispose() {
    _dataTimer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    AutoPilot ap = widget.autoPilot;

    List<Widget> pilot = [
      Text(style: Theme.of(context).textTheme.titleLarge, "Pilot"),
      Text(ap.state.displayName),
    ];

    switch(ap.state) {
      case AutoPilotState.standby:
        break;
      case AutoPilotState.auto:
        pilot.add(Text("Heading: ${ap.heading}"));
        break;
      case AutoPilotState.track:
        pilot.add(Text("Waypoint: ${ap.waypoint}"));
        break;
      case AutoPilotState.vane:
        pilot.add(Text("Wind Angle: ${ap.vaneAngle.abs()} ${ap.vaneAngle < 0 ? 'P' : 'S'}"));
        break;
    }

    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: pilot),
      Column(children: [
        Text(style: Theme.of(context).textTheme.titleLarge, "Actual"),
        Text("COG: ${ap.cog}"),
        Text("Apparent Wind Angle: ${ap.apparentWindAngle.abs()} ${ap.apparentWindAngle < 0 ? 'P' : 'S'}"),
      ],)
    ]);
  }

  void _startDataTimer () {
    _dataTimer = Timer(const Duration(seconds: 5), _getAutoPilotState);
  }

  dynamic _getData (String path) async {
    Uri uri = Uri.http(
        widget.settings.signalkServer, '/signalk/v1/api/vessels/self/$path');

    http.Response response = await http.get(
      uri,
      headers: {
        "accept": "application/json",
        "Content-Type": "application/json"
      },
    );

    return json.decode(response.body);
  }

  void _getAutoPilotState () async {
    dynamic navigation = await _getData('navigation');
    dynamic autopilot = await _getData('steering/autopilot');
    dynamic wind = await _getData('environment/wind');

    if(mounted) {
      setState(() {
        widget.autoPilot.state = AutoPilotState.get(autopilot['state']['value']);
        widget.autoPilot.state = AutoPilotState.track;
        double d = (autopilot['target']['headingMagnetic']['value']+navigation['magneticVariation']['value'])*rad2Deg;
        widget.autoPilot.heading = d.toInt();
        d = autopilot['target']['windAngleApparent']?['value']*rad2Deg;
        widget.autoPilot.vaneAngle = d.toInt();
        widget.autoPilot.waypoint = navigation['currentRoute']['waypoints']['value'][1]['name'];

        d = navigation['courseOverGroundTrue']['value']*rad2Deg;
        widget.autoPilot.cog = d.toInt();
        d = wind['angleApparent']['value']*rad2Deg;
        widget.autoPilot.apparentWindAngle = d.toInt();
      });
    }

    _startDataTimer();
  }
}
