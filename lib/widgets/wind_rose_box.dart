import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';

 class WindRoseBox extends BoxWidget {
  final BoatInstrumentController _controller;

  const WindRoseBox(this._controller, {super.key});

  @override
  State<WindRoseBox> createState() => _WindRoseBoxState();

  static String sid = 'wind-rose';
  @override
  String get id => sid;
}

class _WindRoseBoxState extends State<WindRoseBox> {
  double? _windAngleApparent;
  double? _windAngleTrue;
  //TODO get/make proper images.
  final Image _rose = const Image(image: AssetImage('assets/wind-rose.png'));
  final Image _apparentNeedle = const Image(color: Colors.red, image: AssetImage('assets/wind-needle.png'));
  final Image _trueNeedle = const Image(color: Colors.yellow, image: AssetImage('assets/wind-needle.png'));

  @override
  void initState() {
    super.initState();
    widget._controller.configure(widget, onUpdate: _processData, paths: {
      'environment.wind.angleApparent',
      'environment.wind.angleTrueWater'
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Stack(alignment: Alignment.center, children: [
      _rose,
      Transform.rotate(angle: _windAngleApparent??0.0, child: _apparentNeedle),
      Transform.rotate(angle: _windAngleTrue??0.0, child: _trueNeedle)
    ]));
  }

  _processData(List<Update> updates) {
    for (Update u in updates) {
      try {
        switch (u.path) {
          case 'environment.wind.angleApparent':
            double latest = (u.value as num).toDouble();
            _windAngleApparent = averageAngle(
                _windAngleApparent ?? latest, latest,
                smooth: widget._controller.valueSmoothing);
            break;
          case 'environment.wind.angleTrueWater':
            double latest = (u.value as num).toDouble();
            _windAngleTrue = averageAngle(
                _windAngleTrue ?? latest, latest,
                smooth: widget._controller.valueSmoothing);
            break;
        }
      } catch (e) {
        widget._controller.l.e("Error converting $u", error: e);
      }

      if (mounted) {
        setState(() {});
      }
    }
  }
}
