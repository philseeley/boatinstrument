import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:latlong_formatter/latlong_formatter.dart';

class PositionBox extends BoxWidget {
  final BoatInstrumentController _controller;

  const PositionBox(this._controller, {super.key});

  @override
  State<PositionBox> createState() => _PositionBoxState();

  static String sid = 'position';
  @override
  String get id => sid;
}

class _PositionBoxState extends State<PositionBox> {
  LatLongFormatter llf = LatLongFormatter('0{lat0d 0m.mmm c}\n{lon0d 0m.mmm c}');
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    widget._controller.configure(widget, onUpdate: _processData, paths: {'navigation.position'});
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('Position', style: widget._controller.headTS),
      Text((_latitude == null && _longitude == null) ?
        '--- --.--- -\n--- --.--- -' :
        llf.format(LatLong(_latitude!, _longitude!)), style: widget._controller.infoTS)
    ]);
  }

  _processData(List<Update> updates) {
    try {
      _latitude = updates[0].value['latitude'];
      _longitude = updates[0].value['longitude'];
    } catch (e) {
      widget._controller.l.e("Error converting $updates", error: e);
    }

    if(mounted) {
      setState(() {});
    }
  }
}
