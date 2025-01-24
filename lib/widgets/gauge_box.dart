import 'dart:async';
import 'dart:math';

import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:json_annotation/json_annotation.dart';
import 'package:format/format.dart' as fmt;

import 'double_value_box.dart';

part 'gauge_box.g.dart';

class GaugeRange {
  final double min;
  final double max;
  final Color color;

  const GaugeRange(this.min, this.max, this.color);
}

abstract class DoubleValueGaugeBox extends DoubleValueBox {
  final double step;
  final List<GaugeRange> ranges;

  const DoubleValueGaugeBox(super.config, super.title, super.path,
    {super.minValue = 0, required super.maxValue, super.angle, super.smoothing,
    this.step = 1, this.ranges = const [],
    super.key});

  @override
  DoubleValueGaugeBoxState createState() => DoubleValueGaugeBoxState();
}

const double _defaultMax = 100;

class DoubleValueGaugeBoxState<T extends DoubleValueGaugeBox> extends DoubleValueBoxState<T> {
  int minDisplay = 0;
  int maxDisplay = 0;
  int _displayStep = 0;
  final List<GaugeRange> _displayRanges = [];

  @override
  void initState() {
    super.initState();
    minDisplay = widget.convert(widget.minValue??0).ceil();
    maxDisplay = widget.convert(widget.maxValue??_defaultMax).floor();
    double steps = ((widget.maxValue??100) - (widget.minValue??0))/widget.step;
    _displayStep = ((maxDisplay - minDisplay)/steps).round();
    _displayStep = _displayStep < 1 ? 1 : _displayStep;
    for(GaugeRange r in widget.ranges) {
      _displayRanges.add(GaugeRange(widget.convert(r.min), widget.convert(r.max), r.color));
    }
  }
}

class _SemiGaugePainter extends CustomPainter {
  final BuildContext _context;
  final GaugeOrientation _orientation;
  final bool _mirror;
  final int _minValue;
  final int _maxValue;
  final int _step;
  final List<GaugeRange> _ranges;

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
    canvas.translate(base*_orientation.xm, base*_orientation.ym);
    canvas.translate(base/2, base/2);
    canvas.rotate(_orientation.rotation);
    canvas.translate(-base/2, -base/2);

    canvas.drawArc(Rect.fromLTWH(0, 0, base, base), 0.0, pi, true, paint);

    paint.strokeWidth = 5.0;
    int range = _maxValue - _minValue;

    for(GaugeRange r in _ranges) {
      paint.color = r.color;
      double start = pi*((r.min - _minValue)/range);
      double end = (pi*((r.max - _minValue)/range)) - start;
      canvas.drawArc(Rect.fromLTWH(0, 0, base, base), start, end, false, paint);
    }

    canvas.restore();

    TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    try {
      canvas.translate((base / 2) + base*_orientation.xm, (base / 2) + base*_orientation.ym);

      double steps = range / _step;
      double angleStep = pi/steps;

      for (int i = 0; i <= steps; ++i) {
        String label = (_minValue + (_step*i)).toInt().toString();

        tp.text = TextSpan(
            text: label,
            style: theme.textTheme.bodyMedium?.copyWith(backgroundColor: theme.colorScheme.surface));
        tp.layout();

        double angle = (_mirror ? pi - angleStep*i : angleStep*i) + _orientation.rotation;
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

    canvas.translate(base*_orientation.xm, base*_orientation.ym);
    canvas.translate(base/2, base/2);
    canvas.rotate(_orientation.rotation);
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
    {super.minValue = 0, required super.maxValue, super.step, super.angle, super.smoothing, super.ranges,
    this.mirror = false, super.key});

  @override
  DoubleValueSemiGaugeBoxState createState() => DoubleValueSemiGaugeBoxState();
}

class DoubleValueSemiGaugeBoxState<T extends DoubleValueSemiGaugeBox> extends DoubleValueGaugeBoxState<T> {

