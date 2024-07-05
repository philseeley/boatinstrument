import 'dart:math';

import '../boatinstrument_controller.dart';
import 'double_value_box.dart';
import 'gauge_box.dart';

class SpeedThroughWaterBox extends SpeedBox {
  static const String sid = 'speed-through-water';
  @override
  String get id => sid;

  SpeedThroughWaterBox(config, {super.key}) : super(config, 'Speed', 'navigation.speedThroughWater');
}

class AttitudeRollGaugeBox extends DoubleValueSemiGaugeBox {
  AttitudeRollGaugeBox(config, {super.key}) : super(config, 'Roll', GaugeOrientation.down, 'navigation.attitude', -pi/2, pi/2) {
    super.extractValue = _extractRoll;
  }

  static String sid = 'attitude-roll';
  @override
  String get id => sid;

  double _extractRoll(Update update) {
    return (update.value['roll'] as num).toDouble();
  }
}
