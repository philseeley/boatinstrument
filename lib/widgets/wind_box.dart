import 'package:boatinstrument/boatinstrument_controller.dart';
import 'double_value_box.dart';

class WindSpeedApparentBox extends WindSpeedBox {
  static const String sid = 'wind-speed-apparent';
  @override
  String get id => sid;

  WindSpeedApparentBox(config, {super.key}) : super(config, 'AWS', 'environment.wind.speedApparent');
}

class WindSpeedTrueBox extends WindSpeedBox {
  static const String sid = 'wind-speed-true';
  @override
  String get id => sid;

  WindSpeedTrueBox(config, {super.key}) : super(config, 'TWS', 'environment.wind.speedTrue');
}

abstract class WindSpeedBox extends DoubleValueBox {

  WindSpeedBox(super.config, super.title, super.path, {super.key}) {
    setup(_convertSpeed, _speedUnits);
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
