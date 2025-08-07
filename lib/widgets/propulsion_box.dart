import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:boatinstrument/widgets/double_value_box.dart';
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
  double maxExhaustTemp;

  _EngineSettings({this.id = '', this.maxRPM = 4000, this.rpmRedLine = 3500, this.maxTemp = kelvinOffset+120, this.maxOilPressure = 500000, this.maxExhaustTemp = kelvinOffset+600});
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

  factory EngineRPMBox.fromSettings(BoxWidgetConfig config, {key}) {
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
    return _EngineSettingsWidget(config.controller, this, _settings);
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

  factory EngineTempBox.fromSettings(BoxWidgetConfig config, {key}) {
    _EngineSettings s = _$EngineSettingsFromJson(config.settings);

    return EngineTempBox._init(s, config, 'Temp:${s.id}', 'propulsion.${s.id}.temperature',
      minValue: kelvinOffset, maxValue: s.maxTemp, key: key, ranges: [
        GaugeRange(s.maxTemp-((s.maxTemp-kelvinOffset)*0.1), s.maxTemp, Colors.red),
        GaugeRange(kelvinOffset+((s.maxTemp-kelvinOffset)*0.1), s.maxTemp-((s.maxTemp-kelvinOffset)*0.1), Colors.green),
        GaugeRange(kelvinOffset, kelvinOffset+((s.maxTemp-kelvinOffset)*0.1), Colors.orange)
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
    return _EngineSettingsWidget(config.controller, this, _settings);
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

class EngineExhaustTempBox extends DoubleValueSemiGaugeBox {
  static const sid = 'propulsion-exhaust-temp';
  @override
  String get id => sid;

  final _EngineSettings _settings;

  const EngineExhaustTempBox._init(this._settings, config, title, path, {super.key, super.minValue,  super.maxValue, super.ranges}) :
    super(config, title, GaugeOrientation.up, path, step: 100);

  factory EngineExhaustTempBox.fromSettings(BoxWidgetConfig config, {key}) {
    _EngineSettings s = _$EngineSettingsFromJson(config.settings);

    return EngineExhaustTempBox._init(s, config, 'Exhaust Temp:${s.id}', 'propulsion.${s.id}.exhaustTemperature',
      minValue: kelvinOffset, maxValue: s.maxExhaustTemp, key: key, ranges: [
        GaugeRange(s.maxExhaustTemp-((s.maxExhaustTemp-kelvinOffset)*0.1), s.maxExhaustTemp, Colors.red),
        GaugeRange(kelvinOffset+((s.maxExhaustTemp-kelvinOffset)*0.1), s.maxExhaustTemp-((s.maxExhaustTemp-kelvinOffset)*0.1), Colors.green),
        GaugeRange(kelvinOffset, kelvinOffset+((s.maxExhaustTemp-kelvinOffset)*0.1), Colors.orange)
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
    return _EngineSettingsWidget(config.controller, this, _settings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('For a path of "propulsion.port.exhaustTemperature" the ID is "port"');

  @override
  DoubleValueSemiGaugeBoxState<EngineExhaustTempBox> createState() => _EngineExhaustTempState();
}

class _EngineExhaustTempState extends DoubleValueSemiGaugeBoxState<EngineExhaustTempBox> {

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

  factory EngineOilPressureBox.fromSettings(BoxWidgetConfig config, {key}) {
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
    return _EngineSettingsWidget(config.controller, this, _settings);
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

class EngineFuelRateBox extends DoubleValueBox {
  static const sid = 'propulsion-fuel-rate';
  @override
  String get id => sid;

  final _EngineSettings _settings;

  const EngineFuelRateBox._init(this._settings, super.config, super.title, super.path, {super.key, super.minLen, super.precision});

  factory EngineFuelRateBox.fromSettings(BoxWidgetConfig config, {key}) {
    _EngineSettings s = _$EngineSettingsFromJson(config.settings);

    return EngineFuelRateBox._init(s, config, 'Fuel Rate:${s.id}', 'propulsion.${s.id}.fuel.rate', minLen: 1, precision: 2, key: key);
  }

  @override
  double convert(double value) {
    return config.controller.fluidRateToDisplay(value);
  }
  
  @override
  String units(double value) {
    return config.controller.fluidRateUnits.unit;
  }

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _EngineSettingsWidget(config.controller, this, _settings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('For a path of "propulsion.port.fuel.rate" the ID is "port"');
}

class _EngineSettingsWidget extends BoxSettingsWidget {
  final BoatInstrumentController _controller;
  final DoubleValueBox _box;
  final _EngineSettings _settings;

  const _EngineSettingsWidget(this._controller, this._box, this._settings);

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
    DoubleValueBox b = widget._box;
    _EngineSettings s = widget._settings;

    List<Widget> list = [
      ListTile(
          leading: const Text("Engine ID:"),
          title: SignalkPathDropdownMenu(c, s.id, 'propulsion', (value) => s.id = value)
      ),
      if({EngineRPMBox}.contains(b.runtimeType))
        ListTile(
            leading: const Text("Max RPM:"),
            title: TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                initialValue: s.maxRPM.toString(),
                onChanged: (value) => s.maxRPM = int.parse(value)),
            trailing: const Text('rpm')
        ),
      if({EngineRPMBox}.contains(b.runtimeType))
        ListTile(
            leading: const Text("Redline:"),
            title: TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                initialValue: s.rpmRedLine.toString(),
                onChanged: (value) => s.rpmRedLine = int.parse(value)),
            trailing: const Text('rpm')
        ),
      if({EngineTempBox}.contains(b.runtimeType))
        ListTile(
            leading: const Text("Max Temp:"),
            title: TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                initialValue: c.temperatureToDisplay(s.maxTemp).toInt().toString(),
                onChanged: (value) => s.maxTemp = c.temperatureFromDisplay(double.parse(value))),
            trailing: Text(c.temperatureUnits.unit)
        ),
      if({EngineOilPressureBox}.contains(b.runtimeType))
        ListTile(
            leading: const Text("Max Oil Pressure:"),
            title: TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                initialValue: c.oilPressureToDisplay(s.maxOilPressure).toInt().toString(),
                onChanged: (value) => s.maxOilPressure = c.oilPressureFromDisplay(double.parse(value))),
            trailing: Text(c.oilPressureUnits.unit)
        ),
      if({EngineExhaustTempBox}.contains(b.runtimeType))
        ListTile(
            leading: const Text("Max Exhaust Temp:"),
            title: TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                initialValue: c.temperatureToDisplay(s.maxExhaustTemp).toInt().toString(),
                onChanged: (value) => s.maxExhaustTemp = c.temperatureFromDisplay(double.parse(value))),
            trailing: Text(c.temperatureUnits.unit)
        ),
    ];

    return ListView(children: list);
  }
}
