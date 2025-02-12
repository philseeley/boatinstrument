import 'dart:math';

import 'package:circular_buffer/circular_buffer.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../boatinstrument_controller.dart';
import 'double_value_box.dart';
import 'gauge_box.dart';

part 'boat_box.g.dart';

class SpeedThroughWaterBox extends SpeedBox {
  static const String sid = 'boat-speed-through-water';
  @override
  String get id => sid;

  const SpeedThroughWaterBox(config, {super.key}) : super(config, 'Speed', 'navigation.speedThroughWater');
}

class SpeedThroughWaterGraphBackground extends BackgroundData {
  static double? _value;
  static CircularBuffer<DataPoint> _data = CircularBuffer(BackgroundData.dataIncrement);

  SpeedThroughWaterGraphBackground({controller}) : super(controller: controller, SpeedThroughWaterGraph.sid, 'navigation.speedThroughWater');

  @override
  CircularBuffer<DataPoint> get data => _data;
  @override
  set data(CircularBuffer<DataPoint> data) => _data = data;

  @override
  double? get value => _value;
  @override
  set value(double? value) => _value = value;
}

class SpeedThroughWaterGraph extends GraphBox {
  static const String sid = 'boat-speed-through-water-graph';
  @override
  String get id => sid;

  final SpeedThroughWaterGraphBackground background = SpeedThroughWaterGraphBackground();

  @override
  List<DataPoint> get data => background.data;

  SpeedThroughWaterGraph(BoxWidgetConfig config, {super.key}) : super(config, 'Speed', step: kts2ms(1), zeroBase: false);

  @override
  double convert(double value) {
    return config.controller.speedToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.speedUnits.unit;
  }
}

class AttitudeRollGaugeBox extends DoubleValueSemiGaugeBox {
  const AttitudeRollGaugeBox(config, {super.key}) : super(
    config,
    'Roll',
    GaugeOrientation.down,
    'navigation.attitude',
    minValue: -pi/4,
    maxValue: pi/4,
    step: pi/40,
    mirror: true,
    angle: true,
    relativeAngle: true,
    smoothing: false);

  static String sid = 'boat-attitude-roll';
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
    return degreesUnits;
  }
}

@JsonSerializable()
class _RudderAngleSettings {
  bool showLabels;
  int maxAngle;
  bool autoScale;

  _RudderAngleSettings({
    this.showLabels = true,
    this.maxAngle = 30,
    this.autoScale = true
  });
}

class _RudderAnglePainter extends CustomPainter {
  final BoatInstrumentController _controller;
  final BuildContext _context;
  final _RudderAngleSettings _settings;
  final double? _rudderAngle;

  _RudderAnglePainter(this._controller, this._context, this._settings, this._rudderAngle);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    int maxAngle = _settings.maxAngle;
    int rudderAngle = rad2Deg((_rudderAngle??0).abs());
    double max = canvasSize.width/2;

    Paint paint = Paint()..style = PaintingStyle.fill;

    double d = 0;
    double sign = (_rudderAngle??0)<0 ? -1 : 1;

    if(_settings.autoScale) {
      while(rudderAngle > maxAngle) {
        maxAngle += 10;
      }
    }

    if(_rudderAngle != null) {
      paint.color = _controller.val2PSColor(_context, _rudderAngle);

      double w = max / (maxAngle / rudderAngle);
      if(w - max > 0) {
        d = w - max;
        w = max;
      }
      canvas.drawRect(Rect.fromLTWH(
          max, 0, w*sign,
          canvasSize.height), paint);
    }

    canvas.save();
    canvas.translate(max, 0);

    paint.color = Theme.of(_context).colorScheme.onSurface;
    TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    try {
      for (int a = 0; a <= maxAngle; a += 10) {
        double x = max / (maxAngle / a);

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

    canvas.restore();

    if(d > 0) {
      paint.color = Colors.blue;
      canvas.drawRect(Rect.fromLTWH(
          max+((d%max)*sign)-(1*sign), 0, 2*sign,
          canvasSize.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RudderAngleBox extends DoubleValueBox {
  late final _RudderAngleSettings _settings;

  RudderAngleBox(config, {super.key}) : super(config, '', 'steering.rudderAngle', smoothing: false) {
    _settings = _$RudderAngleSettingsFromJson(config.settings);
  }

  @override
  State<RudderAngleBox> createState() => _RudderAngleBoxState();

  static String sid = 'boat-rudder-angle';
  @override
  String get id => sid;

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _RudderAngleSettingsWidget(_settings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('Auto Scaling will temporarily extend the Max Angle if it is exceeded. If Auto Scaling is disabled and Max Angle is exceeded, a line will indicate further rudder movement');

  @override
  double convert(double value) {
    return value;
  }

  @override
  String units(double value) {
    return '_NOT_USED_';
  }
}

class _RudderAngleBoxState extends DoubleValueBoxState<RudderAngleBox> {
  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      displayValue = deg2Rad(12);
    }

    return Container(
        padding: const EdgeInsets.all(5.0),
        child: RepaintBoundary(
            child: CustomPaint(
                size: Size.infinite,
                painter: _RudderAnglePainter(
                    widget.config.controller,
                    context,
                    widget._settings,
                    displayValue)
            )
        )
    );
  }
}

class _RudderAngleSettingsWidget extends BoxSettingsWidget {
  final _RudderAngleSettings _settings;

  const _RudderAngleSettingsWidget(this._settings);

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$RudderAngleSettingsToJson(_settings);
  }

  @override
  createState() => _RudderAngleSettingsState();
}

class _RudderAngleSettingsState extends State<_RudderAngleSettingsWidget> {

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
      SwitchListTile(title: const Text("Auto Scale:"),
          value: s.autoScale,
          onChanged: (bool value) {
            setState(() {
              s.autoScale = value;
            });
          }),
    ]);
  }
}
