import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:boatinstrument/widgets/gauge_box.dart';
import 'package:flutter/material.dart';
// import 'package:great_circle_distance_calculator/great_circle_distance_calculator.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'double_value_box.dart';
import 'package:latlong_formatter/latlong_formatter.dart';

part 'navigation_box.g.dart';

class CrossTrackErrorBox extends DoubleValueBox {
  static const String sid = 'navigation-xte';
  @override
  String get id => sid;

  const CrossTrackErrorBox(BoxWidgetConfig config, {super.key}) : super(config, 'XTE', 'navigation.*.crossTrackError', precision: 2, smoothing: false, portStarboard: true);

  @override
  double convert(double value) {
    return config.controller.distanceToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.distanceUnitsToDisplay(value);
  }
}

class CrossTrackErrorGraphBackground extends BackgroundData {
  CrossTrackErrorGraphBackground({BoatInstrumentController? controller}) : super(controller: controller, CrossTrackErrorGraph.sid, {'navigation.*.crossTrackError'}, smoothing: false);
}

class CrossTrackErrorGraph extends GraphBox {
  static const String sid = 'navigation-xte-graph';
  @override
  String get id => sid;

  CrossTrackErrorGraph(BoxWidgetConfig config, {super.key}) :
    super(
      config,
      'XTE',
      CrossTrackErrorGraphBackground(),
      step: nm2m(1),
      precision: 2,
      zeroBase: false,
      vertical: true,
      mirror: true,
      ranges: [
        GaugeRange(0, 0, Colors.blue)
      ]
    );

  @override
  double convert(double value) {
    return config.controller.distanceToDisplay(value, fixed: true);
  }

  @override
  String units(double value) {
    return config.controller.distanceUnitsToDisplay(value, fixed: true);
  }
}

class CrossTrackErrorDeltaBox extends DoubleValueSemiGaugeBox {
  static const String sid = 'navigation-xte-delta';
  @override
  String get id => sid;

  const CrossTrackErrorDeltaBox(BoxWidgetConfig config, {super.key}) : super(config, 'XTE', GaugeOrientation.up, 'navigation.*.crossTrackError', minValue: -2, maxValue: 2);

  @override
  double convert(double value) {
    return value;
  }

  @override
  String units(double value) {
    return deltaChar; // Delta symbol
  }

  @override
  DoubleValueSemiGaugeBoxState<CrossTrackErrorDeltaBox> createState() => _CrossTrackErrorDeltaBoxState();
}

class _CrossTrackErrorDeltaBoxState extends DoubleValueSemiGaugeBoxState<CrossTrackErrorDeltaBox> {
  double? _lastValue;

  @override
  Widget build(BuildContext context) {
    if(value != null) {
      double diff = value! - (_lastValue??value!);
      _lastValue = value!;
      if (diff < widget.minValue! || diff > widget.maxValue!) {
        value = displayValue = null;
        inRange = -1;
        if(diff > widget.maxValue!) inRange = 1;
      }
      else {
        value = displayValue = diff;
      }
    }
    Widget w = super.build(context);
    value = _lastValue;
    return w;
  }

  // We override this because we don't want to check min and max as the gauge needs these to
  // be adjusted for the diff, not the absolute value.
  @override
  processUpdates(List<Update> updates) {
    if(updates[0].value == null) {
      value = displayValue = null;
      inRange = 0;
    } else {
      try {
        double next = widget.extractValue(updates[0]);

        value = averageDouble(value ?? next, next,
            smooth: widget.config.controller.valueSmoothing);
      } catch (e) {
        widget.config.controller.l.e("Error converting $updates", error: e);
      }
    }

    if(mounted) {
      setState(() {});
    }
  }
}

class CourseOverGroundBox extends DoubleValueBox {
  static const String sid = 'navigation-course-over-ground';
  @override
  String get id => sid;

  const CourseOverGroundBox(BoxWidgetConfig config, {super.key}) : super(config, 'COG', 'navigation.courseOverGroundTrue', minLen: 3, precision: 0, angle: true);

  @override
  double convert(double value) {
    return rad2Deg(value) * 1.0;
  }

