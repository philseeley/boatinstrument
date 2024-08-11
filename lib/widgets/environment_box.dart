import 'dart:math' as m;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:format/format.dart' as fmt;
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:moon_phase_plus/moon_phase_plus.dart';
import 'double_value_box.dart';

part 'environment_box.g.dart';

class DepthBelowSurfaceBox extends DoubleValueBox {
  static const String sid = 'environment-depth-belowSurface';
  @override
  String get id => sid;

  const DepthBelowSurfaceBox(config, {super.key}) : super(config, 'Depth', 'environment.depth.belowSurface', maxValue: 1000.0, smoothing: false);

  @override
  double convert(double value) {
    switch (config.controller.depthUnits) {
      case DepthUnits.m:
        return value;
      case DepthUnits.ft:
        return value * 3.28084;
      case DepthUnits.fa:
        return value * 0.546807;
    }
  }

  @override
  String units(double value) {
    return config.controller.depthUnits.unit;
  }
}

class WaterTemperatureBox extends DoubleValueBox {
  static const String sid = 'environment-water-temperature';
  @override
  String get id => sid;

  const WaterTemperatureBox(config, {super.key}) : super(config, 'Water Temp', 'environment.water.temperature');

  @override
  double convert(double value) {
    return convertTemperature(config.controller, value);
  }

  @override
  String units(double value) {
    return config.controller.temperatureUnits.unit;
  }
}

class SetAndDriftBox extends BoxWidget {

  const SetAndDriftBox(super.config, {super.key});

  @override
  State<SetAndDriftBox> createState() => _SetAndDriftBoxState();

  static String sid = 'environment-set-and-drift';
  @override
  String get id => sid;
}

class _SetAndDriftBoxState extends State<SetAndDriftBox> {
  double? _set;
  double? _drift;
  double? _displayDrift;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(_processData, ['environment.current']);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);
    const double pad = 5.0;

    if(widget.config.editMode) {
      _set = deg2Rad(123);
      _displayDrift = 12.3;
    }

    String text = (_set == null || _displayDrift == null) ?
      '-\n-' :
      fmt.format('{:3}\n{:.1f}', rad2Deg(_set), _displayDrift);

    double fontSize = maxFontSize(text, style,
        (widget.config.constraints.maxHeight - style.fontSize! - (3 * pad)) / 2,
        widget.config.constraints.maxWidth - (2 * pad));

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Text('Set&Drift deg-${widget.config.controller.speedUnits.unit}', style: style))]),
      // We need to disable the device text scaling as this interferes with our text scaling.
      Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(pad), child: Text(text, textScaler: TextScaler.noScaling,  style: style.copyWith(fontSize: fontSize)))))
    ]);
  }

  _processData(List<Update>? updates) {
    if(updates == null) {
      _set = _drift = _displayDrift = null;
    } else {
      try {
        double next = (updates[0].value['setTrue'] as num).toDouble();
        _set = averageAngle(_set ?? next, next,
            smooth: widget.config.controller.valueSmoothing);
        next = (updates[0].value['drift'] as num).toDouble();
        _drift = averageDouble(_drift ?? next, next,
            smooth: widget.config.controller.valueSmoothing);

        _displayDrift = convertSpeed(widget.config.controller.speedUnits, _drift!);
      } catch (e) {
        widget.config.controller.l.e("Error converting $updates", error: e);
      }
    }

    if(mounted) {
      setState(() {});
    }
  }
}

class OutsideTemperatureBox extends DoubleValueBox {
  static const String sid = 'environment-outside-temperature';
  @override
  String get id => sid;

  const OutsideTemperatureBox(config, {super.key}) : super(config, 'Outside Temp', 'environment.outside.temperature');

  @override
  double convert(double value) {
    return convertTemperature(config.controller, value);
  }

  @override
  String units(double value) {
    return config.controller.temperatureUnits.unit;
  }
}

class OutsidePressureBox extends DoubleValueBox {
  static const String sid = 'environment-outside-pressure';
  @override
  String get id => sid;

  const OutsidePressureBox(config, {super.key}) : super(config, 'Pressure', 'environment.outside.pressure');

  @override
  double convert(double value) {
    return convertPressure(config.controller, value);
  }

  @override
  String units(double value) {
    return config.controller.pressureUnits.unit;
  }
}