  @override
  Widget build(BuildContext context) {
    GaugeOrientation o = widget.orientation;

    List<Widget> stack = [
      Positioned(top: o.titleTop, bottom: o.titleBottom, left: o.titleLeft, right: o.titleRight, child: Text(widget.title)),
      Positioned(top: o.unitsTop, bottom: o.unitsBottom, left: o.unitsLeft, right: o.unitsRight, child: Text(widget.units(displayValue??0.0))),
      CustomPaint(
          size: Size.infinite,
          painter: _SemiGaugePainter(context, o, widget.mirror, minDisplay, maxDisplay, _displayStep, _displayRanges)
      )
    ];

    if(displayValue != null) {
      double angle = ((pi/((widget.maxValue??_defaultMax) - (widget.minValue??0))) * (value! - (widget.minValue??0))) - pi/2;
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
  final List<GaugeRange> _ranges;

  _CircularGaugePainter(this._context, this._minValue, this._minDisplay, this._maxDisplay, this._displayStep, this._ranges);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    double size = min(canvasSize.width, canvasSize.height);

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Theme.of(_context).colorScheme.onSurface
      ..strokeWidth = 2.0;

    canvas.drawArc(Rect.fromLTWH(0, 0, size, size), pi/2+circularGaugeOffset, 2*pi-(circularGaugeOffset*2), false, paint);

    paint.strokeWidth = 5.0;
    int range = _maxDisplay - _minDisplay;
    double displayRange = (pi-circularGaugeOffset)*2;
    for(GaugeRange r in _ranges) {
      paint.color = r.color;
      double start = displayRange*((r.min - _minValue)/range);
      double end = (displayRange*((r.max - _minValue)/range)) - start;
      canvas.drawArc(Rect.fromLTWH(0, 0, size, size), start+pi/2+circularGaugeOffset, end, false, paint);
    }

    TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    try {
      paint.color = Theme.of(_context).colorScheme.onSurface;
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
    super.ranges, super.smoothing, super.key});

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
          painter: _CircularGaugePainter(context, widget.convert(widget.minValue??0), minDisplay, maxDisplay, _displayStep, _displayRanges)
      )
    ];

    if(displayValue != null) {
      double steps = (widget.maxValue??_defaultMax) - (widget.minValue??0);
      double angleStep = (2*pi-(circularGaugeOffset*2))/steps;

      double angle = angleStep * (value! - (widget.minValue??0));

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
  final List<GaugeRange> _ranges;
  final double? _value;

  _BarGaugePainter(this._context, this._minValue, this._maxValue, this._step, this._ranges, this._value);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    ThemeData theme = Theme.of(_context);
    double w = canvasSize.width;
    double h = canvasSize.height;

    Paint paint = Paint()
      ..style = PaintingStyle.fill;

    double step = h/(_maxValue - _minValue);

    for(GaugeRange r in _ranges) {
      paint.color = r.color;
      canvas.drawRect(Rect.fromLTRB(0, h-(step*(r.max-_minValue)), w, h-(step*(r.min - _minValue))), paint);
    }

    if(_value != null) {
      paint.color = Colors.blue;
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
    super.ranges, super.smoothing, super.key});

  @override
  DoubleValueBarGaugeBoxState createState() => DoubleValueBarGaugeBoxState();
}

class DoubleValueBarGaugeBoxState<T extends DoubleValueBarGaugeBox> extends DoubleValueGaugeBoxState<T> {
  @override
  Widget build(BuildContext context) {
    const double pad = 5.0;
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Row(children: [Padding(padding: const EdgeInsets.all(pad), child: Text(widget.title, style: Theme.of(context).textTheme.titleMedium))]),
      Expanded(child: Padding(padding: const EdgeInsets.only(left: pad, right: pad),
        child: RepaintBoundary(child: CustomPaint(
          size: Size.infinite,
          painter: _BarGaugePainter(context, minDisplay, maxDisplay, _displayStep, _displayRanges, displayValue)
      )))),
      Row(children: [Padding(padding: const EdgeInsets.all(pad), child: Text(widget.units(value??0), style: Theme.of(context).textTheme.titleMedium))]),
    ]);
  }
}

class _GraphPainter extends CustomPainter {
  static final intl.DateFormat _dateFormat = intl.DateFormat(intl.DateFormat.HOUR24_MINUTE);
  final BuildContext _context;
  final GraphBox _widget;
  final List<DataPoint> _data;
  final int _minutes;
  final int _step;
  final bool _zeroBase;
  final List<GaugeRange> _ranges;

  _GraphPainter(this._context, this._widget, this._data, this._minutes, this._step, this._zeroBase, this._ranges);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    ThemeData theme = Theme.of(_context);
    double w = canvasSize.width;
    double h = canvasSize.height;
    List<double?> values = List.filled(w.toInt(), null);