  @override
  String units(double value) {
    return degreesUnits;
  }
}

class SpeedOverGroundBox extends SpeedBox {
  static const String sid = 'navigation-speed-over-ground';
  @override
  String get id => sid;

  const SpeedOverGroundBox(BoxWidgetConfig config, {super.valueToDisplay, super.key}) : super(config, 'SOG', 'navigation.speedOverGround');
}

class MaxSpeedOverGroundBox extends SpeedOverGroundBox {
  static const String sid = 'navigation-speed-over-ground-max';
  @override
  String get id => sid;

  const MaxSpeedOverGroundBox(super.config, {super.valueToDisplay = DoubleValueToDisplay.maximumValue, super.key});
}

class SpeedOverGroundGraphBackground extends BackgroundData {
  SpeedOverGroundGraphBackground({BoatInstrumentController? controller}) : super(controller: controller, SpeedOverGroundGraph.sid, {'navigation.speedOverGround'});
}

class SpeedOverGroundGraph extends GraphBox {
  static const String sid = 'navigation-speed-over-ground-graph';
  @override
  String get id => sid;

  SpeedOverGroundGraph(BoxWidgetConfig config, {super.key}) : super(config, 'SOG', SpeedOverGroundGraphBackground(), step: kts2ms(1), zeroBase: false);

  @override
  double convert(double value) {
    return config.controller.speedToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.speedUnits.unit;
  }
}

class HeadingTrueBox extends DoubleValueBox {
  static const String sid = 'navigation-heading-true';
  @override
  String get id => sid;

  const HeadingTrueBox(BoxWidgetConfig config, {super.key}) : super(config, 'HDG', 'navigation.headingTrue', minLen: 3, precision: 0, angle: true);

  @override
  double convert(double value) {
    return rad2Deg(value) * 1.0;
  }

  @override
  String units(double value) {
    return degreesUnits;
  }
}

class HeadingMagneticBox extends DoubleValueBox {
  static const String sid = 'navigation-heading-magnetic';
  @override
  String get id => sid;

  const HeadingMagneticBox(BoxWidgetConfig config, {super.key}) : super(config, 'MHDG', 'navigation.headingMagnetic', minLen: 3, precision: 0, angle: true);

  @override
  double convert(double value) {
    return rad2Deg(value) * 1.0;
  }

  @override
  String units(double value) {
    return degreesUnits;
  }
}

class NextPointDistanceBox extends DoubleValueBox {
  static const String sid = 'navigation-next-point-distance';
  @override
  String get id => sid;

  const NextPointDistanceBox(BoxWidgetConfig config, {super.key}) : super(config, 'WPT Dist', 'navigation.*.nextPoint.distance', precision: 2, smoothing: false);

  @override
  double convert(double value) {
    return config.controller.distanceToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.distanceUnitsToDisplay(value);
  }
}

class NextPointBearingBox extends DoubleValueBox {
  static const String sid = 'navigation-next-point-bearing';
  @override
  String get id => sid;

  const NextPointBearingBox(BoxWidgetConfig config, {super.key}) : super(config, 'WPT BRG', 'navigation.*.nextPoint.bearingTrue', minLen: 3, precision: 0, angle: true, smoothing: false);

  @override
  double convert(double value) {
    return rad2Deg(value) * 1.0;
  }

  @override
  String units(double value) {
    return degreesUnits;
  }
}

class NextPointVelocityMadeGoodBox extends SpeedBox {
  static const String sid = 'navigation-next-point-velocity-made-good';
  @override
  String get id => sid;

  const NextPointVelocityMadeGoodBox(BoxWidgetConfig config, {super.key}) : super(config, 'WPT VMG', 'navigation.*.nextPoint.velocityMadeGood');
}

abstract class TimeToGoBox extends BoxWidget {
  final String _title;
  final Set<String> _paths;

  const TimeToGoBox(super.config, this._title, this._paths, {super.key});

  @override
  State<TimeToGoBox> createState() => TimeToGoBoxState();
}

class TimeToGoBoxState<T extends TimeToGoBox> extends HeadedTextBoxState<T> {
  int? _timeToGo;

