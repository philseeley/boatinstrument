import 'package:flutter/material.dart';
import 'package:format/format.dart' as fmt;
import 'package:boatinstrument/boatinstrument_controller.dart';

class DepthBox extends _DoubleValueBox {
  static const String sid = 'depth';
  @override
  String get id => sid;

  DepthBox(controller, {super.key}) : super(controller, 'Depth', 'environment.depth.belowSurface') {
    _setup(_convertDepth, _depthUnits);
  }

  double _convertDepth(double depth) {
    switch (_controller.depthUnits) {
      case DepthUnits.m:
        return depth;
      case DepthUnits.ft:
        return depth * 3.28084;
      case DepthUnits.fa:
        return depth * 0.546807;
    }
  }

  String _depthUnits() {
    return _controller.depthUnits.unit;
  }
}

class SpeedOverGroundBox extends _SpeedBox {
  static const String sid = 'speed-over-ground';
  @override
  String get id => sid;

  SpeedOverGroundBox(controller, {super.key}) : super(controller, 'SOG', 'navigation.speedOverGround');
}

class SpeedBox extends _SpeedBox {
  static const String sid = 'speed-through-water';
  @override
  String get id => sid;

  SpeedBox(controller, {super.key}) : super(controller, 'Speed', 'navigation.speedThroughWater');
}

abstract class _SpeedBox extends _DoubleValueBox {

  _SpeedBox(super.controller, super.title, super.path, {super.key}) {
    _setup(_convertSpeed, _speedUnits);
  }

  double _convertSpeed(double speed) {
    switch (_controller.speedUnits) {
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
    return _controller.speedUnits.unit;
  }
}

class WindSpeedApparentBox extends _WindSpeedBox {
  static const String sid = 'wind-speed-apparent';
  @override
  String get id => sid;

  WindSpeedApparentBox(controller, {super.key}) : super(controller, 'AWS', 'environment.wind.speedApparent');
}

class WindSpeedTrueBox extends _WindSpeedBox {
  static const String sid = 'wind-speed-true';
  @override
  String get id => sid;

  WindSpeedTrueBox(controller, {super.key}) : super(controller, 'TWS', 'environment.wind.speedTrue');
}

abstract class _WindSpeedBox extends _DoubleValueBox {

  _WindSpeedBox(super.controller, super.title, super.path, {super.key}) {
    _setup(_convertSpeed, _speedUnits);
  }

  double _convertSpeed(double speed) {
    switch (_controller.windSpeedUnits) {
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
    return _controller.windSpeedUnits.unit;
  }
}

abstract class _DoubleValueBox extends BoxWidget {
  final BoatInstrumentController _controller;
  final String _title;
  final String _path;
  final int _precision;
  final int _minLen;
  late double Function(double value) _convert;
  late String Function() _units;

  _DoubleValueBox(this._controller, this._title, this._path, {precision = 1, minLen =  2, super.key}): _precision = precision, _minLen = minLen;

  _setup(convert, units) {
    _convert = convert;
    _units = units;
  }

  @override
  State<_DoubleValueBox> createState() => _DoubleValueBoxState();
}

class _DoubleValueBoxState extends State<_DoubleValueBox> {
  double? _value;
  double _displayValue = 0;

  @override
  void initState() {
    super.initState();
    widget._controller.configure(widget, onUpdate: _processData, paths: { widget._path });
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('${widget._title} - ${widget._units()}', style: widget._controller.headTS),
      Text(fmt.format('{:${widget._minLen+1+widget._precision}.${widget._precision}f}', _displayValue), style: widget._controller.infoTS)
    ]);
  }

  _processData(List<Update> updates) {
    try {
      double next = (updates[0].value as num).toDouble();
      _value = averageDouble(_value??next, next);
      _displayValue = widget._convert(_value!);
    } catch (e) {
      widget._controller.l.e("Error converting $updates", error: e);
    }

    if(mounted) {
      setState(() {});
    }
  }
}