    if(_data.isEmpty) {
      return;
    }

    int duration = _minutes*60*1000;
    int slice = (duration/w).round();
    DateTime now = DateTime.now();
    DateTime end = now;

    double minDisplay = _zeroBase ? 0 : double.infinity;
    double maxDisplay = 0;
    int dp=_data.length-1;
    for(int i=values.length-1; i>=0; --i) {
      double total = 0;
      int count = 0;

      DateTime start = end.subtract(Duration(milliseconds: slice));
      while(dp >= 0 && _data[dp].date.isAfter(start)) {
        total += _widget.convert(_data[dp].value);
        ++count;
        --dp;
      }
      end = start;
      if(count > 0) {
        double displayValue = total/count;
        values[i] = displayValue;
        if(displayValue < minDisplay) minDisplay = displayValue;
        if(displayValue > maxDisplay) maxDisplay = displayValue;
      }
    }

    // Scale display range to the step above and below.
    maxDisplay += _step - (maxDisplay % _step);
    minDisplay -= (minDisplay % _step);

    Paint paint = Paint()
      ..strokeWidth = 0.0
      ..style = PaintingStyle.fill;

    double hStep = h/(maxDisplay - minDisplay);

    double steps = (maxDisplay - minDisplay) / _step;
    double lineStep = h / steps;

    paint..color = theme.colorScheme.onSurface
      ..strokeWidth = 0.0
      ..style = PaintingStyle.fill;

    for (int i = 0; i <= steps; ++i) {
      canvas.drawRect(Rect.fromLTWH(0, h-(lineStep*i)-1, w, 2), paint);
    }

    for(GaugeRange r in _ranges) {
      paint.color = r.color;
      if(hStep*(r.max-minDisplay) <= h) {
        canvas.drawRect(Rect.fromLTRB(0, h-(hStep*(r.max-minDisplay))-1, w, h-(hStep*(r.min-minDisplay))+1), paint);
      }
    }

    paint.color = theme.colorScheme.secondary;

    TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    try {
      for (int i = 0; i <= steps; ++i) {
        tp.text = TextSpan(
            text: (i*_step+minDisplay).toInt().toString(),
            style: theme.textTheme.bodyMedium?.copyWith(backgroundColor: theme.colorScheme.surface));
        tp.layout();

        tp.paint(canvas, Offset(5, h-(i*lineStep)-(tp.size.height/2)));
        tp.paint(canvas, Offset(w-5-tp.size.width, h-(i*lineStep)-(tp.size.height/2)));
      }

      int minutesStep = (_minutes/4).round();
      minutesStep = minutesStep < 1 ? 1 : minutesStep;
      double wStep = w/_minutes;
      for (int m = minutesStep; m < _minutes; m+=minutesStep) {

        canvas.drawRect(Rect.fromLTRB(w-(m*wStep)-1, 0, w-(m*wStep)+1, h), paint);

        String time = m.toString();
        if(_minutes > 60) {
          time = _dateFormat.format(now.subtract(Duration(minutes: m)));
        }
        tp.text = TextSpan(
            text: time,
            style: theme.textTheme.bodyMedium?.copyWith(backgroundColor: theme.colorScheme.surface));
        tp.layout();

        tp.paint(canvas, Offset(w-(m*wStep)-(tp.size.width/2), 5));
      }

    } finally {
      tp.dispose();
    }

    paint
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..color = Colors.blue;

