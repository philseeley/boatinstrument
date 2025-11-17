import 'dart:math' as m;

import 'package:boatinstrument/widgets/gauge_box.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:format/format.dart' as fmt;
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:json_annotation/json_annotation.dart';
import 'double_value_box.dart';

part 'environment_box.g.dart';

abstract class DepthBox extends DoubleValueBox {

  const DepthBox(super.config, super.title, super.path, {super.valueToDisplay, super.key}) : super(maxValue: 1000.0, smoothing: false);

  @override
  double convert(double value) {
    return config.controller.depthToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.depthUnits.unit;
  }

  @override
  DoubleValueBoxState<DepthBox> createState() => _DepthBoxState();
}

class _DepthBoxState extends DoubleValueBoxState<DepthBox> {
  @override
  Widget build(BuildContext context) {
    inRange *= -1; // Make exceeding max depth show a down arrow rather than up.
    
    return super.build(context);
  }
}

class DepthBelowSurfaceBox extends DepthBox {
  static const String sid = 'environment-depth-belowSurface';
  @override
  String get id => sid;

  const DepthBelowSurfaceBox(BoxWidgetConfig config, {super.valueToDisplay, super.key}) : super(config, 'Depth', 'environment.depth.belowSurface');
}

class MinDepthBelowSurfaceBox extends DepthBelowSurfaceBox {
  static const String sid = 'environment-depth-belowSurface-min';
  @override
  String get id => sid;

  const MinDepthBelowSurfaceBox(super.config, {super.valueToDisplay = DoubleValueToDisplay.minimumValue, super.key});
}

class DepthBelowSurfaceGraphBackground extends BackgroundData {
  DepthBelowSurfaceGraphBackground({BoatInstrumentController? controller}) : super(controller: controller, DepthBelowSurfaceGraph.sid, {'environment.depth.belowSurface'}, smoothing: false);
}

class DepthBelowSurfaceGraph extends GraphBox {
  static const String sid = 'environment-depth-belowSurface-graph';
  @override
  String get id => sid;

  DepthBelowSurfaceGraph(BoxWidgetConfig config, {super.key}) : super(config, 'Depth', DepthBelowSurfaceGraphBackground(), step: 10, precision: 1, mirror: true);

  @override
  double convert(double value) {
    return config.controller.depthToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.depthUnits.unit;
  }
}

class DepthBelowKeelBox extends DepthBox {
  static const String sid = 'environment-depth-belowKeel';
  @override
  String get id => sid;

  const DepthBelowKeelBox(BoxWidgetConfig config, {super.valueToDisplay, super.key}) : super(config, 'DBK', 'environment.depth.belowKeel');
}

class MinDepthBelowKeelBox extends DepthBelowKeelBox {
  static const String sid = 'environment-depth-belowKeel-min';
  @override
  String get id => sid;

  const MinDepthBelowKeelBox(super.config, {super.valueToDisplay = DoubleValueToDisplay.minimumValue, super.key});
}

class DepthBelowKeelGraphBackground extends BackgroundData {
  DepthBelowKeelGraphBackground({BoatInstrumentController? controller}) : super(controller: controller, DepthBelowKeelGraph.sid, {'environment.depth.belowKeel'}, smoothing: false);
}

class DepthBelowKeelGraph extends GraphBox {
  static const String sid = 'environment-depth-belowKeel-graph';
  @override
  String get id => sid;

  final DepthBelowKeelGraphBackground background = DepthBelowKeelGraphBackground();

  DepthBelowKeelGraph(BoxWidgetConfig config, {super.key}) : super(config, 'Depth below Keel', DepthBelowKeelGraphBackground(), step: 10, precision: 1, mirror: true);

  @override
  double convert(double value) {
    return config.controller.depthToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.depthUnits.unit;
  }
}

class DepthBelowTransducerBox extends DepthBox {
  static const String sid = 'environment-depth-belowTransducer';
  @override
  String get id => sid;

  const DepthBelowTransducerBox(BoxWidgetConfig config, {super.valueToDisplay, super.key}) : super(config, 'DBT', 'environment.depth.belowTransducer');
}

class MinDepthBelowTransducerBox extends DepthBelowTransducerBox {
  static const String sid = 'environment-depth-belowTransducer-min';
  @override
  String get id => sid;

