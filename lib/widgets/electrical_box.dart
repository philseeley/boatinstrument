import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:boatinstrument/widgets/double_value_box.dart';
import 'package:boatinstrument/widgets/gauge_box.dart';
import 'package:flutter/material.dart';
import 'package:format/format.dart';
import 'package:json_annotation/json_annotation.dart';

part 'electrical_box.g.dart';

@JsonSerializable()
class _ElectricalSettings {
  String id;

  _ElectricalSettings({this.id = ''});
}

enum BatteryVoltage {
  twelve('12', 1),
  twentyFour('24', 2),
  fortyEight('48', 4);

  final String displayName;
  final int multiplier;

  const BatteryVoltage(this.displayName, this.multiplier);
}

@JsonSerializable()
class _ElectricalBatterySettings {
  String id;
  BatteryVoltage voltage;

  _ElectricalBatterySettings({this.id = '', this.voltage = BatteryVoltage.twelve});
}

const String batteriesBasePath = 'electrical.batteries';
const String batteryTitle = 'Battery';
const String invertersBasePath = 'electrical.inverters';
const String inverterTitle = 'Inverter';
const String solarBasePath = 'electrical.solar';
const String solarTitle = 'Solar';

class BatteryVoltMeterBox extends DoubleValueSemiGaugeBox {
  static const sid = 'electrical-battery-voltage-meter';
  @override
  String get id => sid;

  final _ElectricalBatterySettings _settings;

  const BatteryVoltMeterBox._init(this._settings, config, title, path, {super.key, super.minValue, super.maxValue, super.ranges}) :
    super(config, title, GaugeOrientation.up, path);

  factory BatteryVoltMeterBox.fromSettings(config, {key}) {
    _ElectricalBatterySettings s = _$ElectricalBatterySettingsFromJson(config.settings);

    return BatteryVoltMeterBox._init(s, config, 'Battery:${s.id}', 'electrical.batteries.${s.id}.voltage',
      minValue: 10.0*s.voltage.multiplier, maxValue: 15.0*s.voltage.multiplier, key: key, ranges: [
        GaugeRange(10.0*s.voltage.multiplier, 12.0*s.voltage.multiplier, Colors.red),
        GaugeRange(12.0*s.voltage.multiplier, 13.0*s.voltage.multiplier, Colors.orange),
        GaugeRange(13.0*s.voltage.multiplier, 15.0*s.voltage.multiplier, Colors.green)
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
    return _ElectricalBatterySettingsWidget(config.controller, _settings, batteryTitle, batteriesBasePath);
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
      value = displayValue = 12.3*widget._settings.voltage.multiplier;
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
    return _ElectricalSettingsWidget(config.controller, _settings, batteryTitle, batteriesBasePath);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('For a path of "electrical.batteries.start.voltage" the ID is "start"');
}

class BatteryCurrentBox extends DoubleValueBox {
  static const sid = 'electrical-battery-current';
  @override
  String get id => sid;

  final _ElectricalSettings _settings;

  const BatteryCurrentBox._init(this._settings, config, title, path, {super.key}) : super(config, title, path, smoothing: false);

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
    return _ElectricalSettingsWidget(config.controller, _settings, batteryTitle, batteriesBasePath);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('For a path of "electrical.batteries.start.current" the ID is "start"');
}

class InverterCurrentBox extends DoubleValueBox {
  static const sid = 'electrical-inverter-current';
  @override
  String get id => sid;

  final _ElectricalSettings _settings;

  const InverterCurrentBox._init(this._settings, config, title, path, {super.key}) : super(config, title, path, smoothing: false);

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
    return _ElectricalSettingsWidget(config.controller, _settings, inverterTitle, invertersBasePath);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('For a path of "electrical.inverters.1.dc.current" the ID is "1"');
}

class SolarVoltageBox extends DoubleValueBox {
  static const sid = 'electrical-solar-voltage';
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
    return _ElectricalSettingsWidget(config.controller, _settings, solarTitle, solarBasePath);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('For a path of "electrical.solar.1.voltage" the ID is "1"');
}

class SolarCurrentBox extends DoubleValueBox {
  static const sid = 'electrical-solar-current';
  @override
  String get id => sid;

  final _ElectricalSettings _settings;

  const SolarCurrentBox._init(this._settings, config, title, path, {super.key}) : super(config, title, path, smoothing: false);

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
    return _ElectricalSettingsWidget(config.controller, _settings, solarTitle, solarBasePath);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('For a path of "electrical.solar.1.current" the ID is "1"');
}

class BatteriesBox extends BoxWidget {
  static const String sid = 'electrical-batteries';
  @override
  String get id => sid;

  const BatteriesBox(super.config, {super.key});

  @override
  State<BatteriesBox> createState() => _BatteriesBoxState();
}

class _Battery {
  final String id;
  String? name;
  double? voltage;
  double? current;
  double? stateOfCharge;
  double? temperature;

  _Battery(this.id);
}

class _BatteriesBoxState extends State<BatteriesBox> {
  List<_Battery> _batteries = [];

  _Battery _getBattery(String id) {
    for (_Battery b in _batteries) {
      if(b.id == id) {
        return b;
      }
    }
    _Battery b = _Battery(id);
    _batteries.add(b);
    
    return b;
  }

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(onUpdate: _onUpdate, paths: {'electrical.batteries.*'});
  }

  @override
  Widget build(BuildContext context) {
    BoatInstrumentController c = widget.config.controller;
    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);
    const double pad = 5.0;

    if(widget.config.editMode) {
      _Battery b = _Battery('1')
         ..name = 'bat1'
         ..voltage = 12.3
         ..current = 12.3
         ..stateOfCharge = 0.5
         ..temperature = kelvinOffset+12.3;
      _batteries = [b];
    }

    _batteries.sort((a, b) => (a.name??a.id).compareTo(b.name??b.id));

    String maxName = '';
    for(_Battery b in _batteries) {
      if((b.name??b.id).length > maxName.length) {
        maxName = b.name??b.id;
      }
    }

    List<Widget> l = [];
    if(_batteries.isNotEmpty) {
      String f = ' {:3.0f}% {:4.1f}V {:6.1f}A {:6.1f}${c.temperatureUnits.unit}';
      String textSample = format('$maxName$f', 1.0, 1.0, 1.0, 1.0);
      double fontSize = maxFontSize(textSample, style,
          (widget.config.constraints.maxHeight - style.fontSize! - (3 * pad)) / _batteries.length,
          widget.config.constraints.maxWidth - (2 * pad));

      TextStyle contentStyle = style.copyWith(fontSize: fontSize);
      for(_Battery b  in _batteries) {
        l.add(Row(children: [Text(format('{:${maxName.length}s}$f', b.name??b.id, (b.stateOfCharge??0.0)*100, b.voltage??0.0, b.current??0.0, c.temperatureToDisplay(b.temperature??0.0)),
              textScaler: TextScaler.noScaling,  style: contentStyle)]));
      }
    }

    return Column(children: [
      Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Row(children: [Text('Batteries', style: style)])),
      Padding(padding: const EdgeInsets.all(pad), child: Column(children: l))]);
  }