    bool first = true;
    Path p = Path();
    for(int i=0; i<values.length; ++i) {
      if(values[i] != null) {
        if(first) {
          first = false;
          p.moveTo(i.toDouble(), h-(hStep*(values[i]!-minDisplay)));
        } else {
          p.lineTo(i.toDouble(), h-(hStep*(values[i]!-minDisplay)));
        }
      }
    }
    canvas.drawPath(p, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

enum GraphDuration implements EnumMenuEntry {
  oneMinutes('1 Minutes', 1),
  twoMinutes('2 Minutes', 2),
  threeMinutes('3 Minutes', 3),
  fourMinutes('4 Minutes', 4),
  fiveMinutes('5 Minutes', 5),
  tenMinutes('10 Minutes', 10),
  fifteenMinutes('15 Minutes', 15),
  thirtyMinutes('30 Minutes', 30),
  oneHour('1 Hour', 1*60),
  twoHours('2 Hours', 2*60),
  fourHours('4 Hours', 4*60),
  sixHours('6 Hours', 6*60),
  twelveHours('12 Hours', 12*60),
  oneDay('1 Day', 24*60);

  @override
  String get displayName => _displayName;

  final String _displayName;
  final int minutes;

  const GraphDuration(this._displayName, this.minutes);

  GraphDuration operator +(int i) => GraphDuration.values[(index+i)%GraphDuration.values.length];
  GraphDuration operator -(int i) => GraphDuration.values[(index-i)%GraphDuration.values.length];
}

@JsonSerializable()
class _GraphSettings {
  GraphDuration displayDuration;

  _GraphSettings({this.displayDuration = GraphDuration.fifteenMinutes});
}

abstract class GraphBox extends BoxWidget {
  late final _GraphSettings _settings;

  final String title;
  final double step;
  final bool zeroBase;
  final int precision;
  final int minLen;
  final List<GaugeRange> ranges;

  GraphBox(super.config, this.title, 
    {required this.step, this.zeroBase = true, this.precision = 1, this.minLen = 2, this.ranges = const [], super.key}) {
    _settings = _$GraphSettingsFromJson(config.settings);
  }

  List<DataPoint> get data;

  double convert(double value);

  String units(double value);

  @override
  bool get hasSettings => true;

  @override
  BoxSettingsWidget? getSettingsWidget(Map<String, dynamic> json) {
    return BackgroundDataSettingsWidget(json);
  }

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _GraphSettingsWidget(_settings);
  }

  @override
  createState() => GraphBoxState();
}

class GraphBoxState extends State<GraphBox> {
  final List<GaugeRange> _displayRanges = [];
  int _displayStep = 0;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure();
    
    for(GaugeRange r in widget.ranges) {
      _displayRanges.add(GaugeRange(widget.convert(r.min), widget.convert(r.max), r.color));
    }

    _displayStep = widget.convert(widget.step).round();

    Timer(Duration(seconds: 1), _update);
  }

  _update() {
    if(mounted) {
      setState(() {});
    }
    Timer(Duration(seconds: 1), _update);
  }

  @override
  Widget build(BuildContext context) {
    const double pad = 5.0;
    double currentValue = widget.data.lastOrNull?.value??0;
    double displayValue = widget.convert(currentValue);
    String currentValueString =
          fmt.format('{:${widget.minLen+(widget.precision > 0?1:0)+widget.precision}.${widget.precision}f} ${widget.units(currentValue)}', displayValue);

    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.all(pad), child: Row(children: [
        Text('${widget.title} ${widget._settings.displayDuration.displayName}', style: Theme.of(context).textTheme.titleMedium),
        Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Expanded(child: Text(currentValueString, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium)),
          IconButton(icon: Icon(Icons.add), onPressed: _increaseTime),
          IconButton(icon: Icon(Icons.remove), onPressed: _decreaseTime),
        ]))
      ])),
      Expanded(child: Padding(padding: const EdgeInsets.only(left: pad, right: pad, bottom: pad*2),
        child: RepaintBoundary(child: CustomPaint(
          size: Size.infinite,
          painter: _GraphPainter(context, widget, widget.data, widget._settings.displayDuration.minutes, _displayStep, widget.zeroBase, _displayRanges)
      )))),
    ]);
  }

  void _increaseTime() {
    setState(() {
      widget._settings.displayDuration++;
    });
  }

  void _decreaseTime() {
    setState(() {
      widget._settings.displayDuration--;
    });
  }
}

class _GraphSettingsWidget extends BoxSettingsWidget {
  final _GraphSettings _settings;

  const _GraphSettingsWidget(this._settings);

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$GraphSettingsToJson(_settings);
  }

  @override
  createState() => _SettingsState();
}

class _SettingsState extends State<_GraphSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _GraphSettings s = widget._settings;

    return ListView(children: [
      ListTile(
          leading: const Text("Display Duration:"),
          title: EnumDropdownMenu(
            GraphDuration.values,
            s.displayDuration,
            (v) {
              setState(() {
                s.displayDuration = v!;
              });
            })
      ),
    ]);
  }
}
