import 'dart:math';

import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:flutter/material.dart';

import 'double_value_box.dart';

class GuageRange {
  final double min;
  final double max;
  final Color color;

  const GuageRange(this.min, this.max, this.color);
}

abstract class DoubleValueGaugeBox extends DoubleValueBox {
  final double step;
  final List<GuageRange> ranges;

  const DoubleValueGaugeBox(super.config, super.title, super.path,
    {super.minValue = 0, required super.maxValue, super.angle,
    this.step = 1, this.ranges = const [],
    super.key});

  @override
  DoubleValueGaugeBoxState createState() => DoubleValueGaugeBoxState();
}

class DoubleValueGaugeBoxState<T extends DoubleValueGaugeBox> extends DoubleValueBoxState<T> {
  int _minDisplay = 0;
  int _maxDisplay = 0;
  int _displayStep = 0;
  final List<GuageRange> _displayRanges = [];

  @override
  void initState() {
    super.initState();
    _minDisplay = widget.convert(widget.minValue!).ceil();
    _maxDisplay = widget.convert(widget.maxValue!).floor();
    double steps = (widget.maxValue! - widget.minValue!)/widget.step;
     _displayStep = ((_maxDisplay - _minDisplay)/steps).round();
    for(GuageRange r in widget.ranges) {
      _displayRanges.add(GuageRange(widget.convert(r.min), widget.convert(r.max), r.color));
    }
  }
}

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
  final int _minValue;
  final int _maxValue;
  final int _step;
  final List<GuageRange> _ranges;

  _SemiGaugePainter(this._context, this._orientation, this._mirror, this._minValue, this._maxValue, this._step, this._ranges);

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

    paint.strokeWidth = 5;
    int range = _maxValue - _minValue;

    for(GuageRange r in _ranges) {
      paint.color = r.color;
      double start = pi*((r.min - _minValue)/range);
      double end = (pi*((r.max - _minValue)/range)) - start;
      canvas.drawArc(Rect.fromLTWH(0, 0, base, base), start, end, false, paint);
    }

    canvas.restore();

    TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    try {
      canvas.translate((base / 2) + base*_orientation._xm, (base / 2) + base*_orientation._ym);

      double steps = range / _step;
      double angleStep = pi/steps;

      for (int i = 0; i <= steps; ++i) {
        String label = (_minValue + (_step*i)).toInt().toString();

        tp.text = TextSpan(
            text: label,
            style: theme.textTheme.bodyMedium?.copyWith(backgroundColor: theme.colorScheme.surface));
        tp.layout();

        double angle = (_mirror ? pi - angleStep*i : angleStep*i) + _orientation._rotation;
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

abstract class DoubleValueSemiGaugeBox extends DoubleValueGaugeBox {
  final GaugeOrientation orientation;
  final bool mirror;

  const DoubleValueSemiGaugeBox(super.config, super.title, this.orientation, super.path,
    {super.minValue = 0, required super.maxValue, super.step, super.angle, super.ranges,
    this.mirror = false, super.key});

  @override
  DoubleValueSemiGaugeBoxState createState() => DoubleValueSemiGaugeBoxState();
}

class DoubleValueSemiGaugeBoxState<T extends DoubleValueSemiGaugeBox> extends DoubleValueGaugeBoxState<T> {

  @override
  Widget build(BuildContext context) {
    GaugeOrientation o = widget.orientation;

    List<Widget> stack = [
      Positioned(top: o._titleTop, bottom: o._titleBottom, left: o._titleLeft, right: o._titleRight, child: Text(widget.title)),
      Positioned(top: o._unitsTop, bottom: o._unitsBottom, left: o._unitsLeft, right: o._unitsRight, child: Text(widget.units(displayValue??0.0))),
      CustomPaint(
          size: Size.infinite,
          painter: _SemiGaugePainter(context, o, widget.mirror, _minDisplay, _maxDisplay, _displayStep, _displayRanges)
      )
    ];

    if(value != null) {
      double angle = ((pi/(widget.maxValue! - widget.minValue!)) * (value! - widget.minValue!)) - pi/2;
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

// This is the number of degrees that the circular gauge starts at from dead south.
final double circularGaugeOffset = deg2Rad(20);

class _CircularGaugePainter extends CustomPainter {
  final BuildContext _context;
  final double _minValue;
  final int _minDisplay;
  final int _maxDisplay;
  final int _displayStep;

  _CircularGaugePainter(this._context, this._minValue, this._minDisplay, this._maxDisplay, this._displayStep);

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
      const double width = 0.02;

      double steps = (_maxDisplay - _minValue) / _displayStep;
      double angleStep = (2*pi-(circularGaugeOffset*2))/steps;
      double convertOffset = (_minDisplay - _minValue) * angleStep;

      for (int i = 0; i <= steps; ++i) {

        canvas.drawArc(
            const Offset(10.0, 10.0) & Size(size - 20.0, size - 20.0),
            (i*angleStep) + (pi / 2) + circularGaugeOffset + convertOffset - (width / 2), width, false, paint);

        tp.text = TextSpan(
            text: (i*_displayStep+_minDisplay).toString(),
            style: Theme
                .of(_context)
                .textTheme
                .bodyMedium);
        tp.layout();

        double x = cos((i*angleStep) + (pi / 2) + circularGaugeOffset + convertOffset) * (size / 2 - 40.0);
        double y = sin((i*angleStep) + (pi / 2) + circularGaugeOffset + convertOffset) * (size / 2 - 40.0);

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

abstract class DoubleValueCircularGaugeBox extends DoubleValueGaugeBox {

  const DoubleValueCircularGaugeBox(super.config, super.title, super.path,
    {super.minValue = 0, required super.maxValue, required super.step,
    super.ranges, super.key});

  @override
  DoubleValueCircularGaugeBoxState createState() => DoubleValueCircularGaugeBoxState();
}

class DoubleValueCircularGaugeBoxState<T extends DoubleValueCircularGaugeBox> extends DoubleValueGaugeBoxState<T> {
  @override
  Widget build(BuildContext context) {

    List<Widget> stack = [
      Positioned(top: 0, left: 0, child: Text(widget.title)),
      Positioned(top: 0, right: 0, child: Text(widget.units(displayValue??0.0))),
      CustomPaint(
          size: Size.infinite,
          painter: _CircularGaugePainter(context, widget.convert(widget.minValue!), _minDisplay, _maxDisplay, _displayStep)
      )
    ];

    if(displayValue != null) {
      double steps = widget.maxValue! - widget.minValue!;
      double angleStep = (2*pi-(circularGaugeOffset*2))/steps;

      double angle = angleStep * (value! - widget.minValue!);

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
  final int _minValue;
  final int _maxValue;
  final int _step;
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
      canvas.drawRect(Rect.fromLTRB(35, h-(step*(_value-_minValue)), w, h), paint);
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

abstract class DoubleValueBarGaugeBox extends DoubleValueGaugeBox {

  const DoubleValueBarGaugeBox(super.config, super.title, super.path,
    {super.minValue = 0, required super.maxValue, required super.step,
    super.ranges, super.key});

  @override
  DoubleValueBarGaugeBoxState createState() => DoubleValueBarGaugeBoxState();
}

class DoubleValueBarGaugeBoxState<T extends DoubleValueBarGaugeBox> extends DoubleValueGaugeBoxState<T> {
  @override
  Widget build(BuildContext context) {
    const double pad = 5.0;
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Row(children: [Padding(padding: const EdgeInsets.all(pad), child: Text(widget.title, style: Theme.of(context).textTheme.titleMedium))]),
      Expanded(child: Padding(padding: const EdgeInsets.all(pad),
        child: RepaintBoundary(child: CustomPaint(
          size: Size.infinite,
          painter: _BarGaugePainter(context, _minDisplay, _maxDisplay, _displayStep, displayValue)
      )))),
      Row(children: [Padding(padding: const EdgeInsets.all(pad), child: Text(widget.units(value??0), style: Theme.of(context).textTheme.titleMedium))]),
    ]);
  }
}
