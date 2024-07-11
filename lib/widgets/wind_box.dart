import 'dart:math' as m;
import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'double_value_box.dart';

class WindSpeedTrueBeaufortBox extends BoxWidget {

  const WindSpeedTrueBeaufortBox(super.config, {super.key});

  @override
  State<WindSpeedTrueBeaufortBox> createState() => _WindSpeedTrueBeaufortBoxState();

  static String sid = 'wind-speed-true-beaufort';
  @override
  String get id => sid;
}

class _WindSpeedTrueBeaufortBoxState extends State<WindSpeedTrueBeaufortBox> {
  double? _windSpeedTrue;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(widget, onUpdate: _processData, paths: {'environment.wind.speedTrue'});
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);
    const double pad = 5.0;

    if(widget.config.editMode) {
      _windSpeedTrue = 12.3;
    }

    String force = (_windSpeedTrue == null) ? '-' : 'F${m.pow(_windSpeedTrue!/0.836, 1.0/1.5).round()}';

    double fontSize = maxFontSize(force, style,
        widget.config.constraints.maxHeight - style.fontSize! - (3 * pad),
        widget.config.constraints.maxWidth - (2 * pad));

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Text('True Wind', style: style))]),
      // We need to disable the device text scaling as this interferes with our text scaling.
      Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(pad), child: Text(force, textScaler: TextScaler.noScaling,  style: style.copyWith(fontSize: fontSize)))))

    ]);
  }

  _processData(List<Update>? updates) {
    if(updates == null) {
      _windSpeedTrue = null;
    } else {
      try {
        _windSpeedTrue = (updates[0].value as num).toDouble();
      } catch (e) {
        widget.config.controller.l.e("Error converting $updates", error: e);
      }
    }

    if(mounted) {
      setState(() {});
    }
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
