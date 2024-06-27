import 'double_value_box.dart';

class SpeedThroughWaterBox extends SpeedBox {
  static const String sid = 'speed-through-water';
  @override
  String get id => sid;

  SpeedThroughWaterBox(config, {super.key}) : super(config, 'Speed', 'navigation.speedThroughWater');
}
