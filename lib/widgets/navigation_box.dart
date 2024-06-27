import 'package:boatinstrument/boatinstrument_controller.dart';
import 'double_value_box.dart';

class CrossTrackErrorBox extends DoubleValueBox {
  static const String sid = 'navigation-xte';
  @override
  String get id => sid;

  CrossTrackErrorBox(config, {super.key}) : super(config, 'XTE', 'navigation.courseGreatCircle.crossTrackError', precision: 2) {
    super.convert = _convertXTE;
    super.units = _xteUnits;
  }

  double _convertXTE(double xte) {
    switch (config.controller.distanceUnits) {
      case DistanceUnits.meters:
        return xte;
      case DistanceUnits.km:
        return xte * 0.001;
      case DistanceUnits.miles:
        return xte * 0.000621371;
      case DistanceUnits.nm:
        return xte * 0.000539957;
    }
  }

  String _xteUnits() {
    return config.controller.distanceUnits.unit;
  }
}

class CourseOverGroundBox extends DoubleValueBox {
  static const String sid = 'course-over-ground';
  @override
  String get id => sid;

  CourseOverGroundBox(config, {super.key}) : super(config, 'COG', 'navigation.courseOverGroundTrue', minLen: 3, precision: 0, angle: true) {
    super.convert = _convertCOG;
    super.units = _cogUnits;
  }

  double _convertCOG(double cog) {
    return rad2Deg(cog) * 1.0;
  }

  String _cogUnits() {
    return 'deg';
  }
}

class SpeedOverGroundBox extends SpeedBox {
  static const String sid = 'speed-over-ground';
  @override
  String get id => sid;

  SpeedOverGroundBox(config, {super.key}) : super(config, 'SOG', 'navigation.speedOverGround');
}
