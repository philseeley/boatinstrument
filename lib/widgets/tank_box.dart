import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:boatinstrument/widgets/gauge_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tank_box.g.dart';

@JsonSerializable()
class _TankSettings {
  String id;
  double capacity;

  _TankSettings({this.id = '', this.capacity = 0.5});
}

abstract class TankBox extends DoubleValueBarGaugeBox {
  final _TankSettings _settings;
  final String _type;

  const TankBox._init(this._settings, config, title, this._type, id, {super.key, required super.maxValue}) :
    super(config, '$title:$id', 'tanks.$_type.$id.currentLevel', step: 0.1);

  @override
  double convert(double value) {
    return config.controller.capacityToDisplay(value);
  }
  
  @override
  String units(double value) {
    return config.controller.capacityUnits.unit;
  }

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _TankSettingsWidget(config.controller, _settings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => HelpTextWidget('For a path of "tanks.$_type.port.currentLevel" the ID is "port"');

  @override
  DoubleValueBarGaugeBoxState<TankBox> createState() => _TankState();
}

class _TankState extends DoubleValueBarGaugeBoxState<TankBox> {

  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      value = 0.5;
    }

    displayValue = maxDisplay * (value??0);

    return super.build(context);
  }
}

class FreshWaterTankBox extends TankBox {
  static const sid = 'tank-freshwater';
  @override
  String get id => sid;

  const FreshWaterTankBox._init(s, config, id, {super.key, super.maxValue}) :
    super._init(s, config, 'Fresh', 'freshWater', id);

  factory FreshWaterTankBox.fromSettings(config, {key}) {
    _TankSettings s = _$TankSettingsFromJson(config.settings);

    return FreshWaterTankBox._init(s, config, s.id, maxValue: s.capacity, key: key);
  }
}

class GreyWaterTankBox extends TankBox {
  static const sid = 'tank-wastewater';
  @override
  String get id => sid;

  const GreyWaterTankBox._init(s, config, id, {super.key, super.maxValue}) :
    super._init(s, config, 'Grey', 'wasteWater', id);

  factory GreyWaterTankBox.fromSettings(config, {key}) {
    _TankSettings s = _$TankSettingsFromJson(config.settings);

    return GreyWaterTankBox._init(s, config, s.id, maxValue: s.capacity, key: key);
  }
}

class BlackWaterTankBox extends TankBox {
  static const sid = 'tank-blackwater';
  @override
  String get id => sid;

  const BlackWaterTankBox._init(s, config, id, {super.key, super.maxValue}) :
    super._init(s, config, 'Black', 'blackWater', id);

  factory BlackWaterTankBox.fromSettings(config, {key}) {
    _TankSettings s = _$TankSettingsFromJson(config.settings);

    return BlackWaterTankBox._init(s, config, s.id, maxValue: s.capacity, key: key);
  }
}

class FuelTankBox extends TankBox {
  static const sid = 'tank-fuel';
  @override
  String get id => sid;

  const FuelTankBox._init(s, config, id, {super.key, super.maxValue}) :
    super._init(s, config, 'Fuel', 'fuel', id);

  factory FuelTankBox.fromSettings(config, {key}) {
    _TankSettings s = _$TankSettingsFromJson(config.settings);

    return FuelTankBox._init(s, config, s.id, maxValue: s.capacity, key: key);
  }
}

class LubricationTankBox extends TankBox {
  static const sid = 'tank-lubrication';
  @override
  String get id => sid;

  const LubricationTankBox._init(s, config, id, {super.key, super.maxValue}) :
    super._init(s, config, 'Lube', 'lubrication', id);

  factory LubricationTankBox.fromSettings(config, {key}) {
    _TankSettings s = _$TankSettingsFromJson(config.settings);

    return LubricationTankBox._init(s, config, s.id, maxValue: s.capacity, key: key);
  }
}

class _TankSettingsWidget extends BoxSettingsWidget {
  final BoatInstrumentController _controller;
  final _TankSettings _settings;

  const _TankSettingsWidget(this._controller, this._settings);

  @override
  createState() => _TankSettingsState();

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$TankSettingsToJson(_settings);
  }
}

class _TankSettingsState extends State<_TankSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    BoatInstrumentController c = widget._controller;
    _TankSettings s = widget._settings;

    List<Widget> list = [
      ListTile(
          leading: const Text("Tank ID:"),
          title: TextFormField(
              initialValue: s.id,
              onChanged: (value) => s.id = value)
      ),
      ListTile(
          leading: const Text("Capacity:"),
          title: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              initialValue: c.capacityToDisplay(s.capacity).toInt().toString(),
              onChanged: (value) => s.capacity = c.capacityFromDisplay(double.parse(value))),
          trailing: Text(c.capacityUnits.unit)
      ),
    ];

    return ListView(children: list);
  }
}