  const MinDepthBelowTransducerBox(super.config, {super.valueToDisplay = DoubleValueToDisplay.minimumValue, super.key});
}

class DepthBelowTransducerGraphBackground extends BackgroundData {
  DepthBelowTransducerGraphBackground({BoatInstrumentController? controller}) : super(controller: controller, DepthBelowTransducerGraph.sid, {'environment.depth.belowTransducer'}, smoothing: false);
}

class DepthBelowTransducerGraph extends GraphBox {
  static const String sid = 'environment-depth-belowTransducer-graph';
  @override
  String get id => sid;
  DepthBelowTransducerGraph(BoxWidgetConfig config, {super.key}) : super(config, 'DBT', DepthBelowTransducerGraphBackground(), step: 10, precision: 1, mirror: true);

  @override
  double convert(double value) {
    return config.controller.depthToDisplay(value);
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

  const WaterTemperatureBox(BoxWidgetConfig config, {super.key}) : super(config, 'Water Temp', 'environment.water.temperature');

  @override
  double convert(double value) {
    return config.controller.temperatureToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.temperatureUnits.unit;
  }
}

class WaterTemperatureGraphBackground extends BackgroundData {
  WaterTemperatureGraphBackground({BoatInstrumentController? controller}) : super(controller: controller, WaterTemperatureGraph.sid, {'environment.water.temperature'});
}

class WaterTemperatureGraph extends GraphBox {
  static const String sid = 'environment-water-temperature-graph';
  @override
  String get id => sid;

  WaterTemperatureGraph(BoxWidgetConfig config, {super.key}) : super(config, 'Water Temp', WaterTemperatureGraphBackground(), step: 1+kelvinOffset, zeroBase: false);

  @override
  double convert(double value) {
    return config.controller.temperatureToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.temperatureUnits.unit;
  }
}

class OutsideHumidityBox extends DoubleValueBox {
  static const String sid = 'environment-outside-relative-humidity';
  @override
  String get id => sid;

  const OutsideHumidityBox(BoxWidgetConfig config, {super.key}) : super(config, 'Humidity Out', 'environment.outside.relativeHumidity', precision: 0);

  @override
  double convert(double value) {
    return value*100;
  }

  @override
  String units(double value) {
    return '%';
  }
}

class InsideHumidityBox extends DoubleValueBox {
  static const String sid = 'environment-inside-relative-humidity';
  @override
  String get id => sid;

  const InsideHumidityBox(BoxWidgetConfig config, {super.key}) : super(config, 'Humidity In', 'environment.inside.relativeHumidity', precision: 0);

  @override
  double convert(double value) {
    return value*100;
  }

  @override
  String units(double value) {
    return '%';
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

class _SetAndDriftBoxState extends HeadedTextBoxState<SetAndDriftBox> {
  double? _set;
  double? _drift;
  double? _displayDrift;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(onUpdate: _processData, paths: {'environment.current'});
  }

  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      _set = deg2Rad(123);
      _displayDrift = 12.3;
    }

    header = 'Set&Drift $degreesUnits-${widget.config.controller.speedUnits.unit}';
    text = (_set == null || _displayDrift == null) ?
      '-\n-' :
      fmt.format('{:3}\n{:.1f}', rad2Deg(_set), _displayDrift);

    return super.build(context);
  }

