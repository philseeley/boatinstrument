import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nav/settings.dart';
import 'package:nav/signalk.dart';

class AutoPilotDisplay extends StatefulWidget {
  final Settings settings;

  const AutoPilotDisplay(this.settings, {super.key});

  @override
  State<AutoPilotDisplay> createState() => _AutoPilotDisplayState();
}

class _AutoPilotDisplayState extends State<AutoPilotDisplay> {
  Timer? _dataTimer;
  Vessel self = Vessel();
  String? _error;

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
    AutopilotState? state = self.steering?.autopilot?.state?.value;

    List<Widget> pilot = [
      Text(style: Theme.of(context).textTheme.titleLarge, "Pilot"),
      Text(state?.name ?? 'No State'),
    ];

    switch(state) {
      case null:
      case AutopilotState.standby:
        break;
      case AutopilotState.auto:
        pilot.add(Text("Heading: ${rad2Deg(self.steering?.autopilot?.target?.headingMagnetic?.value)}"));
        break;
      case AutopilotState.track:
        pilot.add(Text("Waypoint: ${self.navigation?.currentRoute?.waypoints?.value.elementAtOrNull(1)?.name}"));
        break;
      case AutopilotState.vane:
        int targetWindAngleApparent = rad2Deg(self.steering?.autopilot?.target?.windAngleApparent?.value);
        pilot.add(Text("Wind Angle: ${targetWindAngleApparent.abs()} ${targetWindAngleApparent < 0 ? 'P' : 'S'}"));
        break;
    }

    int windAngleApparent = rad2Deg(self.environment?.wind?.angleApparent?.value);

    return Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: pilot),
          Column(children: [
            Text(style: Theme.of(context).textTheme.titleLarge, "Actual"),
            Text("COG: ${rad2Deg(self.navigation?.courseOverGroundTrue?.value)}"),
            Text("Apparent Wind Angle: ${windAngleApparent.abs()} ${windAngleApparent < 0 ? 'P' : 'S'}"),
          ],)
        ]),
      Text(_error??'')
    ]);
  }

  void _startDataTimer () {
    _dataTimer = Timer(const Duration(seconds: 3), _getAutoPilotState);
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
    _error = null;

    try {
      dynamic data = await _getData('');

      if (mounted) {
        setState(() {
          self = Vessel.fromJson(data);
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to get data $e';
      });
    }

    _startDataTimer();
  }
}
