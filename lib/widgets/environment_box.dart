import 'package:flutter/material.dart';
import 'package:format/format.dart' as fmt;
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'double_value_box.dart';

class DepthBox extends DoubleValueBox {
  static const String sid = 'depth';
  @override
  String get id => sid;

  DepthBox(config, {super.key}) : super(config, 'Depth', 'environment.depth.belowSurface', maxValue: 1000.0, smoothing: false) {
    super.convert = _convertDepth;
    super.units = _depthUnits;
  }

  double _convertDepth(double depth) {
    switch (config.controller.depthUnits) {
      case DepthUnits.m:
        return depth;
      case DepthUnits.ft:
        return depth * 3.28084;
      case DepthUnits.fa:
        return depth * 0.546807;
    }
  }

  String _depthUnits(_) {
    return config.controller.depthUnits.unit;
  }
}

class WaterTemperatureBox extends DoubleValueBox {
  static const String sid = 'sea-temperature';
  @override
  String get id => sid;

  WaterTemperatureBox(config, {super.key}) : super(config, 'Water Temp', 'environment.water.temperature') {
    super.convert = _convertTemp;
    super.units = _tempUnits;
  }

  double _convertTemp(double temp) {
    switch (config.controller.temperatureUnits) {
      case TemperatureUnits.c:
        return temp - 273.15;
      case TemperatureUnits.f:
        return (temp - 273.15) * 9/5 + 32;
    }
  }

  String _tempUnits(_) {
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
  int? _set;
  double? _drift;

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
      _set = 123;
      _drift = 12.3;
    }

    String text = (_set == null || _drift == null) ?
      '-\n-' :
      fmt.format('{:3}\n{:.1f}', _set!, _drift);

    double fontSize = maxFontSize(text, style,
        (widget.config.constraints.maxHeight - style.fontSize! - (3 * pad)) / 2,
        widget.config.constraints.maxWidth - (2 * pad));

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Text('Set&Drift ${widget.config.controller.speedUnits.unit}', style: style))]),
      // We need to disable the device text scaling as this interferes with our text scaling.
      Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(pad), child: Text(text, textScaler: TextScaler.noScaling,  style: style.copyWith(fontSize: fontSize)))))

    ]);
  }

  _processData(List<Update>? updates) {
    if(updates == null) {
      _set = _drift = null;
    } else {
      try {
        _set = rad2Deg((updates[0].value['setTrue'] as num).toDouble());
        _drift = convertSpeed(widget.config.controller.speedUnits, (updates[0].value['drift'] as num).toDouble());
      } catch (e) {
        widget.config.controller.l.e("Error converting $updates", error: e);
      }
    }

    if(mounted) {
      setState(() {});
    }
  }
}
