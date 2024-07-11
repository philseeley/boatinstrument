import 'dart:math';

import 'package:boatinstrument/boatinstrument_controller.dart';
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

class _SemiGaugePainter extends CustomPainter {
  final BuildContext _context;
  final GaugeOrientation _orientation;
  final bool _mirror;
  final double _minValue;
  final double _maxValue;

  _SemiGaugePainter(this._context, this._orientation, this._mirror, this._minValue, this._maxValue);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    ThemeData theme = Theme.of(_context);
    double w = canvasSize.width;
    double h = canvasSize.height;

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = theme.colorScheme.onSurface
      ..strokeWidth = 2.0;

    double base = w;
    if(_orientation == GaugeOrientation.left ||
       _orientation == GaugeOrientation.right) {
      base = h;
    }

    canvas.save();
    canvas.translate(base*_orientation._xm, base*_orientation._ym);
    canvas.translate(base/2, base/2);
    canvas.rotate(_orientation._rotation);
    canvas.translate(-base/2, -base/2);

    canvas.drawArc(Rect.fromLTWH(0, 0, base, base), 0.0, pi, true, paint);
    canvas.restore();

    TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    try {
      canvas.translate((base / 2) + base*_orientation._xm, (base / 2) + base*_orientation._ym);

      double diff = (_maxValue - _minValue) / 4;
      for (int i = 0; i <= 4; ++i) {
        String label = (_minValue + (diff*i)).toInt().toString();

        tp.text = TextSpan(
            text: label,
            style: theme.textTheme.bodyMedium?.copyWith(backgroundColor: theme.colorScheme.surface));
        tp.layout();

        double angle = (_mirror ? pi - pi/4*i : pi/4*i) + _orientation._rotation;
        angle = i == 0 ? angle: angle;
        angle = i == 4 ? angle: angle;
        double x = cos(angle) * (base / 2 - 20.0);
        double y = sin(angle) * (base / 2 - 20.0);

        tp.paint(
            canvas, Offset(x - tp.size.width / 2, y - tp.size.height / 2));
      }
    } finally {
      tp.dispose();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SemiGaugeNeedlePainter extends CustomPainter {
  final GaugeOrientation _orientation;
  final double _angle;

  _SemiGaugeNeedlePainter(this._orientation, this._angle);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    double w = canvasSize.width;
    double h = canvasSize.height;

    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue;

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

  const DoubleValueSemiGaugeBox(super.config, super.title, this.orientation, super.path, {super.minValue = 0, required super.maxValue, this.mirror = false, super.angle, super.key});

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
          painter: _SemiGaugePainter(context, o, widget.mirror, widget.minValue!, widget.maxValue!)
      )
    ];

    if(displayValue != null) {
      double angle = ((pi/(widget.maxValue! - widget.minValue!)) * (displayValue! - widget.minValue!)) - pi/2;
      if(widget.mirror) {
        angle = (pi*2)-angle;
      }
      stack.add(CustomPaint(
          size: Size.infinite,
          painter: _SemiGaugeNeedlePainter(o, angle)
      ));
    }

    return Container(padding: const EdgeInsets.all(15.0), child: RepaintBoundary(child: Stack(children: stack)));
  }
}

final double circularGaugeOffset = deg2Rad(20);

class _CircularGaugePainter extends CustomPainter {
  final BuildContext _context;
  final double _minValue;
  final double _maxValue;
  final double _step;

  _CircularGaugePainter(this._context, this._minValue, this._maxValue, this._step);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    double size = min(canvasSize.width, canvasSize.height);

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Theme.of(_context).colorScheme.onSurface
      ..strokeWidth = 2.0;

    canvas.drawArc(Rect.fromLTWH(0, 0, size, size), pi/2+circularGaugeOffset, 2*pi-(circularGaugeOffset*2), false, paint);

    TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    try {
      paint.strokeWidth = 20.0;
      double width = 0.02;

      double steps = (_maxValue - _minValue) / _step;
      double angleStep = (2*pi-(circularGaugeOffset*2))/steps;

      for (double i = 0; i <= steps; ++i) {

        canvas.drawArc(
            const Offset(10.0, 10.0) & Size(size - 20.0, size - 20.0),
            (i*angleStep) + (pi / 2) + circularGaugeOffset - (width / 2), width, false, paint);

        tp.text = TextSpan(
            text: (i*_step).toInt().toString(),
            style: Theme
                .of(_context)
                .textTheme
                .bodyMedium);
        tp.layout();

        double x = cos((i*angleStep) + (pi / 2) + circularGaugeOffset) * (size / 2 - 40.0);
        double y = sin((i*angleStep) + (pi / 2) + circularGaugeOffset) * (size / 2 - 40.0);

        canvas.save();
        canvas.translate(size / 2, size / 2);
        tp.paint(
            canvas, Offset(x - tp.size.width / 2, y - tp.size.height / 2));
        canvas.restore();
      }
    } finally {
      tp.dispose();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CircularGaugeNeedlePainter extends CustomPainter {
  final double _angle;

  _CircularGaugeNeedlePainter(this._angle);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    double size = min(canvasSize.width, canvasSize.height);
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue;

    Path needle = Path()
      ..moveTo(-10.0, 0.0)
      ..lineTo(0.0, -size/2)
      ..lineTo(10.0, 0.0)
      ..moveTo(0.0, 0.0)
      ..addArc(const Offset(-10, -10.0) & const Size(20.0, 20.0), 0.0, pi)
      ..close();

    canvas.translate(size/2, size/2);
    canvas.rotate(pi+_angle+circularGaugeOffset);
    canvas.drawPath(needle, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

abstract class DoubleValueCircularGaugeBox extends DoubleValueBox {
  final double step;

  const DoubleValueCircularGaugeBox(super.config, super.title, super.path, {super.minValue = 0, required super.maxValue, required this.step, super.key});

  @override
  DoubleValueBoxState<DoubleValueCircularGaugeBox> createState() => _DoubleValueCircularGaugeBoxState();
}

class _DoubleValueCircularGaugeBoxState extends DoubleValueBoxState<DoubleValueCircularGaugeBox> {

  @override
  Widget build(BuildContext context) {

    List<Widget> stack = [
      Positioned(top: 0, left: 0, child: Text(widget.title)),
      Positioned(top: 0, right: 0, child: Text(widget.units(displayValue??0.0))),
      CustomPaint(
          size: Size.infinite,
          painter: _CircularGaugePainter(context, widget.minValue!, widget.maxValue!, widget.step)
      )
    ];

    if(displayValue != null) {
      double steps = widget.maxValue! - widget.minValue!;
      double angleStep = (2*pi-(circularGaugeOffset*2))/steps;

      double angle = angleStep * displayValue!;

      stack.add(CustomPaint(
          size: Size.infinite,
          painter: _CircularGaugeNeedlePainter(angle)
      ));
    }

    return Container(padding: const EdgeInsets.all(5.0), child: RepaintBoundary(child: Stack(children: stack)));
  }
}

class _BarGaugePainter extends CustomPainter {
  final BuildContext _context;
  final double _minValue;
  final double _maxValue;
  final double _step;
  final double? _value;

  _BarGaugePainter(this._context, this._minValue, this._maxValue, this._step, this._value);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    ThemeData theme = Theme.of(_context);
    double w = canvasSize.width;
    double h = canvasSize.height;

    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue;

    if(_value != null) {
      double step = h/(_maxValue - _minValue);
      canvas.drawRect(Rect.fromLTRB(35, h-(step*_value), w, h), paint);
    }

    paint.color = theme.colorScheme.onSurface;
    TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    try {
      double steps = (_maxValue - _minValue) / _step;
      double lineStep = h / steps;

      for (int i = 0; i <= steps; ++i) {
        canvas.drawRect(Rect.fromLTWH(0, h-(lineStep*i)-1, w, 2), paint);

        tp.text = TextSpan(
            text: (i*_step+_minValue).toInt().toString(),
            style: theme.textTheme.bodyMedium?.copyWith(backgroundColor: theme.colorScheme.surface));
        tp.layout();

        tp.paint(canvas, Offset(5, h-(i*lineStep)-(tp.size.height/2)));
      }
    } finally {
      tp.dispose();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

abstract class DoubleValueBarGaugeBox extends DoubleValueBox {
  final double step;

  const DoubleValueBarGaugeBox(super.config, super.title, super.path, {super.minValue = 0, required super.maxValue, required this.step, super.key});

  @override
  State<DoubleValueBarGaugeBox> createState() => _DoubleValueBarGaugeBoxState();
}

class _DoubleValueBarGaugeBoxState extends DoubleValueBoxState<DoubleValueBarGaugeBox> {
  @override
  Widget build(BuildContext context) {
    const double pad = 5.0;
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Row(children: [Padding(padding: const EdgeInsets.all(pad), child: Text(widget.title, style: Theme.of(context).textTheme.titleMedium))]),
      Expanded(child: Padding(padding: const EdgeInsets.all(pad),
        child: RepaintBoundary(child: CustomPaint(
          size: Size.infinite,
          painter: _BarGaugePainter(context, widget.minValue!, widget.maxValue!, widget.step, displayValue)
      )))),
      Row(children: [Padding(padding: const EdgeInsets.all(pad), child: Text(widget.units(value??0), style: Theme.of(context).textTheme.titleMedium))]),
    ]);
  }
}
