import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../boatinstrument_controller.dart';
import 'double_value_box.dart';
import 'gauge_box.dart';

part 'boat_box.g.dart';

class SpeedThroughWaterBox extends SpeedBox {
  static const String sid = 'speed-through-water';
  @override
  String get id => sid;

  const SpeedThroughWaterBox(config, {super.key}) : super(config, 'Speed', 'navigation.speedThroughWater');
}

class AttitudeRollGaugeBox extends DoubleValueSemiGaugeBox {
  const AttitudeRollGaugeBox(config, {super.key}) : super(config, 'Roll', GaugeOrientation.down, 'navigation.attitude', minValue: -45, maxValue: 45, mirror: true, angle: true);

  static String sid = 'attitude-roll';
  @override
  String get id => sid;

  @override
  double extractValue(Update update) {
    return (update.value['roll'] as num).toDouble();
  }

  @override
  double convert(double value) {
    return rad2Deg(value).toDouble();
  }

  @override
  String units(double value) {
    return 'deg';
  }
}

@JsonSerializable()
class _RudderAngleSettings {
  bool showLabels;
  int maxAngle;

  _RudderAngleSettings({
    this.showLabels = true,
    this.maxAngle = 30
  });
}

class _RudderAnglePainter extends CustomPainter {
  final BuildContext _context;
  final _RudderAngleSettings _settings;
  final double? _rudderAngle;

  _RudderAnglePainter(this._context, this._settings, this._rudderAngle);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    double max = canvasSize.width/2;

    Paint paint = Paint()..style = PaintingStyle.fill;

    if(_rudderAngle != null) {
      paint.color = (_rudderAngle! < 0) ? Colors.red : Colors.green;

      canvas.drawRect(Rect.fromLTWH(
          max, 0, max / (_settings.maxAngle / rad2Deg(_rudderAngle)),
          canvasSize.height), paint);
    }

    paint.color = Theme.of(_context).colorScheme.onSurface;
    TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    try {
      canvas.translate(max, 0);
      for (int a = 0; a <= _settings.maxAngle; a += 10) {
        double x = max / (_settings.maxAngle / a);

        canvas.drawRect(Rect.fromLTWH(x - 1, 0, 2, canvasSize.height), paint);
        canvas.drawRect(Rect.fromLTWH(-x - 1, 0, 2, canvasSize.height), paint);

        if (_settings.showLabels && a != 0) {
          tp.text = TextSpan(text: a.toString(), style: Theme
              .of(_context)
              .textTheme
              .bodyMedium);
          tp.layout();

          tp.paint(canvas, Offset(x - tp.size.width - 2, 0));
          tp.paint(canvas, Offset(-x + 2, 0));
        }
      }
    } finally {
      tp.dispose();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RudderAngleBox extends BoxWidget {
  late final _RudderAngleSettings _settings;

  RudderAngleBox(super.config, {super.key}) {
    _settings = _$RudderAngleSettingsFromJson(config.settings);
  }

  @override
  State<RudderAngleBox> createState() => _RudderAngleBoxState();

  static String sid = 'rudder-angle';
  @override
  String get id => sid;

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _SettingsWidget(_settings);
  }
}

class _RudderAngleBoxState extends State<RudderAngleBox> {
  double? _rudderAngle;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(widget, onUpdate: _processData, paths: {
      "steering.rudderAngle",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(5.0), child: CustomPaint(size: Size.infinite, painter: _RudderAnglePainter(context, widget._settings, _rudderAngle)));
  }

  _processData(List<Update>? updates) {
    if(updates == null) {
      _rudderAngle = null;
    } else {
      try {
        _rudderAngle = (updates[0].value as num).toDouble();
      } catch (e) {
        widget.config.controller.l.e("Error converting $updates", error: e);
      }
    }

    if(mounted) {
      setState(() {});
    }
  }
}

class _SettingsWidget extends BoxSettingsWidget {
  final _RudderAngleSettings _settings;

  const _SettingsWidget(this._settings);

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$RudderAngleSettingsToJson(_settings);
  }

  @override
  createState() => _SettingsState();
}

class _SettingsState extends State<_SettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _RudderAngleSettings s = widget._settings;

    return ListView(children: [
      SwitchListTile(title: const Text("Show Labels:"),
          value: s.showLabels,
          onChanged: (bool value) {
            setState(() {
              s.showLabels = value;
            });
          }),
      ListTile(
        leading: const Text("Max Angle:"),
        title: Slider(
            min: 20,
            max: 90,
            divisions: 71,
            value: s.maxAngle.toDouble(),
            label: "${s.maxAngle.toInt()}",
            onChanged: (double value) {
              setState(() {
                s.maxAngle = value.toInt();
              });
            }),
      ),
    ]);
  }
}
