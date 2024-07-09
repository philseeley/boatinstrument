import 'dart:math';

import 'package:flutter/material.dart';

import 'double_value_box.dart';

enum GaugeOrientation {
  down(0, 0.0, -0.5, null, 0, 0, null, null, 0, null, 0),
  left(pi/2, 0.0, 0.0, 0, null, 0, null, null, 0, 0, null),
  up(pi, 0.0, 0.0, 0, null, 0, null, 0, null, null, 0),
  right(pi/2+pi, -0.5, 0.0, 0, null, null, 0, null, 0, null, 0);

  final double _rotation;
  final double _xm;
  final double _ym;
  final double? _titleTop;
  final double? _titleBottom;
  final double? _titleLeft;
  final double? _titleRight;
  final double? _unitsTop;
  final double? _unitsBottom;
  final double? _unitsLeft;
  final double? _unitsRight;

  const GaugeOrientation(this._rotation, this._xm, this._ym,
      this._titleTop, this._titleBottom, this._titleLeft, this._titleRight,
      this._unitsTop, this._unitsBottom, this._unitsLeft, this._unitsRight);
}

class _GaugePainter extends CustomPainter {
  final Color _color;
  final GaugeOrientation _orientation;

  _GaugePainter(this._color, this._orientation);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    double w = canvasSize.width;
    double h = canvasSize.height;

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = _color
      ..strokeWidth = 2.0;

    double base = w;
    if(_orientation == GaugeOrientation.left ||
       _orientation == GaugeOrientation.right) {
      base = h;
    }

    canvas.translate(base*_orientation._xm, base*_orientation._ym);
    canvas.translate(base/2, base/2);
    canvas.rotate(_orientation._rotation);
    canvas.translate(-base/2, -base/2);

    canvas.drawArc(Rect.fromLTWH(0, 0, base, base), 0.0, pi, true, paint);
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

    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = _color;

    double base = w;
    if(_orientation == GaugeOrientation.left ||
        _orientation == GaugeOrientation.right) {
      base = h;
    }

    Path needle = Path()
      ..moveTo(-10.0, 0.0)
      ..lineTo(0.0, base/2)
      ..lineTo(10.0, 0.0)
      ..moveTo(0.0, 0.0)
      ..addArc(const Offset(-10, -10.0) & const Size(20.0, 20.0), 0.0, -pi)
      ..close();

    canvas.translate(base*_orientation._xm, base*_orientation._ym);
    canvas.translate(base/2, base/2);
    canvas.rotate(_orientation._rotation);
    canvas.rotate(_angle);

    canvas.drawPath(needle, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

abstract class DoubleValueSemiGaugeBox extends DoubleValueBox {
  final GaugeOrientation orientation;
  final bool mirror;

  const DoubleValueSemiGaugeBox(super.config, super.title, this.orientation, super.path, {required super.minValue, required super.maxValue, this.mirror = false, super.angle, super.key});

  @override
  DoubleValueBoxState<DoubleValueSemiGaugeBox> createState() => _DoubleValueSemiGaugeBoxState();
}

class _DoubleValueSemiGaugeBoxState extends DoubleValueBoxState<DoubleValueSemiGaugeBox> {

  @override
  Widget build(BuildContext context) {
    GaugeOrientation o = widget.orientation;

    List<Widget> stack = [
      Positioned(top: o._titleTop, bottom: o._titleBottom, left: o._titleLeft, right: o._titleRight, child: Text(widget.title)),
      Positioned(top: o._unitsTop, bottom: o._unitsBottom, left: o._unitsLeft, right: o._unitsRight, child: Text(widget.units(displayValue??0.0))),
      CustomPaint(
          size: Size.infinite,
          painter: _GaugePainter(Theme.of(context).colorScheme.onSurface, o)
      )
    ];

    if(displayValue != null) {
      double angle = (((pi)/(widget.maxValue! - widget.minValue!)) * (displayValue! - widget.minValue!)) - pi/2;
      if(widget.mirror) {
        angle = (pi*2)-angle;
      }
      stack.add(CustomPaint(
          size: Size.infinite,
          painter: _NeedlePainter(Theme.of(context).colorScheme.onSurface, o, angle)
      ));
    }

    return Container(padding: const EdgeInsets.all(5.0), child: Stack(children: stack));
  }
}
