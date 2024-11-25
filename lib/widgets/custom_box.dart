import 'dart:convert';
import 'dart:io';
import 'package:boatinstrument/widgets/double_value_box.dart';
import 'package:boatinstrument/widgets/gauge_box.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:share_plus/share_plus.dart';

import '../boatinstrument_controller.dart';

part 'custom_box.g.dart';

@JsonSerializable()
class _CustomSettings {
  String title;
  String path;
  int precision;
  int minLen;
  double minValue;
  double maxValue;
  bool angle;
  bool smoothing;
  String units;
  double multiplier;
  double step;
  bool portStarboard;

  _CustomSettings({
    this.title = 'title',
    this.path = 'path',
    this.precision = 1,
    this.minLen = 2,
    this.minValue = 0,
    this.maxValue = 100,
    this.angle = false,
    this.smoothing = true,
    this.units = 'units',
    this.multiplier = 1,
    this.step = 1,
    this.portStarboard = false
  });
}

class CustomDoubleValueBox extends DoubleValueBox {
  final _CustomSettings _settings;
  final String _unitsString;
  final double _multiplier;

  const CustomDoubleValueBox._init(this._settings, this._unitsString, this._multiplier, super.config, super.title, super.path, {super.precision, super.minLen, super.minValue, super.maxValue, super.angle, super.smoothing, super.portStarboard, super.key});

  factory CustomDoubleValueBox.fromSettings(config, {key}) {
    _CustomSettings s = _$CustomSettingsFromJson(config.settings);
    return CustomDoubleValueBox._init(s, s.units, s.multiplier, config, s.title, s.path, precision: s.precision, minLen: s.minLen, minValue: s.minValue, maxValue: s.maxValue, angle: s.angle, smoothing: s.smoothing, portStarboard: s.portStarboard, key: key);
  }

  static String sid = 'custom-double-value';
  @override
  String get id => sid;

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _SettingsWidget(config, _settings);
  }

  @override
  double convert(double value) {
    return value * _multiplier;
  }

  @override
  String units(double value) {
    return _unitsString;
  }
}

class CustomDoubleValueSemiGaugeBox extends DoubleValueSemiGaugeBox {
  final _CustomSettings _settings;
  final String _unitsString;
  final double _multiplier;

  const CustomDoubleValueSemiGaugeBox._init(this._settings, this._unitsString, this._multiplier, super.config, super.title, super.orientation, super.path, {super.minValue, super.maxValue, super.step, super.angle, super.smoothing, super.key});

  factory CustomDoubleValueSemiGaugeBox.fromSettings(config, {key}) {
    _CustomSettings s = _$CustomSettingsFromJson(config.settings);
    return CustomDoubleValueSemiGaugeBox._init(s, s.units, s.multiplier, config, s.title, GaugeOrientation.up, s.path, minValue: s.minValue, maxValue: s.maxValue, step: s.step, angle: s.angle, smoothing: s.smoothing, key: key);
  }

  static String sid = 'custom-gauge-semi';
  @override
  String get id => sid;

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _SettingsWidget(config, _settings);
  }

  @override
  double convert(double value) {
    return value * _multiplier;
  }

  @override
  String units(double value) {
    return _unitsString;
  }
}

class CustomDoubleValueCircularGaugeBox extends DoubleValueCircularGaugeBox {
  final _CustomSettings _settings;
  final String _unitsString;
  final double _multiplier;

  const CustomDoubleValueCircularGaugeBox._init(this._settings, this._unitsString, this._multiplier, super.config, super.title, super.path, {super.minValue, super.maxValue, required super.step, super.smoothing, super.key});

  factory CustomDoubleValueCircularGaugeBox.fromSettings(config, {key}) {
    _CustomSettings s = _$CustomSettingsFromJson(config.settings);
    return CustomDoubleValueCircularGaugeBox._init(s, s.units, s.multiplier, config, s.title, s.path, minValue: s.minValue, maxValue: s.maxValue, step: s.step, smoothing: s.smoothing, key: key);
  }

  static String sid = 'custom-gauge-circular';
  @override
  String get id => sid;

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _SettingsWidget(config, _settings);
  }

  @override
  double convert(double value) {
    return value * _multiplier;
  }

  @override
  String units(double value) {
    return _unitsString;
  }
}

class CustomDoubleValueBarGaugeBox extends DoubleValueBarGaugeBox {
  final _CustomSettings _settings;
  final String _unitsString;
  final double _multiplier;

  const CustomDoubleValueBarGaugeBox._init(this._settings, this._unitsString, this._multiplier, super.config, super.title, super.path, {super.minValue, super.maxValue, required super.step, super.smoothing, super.key});

  factory CustomDoubleValueBarGaugeBox.fromSettings(config, {key}) {
    _CustomSettings s = _$CustomSettingsFromJson(config.settings);
    return CustomDoubleValueBarGaugeBox._init(s, s.units, s.multiplier, config, s.title, s.path, minValue: s.minValue, maxValue: s.maxValue, step: s.step, smoothing: s.smoothing, key: key);
  }

  static String sid = 'custom-gauge-bar';
  @override
  String get id => sid;

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _SettingsWidget(config, _settings);
  }

  @override
  double convert(double value) {
    return value * _multiplier;
  }

  @override
  String units(double value) {
    return _unitsString;
  }
}

class _SettingsWidget extends BoxSettingsWidget {
  final BoxWidgetConfig _config;
  final _CustomSettings _settings;

  const _SettingsWidget(this._config, this._settings);

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$CustomSettingsToJson(_settings);
  }

  @override
  createState() => _SettingsState();
}

