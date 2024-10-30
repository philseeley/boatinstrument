import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:boatinstrument/widgets/gauge_box.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'electrical_box.g.dart';

@JsonSerializable()
class _VoltMeterSettings {
  String id;

  _VoltMeterSettings({this.id = ''});
}

class VoltMeterBox extends DoubleValueSemiGaugeBox {
  static const sid = 'electrical-battery-voltage';
  @override
  String get id => sid;

  final _VoltMeterSettings _settings;

  const VoltMeterBox._init(this._settings, config, path, {super.key, super.minValue, super.maxValue = 15, super.ranges}) :
    super(config, 'Battery', GaugeOrientation.up, path);

  factory VoltMeterBox.fromSettings(config, {key}) {
    _VoltMeterSettings s = _$VoltMeterSettingsFromJson(config.settings);
print(s.id);
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
  Widget? getSettingsHelp() => const HelpTextWidget('For a path of "electrical.batteries.start.voltage" the ID is "start"');

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
  final _VoltMeterSettings _settings;

  const _VoltMeterSettingsWidget(this._settings);

  @override
  createState() => _AnchorAlarmSettingsState();

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$VoltMeterSettingsToJson(_settings);
  }
}

class _AnchorAlarmSettingsState extends State<_VoltMeterSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _VoltMeterSettings s = widget._settings;

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
