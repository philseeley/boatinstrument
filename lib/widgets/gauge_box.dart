import 'dart:math';

import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';

enum GaugeOrientation {
  down(0, 0.0, -0.5, null, 0, 0, null),
  left(pi/2, 0.0, 0.0, 0, null, 0, null),
  up(pi, 0.0, 0.0, 0, null, 0, null),
  right(pi/2+pi, -0.5, 0.0, 0, null, null, 0);

  final double _rotation;
  final double _xm;
  final double _ym;
  final double? _top;
  final double? _bottom;
  final double? _left;
  final double? _right;

  const GaugeOrientation(this._rotation, this._xm, this._ym, this._top, this._bottom, this._left, this._right);
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

abstract class DoubleValueSemiGaugeBox extends BoxWidget {
  final String title;
  final GaugeOrientation orientation;
  final bool mirror;
  final String path;
  final double minValue;
  final double maxValue;
  final bool angle;
  late final double Function(Update update)? extractValue;

  //ignore: prefer_const_constructors_in_immutables
  DoubleValueSemiGaugeBox(super.config, this.title, this.orientation, this.path, this.minValue, this.maxValue, {this.mirror = false, this.angle = false, super.key});

  @override
  State<DoubleValueSemiGaugeBox> createState() => _DoubleValueSemiGaugeBoxState();
}

class _DoubleValueSemiGaugeBoxState extends State<DoubleValueSemiGaugeBox> {
  double? _value;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(widget, onUpdate: _processData, paths: {widget.path});
  }

  @override
  Widget build(BuildContext context) {
    GaugeOrientation o = widget.orientation;

    List<Widget> stack = [
      Positioned(top: o._top, bottom: o._bottom, left: o._left, right: o._right, child: Text(widget.title)),
      CustomPaint(
          size: Size.infinite,
          painter: _GaugePainter(Theme.of(context).colorScheme.onSurface, o)
      )
    ];

    if(_value != null) {
      double angle = (((pi)/(widget.maxValue - widget.minValue)) * (_value! - widget.minValue)) - pi/2;
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

  _processData(List<Update>? updates) {
    if(updates == null) {
      _value = null;
    } else {
      try {
        double next;
        if(widget.extractValue != null) {
          next = widget.extractValue!(updates[0]);
        } else {
          next = (updates[0].value as num).toDouble();
        }

        if (next < widget.minValue ||
            next > widget.maxValue) {
          _value = null;
        } else {
          if (widget.angle) {
            _value = averageAngle(_value ?? next, next,
                smooth: widget.config.controller.valueSmoothing);
          } else {
            _value = averageDouble(_value ?? next, next,
                smooth: widget.config.controller.valueSmoothing);
          }
        }
      } catch (e) {
        widget.config.controller.l.e("Error converting $updates", error: e);
      }
    }

    if(mounted) {
      setState(() {});
    }
  }
}

class TestGauge extends DoubleValueSemiGaugeBox {
  TestGauge(config, {super.key}) : super(config, 'test', GaugeOrientation.left, 'environment.wind.speedApparent', 0, 10);

  static String sid = 'test-gauge';
  @override
  String get id => sid;
}
