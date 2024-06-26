import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:flutter/material.dart';
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
    return convertDistance (config.controller, xte);
  }

  String _xteUnits(double xte) {
    return distanceUnits(config.controller, xte);
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

  String _cogUnits(_) {
    return 'deg';
  }
}

class SpeedOverGroundBox extends SpeedBox {
  static const String sid = 'speed-over-ground';
  @override
  String get id => sid;

  SpeedOverGroundBox(config, {super.key}) : super(config, 'SOG', 'navigation.speedOverGround');
}

class HeadingBox extends DoubleValueBox {
  static const String sid = 'heading';
  @override
  String get id => sid;

  HeadingBox(config, {super.key}) : super(config, 'Heading', 'navigation.headingTrue', minLen: 3, precision: 0, angle: true) {
    super.convert = _convert;
    super.units = _units;
  }

  double _convert(double cog) {
    return rad2Deg(cog) * 1.0;
  }

  String _units(_) {
    return 'deg';
  }
}

class NextPointDistanceBox extends DoubleValueBox {
  static const String sid = 'navigation-next-point-distance';
  @override
  String get id => sid;

  NextPointDistanceBox(config, {super.key}) : super(config, 'WPT Distance', 'navigation.courseGreatCircle.nextPoint.distance', precision: 2) {
    super.convert = _convert;
    super.units = _units;
  }

  double _convert(double distance) {
    return convertDistance (config.controller, distance);
  }

  String _units(double distance) {
    return distanceUnits(config.controller, distance);
  }
}

class NextPointVelocityMadeGoodBox extends SpeedBox {
  static const String sid = 'navigation-next-point-velocity-made-good';
  @override
  String get id => sid;

  NextPointVelocityMadeGoodBox(config, {super.key}) : super(config, 'WPT VMG', 'navigation.courseGreatCircle.nextPoint.velocityMadeGood');
}

class NextPointDistanceTimeToGo extends BoxWidget {

  const NextPointDistanceTimeToGo(super.config, {super.key});

  @override
  State<NextPointDistanceTimeToGo> createState() => _NextPointDistanceTimeToGoState();

  static String sid = 'navigation-next-point-time-to-go';
  @override
  String get id => sid;
}

class _NextPointDistanceTimeToGoState extends State<NextPointDistanceTimeToGo> {
  int? _timeToGo;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(widget, onUpdate: _processData, paths: {'navigation.courseGreatCircle.nextPoint.timeToGo'});
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);
    const double pad = 5.0;

    if(widget.config.editMode) {
      _timeToGo = 123;
    }

    String ttgString = '-';
    if(_timeToGo != null) {
      Duration ttg = Duration(seconds: _timeToGo!);
      List<String> parts = ttg.toString().split(RegExp('[.:]'));
      int hours = int.parse(parts[0]);
      int days = hours~/24;
      if(days > 0) {
        ttgString = '${days}d${hours%24}h';
      } else if(hours > 0) {
        ttgString = '${hours}h${parts[1]}m';
      } else {
        ttgString = '${parts[1]}m${parts[2]}s';
      }
    }

    double fontSize = maxFontSize(ttgString, style,
        widget.config.constraints.maxHeight - style.fontSize! - (3 * pad),
        widget.config.constraints.maxWidth - (2 * pad));

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Text('WPT TTG', style: style))]),
      // We need to disable the device text scaling as this interferes with our text scaling.
      Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(pad), child: Text(ttgString, textScaler: TextScaler.noScaling,  style: style.copyWith(fontSize: fontSize)))))

    ]);
  }

  _processData(List<Update>? updates) {
    if(updates == null) {
      _timeToGo = null;
    } else {
      try {
        _timeToGo = (updates[0].value as num).toInt();
      } catch (e) {
        widget.config.controller.l.e("Error converting $updates", error: e);
      }
    }

    if(mounted) {
      setState(() {});
    }
  }
}