  void _onUpdate(List<Update>? updates) {
    if(updates == null) {
      _batteries = [];
    } else {
      for (Update u in updates) {
        try {
          List<String> p = u.path.split('.');
          _Battery b = _getBattery(p[2]);

          switch (p[3]) {
            case 'name':
              b.name = u.value;
              break;
            case 'voltage':
              b.voltage = (u.value as num).toDouble();
              break;
            case 'current':
              b.current = (u.value as num).toDouble();
              break;
            case 'capacity':
              switch (p[4]) {
                case 'stateOfCharge':
                b.stateOfCharge = (u.value as num).toDouble();
                break;
              }
              break;
            case 'temperature':
              b.temperature = (u.value as num).toDouble();
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

class _ElectricalSettingsWidget extends BoxSettingsWidget {
  final BoatInstrumentController _controller;
  final _ElectricalSettings _settings;
  final String _title;
  final String _basePath;

  const _ElectricalSettingsWidget(this._controller, this._settings, this._title, this._basePath);

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
          leading: Text("${widget._title} ID:"),
          title: SignalkPathDropdownMenu(
            widget._controller,
            s.id,
            widget._basePath,
            (value) => s.id = value)
      ),
    ];

    return ListView(children: list);
  }
}

class _ElectricalBatterySettingsWidget extends BoxSettingsWidget {
  final BoatInstrumentController _controller;
  final _ElectricalBatterySettings _settings;
  final String _title;
  final String _basePath;

  const _ElectricalBatterySettingsWidget(this._controller, this._settings, this._title, this._basePath);

  @override
  createState() => _ElectricalBatterySettingsState();

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$ElectricalBatterySettingsToJson(_settings);
  }
}

class _ElectricalBatterySettingsState extends State<_ElectricalBatterySettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _ElectricalBatterySettings s = widget._settings;

    List<Widget> list = [
      ListTile(
          leading: Text("${widget._title} ID:"),
          title: SignalkPathDropdownMenu(
            widget._controller,
            s.id,
            widget._basePath,
            (value) => s.id = value)
      ),
      ListTile(
        leading: const Text("System Voltage:"),
        title: DropdownMenu<BatteryVoltage>(
          expandedInsets: EdgeInsets.zero,
          initialSelection: s.voltage,
          dropdownMenuEntries: BatteryVoltage.values.map((v) {
            return DropdownMenuEntry<BatteryVoltage>(
              label: v.displayName,
              value: v,
              style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.grey))
            );
          }).toList(),
          onSelected: (value) {
            setState(() {
              s.voltage = value!;
            });
          },
        )
      ),
    ];

    return ListView(children: list);
  }
}
