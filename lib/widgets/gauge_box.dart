import 'dart:math';

import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';

enum GaugeOrientation {
  down(0, 0.0, -0.5),
  left(pi/2, 0.0, -1.0),
  up(pi, -1.0, -1.0),
  right(pi/2+pi, -1.0, -0.5);

  final double _rotation;
  final double _xm;
  final double _ym;

  const GaugeOrientation(this._rotation, this._xm, this._ym);
}

class _GaugePainter extends CustomPainter {
  final Color _color;
  final GaugeOrientation _orientation;

  _GaugePainter(this._color, this._orientation);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    double w = canvasSize.width;
    double h = canvasSize.height;

    if(_orientation == GaugeOrientation.left ||
       _orientation == GaugeOrientation.right) {
      double t = w;
      w = h;
      h = t;
    }

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = _color
      ..strokeWidth = 2.0;

    //TODO up and left need shifting.
    canvas.rotate(_orientation._rotation);
    canvas.translate(w*_orientation._xm, w*_orientation._ym);
    canvas.drawArc(Rect.fromLTWH(0, 0, w, w), 0.0, pi, true, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NeedlePainter extends CustomPainter {

  final Color _color;
  final GaugeOrientation _orientation;
  final double _angle;

  _NeedlePainter(this._color, this._orientation, this._angle);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    double w = canvasSize.width;
    double h = canvasSize.height;

    if(_orientation == GaugeOrientation.left ||
       _orientation == GaugeOrientation.right) {
      double t = w;
      w = h;
      h = t;
    }

    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = _color;

    Path needle = Path()
      ..moveTo(-10.0, 0.0)
      ..lineTo(0.0, w*_orientation._ym)
      ..lineTo(10.0, 0.0)
      ..moveTo(0.0, 0.0)
      ..addArc(const Offset(-10, -10.0) & const Size(20.0, 20.0), 0.0, pi)
      ..close();
    canvas.rotate(_orientation._rotation);
    canvas.translate(-w*_orientation._ym, 0.0);
    canvas.rotate(_angle+pi);
    canvas.drawPath(needle, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GaugeBox extends BoxWidget {
  final GaugeOrientation _orientation;

  const GaugeBox(super.config, this._orientation, {super.key});

  @override
  State<GaugeBox> createState() => _GaugeBoxState();

  static String sid = 'gauge';
  @override
  String get id => sid;

}

class _GaugeBoxState extends State<GaugeBox> {

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(widget);
  }

  @override
  Widget build(BuildContext context) {
    _GaugePainter gaugePainter = _GaugePainter(Theme.of(context).colorScheme.onSurface, widget._orientation);
    _NeedlePainter needlePainter = _NeedlePainter(Theme.of(context).colorScheme.onSurface, widget._orientation, 0.0);

    List<Widget> stack = [
      CustomPaint(size: Size.infinite, painter: gaugePainter),
      CustomPaint(size: Size.infinite, painter: needlePainter)
    ];

    return Container(padding: const EdgeInsets.all(5.0), child: Stack(children: stack));
  }
}
