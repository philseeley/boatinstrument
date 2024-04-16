import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sailingapp/settings.dart';
import 'package:sailingapp/signalk.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class AutoPilotDisplay extends StatefulWidget {
  final Settings settings;

  const AutoPilotDisplay(this.settings, {super.key});

  @override
  State<AutoPilotDisplay> createState() => _AutoPilotDisplayState();
}

class _AutoPilotDisplayState extends State<AutoPilotDisplay> {
  WebSocketChannel? _channel;
  AutopilotState? _autopilotState;
  double? _courseOverGroundTrue;
  double? _targetWindAngleApparent;
  double? _windAngleApparent;
  double? _targetHeadingMagnetic;
  double? _magneticVariation;
  String? _waypoint;
  double? _crossTrackError;
  double? _rudderAngle;
  String? _error;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle headTS = Theme.of(context).textTheme.titleLarge!;
    TextStyle infoTS = Theme.of(context).textTheme.titleMedium!.apply(fontSizeDelta: 8);

    List<Widget> pilot = [
      Text("Pilot", style: headTS),
      Text("State: ${_autopilotState?.displayName ?? 'No State'}", style: infoTS),
    ];

    switch(_autopilotState) {
      case null:
      case AutopilotState.standby:
        break;
      case AutopilotState.auto:
        if(_targetHeadingMagnetic != null &&
           _magneticVariation != null) {
          double headingTrue = _targetHeadingMagnetic! + _magneticVariation!;
          pilot.add(Text("HDG: ${rad2Deg(headingTrue)}", style: infoTS));
        }
        break;
      case AutopilotState.track:
        pilot.add(Text("WPT: $_waypoint", style: infoTS));
        break;
      case AutopilotState.wind:
        int targetWindAngleApparent = rad2Deg(_targetWindAngleApparent);
        pilot.add(Text("AWA: ${targetWindAngleApparent.abs()} ${val2PS(targetWindAngleApparent)}", style: infoTS));
        break;
    }

    List<Widget> actual = [
      Text("Actual", style: headTS),
      Text("COG: ${_courseOverGroundTrue == null ? '' : rad2Deg(_courseOverGroundTrue)}", style: infoTS),
      Text("AWA: ${_windAngleApparent == null ? '' : rad2Deg(_windAngleApparent!.abs())} ${val2PS(_windAngleApparent??0)}", style: infoTS),
    ];

    if((_autopilotState??AutopilotState.standby) == AutopilotState.track) {
      if(_crossTrackError != null) {
        actual.add(Text("XTE: ${meters2NM(_crossTrackError!.abs())} ${val2PS(_crossTrackError!)}"));
      }
    }

    const rudderStr = '===================='; // 40 degrees
    double rudderAngle = _rudderAngle??0;
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

  void _connect() async {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://${widget.settings.signalkServer}/signalk/v1/stream?subscribe=none'),
    );

    await _channel?.ready;

    _channel?.stream.listen(_processData);

    _channel?.sink.add(
      jsonEncode(
        {
          "context": "vessels.self",
          "subscribe": [
            {
              "path": "steering.autopilot.state",
            },
            {
              "path": "navigation.courseOverGroundTrue",
            },
            {
              "path": "steering.autopilot.target.windAngleApparent",
            },
            {
              "path": "environment.wind.angleApparent",
            },
            {
              "path": "navigation.currentRoute.waypoints",
            },
            {
              "path": "navigation.courseGreatCircle.crossTrackError",
            },
            {
              "path": "steering.autopilot.target.headingMagnetic",
            },
            {
              "path": "navigation.magneticVariation",
            },
            {
              "path": "steering.rudderAngle",
            },
            {
              "path": "notifications.autopilot.*",
            },
          ]
        },
      ),
    );
  }

  _processData(data) {
    dynamic d = json.decode(data);

    if(d['updates'] != null) {
      for (dynamic u in d['updates']) {
        for (dynamic v in u['values']) {
          try {
            switch (v['path']) {
              case 'steering.autopilot.state':
                _autopilotState = AutopilotState.values.byName(v['value']);
                break;
              case 'navigation.courseOverGroundTrue':
                // The '* 1.0' forces the result to be a double as sometimes the value is 0 and therefore an int.
                double cogLatest = v['value'] * 1.0;
                _courseOverGroundTrue = averageAngle(
                    _courseOverGroundTrue ?? cogLatest, cogLatest,
                    smooth: widget.settings.valueSmoothing);
                break;
              case 'steering.autopilot.target.windAngleApparent':
                _targetWindAngleApparent = v['value'] * 1.0;
                break;
              case 'environment.wind.angleApparent':
                double waa = v['value'] * 1.0;
                _windAngleApparent = averageAngle(
                    _windAngleApparent ?? waa, waa,
                    smooth: widget.settings.valueSmoothing, relative: true);
                break;
              case 'navigation.currentRoute.waypoints':
                break;
              case 'navigation.courseGreatCircle.crossTrackError':
                _crossTrackError = v['value'] * 1.0;
                break;
              case 'steering.autopilot.target.headingMagnetic':
                _targetHeadingMagnetic = v['value'] * 1.0;
                break;
              case 'navigation.magneticVariation':
                _magneticVariation = v['value'] * 1.0;
                break;
              case 'steering.rudderAngle':
                _rudderAngle = v['value'] * 1.0;
                break;
              case 'notifications.autopilot.*':
              //TODO
                break;
            }
          } catch (e) {
            print(v);
            print(e);
          }
        }
      }
    }

    setState(() {});
  }
}
