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

  const WindSpeedApparentBox(config, {super.valueToDisplay, super.key}) : super(config, 'AWS', 'environment.wind.speedApparent');
}

class MaxWindSpeedApparentBox extends WindSpeedApparentBox {
  static const String sid = 'wind-speed-apparent-max';
  @override
  String get id => sid;

  const MaxWindSpeedApparentBox(super.config, {super.key, super.valueToDisplay = DoubleValueToDisplay.maximumValue});
}

class WindSpeedTrueBox extends WindSpeedBox {
  static const String sid = 'wind-speed-true';
  @override
  String get id => sid;

  const WindSpeedTrueBox(config, {super.valueToDisplay, super.key}) : super(config, 'TWS', 'environment.wind.speedTrue');
}

class MaxWindSpeedTrueBox extends WindSpeedTrueBox {
  static const String sid = 'wind-speed-true-max';
  @override
  String get id => sid;

  const MaxWindSpeedTrueBox(super.config, {super.key, super.valueToDisplay = DoubleValueToDisplay.maximumValue});
}

abstract class WindSpeedBox extends DoubleValueBox {

  const WindSpeedBox(super.config, super.title, super.path, {super.valueToDisplay, super.key});

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

class TrueWindSpeedGraphBackground extends BackgroundData {
  static double? _value;
  static CircularBuffer<DataPoint> _data = CircularBuffer(BackgroundData.dataIncrement);

  TrueWindSpeedGraphBackground({controller}) : super(controller: controller, TrueWindSpeedGraph.sid, {'environment.wind.speedTrue'});

  @override
  CircularBuffer<DataPoint> get data => _data;
  @override
  set data(CircularBuffer<DataPoint> data) => _data = data;

  @override
  double? get value => _value;
  @override
  set value(double? value) => _value = value;
}

class TrueWindSpeedGraph extends GraphBox {
  static const String sid = 'wind-speed-true-graph';
  @override
  String get id => sid;

  final TrueWindSpeedGraphBackground background = TrueWindSpeedGraphBackground();

  @override
  List<DataPoint> get data => background.data;

  TrueWindSpeedGraph(BoxWidgetConfig config, {super.key}) : super(config, 'TWS', step: kts2ms(5),
  ranges: [
        GaugeRange(kts2ms(10), kts2ms(10), Colors.green),
        GaugeRange(kts2ms(20), kts2ms(20), Colors.orange),
        GaugeRange(kts2ms(30), kts2ms(30), Colors.red),
      ]);

  @override
  double convert(double value) {
    return config.controller.windSpeedToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.windSpeedUnits.unit;
  }
}

class ApparentWindSpeedGraphBackground extends BackgroundData {
  static double? _value;
  static CircularBuffer<DataPoint> _data = CircularBuffer(BackgroundData.dataIncrement);

  ApparentWindSpeedGraphBackground({controller}) : super(controller: controller, ApparentWindSpeedGraph.sid, {'environment.wind.speedApparent'});

  @override
  CircularBuffer<DataPoint> get data => _data;
  @override
  set data(CircularBuffer<DataPoint> data) => _data = data;

  @override
  double? get value => _value;
  @override
  set value(double? value) => _value = value;
}

class ApparentWindSpeedGraph extends GraphBox {
  static const String sid = 'wind-speed-apparent-graph';
  @override
  String get id => sid;

  final ApparentWindSpeedGraphBackground background = ApparentWindSpeedGraphBackground();

  @override
  List<DataPoint> get data => background.data;

  ApparentWindSpeedGraph(BoxWidgetConfig config, {super.key}) : super(config, 'AWS', step: kts2ms(5),
  ranges: [
        GaugeRange(kts2ms(10), kts2ms(10), Colors.green),
        GaugeRange(kts2ms(20), kts2ms(20), Colors.orange),
        GaugeRange(kts2ms(30), kts2ms(30), Colors.red),
      ]);

  @override
  double convert(double value) {
    return config.controller.windSpeedToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.windSpeedUnits.unit;
  }
}