@JsonSerializable()
class _CelestialSettings {
  String timeFormat;

  _CelestialSettings({
    this.timeFormat = 'HH:mm'
  });
}

abstract class CelestialBox extends BoxWidget {
  static const String sid = 'environment-celestial';
  @override
  String get id => sid;

  late final _CelestialSettings _settings;

  CelestialBox(super.config, {super.key}) {
    _settings = _$CelestialSettingsFromJson(config.controller.getBoxSettingsJson(sid));
  }

  @override
  bool get hasSettings => true;

  @override
  BoxSettingsWidget getSettingsWidget(Map<String, dynamic> json) {
    return _CelestialSettingsWidget(_$CelestialSettingsFromJson(json));
  }

  @override
  Widget? getSettingsHelp() => const Text('For a full list of formats see https://api.flutter.dev/flutter/intl/DateFormat-class.html');
}

class _CelestialSettingsWidget extends BoxSettingsWidget {
  final _CelestialSettings _settings;

  const _CelestialSettingsWidget(this._settings);

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$CelestialSettingsToJson(_settings);
  }

  @override
  createState() => _CelestialSettingsState();
}

class _CelestialSettingsState extends State<_CelestialSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _CelestialSettings s = widget._settings;

    return ListView(children: [
      ListTile(
          leading: const Text('Time Format:'),
          title: TextFormField(
              initialValue: s.timeFormat,
              onChanged: (value) => s.timeFormat = value)
      ),
    ]);
  }
}

class SunlightBox extends CelestialBox {
  static const String sid = 'environment-sun';

  SunlightBox(super.config, {super.key});

  @override
  Widget? getHelp() => const Text('Ensure the signalk-derived-data plugin is installed on signalk and the "Sets environment.sunlight.times.*" is enabled.');

  @override
  State<SunlightBox> createState() => _SunlightBox();
}

class _SunlightBox extends State<SunlightBox> {
  DateTime? _rise, _set, _dawn, _dusk, _nauticalDawn, _nauticalDusk, _solarNoon;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(_onUpdate, ['environment.sunlight.times.*'], dataTimeout: false);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat(widget._settings.timeFormat);

    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);
    const double pad = 5.0;

    if(widget.config.editMode) {
      _rise = _set = _dawn = _dusk = _nauticalDawn = _nauticalDusk = _solarNoon = DateTime.now();
    }

    String text =
'''Rise:     ${(_rise == null) ? '-' : fmt.format(_rise!)}
Set:      ${(_set == null) ? '-' : fmt.format(_set!)}
Dawn:     ${(_dawn == null) ? '-' : fmt.format(_dawn!)}
Dusk:     ${(_dusk == null) ? '-' : fmt.format(_dusk!)}
Naut Dwn: ${(_nauticalDawn == null) ? '-' : fmt.format(_nauticalDawn!)}
Naut Dsk: ${(_nauticalDusk == null) ? '-' : fmt.format(_nauticalDusk!)}
Sol Noon: ${(_solarNoon == null) ? '-' : fmt.format(_solarNoon!)}''';

    double fontSize = maxFontSize(text, style,
        (widget.config.constraints.maxHeight - style.fontSize! - (3 * pad)) / 7,
        widget.config.constraints.maxWidth - (2 * pad));

    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Row(children: [Text('Sunlight', style: style)])),
      // We need to disable the device text scaling as this interferes with our text scaling.
      Padding(padding: const EdgeInsets.all(pad), child: Row(children: [Text(text, textScaler: TextScaler.noScaling,  style: style.copyWith(fontSize: fontSize))]))
    ]);
  }

  void _onUpdate(List<Update>? updates) {
    if(updates == null) {
      _rise = _set = _dawn = _dusk = _nauticalDawn = _nauticalDusk = _solarNoon = null;
    } else {
      for (Update u in updates) {
        try {
          DateTime dt = DateTime.parse(u.value).toLocal();

          switch (u.path) {
            case 'environment.sunlight.times.sunrise':
              _rise = dt;
              break;
            case 'environment.sunlight.times.sunset':
              _set = dt;
              break;
            case 'environment.sunlight.times.dawn':
              _dawn = dt;
              break;
            case 'environment.sunlight.times.dusk':
              _dusk = dt;
              break;
            case 'environment.sunlight.times.nauticalDawn':
              _nauticalDawn = dt;
              break;
            case 'environment.sunlight.times.nauticalDusk':
              _nauticalDusk = dt;
              break;
            case 'environment.sunlight.times.solarNoon':
              _solarNoon = dt;
              break;
          }
        } catch (e) {
          widget.config.controller.l.e("Error converting $u", error: e);
        }
      }
    }

    if(mounted) {
      setState(() {});
    }
  }
}

