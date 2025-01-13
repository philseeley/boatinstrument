import 'dart:io';

import 'package:boatinstrument/authorization.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:boatinstrument/widgets/double_value_box.dart';
import 'package:boatinstrument/widgets/gauge_box.dart';
import 'package:flutter/material.dart';
import 'package:format/format.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:nanoid/nanoid.dart';

part 'electrical_box.g.dart';

@JsonSerializable()
class _ElectricalSettings {
  String id;

  _ElectricalSettings({this.id = ''});
}

enum BatteryVoltage implements EnumMenuEntry {
  twelve(12, 1),
  twentyFour(24, 2),
  fortyEight(48, 4);

  @override
  String get displayName => '${voltage}v';

  final int voltage;
  final int multiplier;

  const BatteryVoltage(this.voltage, this.multiplier);
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

  const BatteryVoltMeterBox._init(this._settings, config, title, path, {super.key, super.minValue, super.maxValue, super.ranges, super.step}) :
    super(config, title, GaugeOrientation.up, path);

  factory BatteryVoltMeterBox.fromSettings(config, {key}) {
    _ElectricalBatterySettings s = _$ElectricalBatterySettingsFromJson(config.settings);

    return BatteryVoltMeterBox._init(s, config, 'Battery:${s.id}', 'electrical.batteries.${s.id}.voltage',
      minValue: 10.0*s.voltage.multiplier, maxValue: 15.0*s.voltage.multiplier, step: s.voltage.multiplier.toDouble(), key: key, ranges: [
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
        title: EnumDropdownMenu(
          BatteryVoltage.values,
          s.voltage,
          (value) {s.voltage = value!;},
        )
      ),
    ];

    return ListView(children: list);
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

@JsonSerializable()
class _ElectricalSwitchesSettings {
  bool useSliderForDimming;
  String clientID;
  String authToken;

  _ElectricalSwitchesSettings({
    this.useSliderForDimming = false,
    clientID,
    this.authToken = '',
  }) : clientID = clientID??'boatinstrument-electrical-switches-${customAlphabet('0123456789', 4)}';
}

mixin SwitchCommands {
  void _sendCommand(BoxWidgetConfig config, BuildContext context, String authToken, String id, String type, String params) async {
    if(config.editMode) {
      return;
    }

    try {
      Uri uri = config.controller.httpApiUri.replace(
          path: 'signalk/v1/api/vessels/self/electrical/switches/$id/$type');

      http.Response response = await http.put(
          uri,
          headers: {
            "Content-Type": "application/json",
            "accept": "application/json",
            "Authorization": "Bearer $authToken"
          },
          body: params
      );

      if(response.statusCode != HttpStatus.ok) {
        if(context.mounted) {
          config.controller.showMessage(context, response.reasonPhrase ?? '', error: true);
        }
      }
    } catch (e) {
      config.controller.l.e('Error putting to server', error: e);
    }
  }
}

class ElectricalSwitchesBox extends BoxWidget {
  static const String sid = 'electrical-switches';
  @override
  String get id => sid;

  const ElectricalSwitchesBox(super.config, {super.key});

  @override
  bool get hasSettings => true;

  @override
  BoxSettingsWidget getSettingsWidget(Map<String, dynamic> json) {
    return _ElectricalSwitchesSettingsWidget(super.config.controller, _$ElectricalSwitchesSettingsFromJson(json));
  }

  @override
  Widget? getHelp(BuildContext context) => const HelpTextWidget('''Note: due to the scrollable list of Switches, swipe down from the title to configure.

This Box requires digital switching plugins that allow PUT requests, e.g. signalk-empirbusnxt-plugin.''');

  @override
  Widget? getSettingsHelp() => const HelpTextWidget('''To be able to control switches, the device must be given "read/write" permission to signalk. Request an Auth Token and without closing the settings page authorise the device in the signalk web interface. When the Auth Token is shown, the settings page can be closed.
The Client ID can be set to reflect the instrument's location, e.g. "boatinstrument-electrical-switches-tablet". Or the ID can be set to the same value for all instruments to share the same authorisation.''');

  @override
  State<ElectricalSwitchesBox> createState() => _ElectricalSwitchesBoxState();
}

enum ElectricalSwitchType {
  toggleSwitch('switch'),
  dimmer('dimmer');

  final String type;

  const ElectricalSwitchType(this.type);
}

class _ElectricalSwitch {
  final String id;
  ElectricalSwitchType? type;
  String? name;
  bool? state;
  double? dimmingLevel;

  _ElectricalSwitch(this.id);
}

class _ElectricalSwitchesBoxState extends State<ElectricalSwitchesBox> with SwitchCommands {
  late final _ElectricalSwitchesSettings _settings;
  List<_ElectricalSwitch> _switches = [];

  _ElectricalSwitch _getSwitch(String id) {
    for (_ElectricalSwitch s in _switches) {
      if(s.id == id) {
        return s;
      }
    }
    _ElectricalSwitch s = _ElectricalSwitch(id);
    _switches.add(s);

    return s;
  }

  @override
  void initState() {
    super.initState();
    _settings = _$ElectricalSwitchesSettingsFromJson(widget.config.controller.getBoxSettingsJson(widget.id));

    widget.config.controller.configure(onUpdate: _onUpdate, paths: {'electrical.switches.*'});
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);
    const double pad = 5.0;

    if(widget.config.editMode) {
      _ElectricalSwitch s1 = _ElectricalSwitch('sw1')
        ..type = ElectricalSwitchType.toggleSwitch
        ..name = 'Running'
        ..state = true;
      _ElectricalSwitch s2 = _ElectricalSwitch('dm1')
        ..type = ElectricalSwitchType.dimmer
        ..name = 'cabin'
        ..state = false
        ..dimmingLevel = 0.5;
      _switches = [s1, s2];
    }

    _switches.sort((a, b) => (a.name??a.id).compareTo(b.name??b.id));

    String maxName = '';
    for(_ElectricalSwitch b in _switches) {
      if((b.name??b.id).length > maxName.length) {
        maxName = b.name??b.id;
      }
    }

    List<Widget> l = [];

    for(_ElectricalSwitch s  in _switches) {
      List<Widget> dimmerList = [];

      if(s.type == ElectricalSwitchType.dimmer &&
         s.dimmingLevel != null) {
          if(_settings.useSliderForDimming) {
            dimmerList.addAll([
              Text('${(s.dimmingLevel!*100).toInt()}%'),
              Expanded(child: Slider(
                min: 0,
                max: 100,
                divisions: 10,
                value: s.dimmingLevel!*100,
                label: "${(s.dimmingLevel!*100).toInt()}",
                onChanged: (double value) {
                  setState(() {
                    s.dimmingLevel = value/100;
                  });
                },
                onChangeEnd: (double value) {
                  _setDimmer(s, value/100);
                }
              ))
            ]);
          } else {
            dimmerList.addAll([
              IconButton(icon: const Icon(Icons.first_page), onPressed: () {_setDimmer(s, 0);}),
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {_setDimmer(s, s.dimmingLevel!-0.1);}),
              Text('${((s.dimmingLevel??0)*100).round()}%'),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {_setDimmer(s, s.dimmingLevel!+0.1);}),
              IconButton(icon: const Icon(Icons.last_page), onPressed: () {_setDimmer(s, 1);}),
            ]);
          }
      }
      ListTile lt = ListTile(
        leading: Text(format('{:${maxName.length}s}', s.name??s.id), style: style),
        title: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: dimmerList),
        trailing: s.state == null ? null : Switch(value: s.state!, onChanged: (value) {
            _setSwitchState(s, value);
        }),
      );
      l.add(lt);
    }

    return Column(children: [
        Padding(padding: const EdgeInsets.all(pad), child: Row(children: [Text('Switches', style: style)])),
        Expanded(child: ListView(children: l))
      ]);
  }

  void _setSwitchState(_ElectricalSwitch s, bool state) {
    setState(() {
      s.state = state;
    });
    _sendCommand(widget.config, context, _settings.authToken, s.id, 'state', '{"value": $state}');
  }

  void _setDimmer(_ElectricalSwitch s, double dimmingLevel) {
    setState(() {
      dimmingLevel = dimmingLevel>1 ? 1 : dimmingLevel;
      dimmingLevel = dimmingLevel<0 ? 0 : dimmingLevel;
      s.dimmingLevel = dimmingLevel;
    });
    _sendCommand(widget.config, context, _settings.authToken, s.id, 'dimmingLevel', '{"value": $dimmingLevel}');
  }

  void _onUpdate(List<Update>? updates) {
    if(updates == null) {
      _switches = [];
    } else {
      for (Update u in updates) {
        try {
          List<String> p = u.path.split('.');
          _ElectricalSwitch s = _getSwitch(p[2]);

          switch (p[3]) {
            case 'name':
              s.name = u.value;
              break;
            case 'type':
              s.type = ElectricalSwitchType.values.firstWhere((s) => s.type == u.value);
              break;
            case 'state':
              s.state = u.value;
              break;
            case 'dimmingLevel':
              s.dimmingLevel = (u.value as num).toDouble();
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

class _ElectricalSwitchesSettingsWidget extends BoxSettingsWidget {
  final BoatInstrumentController _controller;
  final _ElectricalSwitchesSettings _settings;

  const _ElectricalSwitchesSettingsWidget(this._controller, this._settings);

  @override
  createState() => _ElectricalSwitchesSettingsState();

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$ElectricalSwitchesSettingsToJson(_settings);
  }
}

class _ElectricalSwitchesSettingsState extends State<_ElectricalSwitchesSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _ElectricalSwitchesSettings s = widget._settings;

    List<Widget> list = [
      SwitchListTile(title: const Text('Use Slider for Dimming:'),
          value: s.useSliderForDimming,
          onChanged: (bool value) {
            setState(() {
              s.useSliderForDimming = value;
            });
          }),
      ListTile(
          leading: const Text("Client ID:"),
          title: TextFormField(
              initialValue: s.clientID,
              onChanged: (value) => s.clientID = value)
      ),
      ListTile(
          leading: const Text("Request Auth Token:"),
          title: IconButton(onPressed: _requestAuthToken, icon: const Icon(Icons.login))
      ),
      ListTile(
          leading: const Text("Auth token:"),
          title: Text(s.authToken)
      ),
    ];

    return ListView(children: list);
  }

  void _requestAuthToken() async {
    SignalKAuthorization(widget._controller).request(widget._settings.clientID, "Boat Instrument - Electrical Switches",
            (authToken) {
          setState(() {
            widget._settings.authToken = authToken;
          });
        },
            (msg) {
          if (mounted) {
            setState(() {
              widget._settings.authToken = msg;
            });
          }
        });

    setState(() {
      widget._settings.authToken = 'PENDING - keep this page open until request approved';
    });
  }
}

class ElectricalSwitchBox extends BoxWidget {
  late final _ElectricalSettings _perBoxSettings;

  static const String sid = 'electrical-switch';
  @override
  String get id => ElectricalSwitchesBox.sid;

  ElectricalSwitchBox(super.config, {super.key}) {
    _perBoxSettings = _$ElectricalSettingsFromJson(config.settings);
  }

  @override
  bool get hasSettings => true;

  @override
  BoxSettingsWidget getSettingsWidget(Map<String, dynamic> json) {
    return _ElectricalSwitchesSettingsWidget(super.config.controller, _$ElectricalSwitchesSettingsFromJson(json));
  }

  @override
  Widget? getHelp(BuildContext context) => const HelpTextWidget('This Box requires digital switching plugins that allow PUT requests, e.g. signalk-empirbusnxt-plugin.');

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _ElectricalSettingsWidget(config.controller, _perBoxSettings, 'Switch', 'electrical.switches');
  }

  @override
  Widget? getSettingsHelp() => const HelpTextWidget('''To be able to control switches, the device must be given "read/write" permission to signalk. Request an Auth Token and without closing the settings page authorise the device in the signalk web interface. When the Auth Token is shown, the settings page can be closed.
The Client ID can be set to reflect the instrument's location, e.g. "boatinstrument-electrical-switches-tablet". Or the ID can be set to the same value for all instruments to share the same authorisation.''');

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('For a path of "electrical.switch.1.state" the ID is "1"');

  @override
  State<ElectricalSwitchBox> createState() => _ElectricalSwitchBoxState();
}

class _ElectricalSwitchBoxState extends State<ElectricalSwitchBox> with SwitchCommands {
  late final _ElectricalSwitchesSettings _settings;
  late final _ElectricalSwitch _switch;

  @override
  void initState() {
    super.initState();
    _settings = _$ElectricalSwitchesSettingsFromJson(widget.config.controller.getBoxSettingsJson(widget.id));
    
    _switch = _ElectricalSwitch(widget._perBoxSettings.id);

    widget.config.controller.configure(onUpdate: _onUpdate, paths: {'electrical.switches.${widget._perBoxSettings.id}.*'});
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);
    const double pad = 5.0;

    List<Widget> dimmerList = [];

    if(_switch.type == ElectricalSwitchType.dimmer &&
        _switch.dimmingLevel != null) {
        if(_settings.useSliderForDimming) {
          dimmerList.addAll([
            Text(' ${(_switch.dimmingLevel!*100).toInt()}%'),
            Expanded(child: Slider(
              min: 0,
              max: 100,
              divisions: 10,
              value: _switch.dimmingLevel!*100,
              label: "${(_switch.dimmingLevel!*100).toInt()}",
              onChanged: (double value) {
                setState(() {
                  _switch.dimmingLevel = value/100;
                });
              },
              onChangeEnd: (double value) {
                _setDimmer(_switch, value/100);
              }
            ))
          ]);
        } else {
          dimmerList.addAll([
            IconButton(icon: const Icon(Icons.first_page), onPressed: () {_setDimmer(_switch, 0);}),
            IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {_setDimmer(_switch, _switch.dimmingLevel!-0.1);}),
            Text('${((_switch.dimmingLevel??0)*100).round()}%'),
            IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {_setDimmer(_switch, _switch.dimmingLevel!+0.1);}),
            IconButton(icon: const Icon(Icons.last_page), onPressed: () {_setDimmer(_switch, 1);}),
          ]);
        }
    }

    Widget? toggleSwitch = _switch.state == null ?
      null :
      Switch(value: _switch.state!, onChanged: (value) {
            _setSwitchState(value);
      });

    return Column(children: [
        Padding(padding: const EdgeInsets.all(pad), child: Row(children: [Text('Switch ${_switch.name??_switch.id}', style: style)])),
        Center(child: toggleSwitch),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: dimmerList)
      ]);
  }

  void _setSwitchState(bool state) {
    setState(() {
      _switch.state = state;
    });
    _sendCommand(widget.config, context, _settings.authToken, _switch.id, 'state', '{"value": $state}');
  }

  void _setDimmer(_ElectricalSwitch s, double dimmingLevel) {
    setState(() {
      dimmingLevel = dimmingLevel>1 ? 1 : dimmingLevel;
      dimmingLevel = dimmingLevel<0 ? 0 : dimmingLevel;
      s.dimmingLevel = dimmingLevel;
    });
    _sendCommand(widget.config, context, _settings.authToken, s.id, 'dimmingLevel', '{"value": $dimmingLevel}');
  }

  void _onUpdate(List<Update>? updates) {
    if(updates == null) {
      _switch.state = _switch.dimmingLevel = null;
    } else {
      for (Update u in updates) {
        try {
          List<String> p = u.path.split('.');

          switch (p[3]) {
            case 'name':
              _switch.name = u.value;
              break;
            case 'type':
              _switch.type = ElectricalSwitchType.values.firstWhere((s) => s.type == u.value);
              break;
            case 'state':
              _switch.state = u.value;
              break;
            case 'dimmingLevel':
              _switch.dimmingLevel = (u.value as num).toDouble();
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
