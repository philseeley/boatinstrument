import 'package:boatinstrument/boatinstrument_controller.dart';
import 'double_value_box.dart';

class DepthBox extends DoubleValueBox {
  static const String sid = 'depth';
  @override
  String get id => sid;

  DepthBox(config, {super.key}) : super(config, 'Depth', 'environment.depth.belowSurface', maxValue: 1000.0, smoothing: false) {
    super.convert = _convertDepth;
    super.units = _depthUnits;
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

  String _depthUnits(_) {
    return config.controller.depthUnits.unit;
  }
}

class WaterTemperatureBox extends DoubleValueBox {
  static const String sid = 'sea-temperature';
  @override
  String get id => sid;

  WaterTemperatureBox(config, {super.key}) : super(config, 'Water Temp', 'environment.water.temperature') {
    super.convert = _convertTemp;
    super.units = _tempUnits;
  }

  double _convertTemp(double temp) {
    switch (config.controller.temperatureUnits) {
      case TemperatureUnits.c:
        return temp - 273.15;
      case TemperatureUnits.f:
        return (temp - 273.15) * 9/5 + 32;
    }
  }

  String _tempUnits(_) {
    return config.controller.temperatureUnits.unit;
  }
}
