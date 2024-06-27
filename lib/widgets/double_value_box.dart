import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:format/format.dart' as fmt;
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:json_annotation/json_annotation.dart';

part 'double_value_box.g.dart';

class CrossTrackErrorBox extends DoubleValueBox {
  static const String sid = 'navigation-xte';
  @override
  String get id => sid;

  CrossTrackErrorBox(config, {super.key}) : super(config, 'XTE', 'navigation.courseGreatCircle.crossTrackError', precision: 2) {
    setup(_convertXTE, _xteUnits);
  }

  double _convertXTE(double xte) {
    switch (config.controller.distanceUnits) {
      case DistanceUnits.meters:
        return xte;
      case DistanceUnits.km:
        return xte * 0.001;
      case DistanceUnits.miles:
        return xte * 0.000621371;
      case DistanceUnits.nm:
        return xte * 0.000539957;
    }
  }

  String _xteUnits() {
    return config.controller.distanceUnits.unit;
  }
}

class WaterTemperatureBox extends DoubleValueBox {
  static const String sid = 'sea-temperature';
  @override
  String get id => sid;

  WaterTemperatureBox(config, {super.key}) : super(config, 'Water Temp', 'environment.water.temperature') {
    setup(_convertTemp, _tempUnits);
  }

  double _convertTemp(double temp) {
    switch (config.controller.temperatureUnits) {
      case TemperatureUnits.c:
        return temp - 273.15;
      case TemperatureUnits.f:
        return (temp - 273.15) * 9/5 + 32;
    }
  }

  String _tempUnits() {
    return config.controller.temperatureUnits.unit;
  }
}

class CourseOverGroundBox extends DoubleValueBox {
  static const String sid = 'course-over-ground';
  @override
  String get id => sid;

  CourseOverGroundBox(config, {super.key}) : super(config, 'COG', 'navigation.courseOverGroundTrue', minLen: 3, precision: 0, angle: true) {
    setup(_convertCOG, _cogUnits);
  }

  double _convertCOG(double cog) {
    return rad2Deg(cog) * 1.0;
  }

  String _cogUnits() {
    return 'deg';
  }
}

class SpeedOverGroundBox extends SpeedBox {
  static const String sid = 'speed-over-ground';
  @override
  String get id => sid;

  SpeedOverGroundBox(config, {super.key}) : super(config, 'SOG', 'navigation.speedOverGround');
}

abstract class SpeedBox extends DoubleValueBox {

  SpeedBox(super.config, super.title, super.path, {super.key}) : super(minLen: 1){
    setup(_convertSpeed, _speedUnits);
  }

  double _convertSpeed(double speed) {
    switch (config.controller.speedUnits) {
      case SpeedUnits.mps:
        return speed;
      case SpeedUnits.kph:
        return speed * 3.6;
      case SpeedUnits.mph:
        return speed * 2.236936;
      case SpeedUnits.kts:
        return speed * 1.943844;
    }
  }

  String _speedUnits() {
    return config.controller.speedUnits.unit;
  }
}

class WindSpeedApparentBox extends WindSpeedBox {
  static const String sid = 'wind-speed-apparent';
  @override
  String get id => sid;

  WindSpeedApparentBox(config, {super.key}) : super(config, 'AWS', 'environment.wind.speedApparent');
}

class WindSpeedTrueBox extends WindSpeedBox {
  static const String sid = 'wind-speed-true';
  @override
  String get id => sid;

  WindSpeedTrueBox(config, {super.key}) : super(config, 'TWS', 'environment.wind.speedTrue');
}

abstract class WindSpeedBox extends DoubleValueBox {

  WindSpeedBox(super.config, super.title, super.path, {super.key}) {
    setup(_convertSpeed, _speedUnits);
  }

  double _convertSpeed(double speed) {
    switch (config.controller.windSpeedUnits) {
      case SpeedUnits.mps:
        return speed;
      case SpeedUnits.kph:
        return speed * 3.6;
      case SpeedUnits.mph:
        return speed * 2.236936;
      case SpeedUnits.kts:
        return speed * 1.943844;
    }
  }

  String _speedUnits() {
    return config.controller.windSpeedUnits.unit;
  }
}

@JsonSerializable()
class _Settings {
  String title;
  String path;
  int precision;
  int minLen;
  double minValue;
  double maxValue;
  bool angle;
  String units;
  double multiplier;

  _Settings({
    this.title = 'title',
    this.path = 'path',
    this.precision = 1,
    this.minLen = 2,
    this.minValue = 0,
    this.maxValue = 100,
    this.angle = false,
    this.units = 'units',
    this.multiplier = 1
  });
}

class CustomDoubleValueBox extends DoubleValueBox {
  late _Settings _settings;
  String _unitsString;
  double _multiplier;

  CustomDoubleValueBox._init(this._settings, this._unitsString, this._multiplier, super.config, super.title, super.path, {super.precision, super.minLen, super.minValue, super.maxValue, super.angle, super.key}) {
    setup(_multiply, _getUnits);
  }

  factory CustomDoubleValueBox.fromSettings(config, {key}) {
    _Settings s = _$SettingsFromJson(config.settings);
    return CustomDoubleValueBox._init(s, s.units, s.multiplier, config, s.title, s.path, precision: s.precision, minLen: s.minLen, minValue: s.minValue, maxValue: s.maxValue, angle: s.angle, key: key);
  }

  static String sid = 'custom-double-value';
  @override
  String get id => sid;

  @override
  bool get hasPerBoxSettings => true;

  @override
  Widget getPerBoxSettingsWidget() {
    return _SettingsWidget(config, _settings);
  }

