import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:format/format.dart' as fmt;
import 'package:boatinstrument/boatinstrument_controller.dart';

class SeaTemperatureBox extends _DoubleValueBox {
  static const String sid = 'sea-temperature';
  @override
  String get id => sid;

  SeaTemperatureBox(controller, constraints, {super.key}) : super(controller, constraints, 'Sea Temp', 'environment.water.temperature') {
    _setup(_convertTemp, _tempUnits);
  }

  double _convertTemp(double temp) {
    switch (controller.temperatureUnits) {
      case TemperatureUnits.c:
        return temp - 273.15;
      case TemperatureUnits.f:
        return temp - 459.67;//TODO this isn't correct
    }
  }

  String _tempUnits() {
    return controller.temperatureUnits.unit;
  }
}

class CourseOverGroundBox extends _DoubleValueBox {
  static const String sid = 'course-over-ground';
  @override
  String get id => sid;

  CourseOverGroundBox(controller, constraints, {super.key}) : super(controller, constraints, 'COG', 'navigation.courseOverGroundTrue', minLen: 3, precision: 0) {
    _setup(_convertCOG, _cogUnits);
  }

  double _convertCOG(double cog) {
    return rad2Deg(cog) * 1.0;
  }

  String _cogUnits() {
    return 'deg';
  }
}

class DepthBox extends _DoubleValueBox {
  static const String sid = 'depth';
  @override
  String get id => sid;

  DepthBox(controller, constraints, {super.key}) :
        super(controller, constraints, 'Depth', 'environment.depth.belowSurface', maxValue: 1000.0) {
    _setup(_convertDepth, _depthUnits);
  }

  double _convertDepth(double depth) {
    switch (controller.depthUnits) {
      case DepthUnits.m:
        return depth;
      case DepthUnits.ft:
        return depth * 3.28084;
      case DepthUnits.fa:
        return depth * 0.546807;
    }
  }

  String _depthUnits() {
    return controller.depthUnits.unit;
  }
}

class SpeedOverGroundBox extends _SpeedBox {
  static const String sid = 'speed-over-ground';
  @override
  String get id => sid;

  SpeedOverGroundBox(controller, constraints, {super.key}) : super(controller, constraints, 'SOG', 'navigation.speedOverGround');
}

class SpeedBox extends _SpeedBox {
  static const String sid = 'speed-through-water';
  @override
  String get id => sid;

  SpeedBox(controller, constraints, {super.key}) : super(controller, constraints, 'Speed', 'navigation.speedThroughWater');
}

abstract class _SpeedBox extends _DoubleValueBox {

  _SpeedBox(super.controller, super.constraints, super.title, super.path, {super.key}) {
    _setup(_convertSpeed, _speedUnits);
  }

  double _convertSpeed(double speed) {
    switch (controller.speedUnits) {
      case SpeedUnits.mps:
        return speed;
      case SpeedUnits.kph:
        return speed * 3.6;
      case SpeedUnits.mph:
        return speed * 2.236936;
      case SpeedUnits.kts:
        return speed * 1.943844; //TODO or uk kts 1.942603
    }
  }

  String _speedUnits() {
    return controller.speedUnits.unit;
  }
}

class WindSpeedApparentBox extends _WindSpeedBox {
  static const String sid = 'wind-speed-apparent';
  @override
  String get id => sid;

  WindSpeedApparentBox(controller, constraints, {super.key}) : super(controller, constraints, 'AWS', 'environment.wind.speedApparent');
}

class WindSpeedTrueBox extends _WindSpeedBox {
  static const String sid = 'wind-speed-true';
  @override
  String get id => sid;

  WindSpeedTrueBox(controller, constraints, {super.key}) : super(controller, constraints, 'TWS', 'environment.wind.speedTrue');
}

abstract class _WindSpeedBox extends _DoubleValueBox {

  _WindSpeedBox(super.controller, super.constraints, super.title, super.path, {super.key}) {
    _setup(_convertSpeed, _speedUnits);
  }

  double _convertSpeed(double speed) {
    switch (controller.windSpeedUnits) {
      case SpeedUnits.mps:
        return speed;
      case SpeedUnits.kph:
        return speed * 3.6;
      case SpeedUnits.mph:
        return speed * 2.236936;
      case SpeedUnits.kts:
        return speed * 1.943844; //TODO or uk kts 1.942603
    }
  }

  String _speedUnits() {
    return controller.windSpeedUnits.unit;
  }
}

abstract class _DoubleValueBox extends BoxWidget {
  final String _title;
  final String _path;
  final int _precision;
  final int _minLen;
  final double? minValue;
  final double? maxValue;
  late double Function(double value) _convert;
  late String Function() _units;

  _DoubleValueBox(super.controller, super.constraints, this._title, this._path, {precision = 1, minLen =  2, this.minValue, this.maxValue, super.key}): _precision = precision, _minLen = minLen;

  _setup(convert, units) {
    _convert = convert;
    _units = units;
  }

  @override
  State<_DoubleValueBox> createState() => _DoubleValueBoxState();
}

class _DoubleValueBoxState extends State<_DoubleValueBox> {
  double? _value;
  double? _displayValue;

  @override
  void initState() {
    super.initState();
    widget.controller.configure(widget, onUpdate: _processData, paths: { widget._path });
  }

  @override
  Widget build(BuildContext context) {
    String valueText = '-';
    if(_displayValue != null) {
      valueText = fmt.format('{:${widget._minLen+1+widget._precision}.${widget._precision}f}', _displayValue!);
    }

    const double pad = 5.0;

    // Assume the font height is the height of the available Box.
    double fontSize = widget.constraints.maxHeight-widget.controller.headTS.fontSize! - pad - 1.0;

    // We use this to determine the relationship between the font height and width, as we can only
    // control the font size by its height.
    Size txtSize = _textSize(valueText, widget.controller.infoTS.copyWith(fontSize: fontSize));

    // Check if we're constrained by width.
    if(txtSize.width > (widget.constraints.maxWidth)) {
      fontSize = (fontSize * (widget.constraints.maxWidth / txtSize.width)) - 1.0;
    }

    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Row(children: [Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Text('${widget._title} - ${widget._units()}', style: widget.controller.headTS))]),
      // We need to disable the device text scaling as this interferes with our text scaling.
      Expanded(child: Center(child: Text(valueText, textScaler: TextScaler.noScaling,  style: widget.controller.infoTS.copyWith(fontSize: fontSize))))
    ]);
  }

  // This determines the size of rendered text.
  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  _processData(List<Update> updates) {
    try {
      double next = (updates[0].value as num).toDouble();

      if((widget.minValue != null && next < widget.minValue!) ||
         (widget.maxValue != null && next > widget.maxValue!)) {
        _displayValue = null;
      } else {
        _value = averageDouble(_value ?? next, next);
        _displayValue = widget._convert(_value!);
      }
    } catch (e) {
      widget.controller.l.e("Error converting $updates", error: e);
    }

    if(mounted) {
      setState(() {});
    }
  }
}
