import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:boatinstrument/widgets/gauge_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';

part 'propulsion_box.g.dart';

@JsonSerializable()
class _EngineSettings {
  String id;
  int maxRPM;
  int rpmRedLine;
  double maxTemp;
  double maxOilPressure;

  _EngineSettings({this.id = '', this.maxRPM = 4000, this.rpmRedLine = 3500, this.maxTemp = kelvinOffset+120, this.maxOilPressure = 500000});
}

double  revolutions2RPMK(double value) {
  return revolutions2RPM(value)/1000;
}

double  rpmK2Revolutions(double value) {
  return rpm2Revolutions(value*1000);
}

class EngineRPMBox extends DoubleValueCircularGaugeBox {
  static const sid = 'propulsion-rpm';
  @override
  String get id => sid;

  final _EngineSettings _settings;

  EngineRPMBox._init(this._settings, config, title, path, {super.key, super.maxValue, super.ranges}) :
    super(config, title, path, step: rpmK2Revolutions(1));

  factory EngineRPMBox.fromSettings(config, {key}) {
    _EngineSettings s = _$EngineSettingsFromJson(config.settings);

    return EngineRPMBox._init(s, config, 'RPM:${s.id}', 'propulsion.${s.id}.revolutions',
      maxValue: rpm2Revolutions(s.maxRPM.toDouble()), key: key, ranges: [
        GaugeRange(rpm2Revolutions(s.rpmRedLine.toDouble()), rpm2Revolutions(s.maxRPM.toDouble()), Colors.red)
      ]);
  }

  @override
  double convert(double value) {
    return revolutions2RPMK(value);
  }
  
  @override
  String units(double value) {
    return 'RPM/K';
  }

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _EngineSettingsWidget(config.controller, _settings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('For a path of "propulsion.port.revolutions" the ID is "port"');

  @override
  DoubleValueCircularGaugeBoxState<EngineRPMBox> createState() => _EngineRPMState();
}

class _EngineRPMState extends DoubleValueCircularGaugeBoxState<EngineRPMBox> {

  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      value = displayValue = 1230;
    }

    return super.build(context);
  }
}

class EngineTempBox extends DoubleValueSemiGaugeBox {
  static const sid = 'propulsion-temp';
  @override
  String get id => sid;

  final _EngineSettings _settings;

  const EngineTempBox._init(this._settings, config, title, path, {super.key, super.minValue,  super.maxValue, super.ranges}) :
    super(config, title, GaugeOrientation.up, path, step: 20);

  factory EngineTempBox.fromSettings(config, {key}) {
    _EngineSettings s = _$EngineSettingsFromJson(config.settings);

    return EngineTempBox._init(s, config, 'Temp:${s.id}', 'propulsion.${s.id}.temperature',
      minValue: kelvinOffset, maxValue: s.maxTemp, key: key, ranges: [
        GaugeRange(s.maxTemp-10, s.maxTemp, Colors.red),
        GaugeRange(kelvinOffset+10, s.maxTemp-10, Colors.green),
        const GaugeRange(kelvinOffset, kelvinOffset+10, Colors.orange)
      ]);
  }

  @override
  double convert(double value) {
    return config.controller.temperatureToDisplay(value);
  }
  
  @override
  String units(double value) {
    return config.controller.temperatureUnits.unit;
  }

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _EngineSettingsWidget(config.controller, _settings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('For a path of "propulsion.port.temperature" the ID is "port"');

  @override
  DoubleValueSemiGaugeBoxState<EngineTempBox> createState() => _EngineTempState();
}

class _EngineTempState extends DoubleValueSemiGaugeBoxState<EngineTempBox> {

  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      value = kelvinOffset+12.3;
      displayValue = widget.convert(value!);
    }

    return super.build(context);
  }
}

class EngineOilPressureBox extends DoubleValueSemiGaugeBox {
  static const sid = 'propulsion-oil-pressure';
  @override
  String get id => sid;

  final _EngineSettings _settings;

  const EngineOilPressureBox._init(this._settings, config, title, path, {super.key, super.maxValue, super.ranges}) :
    super(config, title, GaugeOrientation.up, path, step: 50000);

  factory EngineOilPressureBox.fromSettings(config, {key}) {
    _EngineSettings s = _$EngineSettingsFromJson(config.settings);

    return EngineOilPressureBox._init(s, config, 'Oil:${s.id}', 'propulsion.${s.id}.oilPressure',
      maxValue: s.maxOilPressure, key: key, ranges: [
        GaugeRange(s.maxOilPressure-50000, s.maxOilPressure, Colors.red),
      ]);
  }

  @override
  double convert(double value) {
    return config.controller.oilPressureToDisplay(value);
  }
  
  @override
  String units(double value) {
    return config.controller.oilPressureUnits.unit;
  }

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _EngineSettingsWidget(config.controller, _settings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('For a path of "propulsion.port.oilPressure" the ID is "port"');

  @override
  DoubleValueSemiGaugeBoxState<EngineOilPressureBox> createState() => _EngineOilPressureState();
}

class _EngineOilPressureState extends DoubleValueSemiGaugeBoxState<EngineOilPressureBox> {

  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      value = 123000;
      displayValue = widget.convert(value!);
    }

    return super.build(context);
  }
}

class _EngineSettingsWidget extends BoxSettingsWidget {
  final BoatInstrumentController _controller;
  final _EngineSettings _settings;

  const _EngineSettingsWidget(this._controller, this._settings);

  @override
  createState() => _EngineSettingsState();

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$EngineSettingsToJson(_settings);
  }
}

class _EngineSettingsState extends State<_EngineSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    BoatInstrumentController c = widget._controller;
    _EngineSettings s = widget._settings;

    List<Widget> list = [
      ListTile(
          leading: const Text("Engine ID:"),
          title: TextFormField(
              initialValue: s.id,
              onChanged: (value) => s.id = value)
      ),
      ListTile(
          leading: const Text("Max RPM:"),
          title: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              initialValue: s.maxRPM.toString(),
              onChanged: (value) => s.maxRPM = int.parse(value)),
          trailing: const Text('rpm')
      ),
      ListTile(
          leading: const Text("Redline:"),
          title: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              initialValue: s.rpmRedLine.toString(),
              onChanged: (value) => s.rpmRedLine = int.parse(value)),
          trailing: const Text('rpm')
      ),
      ListTile(
          leading: const Text("Max Temp:"),
          title: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              initialValue: c.temperatureToDisplay(s.maxTemp).toInt().toString(),
              onChanged: (value) => s.maxTemp = c.temperatureFromDisplay(double.parse(value))),
          trailing: Text(c.temperatureUnits.unit)
      ),
      ListTile(
          leading: const Text("Max Oil Pressure:"),
          title: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              initialValue: c.oilPressureToDisplay(s.maxOilPressure).toInt().toString(),
              onChanged: (value) => s.maxOilPressure = c.oilPressureFromDisplay(double.parse(value))),
          trailing: Text(c.oilPressureUnits.unit)
      ),
    ];

    return ListView(children: list);
  }
}
