import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:boatinstrument/widgets/double_value_box.dart';
import 'package:boatinstrument/widgets/gauge_box.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'electrical_box.g.dart';

@JsonSerializable()
class _ElectricalSettings {
  String id;

  _ElectricalSettings({this.id = ''});
}

class BatteryVoltMeterBox extends DoubleValueSemiGaugeBox {
  static const sid = 'electrical-battery-voltage-meter';
  @override
  String get id => sid;

  final _ElectricalSettings _settings;

  const BatteryVoltMeterBox._init(this._settings, config, title, path, {super.key, super.minValue, super.maxValue, super.ranges}) :
    super(config, title, GaugeOrientation.up, path);

  factory BatteryVoltMeterBox.fromSettings(config, {key}) {
    _ElectricalSettings s = _$ElectricalSettingsFromJson(config.settings);

    return BatteryVoltMeterBox._init(s, config, 'Battery:${s.id}', 'electrical.batteries.${s.id}.voltage',
      minValue: 10, maxValue: 15, key: key, ranges: const [
        GuageRange(10, 12, Colors.red),
        GuageRange(12, 13, Colors.orange),
        GuageRange(13, 15, Colors.green)
      ]);
  }

  @override
  double convert(double value) {
    return value;
  }
  
  @override
  String units(double value) {
    return 'V';
  }

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _ElectricalSettingsWidget(_settings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('For a path of "electrical.batteries.start.voltage" the ID is "start"');

  @override
  DoubleValueSemiGaugeBoxState<BatteryVoltMeterBox> createState() => _BatteryVoltMeterState();
}

class _BatteryVoltMeterState extends DoubleValueSemiGaugeBoxState<BatteryVoltMeterBox> {

  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      value = displayValue = 12.3;
    }

    return super.build(context);
  }
}

class BatteryVoltageBox extends DoubleValueBox {
  static const sid = 'electrical-battery-voltage';
  @override
  String get id => sid;

  final _ElectricalSettings _settings;

  const BatteryVoltageBox._init(this._settings, config, title, path, {super.key}) : super(config, title, path);

  factory BatteryVoltageBox.fromSettings(config, {key}) {
    _ElectricalSettings s = _$ElectricalSettingsFromJson(config.settings);

    return BatteryVoltageBox._init(s, config, 'Voltage:${s.id}', 'electrical.batteries.${s.id}.voltage', key: key);
  }

  @override
  double convert(double value) {
    return value;
  }

  @override
  String units(double value) {
    return 'V';
  }
  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _ElectricalSettingsWidget(_settings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('For a path of "electrical.batteries.start.voltage" the ID is "start"');
}

class BatteryCurrentBox extends DoubleValueBox {
  static const sid = 'electrical-battery-current';
  @override
  String get id => sid;

  final _ElectricalSettings _settings;

  const BatteryCurrentBox._init(this._settings, config, title, path, {super.key}) : super(config, title, path);

  factory BatteryCurrentBox.fromSettings(config, {key}) {
    _ElectricalSettings s = _$ElectricalSettingsFromJson(config.settings);

    return BatteryCurrentBox._init(s, config, 'Current:${s.id}', 'electrical.batteries.${s.id}.current', key: key);
  }

  @override
  double convert(double value) {
    return value;
  }

  @override
  String units(double value) {
    return 'A';
  }
  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _ElectricalSettingsWidget(_settings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('For a path of "electrical.batteries.start.current" the ID is "start"');
}

class InverterCurrentBox extends DoubleValueBox {
  static const sid = 'electrical-inverter-current';
  @override
  String get id => sid;

  final _ElectricalSettings _settings;

  const InverterCurrentBox._init(this._settings, config, title, path, {super.key}) : super(config, title, path);

  factory InverterCurrentBox.fromSettings(config, {key}) {
    _ElectricalSettings s = _$ElectricalSettingsFromJson(config.settings);

    return InverterCurrentBox._init(s, config, 'Inverter:${s.id}', 'electrical.inverters.${s.id}.dc.current', key: key);
  }

  @override
  double convert(double value) {
    return value;
  }

  @override
  String units(double value) {
    return 'A';
  }
  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _ElectricalSettingsWidget(_settings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('For a path of "electrical.inverters.1.dc.current" the ID is "1"');
}

class SolarVoltageBox extends DoubleValueBox {
  static const sid = 'electrical-solar-current';
  @override
  String get id => sid;

  final _ElectricalSettings _settings;

  const SolarVoltageBox._init(this._settings, config, title, path, {super.key}) : super(config, title, path);

  factory SolarVoltageBox.fromSettings(config, {key}) {
    _ElectricalSettings s = _$ElectricalSettingsFromJson(config.settings);

    return SolarVoltageBox._init(s, config, 'Solar:${s.id}', 'electrical.solar.${s.id}.voltage', key: key);
  }

  @override
  double convert(double value) {
    return value;
  }

  @override
  String units(double value) {
    return 'V';
  }
  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _ElectricalSettingsWidget(_settings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('For a path of "electrical.solar.1.voltage" the ID is "1"');
}

class SolarCurrentBox extends DoubleValueBox {
  static const sid = 'electrical-solar-current';
  @override
  String get id => sid;

  final _ElectricalSettings _settings;

  const SolarCurrentBox._init(this._settings, config, title, path, {super.key}) : super(config, title, path);

  factory SolarCurrentBox.fromSettings(config, {key}) {
    _ElectricalSettings s = _$ElectricalSettingsFromJson(config.settings);

    return SolarCurrentBox._init(s, config, 'Solar:${s.id}', 'electrical.solar.${s.id}.current', key: key);
  }

  @override
  double convert(double value) {
    return value;
  }

  @override
  String units(double value) {
    return 'A';
  }
  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _ElectricalSettingsWidget(_settings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('For a path of "electrical.solar.1.current" the ID is "1"');
}

class _ElectricalSettingsWidget extends BoxSettingsWidget {
  final _ElectricalSettings _settings;

  const _ElectricalSettingsWidget(this._settings);

  @override
  createState() => _ElectricalSettingsState();

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$ElectricalSettingsToJson(_settings);
  }
}

class _ElectricalSettingsState extends State<_ElectricalSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _ElectricalSettings s = widget._settings;

    List<Widget> list = [
      ListTile(
          leading: const Text("Battery ID:"),
          title: TextFormField(
              initialValue: s.id,
              onChanged: (value) => s.id = value)
      ),
    ];

    return ListView(children: list);
  }
}
