import 'package:flutter/material.dart';
import 'package:format/format.dart' as fmt;
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'double_value_box.dart';

class DepthBox extends DoubleValueBox {
  static const String sid = 'depth';
  @override
  String get id => sid;

  const DepthBox(config, {super.key}) : super(config, 'Depth', 'environment.depth.belowSurface', maxValue: 1000.0, smoothing: false);

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
  static const String sid = 'sea-temperature';
  @override
  String get id => sid;

  const WaterTemperatureBox(config, {super.key}) : super(config, 'Water Temp', 'environment.water.temperature');

  @override
  double convert(double value) {
    switch (config.controller.temperatureUnits) {
      case TemperatureUnits.c:
        return value - 273.15;
      case TemperatureUnits.f:
        return (value - 273.15) * 9/5 + 32;
    }
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

  static String sid = 'set-and-drift';
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
    widget.config.controller.configure(widget, onUpdate: _processData, paths: {'environment.current'});
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
