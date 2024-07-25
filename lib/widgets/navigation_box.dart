import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:boatinstrument/widgets/gauge_box.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'double_value_box.dart';
import 'package:latlong_formatter/latlong_formatter.dart';

part 'navigation_box.g.dart';

class CrossTrackErrorBox extends DoubleValueBox {
  static const String sid = 'navigation-xte';
  @override
  String get id => sid;

  const CrossTrackErrorBox(config, {super.key}) : super(config, 'XTE', 'navigation.courseGreatCircle.crossTrackError', precision: 2, smoothing: false, portStarboard: true);

  @override
  double convert(double value) {
    return convertDistance(config.controller, value);
  }

  @override
  String units(double value) {
    return distanceUnits(config.controller, value);
  }
}

class CrossTrackErrorDeltaBox extends DoubleValueSemiGaugeBox {
  static const String sid = 'navigation-xte-delta';
  @override
  String get id => sid;

  const CrossTrackErrorDeltaBox(config, {super.key}) : super(config, 'XTE', GaugeOrientation.up, 'navigation.courseGreatCircle.crossTrackError', minValue: -2, maxValue: 2);

  @override
  double convert(double value) {
    return value;
  }

  @override
  String units(double value) {
    return 'delta';
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
  processUpdates(List<Update>? updates) {
    if(updates == null) {
      value = displayValue = null;
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
  static const String sid = 'course-over-ground';
  @override
  String get id => sid;

  const CourseOverGroundBox(config, {super.key}) : super(config, 'COG', 'navigation.courseOverGroundTrue', minLen: 3, precision: 0, angle: true);

  @override
  double convert(double value) {
    return rad2Deg(value) * 1.0;
  }

  @override
  String units(double value) {
    return 'deg';
  }
}

class SpeedOverGroundBox extends SpeedBox {
  static const String sid = 'speed-over-ground';
  @override
  String get id => sid;

  const SpeedOverGroundBox(config, {super.key}) : super(config, 'SOG', 'navigation.speedOverGround');
}

class HeadingBox extends DoubleValueBox {
  static const String sid = 'heading';
  @override
  String get id => sid;

  const HeadingBox(config, {super.key}) : super(config, 'Heading', 'navigation.headingTrue', minLen: 3, precision: 0, angle: true);

  @override
  double convert(double value) {
    return rad2Deg(value) * 1.0;
  }

  @override
  String units(double value) {
    return 'deg';
  }
}

class NextPointDistanceBox extends DoubleValueBox {
  static const String sid = 'navigation-next-point-distance';
  @override
  String get id => sid;

  const NextPointDistanceBox(config, {super.key}) : super(config, 'WPT Distance', 'navigation.courseGreatCircle.nextPoint.distance', precision: 2);

  @override
  double convert(double value) {
    return convertDistance (config.controller, value);
  }

  @override
  String units(double value) {
    return distanceUnits(config.controller, value);
  }
}

class NextPointVelocityMadeGoodBox extends SpeedBox {
  static const String sid = 'navigation-next-point-velocity-made-good';
  @override
  String get id => sid;

  const NextPointVelocityMadeGoodBox(config, {super.key}) : super(config, 'WPT VMG', 'navigation.courseGreatCircle.nextPoint.velocityMadeGood');
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
    String etaString = '';

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

      DateTime now = DateTime.now();
      DateTime eta = now.add(ttg);
      String fmt = '';
      if(eta.year != now.year) {
        fmt = 'yyyy-MM-dd ';
      } else if(eta.month != now.month || eta.day != now.day) {
        fmt = 'MMM-dd ';
      }
      etaString = DateFormat('${fmt}HH:mm').format(DateTime.now().add(ttg));
    }

    double fontSize = maxFontSize(ttgString, style,
        widget.config.constraints.maxHeight - style.fontSize! - (3 * pad),
        widget.config.constraints.maxWidth - (2 * pad));

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Text('WPT TTG $etaString', style: style))]),
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

@JsonSerializable()
class _PositionSettings {
  String latFormat;
  String lonFormat;

  _PositionSettings({
    this.latFormat = '0{lat0d 0m.mmm c}',
    this.lonFormat = '{lon0d 0m.mmm c}'
  });
}

class PositionBox extends BoxWidget {

  const PositionBox(super.config, {super.key});

  @override
  State<PositionBox> createState() => _PositionBoxState();

  static String sid = 'position';
  @override
  String get id => sid;

  @override
  bool get hasSettings => true;

  @override
  BoxSettingsWidget getSettingsWidget(Map<String, dynamic> json) {
    return _PositionSettingsWidget(_$PositionSettingsFromJson(json));
  }

  @override
  Widget? getSettingsHelp() => const Text('For a full list of formats see https://pub.dev/packages/latlong_formatter');
}

class _PositionBoxState extends State<PositionBox> {
  _PositionSettings _settings = _PositionSettings();
  LatLongFormatter _llf = LatLongFormatter('');
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _settings = _$PositionSettingsFromJson(widget.config.controller.configure(widget, onUpdate: _processData, paths: {'navigation.position'}));
    _llf = LatLongFormatter('${_settings.latFormat}\n${_settings.lonFormat}');
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);
    const double pad = 5.0;

    if(widget.config.editMode) {
      _latitude = _longitude = 0;
    }
    String text = (_latitude == null || _longitude == null) ?
    '--- --.--- -\n--- --.--- -' :
    _llf.format(LatLong(_latitude!, _longitude!));

    double fontSize = maxFontSize(text, style,
        (widget.config.constraints.maxHeight - style.fontSize! - (3 * pad)) / 2,
        widget.config.constraints.maxWidth - (2 * pad));

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Text('Position', style: style))]),
      // We need to disable the device text scaling as this interferes with our text scaling.
      Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(pad), child: Text(text, textScaler: TextScaler.noScaling,  style: style.copyWith(fontSize: fontSize)))))

    ]);
  }

  _processData(List<Update>? updates) {
    if(updates == null) {
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
          leading: const Text("Lat Format:"),
          title: TextFormField(
              initialValue: s.latFormat,
              onChanged: (value) => s.latFormat = value)
      ),
      ListTile(
          leading: const Text("Long Format:"),
          title: TextFormField(
              initialValue: s.lonFormat,
              onChanged: (value) => s.lonFormat = value)
      ),
    ];

    return ListView(children: list);
  }
}