class _SettingsState extends State<_SettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _CustomSettings s = widget._settings;

    return ListView(children: [
      ListTile(
        leading: IconButton(onPressed: _emailSettings, icon: const Icon(Icons.email)),
        title: const Text("Custom Boxes are experimental, so please press the email button to send your setting to the developers(feedback@wheretofly.info), or raise an issue for permanent inclusion."),
      ),
      ListTile(
        leading: const Text("Title:"),
        title: TextFormField(
            initialValue: s.title,
            onChanged: (value) => s.title = value)
      ),
      ListTile(
        leading: const Text("Signalk Path:"),
        title: SignalkPathDropdownMenu(
          searchable: true,
          widget._config.controller,
          s.path,
          '',
          (value) => s.path = value,
          listPaths: true)
      ),
      ListTile(
          leading: const Text("Units:"),
          title: TextFormField(
              initialValue: s.units,
              onChanged: (value) => s.units = value)
      ),
      ListTile(
        leading: const Text("Multiplier:"),
        title: TextFormField(
            initialValue: s.multiplier.toString(),
            onChanged: (value) => s.multiplier = double.parse(value)),
      ),
      ListTile(
        leading: const Text("Precision:"),
        title: TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            initialValue: s.precision.toString(),
            onChanged: (value) => s.precision = int.parse(value)),
      ),
      ListTile(
        leading: const Text("Min Length:"),
        title: TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            initialValue: s.minLen.toString(),
            onChanged: (value) => s.minLen = int.parse(value)),
      ),
      ListTile(
        leading: const Text("Min Value:"),
        title: TextFormField(
            initialValue: s.minValue.toString(),
            onChanged: (value) => s.minValue = double.parse(value)),
      ),
      ListTile(
        leading: const Text("Max Value:"),
        title: TextFormField(
            initialValue: s.maxValue.toString(),
            onChanged: (value) => s.maxValue = double.parse(value)),
      ),
      ListTile(
        leading: const Text("Step:"),
        title: TextFormField(
            initialValue: s.step.toString(),
            onChanged: (value) => s.step = double.parse(value)),
      ),
      SwitchListTile(title: const Text("Is Angle:"),
          value: s.angle,
          onChanged: (bool value) {
            setState(() {
              s.angle = value;
            });
          }),
      SwitchListTile(title: const Text("Smoothing:"),
          value: s.smoothing,
          onChanged: (bool value) {
            setState(() {
              s.smoothing = value;
            });
          }),
      SwitchListTile(title: const Text("Port/Starboard:"),
          value: s.portStarboard,
          onChanged: (bool value) {
            setState(() {
              s.portStarboard = value;
            });
          }),
    ]);
  }

  void _emailSettings() async {
    String settings = json.encode(_$CustomSettingsToJson(widget._settings));

    final Email email = Email(
      body: settings,
      subject: 'Boat Instrument Custom Box Settings',
      recipients: ['feedback@wheretofly.info'],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } on PlatformException catch (e) {
      if(mounted) {
        if (Platform.isIOS && e.code == 'not_available') {
          widget._config.controller.showMessage(context,
              'On iOS you must install and configure the Apple EMail App with an account.', error: true);
        }
      }
      widget._config.controller.l.e('Error Sending Email', error: e);
    } on MissingPluginException {
      await Share.share(settings, subject: 'Boat Instrument Custom Box Settings');
    } catch (e) {
      widget._config.controller.l.e('Error Sending Email', error: e);
    }
  }
}

@JsonSerializable()
class _DebugSettings {
  String path;

  _DebugSettings({
    this.path = 'path'
  });
}

class DebugBox extends BoxWidget {
  late final _DebugSettings _settings;

  DebugBox(super.config, {super.key}) {
    _settings = _$DebugSettingsFromJson(config.settings);
  }

  static String sid = 'custom-debug';
  @override
  String get id => sid;

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _DebugSettingsWidget(_settings);
  }

  @override
  createState() => _DebugBoxState();
}

class _DebugBoxState extends State<DebugBox> {
  bool _pause = true;
  String? _data;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(onUpdate: _onUpdate, paths: {widget._settings.path});
  }

  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      _data = null;
    }

    return Padding(padding: const EdgeInsets.all(5), child:
      Column(children: [
        Row(children: [
          IconButton(onPressed: _togglePause, icon: Icon(_pause ? Icons.play_arrow:Icons.pause)),
          IconButton(onPressed: _clear, icon: const Icon(Icons.clear))
        ]),
        Text('Subscription: ${widget._settings.path}'),
        Text(_data??'NO DATA')
      ]));
  }

  void _togglePause() {
    setState(() {
      _pause = !_pause;
    });
  }

  void _clear (){
    setState(() {
      _data = null;
    });
  }

  void _onUpdate(List<Update>? updates) {
    if(_pause) {
      return;
    }

    if (updates == null) {
      _data = null;
    } else {
      if(mounted) {
          setState(() {
          _data = '${_data??''}\n${updates.toString()}';
        });
      }
    }
  }
}

class _DebugSettingsWidget extends BoxSettingsWidget {
  final _DebugSettings _settings;

  const _DebugSettingsWidget(this._settings);

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$DebugSettingsToJson(_settings);
  }

  @override
  createState() => _DebugSettingsState();
}

class _DebugSettingsState extends State<_DebugSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _DebugSettings s = widget._settings;

    return ListView(children: [
      const ListTile(
        title: Text('Wildcards are allowed')
      ),
      ListTile(
          leading: const Text("Signalk Path:"),
          title: TextFormField(
              initialValue: s.path,
              onChanged: (value) => s.path = value)
      ),
    ]);
  }
}

