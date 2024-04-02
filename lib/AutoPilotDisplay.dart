import 'package:flutter/material.dart';
import 'package:nav/autopilot.dart';

class AutoPilotDisplay extends StatefulWidget {
  AutoPilot autoPilot;

  AutoPilotDisplay(this.autoPilot, {super.key});

  @override
  State<AutoPilotDisplay> createState() => _AutoPilotDisplayState();
}

class _AutoPilotDisplayState extends State<AutoPilotDisplay> {

  @override
  Widget build(BuildContext context) {
    AutoPilot ap = widget.autoPilot;

    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        const Text("Pilot"),
        Text(ap.status.name),
        Text("Vane: ${ap.vaneAngle}"),
        Text("Heading: ${ap.heading}"),
        Text("Waypoint: ${ap.goto}"),
      ],),
      Column(children: [
        const Text("Actual"),
        Text("COG: ${ap.cog}"),
        Text("Apparent Wind Angle: ${ap.apparentWindAngle}"),
      ],)
    ]);
  }
}
