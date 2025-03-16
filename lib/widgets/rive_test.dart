import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:rive/rive.dart';

class RiveTestBox extends BoxWidget {

  const RiveTestBox(super.config, {super.key});

  @override
  State<RiveTestBox> createState() => _RiveTestState();

  static String sid = 'rive-test';
  @override
  String get id => sid;

}

class _RiveTestState extends State<RiveTestBox> {

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure();
  }

  @override
  Widget build(BuildContext context) {
    return RiveAnimation.asset(
          'assets/off_road_car.riv',
          fit: BoxFit.scaleDown,
        );
  }
}
