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
  Vessel _self = Vessel();
  double? _courseOverGround;
  double? _windAngleApparent;
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
    AutopilotState? state = _self.steering?.autopilot?.state?.value;

    List<Widget> pilot = [
      Text(style: Theme.of(context).textTheme.titleLarge, "Pilot"),
      Text(state?.name ?? 'No State'),
    ];

    switch(state) {
      case null:
      case AutopilotState.standby:
        break;
      case AutopilotState.auto:
        pilot.add(Text("Heading: ${rad2Deg(_self.steering?.autopilot?.target?.headingMagnetic?.value)}"));
        break;
      case AutopilotState.track:
        pilot.add(Text("Waypoint: ${_self.navigation?.currentRoute?.waypoints?.value.elementAtOrNull(1)?.name}"));
        break;
      case AutopilotState.vane:
        int targetWindAngleApparent = rad2Deg(_self.steering?.autopilot?.target?.windAngleApparent?.value);
        pilot.add(Text("Wind Angle: ${targetWindAngleApparent.abs()} ${targetWindAngleApparent < 0 ? 'P' : 'S'}"));
        break;
    }

    double cogLatest = _self.navigation?.courseOverGroundTrue?.value??0;
    _courseOverGround = smoothAngle(_courseOverGround??cogLatest, cogLatest, widget.settings.valueSmoothing);

    double windAngleApparentLatest = _self.environment?.wind?.angleApparent?.value??0;
    _windAngleApparent = smoothAngle(_windAngleApparent??windAngleApparentLatest, windAngleApparentLatest, widget.settings.valueSmoothing);

    int windAngleApparent = rad2Deg(_windAngleApparent);

    return Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: pilot),
          Column(children: [
            Text(style: Theme.of(context).textTheme.titleLarge, "Actual"),
            Text("COG: ${rad2Deg(_courseOverGround)}"),
            Text("Apparent Wind Angle: ${windAngleApparent.abs()} ${windAngleApparent < 0 ? 'P' : 'S'}"),
          ],)
        ]),
      Text(_error??'')
    ]);
  }

  void _startDataTimer () {
    _dataTimer = Timer(const Duration(seconds: 1), _getAutoPilotState);
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
          _self = Vessel.fromJson(data);
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to get data: $e';
      });
    }

    _startDataTimer();
  }
}
