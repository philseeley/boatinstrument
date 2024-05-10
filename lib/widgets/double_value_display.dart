import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';

class DepthBox extends _DoubleValueDisplay {
  static const String sid = 'depth';
  @override
  String get id => sid;

  DepthBox(controller, {super.key}) : super(controller, 'Depth', 'environment.depth.belowSurface', 1) {
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

class SpeedOverGroundBox extends _SpeedDisplay {
  static const String sid = 'speed-over-ground';
  @override
  String get id => sid;

  SpeedOverGroundBox(controller, {super.key}) : super(controller, 'SOG', 'navigation.speedOverGround');
}

class SpeedBox extends _SpeedDisplay {
  static const String sid = 'speed-through-water';
  @override
  String get id => sid;

  SpeedBox(controller, {super.key}) : super(controller, 'Speed', 'navigation.speedThroughWater');
}

abstract class _SpeedDisplay extends _DoubleValueDisplay {

  _SpeedDisplay(controller, title, path, {super.key}) : super(controller, title, path, 1) {
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

class WindSpeedApparentBox extends _WindSpeedDisplay {
  static const String sid = 'wind-speed-apparent';
  @override
  String get id => sid;

  WindSpeedApparentBox(controller, {super.key}) : super(controller, 'AWS', 'environment.wind.speedApparent');
}

class WindSpeedTrueBox extends _WindSpeedDisplay {
  static const String sid = 'wind-speed-true';
  @override
  String get id => sid;

  WindSpeedTrueBox(controller, {super.key}) : super(controller, 'TWS', 'environment.wind.speedTrue');
}

abstract class _WindSpeedDisplay extends _DoubleValueDisplay {

  _WindSpeedDisplay(controller, title, path, {super.key}) : super(controller, title, path, 1) {
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

abstract class _DoubleValueDisplay extends BoxWidget {
  final BoatInstrumentController _controller;
  final String _title;
  final String _path;
  final int _precision;
  late double Function(double value) _convert;
  late String Function() _units;

  _DoubleValueDisplay(this._controller, this._title, this._path, this._precision, {super.key});

  _setup(convert, units) {
    _convert = convert;
    _units = units;
  }

  @override
  State<_DoubleValueDisplay> createState() => _DoubleValueDisplayState();
}

class _DoubleValueDisplayState extends State<_DoubleValueDisplay> {
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
      Text(_displayValue.toStringAsFixed(widget._precision), style: widget._controller.infoTS)
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
