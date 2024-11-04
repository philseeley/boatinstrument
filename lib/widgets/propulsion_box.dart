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

  _EngineSettings({this.id = '', this.maxRPM = 4000, this.rpmRedLine = 3500, this.maxTemp = kelvinOffset+120});
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

  EngineRPMBox._init(this._settings, config, path, {super.key, super.maxValue, super.ranges}) :
    super(config, 'RPM', path, step: rpmK2Revolutions(1));

  factory EngineRPMBox.fromSettings(config, {key}) {
    _EngineSettings s = _$EngineSettingsFromJson(config.settings);

    return EngineRPMBox._init(s, config, 'propulsion.${s.id}.revolutions',
      maxValue: rpm2Revolutions(s.maxRPM.toDouble()), key: key, ranges: [
        GuageRange(rpm2Revolutions(s.rpmRedLine.toDouble()), rpm2Revolutions(s.maxRPM.toDouble()), Colors.red)
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

  const EngineTempBox._init(this._settings, config, path, {super.key, super.minValue,  super.maxValue, super.ranges}) :
    super(config, 'Temp', GaugeOrientation.up, path, step: 20);

  factory EngineTempBox.fromSettings(config, {key}) {
    _EngineSettings s = _$EngineSettingsFromJson(config.settings);

    return EngineTempBox._init(s, config, 'propulsion.${s.id}.temperature',
      minValue: kelvinOffset, maxValue: s.maxTemp, key: key, ranges: [
        GuageRange(s.maxTemp-10, s.maxTemp, Colors.red),
        GuageRange(kelvinOffset+10, s.maxTemp-10, Colors.green),
        const GuageRange(kelvinOffset, kelvinOffset+10, Colors.orange)
      ]);
  }

  @override
  double convert(double value) {
    return convertTemperature(config.controller, value);
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
      displayValue = convertTemperature(widget.config.controller, value!);
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
              initialValue: convertTemperature(c, s.maxTemp).toInt().toString(),
              onChanged: (value) => s.maxTemp = invertTemperature(c, double.parse(value))),
          trailing: Text(c.temperatureUnits.unit)
      ),
    ];

    return ListView(children: list);
  }
}
