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

  const VoltMeterBox(config, {super.key, super.minValue = 10, super.maxValue = 15, super.ranges = const [
    GuageRange(10, 12, Colors.red),
    GuageRange(12, 13, Colors.orange),
    GuageRange(13, 15, Colors.green)
  ]}) : super(config, 'Battery', GaugeOrientation.up, '');

  @override
  double convert(double value) {
    return value;
  }
  
  @override
  String units(double value) {
    return 'V';
  }

  @override
  bool get hasSettings => true;

  @override
  BoxSettingsWidget getSettingsWidget(Map<String, dynamic> json) {
    return _VoltMeterSettingsWidget(_$VoltMeterSettingsFromJson(json));
  }

  @override
  Widget? getSettingsHelp() => const HelpTextWidget('For a path of "electrical.batteries.start.voltage" the ID is "start"');

  @override
  DoubleValueSemiGaugeBoxState<VoltMeterBox> createState() => _VoltMeterState();
}

class _VoltMeterState extends DoubleValueSemiGaugeBoxState<VoltMeterBox> {
  late final _VoltMeterSettings _settings;

  _VoltMeterState() : super(configure: false);

  @override
  void initState() {
    super.initState();
    _settings = _$VoltMeterSettingsFromJson(widget.config.controller.getBoxSettingsJson(widget.id));
    widget.config.controller.configure(onUpdate: processUpdates, paths: { 'electrical.batteries.${_settings.id}.voltage' });
  }

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