  @override
  Map<String, dynamic> getPerBoxSettingsJson() {
    return _$SettingsToJson(_settings);
  }

  double _multiply(double value) {
    return value * _multiplier;
  }

  String _getUnits() {
    return _unitsString;
  }

}

class _SettingsWidget extends StatefulWidget {
  final BoxWidgetConfig _config;
  final _Settings _settings;

  const _SettingsWidget(this._config, this._settings);

  @override
  createState() => _SettingsState();
}

class _SettingsState extends State<_SettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _Settings s = widget._settings;

    return ListView(children: [
      ListTile(
        leading: IconButton(onPressed: _emailSettings, icon: const Icon(Icons.email)),
        title: const Text("Please email your setting to the developers for permanent inclusion."),
      ),
      ListTile(
        leading: const Text("Title:"),
        title: TextFormField(
            initialValue: s.title,
            onChanged: (value) => s.title = value)
      ),
      ListTile(
        leading: const Text("Signalk Path:"),
        title: TextFormField(
            initialValue: s.path,
            onChanged: (value) => s.path = value)
      ),
      ListTile(
          leading: const Text("Units:"),
          title: TextFormField(
              initialValue: s.units,
              onChanged: (value) => s.units = value)
      ),
      ListTile(
        leading: const Text("Multiplier:"),
        title: TextFormField(
            initialValue: s.multiplier.toString(),
            onChanged: (value) => s.multiplier = double.parse(value)),
      ),
      ListTile(
        leading: const Text("Precision:"),
        title: TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            initialValue: s.precision.toString(),
            onChanged: (value) => s.precision = int.parse(value)),
      ),
      ListTile(
        leading: const Text("Min Length:"),
        title: TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            initialValue: s.minLen.toString(),
            onChanged: (value) => s.minLen = int.parse(value)),
      ),
      ListTile(
        leading: const Text("Min Value:"),
        title: TextFormField(
            initialValue: s.minValue.toString(),
            onChanged: (value) => s.minValue = double.parse(value)),
      ),
      ListTile(
        leading: const Text("Max Value:"),
        title: TextFormField(
            initialValue: s.maxValue.toString(),
            onChanged: (value) => s.maxValue = double.parse(value)),
      ),
      SwitchListTile(title: const Text("Is Angle:"),
          value: s.angle,
          onChanged: (bool value) {
            setState(() {
              s.angle = value;
            });
          }),
    ]);
  }

  //TODO need to check this works
  void _emailSettings() async {
    _Settings s = widget._settings;

    final Email email = Email(
      body:
'''Title: ${s.title}
Path: ${s.path}
Precision: ${s.precision}
Min Length: ${s.minLen}
Min Value: ${s.minValue}
Max Value: ${s.maxValue}
Is Angle: ${s.angle}
Units: ${s.units}
Multiplier: ${s.multiplier}''',
      subject: 'Boat Instrument Custom Box Settings',
      recipients: ['feedback@wheretofly.info'],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } on PlatformException catch (e) {
      if(mounted) {
        if (Platform.isIOS && e.code == 'not_available') {
          widget._config.controller.showMessage(context,
              'On iOS you must install and configure the Apple EMail App with an account.', error: true);
        }
      }
      widget._config.controller.l.e('Error Sending Email', error: e);
    } catch (e) {
      widget._config.controller.l.e('Error Sending Email', error: e);
    }
  }
}

abstract class DoubleValueBox extends BoxWidget {
  final String title;
  final String path;
  final int precision;
  final int minLen;
  final double? minValue;
  final double? maxValue;
  final bool angle;
  late double Function(double value) _convert;
  late String Function() _units;

  DoubleValueBox(super.config, this.title, this.path, {this.precision = 1, this.minLen =  2, this.minValue, this.maxValue, this.angle = false, super.key});

  setup(convert, units) {
    _convert = convert;
    _units = units;
  }

  @override
  State<DoubleValueBox> createState() => _DoubleValueBoxState();
}

class _DoubleValueBoxState extends State<DoubleValueBox> {
  double? _value;
  double? _displayValue;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(widget, onUpdate: _processData, paths: { widget.path });
  }

  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      _displayValue = 12.3;
    }

    String valueText = (_displayValue == null) ?
      '-' :
      fmt.format('{:${widget.minLen+(widget.precision > 0?1:0)+widget.precision}.${widget.precision}f}', _displayValue!);

    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);

    const double pad = 5.0;
    double fontSize = maxFontSize(valueText, style,
          widget.config.constraints.maxHeight - style.fontSize! - (3 * pad),
          widget.config.constraints.maxWidth - (2 * pad));

    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Row(children: [Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Text('${widget.title} - ${widget._units()}', style: style))]),
      // We need to disable the device text scaling as this interferes with our text scaling.
      Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(pad), child: Text(valueText, textScaler: TextScaler.noScaling,  style: style.copyWith(fontSize: fontSize)))))
    ]);
  }

  _processData(List<Update>? updates) {
    if(updates == null) {
      _displayValue = null;
    } else {
      try {
        double next = (updates[0].value as num).toDouble();

        if ((widget.minValue != null && next < widget.minValue!) ||
            (widget.maxValue != null && next > widget.maxValue!)) {
          _displayValue = null;
        } else {
          if (widget.angle) {
            _value = averageAngle(_value ?? next, next,
                smooth: widget.config.controller.valueSmoothing);
          } else {
            _value = averageDouble(_value ?? next, next,
                smooth: widget.config.controller.valueSmoothing);
          }
          _displayValue = widget._convert(_value!);
        }
      } catch (e) {
        widget.config.controller.l.e("Error converting $updates", error: e);
      }
    }

    if(mounted) {
      setState(() {});
    }
  }
}
