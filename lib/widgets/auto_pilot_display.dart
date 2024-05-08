import 'package:flutter/material.dart';
import 'package:sailingapp/boatinstrument_controller.dart';
import 'package:sailingapp/signalk.dart';

class AutoPilotDisplay extends BoxWidget {
  static const String ID = 'autopilot-display';

  final BoatInstrumentController controller;

  const AutoPilotDisplay(this.controller, {super.key});

  @override
  State<AutoPilotDisplay> createState() => _AutoPilotDisplayState();

  @override
  String get id => ID;
}

class _AutoPilotDisplayState extends State<AutoPilotDisplay> {
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
    widget.controller.configure((AutoPilotDisplay).toString(), widget, _processData, {
      "steering.autopilot.state",
      "navigation.courseOverGroundTrue",
      "steering.autopilot.target.windAngleApparent",
      "environment.wind.angleApparent",
      "navigation.currentRoute.waypoints",
      "navigation.courseGreatCircle.crossTrackError",
      "steering.autopilot.target.headingMagnetic",
      "navigation.magneticVariation",
      "steering.rudderAngle",
    });
  }

  @override
  Widget build(BuildContext context) {
    BoatInstrumentController c = widget.controller;

    List<Widget> pilot = [
      Text("Pilot", style: c.infoTS),
      Text("State: ${_autopilotState?.displayName ?? 'No State'}", style: c.infoTS),
    ];

    switch(_autopilotState) {
      case null:
      case AutopilotState.standby:
        break;
      case AutopilotState.auto:
        if(_targetHeadingMagnetic != null &&
           _magneticVariation != null) {
          double headingTrue = _targetHeadingMagnetic! + _magneticVariation!;
          pilot.add(Text("HDG: ${rad2Deg(headingTrue)}", style: c.infoTS));
        }
        break;
      case AutopilotState.route:
        pilot.add(Text("WPT: $_waypoint", style: c.headTS));
        break;
      case AutopilotState.wind:
        int targetWindAngleApparent = rad2Deg(_targetWindAngleApparent);
        pilot.add(Text("AWA: ${targetWindAngleApparent.abs()} ${val2PS(targetWindAngleApparent)}", style: c.infoTS));
        break;
    }

    List<Widget> actual = [
      Text("Actual", style: c.infoTS),
      Text("COG: ${_courseOverGroundTrue == null ? '' : rad2Deg(_courseOverGroundTrue)}", style: c.infoTS),
      Text("AWA: ${_windAngleApparent == null ? '' : rad2Deg(_windAngleApparent!.abs())} ${val2PS(_windAngleApparent??0)}", style: c.infoTS),
    ];

    if((_autopilotState??AutopilotState.standby) == AutopilotState.route) {
      if(_crossTrackError != null) {
        actual.add(Text("XTE: ${meters2NM(_crossTrackError!.abs()).toStringAsFixed(2)} ${val2PS(_crossTrackError!)}"));
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
        Expanded(child: Text(rudderStr.substring(0, rudderAngle < 0 ? rudderAngleLen : 0), style: c.headTS.apply(color: Colors.red), textAlign: TextAlign.right)),
        Expanded(child: Text(rudderStr.substring(0, rudderAngle > 0 ? rudderAngleLen : 0), style: c.headTS.apply(color: Colors.green))),
      ]),
      Text(_error??'', style: c.headTS.apply(color: Colors.red))
    ]);
  }

  _processData(List<Update> updates) {
    for (Update u in updates) {
      try {
        switch (u.path) {
          case 'steering.autopilot.state':
            _autopilotState = AutopilotState.values.byName(u.value);
            break;
          case 'navigation.courseOverGroundTrue':
            double cogLatest = (u.value as num).toDouble();
            _courseOverGroundTrue = averageAngle(
                _courseOverGroundTrue ?? cogLatest, cogLatest,
                smooth: widget.controller.valueSmoothing);
            break;
          case 'steering.autopilot.target.windAngleApparent':
            _targetWindAngleApparent = (u.value as num).toDouble();
            break;
          case 'environment.wind.angleApparent':
            double waa = (u.value as num).toDouble();
            _windAngleApparent = averageAngle(
                _windAngleApparent ?? waa, waa,
                smooth: widget.controller.valueSmoothing, relative: true);
            break;
          case 'navigation.currentRoute.waypoints':
            _waypoint = u.value[1]['name'];
            break;
          case 'navigation.courseGreatCircle.crossTrackError':
            _crossTrackError = (u.value as num).toDouble();
            break;
          case 'steering.autopilot.target.headingMagnetic':
            _targetHeadingMagnetic = (u.value as num).toDouble();
            break;
          case 'navigation.magneticVariation':
            _magneticVariation = (u.value as num).toDouble();
            break;
          case 'steering.rudderAngle':
            _rudderAngle = (u.value as num).toDouble();
            break;
          case 'notifications.autopilot.*':
          //TODO
            break;
        }
      } catch (e) {
        widget.controller.l.e("Error converting $u", error: e);
      }
    }

    setState(() {});
  }
}
