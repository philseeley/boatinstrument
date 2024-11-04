import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:boatinstrument/widgets/gauge_box.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'electrical_box.g.dart';

@JsonSerializable()
class _ElectricalSettings {
  String id;

  _ElectricalSettings({this.id = ''});
}

class VoltMeterBox extends DoubleValueSemiGaugeBox {
  static const sid = 'electrical-battery-voltage';
  @override
  String get id => sid;

  final _ElectricalSettings _settings;

  const VoltMeterBox._init(this._settings, config, path, {super.key, super.minValue, super.maxValue, super.ranges}) :
    super(config, 'Battery', GaugeOrientation.up, path);

  factory VoltMeterBox.fromSettings(config, {key}) {
    _ElectricalSettings s = _$ElectricalSettingsFromJson(config.settings);

    return VoltMeterBox._init(s, config, 'electrical.batteries.${s.id}.voltage',
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
    return _VoltMeterSettingsWidget(_settings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('For a path of "electrical.batteries.start.voltage" the ID is "start"');

  @override
  DoubleValueSemiGaugeBoxState<VoltMeterBox> createState() => _VoltMeterState();
}

class _VoltMeterState extends DoubleValueSemiGaugeBoxState<VoltMeterBox> {

  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      value = displayValue = 12.3;
    }

    return super.build(context);
  }
}

class _VoltMeterSettingsWidget extends BoxSettingsWidget {
  final _ElectricalSettings _settings;

  const _VoltMeterSettingsWidget(this._settings);

  @override
  createState() => _ElectricalSettingsState();

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$ElectricalSettingsToJson(_settings);
  }
}

class _ElectricalSettingsState extends State<_VoltMeterSettingsWidget> {

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
