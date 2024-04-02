import 'package:flutter/material.dart';
import 'package:nav/autopilot.dart';

class AutoPilotDisplay extends StatefulWidget {
  final AutoPilot autoPilot;

  const AutoPilotDisplay(this.autoPilot, {super.key});

  @override
  State<AutoPilotDisplay> createState() => _AutoPilotDisplayState();
}

class _AutoPilotDisplayState extends State<AutoPilotDisplay> {

  @override
  Widget build(BuildContext context) {
    AutoPilot ap = widget.autoPilot;

    List<Widget> pilot = [
      Text(style: Theme.of(context).textTheme.titleLarge, "Pilot"),
      Text(ap.status.name),
    ];

    switch(ap.status) {
      case AutoPilotState.off:
        break;
      case AutoPilotState.auto:
        pilot.add(Text("Heading: ${ap.heading}"));
        break;
      case AutoPilotState.track:
        pilot.add(Text("Waypoint: ${ap.waypoint}"));
        break;
      case AutoPilotState.vane:
        pilot.add(Text("Wind Angle: ${ap.vaneAngle}"));
        break;
    }

    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: pilot),
      Column(children: [
        Text(style: Theme.of(context).textTheme.titleLarge, "Actual"),
        Text("COG: ${ap.cog}"),
        Text("Apparent Wind Angle: ${ap.apparentWindAngle}"),
      ],)
    ]);
  }
}
