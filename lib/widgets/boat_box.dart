import 'package:boatinstrument/boatinstrument_controller.dart';

import 'double_value_box.dart';

class DepthBox extends DoubleValueBox {
  static const String sid = 'depth';
  @override
  String get id => sid;

  DepthBox(config, {super.key}) : super(config, 'Depth', 'environment.depth.belowSurface', maxValue: 1000.0) {
    setup(_convertDepth, _depthUnits);
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

class SpeedThroughWaterBox extends SpeedBox {
  static const String sid = 'speed-through-water';
  @override
  String get id => sid;

  SpeedThroughWaterBox(config, {super.key}) : super(config, 'Speed', 'navigation.speedThroughWater');
}
