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
  int redLine;

  _EngineSettings({this.id = '', this.maxRPM = 4000, this.redLine = 3500});
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
        GuageRange(rpm2Revolutions(s.redLine.toDouble()), rpm2Revolutions(s.maxRPM.toDouble()), Colors.red)
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
    return _EngineSettingsWidget(_settings);
  }

  @override
  Widget? getSettingsHelp() => const HelpTextWidget('For a path of "propulsion.port.revolutions" the ID is "port"');

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

class _EngineSettingsWidget extends BoxSettingsWidget {
  final _EngineSettings _settings;

  const _EngineSettingsWidget(this._settings);

  @override
  createState() => _AnchorAlarmSettingsState();

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$EngineSettingsToJson(_settings);
  }
}

class _AnchorAlarmSettingsState extends State<_EngineSettingsWidget> {

  @override
  Widget build(BuildContext context) {
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
              initialValue: s.redLine.toString(),
              onChanged: (value) => s.redLine = int.parse(value)),
          trailing: const Text('rpm')
      ),
    ];

    return ListView(children: list);
  }
}
