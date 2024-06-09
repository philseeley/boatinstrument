import 'package:flutter/material.dart';
import 'package:format/format.dart' as fmt;
import 'package:boatinstrument/boatinstrument_controller.dart';

class WaterTemperatureBox extends _DoubleValueBox {
  static const String sid = 'sea-temperature';
  @override
  String get id => sid;

  WaterTemperatureBox(config, {super.key}) : super(config, 'Water Temp', 'environment.water.temperature') {
    _setup(_convertTemp, _tempUnits);
  }

  double _convertTemp(double temp) {
    switch (config.controller.temperatureUnits) {
      case TemperatureUnits.c:
        return temp - 273.15;
      case TemperatureUnits.f:
        return (temp - 273.15) * 9/5 + 32;
    }
  }

  String _tempUnits() {
    return config.controller.temperatureUnits.unit;
  }
}

class CourseOverGroundBox extends _DoubleValueBox {
  static const String sid = 'course-over-ground';
  @override
  String get id => sid;

  CourseOverGroundBox(config, {super.key}) : super(config, 'COG', 'navigation.courseOverGroundTrue', minLen: 3, precision: 0) {
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

  DepthBox(config, {super.key}) : super(config, 'Depth', 'environment.depth.belowSurface', maxValue: 1000.0) {
    _setup(_convertDepth, _depthUnits);
  }

  double _convertDepth(double depth) {
    switch (config.controller.depthUnits) {
      case DepthUnits.m:
        return depth;
      case DepthUnits.ft:
        return depth * 3.28084;
      case DepthUnits.fa:
        return depth * 0.546807;
    }
  }

  String _depthUnits() {
    return config.controller.depthUnits.unit;
  }
}

class SpeedOverGroundBox extends _SpeedBox {
  static const String sid = 'speed-over-ground';
  @override
  String get id => sid;

  SpeedOverGroundBox(config, {super.key}) : super(config, 'SOG', 'navigation.speedOverGround');
}

class SpeedBox extends _SpeedBox {
  static const String sid = 'speed-through-water';
  @override
  String get id => sid;

  SpeedBox(config, {super.key}) : super(config, 'Speed', 'navigation.speedThroughWater');
}

abstract class _SpeedBox extends _DoubleValueBox {

  _SpeedBox(super.config, super.title, super.path, {super.key}) {
    _setup(_convertSpeed, _speedUnits);
  }

  double _convertSpeed(double speed) {
    switch (config.controller.speedUnits) {
      case SpeedUnits.mps:
        return speed;
      case SpeedUnits.kph:
        return speed * 3.6;
      case SpeedUnits.mph:
        return speed * 2.236936;
      case SpeedUnits.kts:
        return speed * 1.943844;
    }
  }

  String _speedUnits() {
    return config.controller.speedUnits.unit;
  }
}

class WindSpeedApparentBox extends _WindSpeedBox {
  static const String sid = 'wind-speed-apparent';
  @override
  String get id => sid;

  WindSpeedApparentBox(config, {super.key}) : super(config, 'AWS', 'environment.wind.speedApparent');
}

class WindSpeedTrueBox extends _WindSpeedBox {
  static const String sid = 'wind-speed-true';
  @override
  String get id => sid;

  WindSpeedTrueBox(config, {super.key}) : super(config, 'TWS', 'environment.wind.speedTrue');
}

abstract class _WindSpeedBox extends _DoubleValueBox {

  _WindSpeedBox(super.config, super.title, super.path, {super.key}) {
    _setup(_convertSpeed, _speedUnits);
  }

  double _convertSpeed(double speed) {
    switch (config.controller.windSpeedUnits) {
      case SpeedUnits.mps:
        return speed;
      case SpeedUnits.kph:
        return speed * 3.6;
      case SpeedUnits.mph:
        return speed * 2.236936;
      case SpeedUnits.kts:
        return speed * 1.943844;
    }
  }

  String _speedUnits() {
    return config.controller.windSpeedUnits.unit;
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

  _DoubleValueBox(super.config, this._title, this._path, {precision = 1, minLen =  2, this.minValue, this.maxValue, super.key}): _precision = precision, _minLen = minLen;

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
    widget.config.controller.configure(widget, onUpdate: _processData, paths: { widget._path });
  }

  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      _displayValue = 12.3;
    }

    String valueText = (_displayValue == null) ?
      '-' :
      fmt.format('{:${widget._minLen+(widget._precision > 0?1:0)+widget._precision}.${widget._precision}f}', _displayValue!);

    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);

    const double pad = 5.0;
    double fontSize = maxFontSize(valueText, style,
          widget.config.constraints.maxHeight - style.fontSize! - (3 * pad),
          widget.config.constraints.maxWidth - (2 * pad));

    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Row(children: [Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Text('${widget._title} - ${widget._units()}', style: style))]),
      // We need to disable the device text scaling as this interferes with our text scaling.
      Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(pad), child: Text(valueText, textScaler: TextScaler.noScaling,  style: style.copyWith(fontSize: fontSize)))))
    ]);
  }

  _processData(List<Update> updates) {
    try {
      double next = (updates[0].value as num).toDouble();

      if((widget.minValue != null && next < widget.minValue!) ||
         (widget.maxValue != null && next > widget.maxValue!)) {
        _displayValue = null;
      } else {
        _value = averageDouble(_value ?? next, next, smooth: widget.config.controller.valueSmoothing);
        _displayValue = widget._convert(_value!);
      }
    } catch (e) {
      widget.config.controller.l.e("Error converting $updates", error: e);
    }

    if(mounted) {
      setState(() {});
    }
  }
}