  TimeToGoBoxState() : super(scrolling: true);
  
  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(onUpdate: processData, paths: widget._paths);
  }

  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      _timeToGo = 123;
    }

    text = '-';
    String etaString = '';

    if(_timeToGo != null) {
      Duration ttg = Duration(seconds: _timeToGo!);
      text = duration2HumanString(ttg);

      DateTime now = widget.config.controller.now().toLocal();
      DateTime eta = now.add(ttg);
      String fmt = '';
      if(eta.year != now.year) {
        fmt = 'yyyy-MM-dd ';
      } else if(eta.month != now.month || eta.day != now.day) {
        fmt = 'MMM-dd ';
      }
      etaString = DateFormat('${fmt}HH:mm').format(now.add(ttg));
    }

    header = '${widget._title} TTG $etaString';

    return super.build(context);
  }

  void processData(List<Update> updates) {
    if(updates[0].value == null) {
      _timeToGo = null;
    } else {
      try {
        double next = (updates[0].value as num).toDouble();

        _timeToGo = averageDouble(_timeToGo?.toDouble()??next, next, smooth: widget.config.controller.valueSmoothing).toInt();
      } catch (e) {
        widget.config.controller.l.e("Error converting $updates", error: e);
      }
    }

    if(mounted) {
      setState(() {});
    }
  }
}

class NextPointTimeToGoBox extends TimeToGoBox {

  NextPointTimeToGoBox(BoxWidgetConfig config, {super.key}) : super(config, 'WPT', {'navigation.*.nextPoint.timeToGo'});

  static String sid = 'navigation-next-point-time-to-go';
  @override
  String get id => sid;
}

//TODO the route seen by signalk is never more that 3 points for some reason.
// class RouteTimeToGoBox extends TimeToGoBox {
//
//   RouteTimeToGoBox(config, {super.key}) :
//         super(config, 'RTE', {
//           'navigation.courseGreatCircle.nextPoint.timeToGo',
//           'navigation.currentRoute.waypoints',
//           'navigation.courseGreatCircle.nextPoint.velocityMadeGood'
//         });
//
//   static String sid = 'navigation-route-time-to-go';
//   @override
//   String get id => sid;
//
//   @override
//   State<TimeToGoBox> createState() => _RouteTimeToGoBoxState();
// }
//
// class _RouteTimeToGoBoxState extends TimeToGoBoxState<RouteTimeToGoBox> {
//   int _waypointTTG = 0;
//   double _waypointVMG = 0.0;
//   double _routeDistance = 0.0;
//
//   @override
//   processData(List<Update>? updates) {
//     if(updates == null) {
//       _timeToGo = null;
//     } else {
//       for (Update u in updates) {
//         try {
//           switch (u.path) {
//             case 'navigation.courseGreatCircle.nextPoint.timeToGo':
//               _waypointTTG = (u.value as num).toInt();
//               break;
//             case 'navigation.currentRoute.waypoints':
//               for(int i=1; i<(u.value as List).length-1; ++i) {
//                 var gcd = GreatCircleDistance.fromDegrees(
//                     latitude1: u.value[i]['position']['value']['latitude'],
//                     longitude1: u.value[i]['position']['value']['longitude'],
//                     latitude2: u.value[i+1]['position']['value']['latitude'],
//                     longitude2: u.value[i+1]['position']['value']['longitude']);
//
//                 _routeDistance = gcd.haversineDistance();
//               }
//               break;
//             case 'navigation.courseGreatCircle.nextPoint.velocityMadeGood':
//               _waypointVMG = (u.value as num).toDouble();
//               break;
//           }
//           //TODO Something like this when all the sections of the route are known.
//           // Needs smoothing.
//           _timeToGo = _routeDistance~/_waypointVMG + _waypointTTG;
//         } catch (e) {
//           widget.config.controller.l.e("Error converting $u", error: e);
//         }
//       }
//     }
//
//     if(mounted) {
//       setState(() {});
//     }
//   }
// }

@JsonSerializable()
class _PositionSettings {
  String format;

  _PositionSettings({
    this.format = '0{lat0d 0m.mmm c}\n{lon0d 0m.mmm c}'
  });
}

class PositionBox extends BoxWidget {

