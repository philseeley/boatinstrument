import '../boatinstrument_controller.dart';
import 'double_value_box.dart';
import 'gauge_box.dart';

class SpeedThroughWaterBox extends SpeedBox {
  static const String sid = 'speed-through-water';
  @override
  String get id => sid;

  const SpeedThroughWaterBox(config, {super.key}) : super(config, 'Speed', 'navigation.speedThroughWater');
}

class AttitudeRollGaugeBox extends DoubleValueSemiGaugeBox {
  const AttitudeRollGaugeBox(config, {super.key}) : super(config, 'Roll', GaugeOrientation.down, 'navigation.attitude', minValue: -45, maxValue: 45, mirror: true, angle: true);

  static String sid = 'attitude-roll';
  @override
  String get id => sid;

  @override
  double extractValue(Update update) {
    return (update.value['roll'] as num).toDouble();
  }

  @override
  double convert(double value) {
    return rad2Deg(value).toDouble();
  }

  @override
  String units(double value) {
    return 'deg';
  }
}
