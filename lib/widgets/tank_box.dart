import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:boatinstrument/widgets/gauge_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:format/format.dart';
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
    return _TankSettingsWidget(config.controller, _settings, 'tanks.$_type');
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

class TanksBox extends BoxWidget {
  static const String sid = 'tanks';
  @override
  String get id => sid;

  const TanksBox(super.config, {super.key});

  @override
  State<TanksBox> createState() => _TanksBoxState();
}

class _Tank {
  final String pathType;
  final String id;
  String? name;
  String? type;
  double? capacity;
  double? currentLevel;
  double? currentVolume;

  _Tank(this.pathType, this.id);
}

class _TanksBoxState extends State<TanksBox> {
  List<_Tank> _tanks = [];

  _Tank _getTank(String pathType, String id) {
    for (_Tank t in _tanks) {
      if(t.pathType == pathType && t.id == id) {
        return t;
      }
    }
    _Tank t = _Tank(pathType, id);
    _tanks.add(t);
    
    return t;
  }

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(onUpdate: _onUpdate, paths: {'tanks.*'});
  }

  @override
  Widget build(BuildContext context) {
    BoatInstrumentController c = widget.config.controller;
    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);
    const double pad = 5.0;

    if(widget.config.editMode) {
      _Tank b = _Tank('fuel', '1')
        ..name = 'diesel1'
        ..type = 'diesel'
        ..capacity = c.capacityFromDisplay(123.0)
        ..currentLevel = 0.5
        ..currentVolume = c.capacityFromDisplay(123.0)*0.5;
      _tanks = [b];
    }

    _tanks.sort((a, b) => (a.name??a.id).compareTo(b.name??b.id));

    String maxName = '';
    for(_Tank b in _tanks) {
      String n = b.name??b.id;
      if(n.length > maxName.length) {
        maxName = n;
      }
    }

    String maxType = '';
    for(_Tank b in _tanks) {
      String t = b.type??b.pathType;
      if(t.length > maxType.length) {
        maxType = t;
      }
    }

    List<Widget> l = [];
    if(_tanks.isNotEmpty) {
      String f = ' {:4.0f} {:3.0f}% {:4.0f}';
      String textSample = format('$maxName $maxType$f', 1.0, 1.0, 1.0);
      double fontSize = maxFontSize(textSample, style,
          (widget.config.constraints.maxHeight - style.fontSize! - (3 * pad)) / _tanks.length,
          widget.config.constraints.maxWidth - (2 * pad));

      TextStyle contentStyle = style.copyWith(fontSize: fontSize);
      for(_Tank t  in _tanks) {
        l.add(Row(children: [Text(format('{:${maxName.length}s} {:${maxType.length}s}$f', t.name??t.id, t.type??t.pathType, c.capacityToDisplay(t.capacity??0.0), (t.currentLevel??0)*100, c.capacityToDisplay(t.currentVolume??0.0)),
              textScaler: TextScaler.noScaling,  style: contentStyle)]));
      }
    }

    return Column(children: [
      Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Row(children: [Text('Tanks ${c.capacityUnits.unit}', style: style)])),
      Padding(padding: const EdgeInsets.all(pad), child: Column(children: l))]);
  }

  void _onUpdate(List<Update>? updates) {
    if(updates == null) {
      _tanks = [];
    } else {
      for (Update u in updates) {
        try {
          List<String> p = u.path.split('.');
          _Tank t = _getTank(p[1], p[2]);

          switch (p[3]) {
            case 'name':
              t.name = u.value;
              break;
            case 'type':
              t.type = u.value;
              break;
            case 'capacity':
              t.capacity = (u.value as num).toDouble();
              break;
            case 'currentLevel':
              t.currentLevel = (u.value as num).toDouble();
              break;
            case 'currentVolume':
              t.currentVolume = (u.value as num).toDouble();
              break;
          }
        } catch (e) {
          widget.config.controller.l.e("Error converting $u", error: e);
        }
      }
    }

    if(mounted) {
      setState(() {});
    }
  }
}

class _TankSettingsWidget extends BoxSettingsWidget {
  final BoatInstrumentController _controller;
  final _TankSettings _settings;
  final String _basePath;

  const _TankSettingsWidget(this._controller, this._settings, this._basePath);

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
          title: SignalkPathDropdownMenu(widget._controller, s.id, widget._basePath, (value) => s.id = value)),
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
