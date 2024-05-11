import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';

enum WindRoseType {
  normal,
  closeHaul,
  auto
}

class WindRoseCHBox extends WindRoseBox {
  const WindRoseCHBox(super._controller, {super.type = WindRoseType.closeHaul, super.key});

  static String sid = 'wind-rose-ch';
  @override
  String get id => sid;
}

class WindRoseBox extends BoxWidget {
  final BoatInstrumentController _controller;
  final WindRoseType _type;

  const WindRoseBox(this._controller, {type = WindRoseType.normal, super.key}) : _type = type;

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
  final Image _roseCH = const Image(image: AssetImage('assets/wind-rose-ch.png'));
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
    Image rose = _rose;
    double angleApparent = _windAngleApparent??0.0;
    double angleTrue = _windAngleTrue??0.0;

    switch(widget._type) {
      case WindRoseType.normal:
        break;
      case WindRoseType.closeHaul: //TODO this needs lots of work
        rose = _roseCH;
        angleApparent = (angleApparent < 0.524) ? angleApparent*0.524 : angleApparent;
        angleTrue = (angleTrue < 0.524) ? angleTrue*0.524 : angleTrue;
        break;
      case WindRoseType.auto:
        // TODO: Handle this case.
    }

    return Center(child: Stack(alignment: Alignment.center, children: [
      rose,
      Transform.rotate(angle: angleApparent, child: _apparentNeedle),
      Transform.rotate(angle: angleTrue, child: _trueNeedle)
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
