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
    TextStyle headTS = Theme.of(context).textTheme.titleLarge!;
    TextStyle infoTS = Theme.of(context).textTheme.titleMedium!.apply(fontSizeDelta: 8);

    AutopilotState? state = _self.steering?.autopilot?.state?.value;

    List<Widget> pilot = [
      Text("Pilot", style: headTS),
      Text("State: ${state?.name ?? 'No State'}", style: infoTS),
    ];

    switch(state) {
      case null:
      case AutopilotState.standby:
        break;
      case AutopilotState.auto:
        if(_self.steering?.autopilot?.target?.headingMagnetic?.value != null &&
           _self.navigation?.magneticVariation?.value != null) {
          double headingTrue =_self.steering!.autopilot!.target!.headingMagnetic!.value + _self.navigation!.magneticVariation!.value;
          pilot.add(Text("HDG: ${rad2Deg(headingTrue)}", style: infoTS));
        }
        break;
      case AutopilotState.track:
        pilot.add(Text("WPT: ${_self.navigation?.currentRoute?.waypoints?.value.elementAtOrNull(1)?.name}", style: infoTS));
        break;
      case AutopilotState.wind:
        int targetWindAngleApparent = rad2Deg(_self.steering?.autopilot?.target?.windAngleApparent?.value);
        pilot.add(Text("AWA: ${targetWindAngleApparent.abs()} ${val2PS(targetWindAngleApparent)}", style: infoTS));
        break;
    }

    double? cogLatest = _self.navigation?.courseOverGroundTrue?.value;
    if(cogLatest != null) {
      _courseOverGround = smoothAngle(_courseOverGround ?? cogLatest, cogLatest,
          widget.settings.valueSmoothing);
    }

    int? windAngleApparent;
    double? windAngleApparentLatest = _self.environment?.wind?.angleApparent?.value;
    if(windAngleApparentLatest != null) {
      _windAngleApparent = smoothAngle(
          _windAngleApparent ?? windAngleApparentLatest,
          windAngleApparentLatest, widget.settings.valueSmoothing);

      windAngleApparent = rad2Deg(_windAngleApparent);
    }

    List<Widget> actual = [
      Text("Actual", style: headTS),
      Text("COG: ${_courseOverGround == null ? '' : rad2Deg(_courseOverGround)}", style: infoTS),
      Text("AWA: ${windAngleApparent == null ? '' : windAngleApparent.abs()} ${val2PS(windAngleApparent??0)}", style: infoTS),
    ];

    if((state??AutopilotState.standby) == AutopilotState.track) {
      double? xte = _self.navigation?.courseGreatCircle?.crossTrackError?.value;
      if(xte != null) {
        actual.add(Text("XTE: ${meters2NM(xte.abs())} ${val2PS(xte)}"));
      }
    }

    const rudderStr = '===================='; // 40 degrees
    double rudderAngle = _self.steering?.rudderAngle?.value??0;
    int rudderAngleLen = rad2Deg(rudderAngle.abs());
    rudderAngleLen = ((rudderAngleLen.toDouble()/40.0)*rudderStr.length).toInt();

    return Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: pilot),
          Column(children: actual)
        ]),
      Row(children: [
        Expanded(child: Text(rudderStr.substring(0, rudderAngle < 0 ? rudderAngleLen : 0), style: Theme.of(context).textTheme.titleMedium!.apply(color: Colors.red), textAlign: TextAlign.right)),
        Expanded(child: Text(rudderStr.substring(0, rudderAngle > 0 ? rudderAngleLen : 0), style: Theme.of(context).textTheme.titleMedium!.apply(color: Colors.green))),
      ]),
      Text(_error??'', style: Theme.of(context).textTheme.titleSmall!.apply(color: Colors.red))
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