  void _processData(List<Update> updates) {
    if(updates[0].value == null) {
      _set = _drift = _displayDrift = null;
    } else {
      try {
        double next = (updates[0].value['setTrue'] as num).toDouble();
        _set = averageAngle(_set ?? next, next,
            smooth: widget.config.controller.valueSmoothing);
        next = (updates[0].value['drift'] as num).toDouble();
        _drift = averageDouble(_drift ?? next, next,
            smooth: widget.config.controller.valueSmoothing);

        _displayDrift = widget.config.controller.speedToDisplay(_drift!);
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

  const OutsideTemperatureBox(BoxWidgetConfig config, {super.key}) : super(config, 'Outside Temp', 'environment.outside.temperature');

  @override
  double convert(double value) {
    return config.controller.temperatureToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.temperatureUnits.unit;
  }
}

class OutsideTemperatureGraphBackground extends BackgroundData {
  OutsideTemperatureGraphBackground({BoatInstrumentController? controller}) : super(controller: controller, OutsideTemperatureGraph.sid, {'environment.outside.temperature'});
}

class OutsideTemperatureGraph extends GraphBox {
  static const String sid = 'environment-outside-temperature-graph';
  @override
  String get id => sid;

  OutsideTemperatureGraph(BoxWidgetConfig config, {super.key}) : super(config, 'Outside Temp', OutsideTemperatureGraphBackground(), step: 1+kelvinOffset, zeroBase: false);

  @override
  double convert(double value) {
    return config.controller.temperatureToDisplay(value);
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

  const OutsidePressureBox(BoxWidgetConfig config, {super.key}) : super(config, 'Pressure', 'environment.outside.pressure');

  @override
  double convert(double value) {
    return config.controller.airPressureToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.airPressureUnits.unit;
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
  Widget? getSettingsHelp() => const HelpPage(text: 'For a full list of formats see https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html');
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
  Widget? getHelp() => const HelpPage(text: 'Ensure the **signalk-derived-data** plugin is installed on signalk and the "Sets environment.sunlight.times.*" is enabled.');

  @override
  State<SunlightBox> createState() => _SunlightBox();
}

class _Time {
  final String name;
  final DateTime time;

  const _Time(this.name, this.time);
}

class _SunlightBox extends HeadedTextBoxState<SunlightBox> {
  static const int _numTimes = 7;
  bool _utc = false;
  List<_Time?> _times = List.filled(_numTimes, null);

  @override
  void initState() {
    super.initState();
    header = 'Sunlight';
    widget.config.controller.configure(onUpdate: _onUpdate, paths: {'environment.sunlight.times.*'}, dataType: SignalKDataType.infrequent);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat(widget._settings.timeFormat);
    final now = widget.config.controller.now();

    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);

    if(widget.config.editMode) {
      _times = List.filled(_numTimes, _Time('Time:    ', now));
    }

    StringBuffer textBuffer = StringBuffer();
    for(int i = 0; i<_times.length; ++i) {
      _Time? t = _times[i];
      if(t == null) {
        textBuffer.writeln('-');
      } else {
        textBuffer.writeln('${t.name} ${fmt.format(_utc?t.time.toUtc():t.time.toLocal())}');
        if(i < _times.length-1 && now.compareTo(t.time) >= 0 && now.compareTo(_times[i+1]?.time??now) < 0) {
          textBuffer.writeln('\u23BC\u23BC\u23BC\u23BC\u23BC${fmt.format(_utc?now.toUtc():now.toLocal())}\u23BC\u23BC\u23BC\u23BC\u23BC');
        }
      }
    }
    text = textBuffer.toString();
    actions = [TextButton(onPressed: _toggleUTC, child: Text('UTC', style: style.copyWith(decoration: _utc ? null : TextDecoration.lineThrough)))];

    return super.build(context);
  }

  void _toggleUTC() {
    setState(() {
      _utc = !_utc;
    });
  }

  void _onUpdate(List<Update> updates) {
    for (Update u in updates) {
      try {        
        DateTime? dt = u.value == null?null:DateTime.parse(u.value);

        switch (u.path) {
          case 'environment.sunlight.times.nauticalDawn':
            _times[0] = u.value == null?null:_Time('Naut Dwn:', dt!);
            break;
          case 'environment.sunlight.times.dawn':
            _times[1] = u.value == null?null:_Time('Dawn:    ', dt!);
            break;
          case 'environment.sunlight.times.sunrise':
            _times[2] = u.value == null?null:_Time('Rise:    ', dt!);
            break;
          case 'environment.sunlight.times.solarNoon':
            _times[3] = u.value == null?null:_Time('Sol Noon:', dt!);
            break;
          case 'environment.sunlight.times.sunset':
            _times[4] = u.value == null?null:_Time('Set:     ', dt!);
            break;
          case 'environment.sunlight.times.dusk':
            _times[5] = u.value == null?null:_Time('Dusk:    ', dt!);
            break;
          case 'environment.sunlight.times.nauticalDusk':
            _times[6] = u.value == null?null:_Time('Naut Dsk:', dt!);
            break;
        }
      } catch (e) {
        widget.config.controller.l.e("Error converting $u", error: e);
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

class _MoonPainter extends CustomPainter {
  final double _fraction;

  const _MoonPainter(this._fraction);

  @override
  void paint(Canvas canvas, Size canvasSize) {

    double size = m.min(canvasSize.width, canvasSize.height);

    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.yellow;

    double left = size*_fraction;
    double right = size-(left*2);
    double end = -m.pi;

    if(_fraction > 0.5) {
      left = size*(1.0-_fraction);
      right = size-(2*left);
      end = m.pi;
    }

    Path sunlight = Path()
      ..addArc(Rect.fromLTWH(0, 0, size, size), -m.pi/2, m.pi)
      ..addArc(Rect.fromLTWH(left, 0, right, size), m.pi/2, end);

    canvas.drawPath(sunlight, paint);
    paint.style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(size/2, size/2), size/2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MoonBox extends CelestialBox {
  static const String sid = 'environment-moon';

  late final _MoonPerBoxSettings _perBoxSettings;

  MoonBox(super.config, {super.key}) {
    _perBoxSettings = _$MoonPerBoxSettingsFromJson(config.settings);
  }

  @override
  Widget? getHelp() => const HelpPage(text: 'Ensure the **signalk-derived-data** plugin is installed on signalk and the "Sets environment.moon.*" is enabled.');

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _MoonPerBoxSettingsWidget(_perBoxSettings);
  }

  @override
  State<MoonBox> createState() => _MoonBox();
}

class _MoonBox extends HeadedTextBoxState<MoonBox> {
  bool _utc = false;
  DateTime? _rise, _set;
  double? _fraction;
  String? _phaseName;

  @override
  void initState() {
    alignment = Alignment.topLeft;
    super.initState();
    widget.config.controller.configure(onUpdate: _onUpdate, paths: {'environment.moon.*'}, dataType: SignalKDataType.infrequent);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat(widget._settings.timeFormat);
    ThemeData td = Theme.of(context);
    TextStyle style = td.textTheme.titleMedium!.copyWith(height: 1.0);
    
    if(widget._perBoxSettings.showMoon) textBgColor = td.colorScheme.surface;

    if(widget.config.editMode) {
      _rise = _set = widget.config.controller.now().toLocal();
      _fraction = 1.0;
      _phaseName = 'Full';
    }

    header = 'Moon';

    text =
'''Rise:  ${(_rise == null) ? '-' : fmt.format(_utc?_rise!.toUtc():_rise!.toLocal())}
Set:   ${(_set == null) ? '-' : fmt.format(_utc?_set!.toUtc():_set!.toLocal())}
Phase: ${(_fraction == null) ? '-' : (_fraction!*100).toInt()}%
${(_phaseName == null) ? '-' : _phaseName}''';

    actions = [TextButton(onPressed: _toggleUTC, child: Text('UTC', style: style.copyWith(decoration: _utc ? null : TextDecoration.lineThrough)))];

    return Stack(children: [
      if(widget._perBoxSettings.showMoon)
        Padding(padding: const EdgeInsets.all(HeadedTextBoxState.pad), child: RepaintBoundary(child: CustomPaint(size: Size.infinite,
          painter: _MoonPainter(_fraction??0)))),
      super.build(context)
    ]);
  }

  void _toggleUTC() {
    setState(() {
      _utc = !_utc;
    });
  }
  
  void _onUpdate(List<Update> updates) {
    for (Update u in updates) {
      try {
        switch (u.path) {
          case 'environment.moon.times.rise':
            _rise = (u.value == null)?null:DateTime.parse(u.value);
            break;
          case 'environment.moon.times.set':
            _set = (u.value == null)?null:DateTime.parse(u.value);
            break;
          case 'environment.moon.fraction':
            _fraction = (u.value == null)?null:(u.value as num).toDouble();
            break;
          case 'environment.moon.phaseName':
            _phaseName = (u.value == null)?null:u.value;
            break;
        }
      } catch (e) {
        widget.config.controller.l.e("Error converting $u", error: e);
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

class OutsidePressureGraphBackground extends BackgroundData {
  OutsidePressureGraphBackground({BoatInstrumentController? controller}) : super(controller: controller, OutsidePressureGraph.sid, {'environment.outside.pressure'});
}

class OutsidePressureGraph extends GraphBox {
  static const String sid = 'environment-outside-pressure-graph';
  @override
  String get id => sid;

  OutsidePressureGraph(BoxWidgetConfig config, {super.key}) : super(config, 'Pressure', OutsidePressureGraphBackground(), step: millibar2pascal(5), zeroBase: false);

  @override
  double convert(double value) {
    return config.controller.airPressureToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.airPressureUnits.unit;
  }
}