@JsonSerializable()
class _MoonPerBoxSettings {
  bool showMoon;

  _MoonPerBoxSettings({
    this.showMoon = true
  });
}

class MoonBox extends CelestialBox {
  static const String sid = 'environment-moon';

  late final _MoonPerBoxSettings _perBoxSettings;

  MoonBox(super.config, {super.key}) {
    _perBoxSettings = _$MoonPerBoxSettingsFromJson(config.settings);
  }

  @override
  Widget? getHelp() => const Text('Ensure the signalk-derived-data plugin is installed on signalk and the "Sets environment.moon.*" is enabled.');

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _MoonPerBoxSettingsWidget(_perBoxSettings);
  }

  @override
  State<MoonBox> createState() => _MoonBox();
}

class _MoonBox extends State<MoonBox> {

  DateTime? _rise, _set;
  double? _fraction;
  String? _phaseName;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(_onUpdate, ['environment.moon.*'], dataTimeout: false);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat(widget._settings.timeFormat);

    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);
    const double pad = 5.0;

    if(widget.config.editMode) {
      _rise = _set = DateTime.now();
      _phaseName = 'Full';
    }

    String text =
'''Rise:  ${(_rise == null) ? '-' : fmt.format(_rise!)}
Set:   ${(_set == null) ? '-' : fmt.format(_set!)}
Phase: ${(_fraction == null) ? '-' : (_fraction!*100).toInt()}%
${(_phaseName == null) ? '-' : _phaseName}''';

    double fontSize = maxFontSize(text, style,
        (widget.config.constraints.maxHeight - style.fontSize! - (3 * pad)) / 4,
        widget.config.constraints.maxWidth - (2 * pad));

    List<Widget> stack = [];
    if(widget._perBoxSettings.showMoon) {
      double min = m.min(widget.config.constraints.maxWidth, widget.config.constraints.maxHeight)-(2*pad);
      stack.add(Center(child: RepaintBoundary(child: MoonWidget(date: DateTime.now(), size: min, resolution: min*min))));
    }

    stack.add(Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Row(children: [Text('Moon', style: style)])),
      // We need to disable the device text scaling as this interferes with our text scaling.
      Padding(padding: const EdgeInsets.all(pad), child: Row(children: [Text(text, textScaler: TextScaler.noScaling,  style: style.copyWith(fontSize: fontSize))])),
    ]));

    return Stack(children: stack);
  }

  void _onUpdate(List<Update>? updates) {
    if(updates == null) {
      _rise = _set = _phaseName = null;
    } else {
      for (Update u in updates) {
        try {
          switch (u.path) {
            case 'environment.moon.times.rise':
              _rise = DateTime.parse(u.value).toLocal();
              break;
            case 'environment.moon.times.set':
              _set = DateTime.parse(u.value).toLocal();
              break;
            case 'environment.moon.fraction':
              _fraction = (u.value as num).toDouble();
              break;
            case 'environment.moon.phaseName':
              _phaseName = u.value;
              break;
          }
        } catch (e) {
          widget.config.controller.l.e("Error converting $u", error: e);
        }
      }
    }

    if(mounted) {
      setState(() {});
    }
  }
}

class _MoonPerBoxSettingsWidget extends BoxSettingsWidget {
  final _MoonPerBoxSettings _perBoxSettings;

  const _MoonPerBoxSettingsWidget(this._perBoxSettings);

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$MoonPerBoxSettingsToJson(_perBoxSettings);
  }

  @override
  createState() => _MoonPerBoxSettingsState();
}

class _MoonPerBoxSettingsState extends State<_MoonPerBoxSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _MoonPerBoxSettings s = widget._perBoxSettings;

    return ListView(children: [
      SwitchListTile(title: const Text('Show Moon:'),
          value: s.showMoon,
          onChanged: (bool value) {
            setState(() {
              s.showMoon = value;
            });
          }),
    ]);
  }
}
