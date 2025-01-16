import 'dart:math';
import 'package:boatinstrument/widgets/gauge_box.dart';
import 'package:circular_buffer/circular_buffer.dart';
import 'package:flutter/material.dart';
import 'package:format/format.dart' as fmt;
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:json_annotation/json_annotation.dart';
import 'double_value_box.dart';

part 'wind_box.g.dart';

class WindSpeedTrueBeaufortBox extends DoubleValueBox {

  const WindSpeedTrueBeaufortBox(config, {super.key}) : super(config, 'True Wind', 'environment.wind.speedTrue');

  @override
  DoubleValueBoxState<WindSpeedTrueBeaufortBox> createState() => _WindSpeedTrueBeaufortBoxState();

  static String sid = 'wind-speed-true-beaufort';
  @override
  String get id => sid;

  @override
  double convert(double value) {
    return value;
  }

  @override
  String units(double value) {
    throw UnimplementedError();
  }
}

class _WindSpeedTrueBeaufortBoxState extends DoubleValueBoxState<WindSpeedTrueBeaufortBox> {

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);
    const double pad = 5.0;

    if(widget.config.editMode) {
      displayValue = 12.3;
    }

    String force = (displayValue == null) ? '-' : 'F${pow(displayValue!/0.836, 1.0/1.5).round()}';

    double fontSize = maxFontSize(force, style,
        widget.config.constraints.maxHeight - style.fontSize! - (3 * pad),
        widget.config.constraints.maxWidth - (2 * pad));

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Text(widget.title, style: style))]),
      // We need to disable the device text scaling as this interferes with our text scaling.
      Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(pad), child: Text(force, textScaler: TextScaler.noScaling,  style: style.copyWith(fontSize: fontSize)))))

    ]);
  }
}

class WindSpeedApparentBox extends WindSpeedBox {
  static const String sid = 'wind-speed-apparent';
  @override
  String get id => sid;

  const WindSpeedApparentBox(config, {super.key}) : super(config, 'AWS', 'environment.wind.speedApparent');
}

class WindSpeedTrueBox extends WindSpeedBox {
  static const String sid = 'wind-speed-true';
  @override
  String get id => sid;

  const WindSpeedTrueBox(config, {super.key}) : super(config, 'TWS', 'environment.wind.speedTrue');
}

abstract class WindSpeedBox extends DoubleValueBox {

  const WindSpeedBox(super.config, super.title, super.path, {super.key});

  @override
  double convert(double value) {
    return config.controller.windSpeedToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.windSpeedUnits.unit;
  }
}

@JsonSerializable()
class _WindDirectionSettings {
  bool cardinalPrimary;

  _WindDirectionSettings({this.cardinalPrimary = true});
}

class WindDirectionTrueBox extends DoubleValueBox {
  late final _WindDirectionSettings _settings;

  WindDirectionTrueBox(config, {super.key}) : super(config, 'TWD', 'environment.wind.directionTrue', angle: true) {
    _settings = _$WindDirectionSettingsFromJson(config.settings);
  }

  @override
  DoubleValueBoxState<WindDirectionTrueBox> createState() => _WindDirectionTrueBoxState();

  static String sid = 'wind-direction-true';
  @override
  String get id => sid;

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _WindDirectionSettingsWidget(_settings);
  }

  @override
  double convert(double value) {
    return value;
  }

  @override
  String units(double value) {
    throw UnimplementedError();
  }
}

class _WindDirectionTrueBoxState extends DoubleValueBoxState<WindDirectionTrueBox> {
  static const List<String> _cardinalDirections = [
    'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S',
    'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW', 'N'
  ];

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);
    const double pad = 5.0;

    if(widget.config.editMode) {
      displayValue = deg2Rad(123);
    }

    String direction = (displayValue == null) ?
    '-' : fmt.format('{:${3}d}', rad2Deg(displayValue));

    const f = (2*pi)/16;
    String cardinal = (displayValue == null) ? '-' : _cardinalDirections[((displayValue!+(f/2))/f).toInt()];

    String primaryText = direction;
    String subText = cardinal;
    if(widget._settings.cardinalPrimary) {
      primaryText = cardinal;
      subText = direction;
    }

    double fontSize = maxFontSize(primaryText, style,
        (widget.config.constraints.maxHeight - style.fontSize! - (3 * pad)),
        widget.config.constraints.maxWidth - (2 * pad));

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Text('${widget.title} deg $subText', style: style))]),
      // We need to disable the device text scaling as this interferes with our text scaling.
      Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(pad), child: Text(primaryText, textScaler: TextScaler.noScaling,  style: style.copyWith(fontSize: fontSize)))))

    ]);
  }
}

class _WindDirectionSettingsWidget extends BoxSettingsWidget {
  final _WindDirectionSettings _settings;

  const _WindDirectionSettingsWidget(this._settings);

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$WindDirectionSettingsToJson(_settings);
  }

  @override
  createState() => _SettingsState();
}

class _SettingsState extends State<_WindDirectionSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _WindDirectionSettings s = widget._settings;

    return ListView(children: [
      SwitchListTile(title: const Text("Primary Cardinal:"),
          value: s.cardinalPrimary,
          onChanged: (bool value) {
            setState(() {
              s.cardinalPrimary = value;
            });
          }),
    ]);
  }
}

class WindAngleApparentBox extends DoubleValueBox {
  static const String sid = 'wind-apparent-angle';
  @override
  String get id => sid;

  const WindAngleApparentBox(config, {super.key}) : super(config, 'AWA', 'environment.wind.angleApparent', minLen: 3, precision: 0, angle: true, relativeAngle: true, portStarboard: true);

  @override
  double convert(double value) {
    return rad2Deg(value).toDouble();
  }

  @override
  String units(double value) {
    return degreesUnits;
  }
}

class ApparentWindSpeedGraphBackground extends GraphBackground {
  static double _value = 0;
  static final CircularBuffer<DataPoint> _data = CircularBuffer(1000);

  ApparentWindSpeedGraphBackground({controller}) : super(controller: controller, 'environment.wind.speedApparent');

  @override
  List<DataPoint> get data => _data.toList();
  @override
  double get value => _value;
  @override
  set value(double value) => _value = value;

  @override
  void addDataPoint(DataPoint dataPoint) {
    _data.add(dataPoint);
  }
}

class ApparentWindSpeedGraph extends GraphBox {
  static const String sid = 'wind-speed-apparent-graph';
  @override
  String get id => sid;

  late final ApparentWindSpeedGraphBackground background;

  @override
  List<DataPoint> get data => background.data;

  ApparentWindSpeedGraph(BoxWidgetConfig config, {super.key}) : super(config, 'AWS', step: 5,
  ranges: [
        GaugeRange(config.controller.windSpeedFromDisplay(10), config.controller.windSpeedFromDisplay(10), Colors.green),
        GaugeRange(config.controller.windSpeedFromDisplay(20), config.controller.windSpeedFromDisplay(20), Colors.orange),
        GaugeRange(config.controller.windSpeedFromDisplay(30), config.controller.windSpeedFromDisplay(30), Colors.red),
      ]) {
        background = ApparentWindSpeedGraphBackground();
      }

  @override
  double convert(double value) {
    return config.controller.windSpeedToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.windSpeedUnits.unit;
  }
}