  const PositionBox(super.config, {super.key});

  @override
  State<PositionBox> createState() => _PositionBoxState();

  static String sid = 'navigation-position';
  @override
  String get id => sid;

  @override
  bool get hasSettings => true;

  @override
  BoxSettingsWidget getSettingsWidget(Map<String, dynamic> json) {
    return _PositionSettingsWidget(_$PositionSettingsFromJson(json));
  }

  @override
  Widget? getSettingsHelp() => const HelpPage(text: 'For a full list of formats see https://pub.dev/packages/latlong_formatter');
}

class _PositionBoxState extends HeadedTextBoxState<PositionBox> {
  _PositionSettings _settings = _PositionSettings();
  LatLongFormatter _llf = LatLongFormatter('');
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    header = 'Position';
    _settings = _$PositionSettingsFromJson(widget.config.controller.getBoxSettingsJson(widget.id));
    widget.config.controller.configure(onUpdate: _processData, paths: {'navigation.position'});
    _llf = LatLongFormatter(_settings.format);
  }

  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      _latitude = _longitude = 0;
    }

    text = (_latitude == null || _longitude == null) ?
      '-' :
      _llf.format(LatLong(_latitude!, _longitude!));

    return super.build(context);
  }

  void _processData(List<Update> updates) {
    if(updates[0].value == null) {
      _latitude = _longitude = null;
    } else {
      try {
        _latitude = updates[0].value['latitude'];
        _longitude = updates[0].value['longitude'];
      } catch (e) {
        widget.config.controller.l.e("Error converting $updates", error: e);
      }
    }

    if(mounted) {
      setState(() {});
    }
  }
}

class _PositionSettingsWidget extends BoxSettingsWidget {
  final _PositionSettings _settings;

  const _PositionSettingsWidget(this._settings);

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$PositionSettingsToJson(_settings);
  }

  @override
  createState() => _PositionSettingsState();
}

class _PositionSettingsState extends State<_PositionSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _PositionSettings s = widget._settings;

    List<Widget> list = [
      ListTile(
          leading: const Text("Format:"),
          title: BiTextFormField(
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            initialValue: s.format,
            onChanged: (value) => s.format = value)
      )
    ];

    return ListView(children: list);
  }
}

class MagneticVariationBox extends DoubleValueBox {
  static const String sid = 'navigation-magnetic-variation';
  @override
  String get id => sid;

  const MagneticVariationBox(BoxWidgetConfig config, {super.key}) : super(config, 'Mag Var', 'navigation.magneticVariation', precision: 0, smoothing: false);

  @override
  double convert(double value) {
    return rad2Deg(value).toDouble();
  }

  @override
  String units(double value) {
    return degreesUnits;
  }
}

class RateOfTurnBox extends DoubleValueBox {
  static const String sid = 'navigation-rate-of-turn';
  @override
  String get id => sid;

  const RateOfTurnBox(BoxWidgetConfig config, {super.key}) : super(config, 'Turn Rate', 'navigation.rateOfTurn', precision: 0, portStarboard: true);

  @override
  double convert(double value) {
    return rad2Deg(value).toDouble();
  }

  @override
  String units(double value) {
    return '$degreesUnits/s';
  }
}

class NavigationLogBox extends DoubleValueBox {
  static const String sid = 'navigation-log';
  @override
  String get id => sid;

  const NavigationLogBox(BoxWidgetConfig config, {super.key}) : super(config, 'Log', 'navigation.log', precision: 0, dataType: SignalKDataType.infrequent, smoothing: false);

  @override
  double convert(double value) {
    return config.controller.distanceToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.distanceUnitsToDisplay(value);
  }
}

class NavigationTripLogBox extends DoubleValueBox {
  static const String sid = 'navigation-log-trip';
  @override
  String get id => sid;

  const NavigationTripLogBox(BoxWidgetConfig config, {super.key}) : super(config, 'Trip Log', 'navigation.trip.log', precision: 0, dataType: SignalKDataType.infrequent, smoothing: false);

  @override
  double convert(double value) {
    return config.controller.distanceToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.distanceUnitsToDisplay(value);
  }
}
