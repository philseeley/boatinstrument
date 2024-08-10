import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:format/format.dart' as fmt;
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'double_value_box.dart';

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

class SunlightBox extends BoxWidget {
  static const String sid = 'environment-sun';
  @override
  String get id => sid;

  const SunlightBox(super.config, {super.key});

  @override
  Widget? getHelp() => const Text('Ensure the signalk-derived-data plugin is installed on signalk and the "Sets environment.sunlight.times.*" is enabled.');

  @override
  State<SunlightBox> createState() => _SunlightBox();
}

class _SunlightBox extends State<SunlightBox> {
  DateTime? _rise, _set, _dawn, _dusk, _nauticalDawn, _nauticalDusk, _solarNoon;
  final fmt = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(_onUpdate, ['environment.sunlight.times.*'], dataTimeout: false);
  }

  @override
  Widget build(BuildContext context) {
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
