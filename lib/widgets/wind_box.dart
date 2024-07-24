import 'dart:math';
import 'package:flutter/material.dart';
import 'package:format/format.dart' as fmt;
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:json_annotation/json_annotation.dart';
import 'double_value_box.dart';

part 'wind_box.g.dart';

class WindSpeedTrueBeaufortBox extends DoubleValueBox {

  const WindSpeedTrueBeaufortBox(config, {super.key}) : super(config, 'True Wind', 'environment.wind.speedTrue');

  @override
  DoubleValueBoxState createState() => _WindSpeedTrueBeaufortBoxState();

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

class _WindSpeedTrueBeaufortBoxState extends DoubleValueBoxState {

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
    return convertSpeed(config.controller.windSpeedUnits, value);
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

class WindDirectionTrueBox extends BoxWidget {
  late final _WindDirectionSettings _settings;

  WindDirectionTrueBox(super.config, {super.key})  {
    _settings = _$WindDirectionSettingsFromJson(config.settings);
  }

  @override
  State<WindDirectionTrueBox> createState() => _WindDirectionTrueBoxState();

  static String sid = 'wind-direction-true';
  @override
  String get id => sid;

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _WindDirectionSettingsWidget(_settings);
  }
}

class _WindDirectionTrueBoxState extends State<WindDirectionTrueBox> {
  static const List<String> _cardinalDirections = [
    'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S',
    'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW', 'N'
  ];

  double? _direction;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(widget, onUpdate: _processData, paths: {'environment.wind.directionTrue'});
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);
    const double pad = 5.0;

    if(widget.config.editMode) {
      _direction = deg2Rad(123);
    }

    String direction = (_direction == null) ?
    '-' : fmt.format('{:${3}d}', rad2Deg(_direction));

    const f = (2*pi)/16;
    String cardinal = (_direction == null) ? '-' : _cardinalDirections[((_direction!+(f/2))/f).toInt()];

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
      Row(children: [Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Text('TWD deg $subText', style: style))]),
      // We need to disable the device text scaling as this interferes with our text scaling.
      Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(pad), child: Text(primaryText, textScaler: TextScaler.noScaling,  style: style.copyWith(fontSize: fontSize)))))

    ]);
  }

  _processData(List<Update>? updates) {
    if(updates == null) {
      _direction = null;
    } else {
      try {
        double next = (updates[0].value as num).toDouble();

        _direction = averageAngle(_direction ?? next, next,
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
