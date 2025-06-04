import 'dart:convert';
import 'dart:io';
import 'package:boatinstrument/path_text_formatter.dart';
import 'package:boatinstrument/widgets/double_value_box.dart';
import 'package:boatinstrument/widgets/gauge_box.dart';
import 'package:color_hex/color_hex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
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
  double? minValue;
  double? maxValue;
  bool angle;
  bool smoothing;
  String units;
  double multiplier;
  double step;
  bool portStarboard;
  bool dataTimeout;
  DoubleValueToDisplay valueToDisplay;
  @JsonKey(
      name: 'color',
      fromJson: _string2Color,
      toJson: _color2String)
  Color color;

  _CustomSettings({
    this.title = 'title',
    this.path = 'path',
    this.precision = 1,
    this.minLen = 2,
    this.minValue,
    this.maxValue,
    this.angle = false,
    this.smoothing = true,
    this.units = 'units',
    this.multiplier = 1,
    this.step = 1,
    this.portStarboard = false,
    this.dataTimeout = true,
    this.valueToDisplay = DoubleValueToDisplay.value,
    this.color = Colors.blue
  });

  static Color _string2Color(String inColor) =>
      inColor.convertToColor;

  static String _color2String(Color color) =>
      color.convertToHex.hex??'#2196f3';// Colors.blue
}

class CustomDoubleValueBox extends DoubleValueBox {
  final _CustomSettings _settings;
  final String _unitsString;
  final double _multiplier;

  const CustomDoubleValueBox._init(this._settings, this._unitsString, this._multiplier, super.config, super.title, super.path, {super.precision, super.minLen, super.minValue, super.maxValue, super.angle, super.smoothing, super.portStarboard, super.dataTimeout, super.valueToDisplay, super.key});

  factory CustomDoubleValueBox.fromSettings(config, {key}) {
    _CustomSettings s = _$CustomSettingsFromJson(config.settings);
    return CustomDoubleValueBox._init(s, s.units, s.multiplier, config, s.title, s.path, precision: s.precision, minLen: s.minLen, minValue: s.minValue, maxValue: s.maxValue, angle: s.angle, smoothing: s.smoothing, portStarboard: s.portStarboard, dataTimeout: s.dataTimeout, valueToDisplay: s.valueToDisplay, key: key);
  }

  static String sid = 'custom-double-value';
  @override
  String get id => sid;
  String get fullID => '$id-$title-${units(0)}-${valueToDisplay.displayName}';

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _SettingsWidget(config, this, _settings);
  }

  @override
  double convert(double value) {
    return value * _multiplier;
  }

  @override
  String units(double value) {
    return _unitsString;
  }

  @override
  double get extremeValue => DoubleValueBox.extremeValues.putIfAbsent(fullID, () => valueToDisplay == DoubleValueToDisplay.minimumValue?double.infinity:0);
  @override
  set extremeValue(double value) => DoubleValueBox.extremeValues[fullID] = value;
}

class CustomDoubleValueSemiGaugeBox extends DoubleValueSemiGaugeBox {
  final _CustomSettings _settings;
  final String _unitsString;
  final double _multiplier;

  const CustomDoubleValueSemiGaugeBox._init(this._settings, this._unitsString, this._multiplier, super.config, super.title, super.orientation, super.path, {super.minValue, super.maxValue, super.step, super.angle, super.smoothing, super.dataTimeout, super.key});

  factory CustomDoubleValueSemiGaugeBox.fromSettings(config, {key}) {
    _CustomSettings s = _$CustomSettingsFromJson(config.settings);
    return CustomDoubleValueSemiGaugeBox._init(s, s.units, s.multiplier, config, s.title, GaugeOrientation.up, s.path, minValue: s.minValue, maxValue: s.maxValue, step: s.step, angle: s.angle, smoothing: s.smoothing, dataTimeout: s.dataTimeout, key: key);
  }

  static String sid = 'custom-gauge-semi';
  @override
  String get id => sid;

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _SettingsWidget(config, this, _settings);
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

  const CustomDoubleValueCircularGaugeBox._init(this._settings, this._unitsString, this._multiplier, super.config, super.title, super.path, {super.minValue, super.maxValue, required super.step, super.smoothing, super.dataTimeout, super.key});

  factory CustomDoubleValueCircularGaugeBox.fromSettings(config, {key}) {
    _CustomSettings s = _$CustomSettingsFromJson(config.settings);
    return CustomDoubleValueCircularGaugeBox._init(s, s.units, s.multiplier, config, s.title, s.path, minValue: s.minValue, maxValue: s.maxValue, step: s.step, smoothing: s.smoothing, dataTimeout: s.dataTimeout, key: key);
  }

  static String sid = 'custom-gauge-circular';
  @override
  String get id => sid;

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _SettingsWidget(config, this, _settings);
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

  const CustomDoubleValueBarGaugeBox._init(this._settings, this._unitsString, this._multiplier, super.config, super.title, super.path, {super.minValue, super.maxValue, required super.step, super.smoothing, super.dataTimeout, super.barColor, super.key});

  factory CustomDoubleValueBarGaugeBox.fromSettings(config, {key}) {
    _CustomSettings s = _$CustomSettingsFromJson(config.settings);
    return CustomDoubleValueBarGaugeBox._init(s, s.units, s.multiplier, config, s.title, s.path, minValue: s.minValue, maxValue: s.maxValue, step: s.step, smoothing: s.smoothing, dataTimeout: s.dataTimeout, barColor: s.color, key: key);
  }

  static String sid = 'custom-gauge-bar';
  @override
  String get id => sid;

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _SettingsWidget(config, this, _settings);
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
  final DoubleValueBox _gaugeBox;
  final _CustomSettings _settings;

  const _SettingsWidget(this._config, this._gaugeBox, this._settings);

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
    DoubleValueBox b = widget._gaugeBox;
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
            onChanged: (value) => s.multiplier = double.tryParse(value)??1),
      ),
      if({CustomDoubleValueBox}.contains(b.runtimeType))
        ListTile(
          leading: const Text("Precision:"),
          title: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              initialValue: s.precision.toString(),
              onChanged: (value) => s.precision = int.tryParse(value)??0),
        ),
      if({CustomDoubleValueBox}.contains(b.runtimeType))
        ListTile(
          leading: const Text("Min Length:"),
          title: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              initialValue: s.minLen.toString(),
              onChanged: (value) => s.minLen = int.tryParse(value)??0),
        ),
      ListTile(
        leading: const Text("Min Value:"),
        title: TextFormField(
            initialValue: (s.minValue??'').toString(),
            onChanged: (value) => s.minValue = double.tryParse(value)),
      ),
      ListTile(
        leading: const Text("Max Value:"),
        title: TextFormField(
            initialValue: (s.maxValue??'').toString(),
            onChanged: (value) => s.maxValue = double.tryParse(value)),
      ),
      if({CustomDoubleValueSemiGaugeBox, CustomDoubleValueCircularGaugeBox, CustomDoubleValueBarGaugeBox}.contains(b.runtimeType))
        ListTile(
          leading: const Text("Step:"),
          title: TextFormField(
              initialValue: s.step.toString(),
              onChanged: (value) => s.step = double.tryParse(value)??1),
        ),
      if({CustomDoubleValueBox}.contains(b.runtimeType))
        ListTile(
            leading: const Text("Value to Display:"),
            title: EnumDropdownMenu(DoubleValueToDisplay.values, s.valueToDisplay, (v) {s.valueToDisplay = v!;})
        ),
      if({CustomDoubleValueBox, CustomDoubleValueSemiGaugeBox}.contains(b.runtimeType))
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
      if({CustomDoubleValueBox}.contains(b.runtimeType))
        SwitchListTile(title: const Text("Port/Starboard:"),
            value: s.portStarboard,
            onChanged: (bool value) {
              setState(() {
                s.portStarboard = value;
              });
            }),
      SwitchListTile(title: const Text("Data Timeout:"),
          value: s.dataTimeout,
          onChanged: (bool value) {
            setState(() {
              s.dataTimeout = value;
            });
          }),
      if({CustomDoubleValueBarGaugeBox}.contains(b.runtimeType))
        ListTile(
            leading: const Text("Colour:"),
            title: MaterialColorPicker(circleSize: 30, spacing: 5, allowShades: false, selectedColor: s.color, onMainColorChange: (ColorSwatch<dynamic>? color) => s.color = color??Colors.blue)
        ),
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
      await SharePlus.instance.share(ShareParams(text: settings, subject: 'Boat Instrument Custom Box Settings'));
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

@JsonSerializable()
class _CustomTextBoxSettings {
  String template;

  _CustomTextBoxSettings({
    this.template = ''
  });
}

class CustomTextBox extends BoxWidget {
  late final _CustomTextBoxSettings _settings;

  static const sid = 'custom-text';
  @override
  String get id => sid;

  CustomTextBox(super.config, {super.key})  {
    _settings = _$CustomTextBoxSettingsFromJson(config.settings);
  }

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _CustomTextBoxSettingsWidget(config.controller, _settings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('''Add SignalK Path data by selecting the Path and pressing "+" to append to the template.

Note: as this Box is intended to display static data like vessel Name or MMSI, the data items are only retrieved once from SignalK.''');

  @override
  State<CustomTextBox> createState() => _CustomTextBoxState();
}

class _CustomTextBoxState extends State<CustomTextBox> {
  late PathTextFormatter _formatter;
  final Map<String, String> _pathData = {};

  @override
  void initState() {
    super.initState();
    _formatter = PathTextFormatter(widget.config.controller, widget._settings.template);
    widget.config.controller.configure(onStaticUpdate: _onUpdate, staticPaths: _formatter.paths);
  }

  @override
  Widget build(BuildContext context) {
    List<String> lines = _formatter.format(_pathData).split('\n');

    if(widget.config.editMode && lines.length == 1 && lines[0].isEmpty) {
      lines = ['Your text here'];
    }

    String max = '-';
    int numLines = 1;
    if(lines.isNotEmpty) {
      numLines = lines.length;
      max = lines.reduce((a, b) {return a.length > b.length ? a : b;});
    }

    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);
    double fontSize = maxFontSize(max, style,
        ((widget.config.constraints.maxHeight - style.fontSize!) / numLines),
        widget.config.constraints.maxWidth);

    return Center(child: Text(lines.join('\n'), textScaler: TextScaler.noScaling,  style: style.copyWith(fontSize: fontSize)));
  }

  void _onUpdate(List<Update>? updates) {
    if(updates != null) {
      if(mounted) {
        setState(() {
          for(Update u in updates) {
            _pathData[u.path] = u.value.toString();
          }
        });
      }
    }
  }
}

class _CustomTextBoxSettingsWidget extends BoxSettingsWidget {
  final BoatInstrumentController _controller;
  final _CustomTextBoxSettings _settings;

  const _CustomTextBoxSettingsWidget(this._controller, this._settings);

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$CustomTextBoxSettingsToJson(_settings);
  }

  @override
  createState() => _CustomTextBoxSettingsState();
}

class _CustomTextBoxSettingsState extends State<_CustomTextBoxSettingsWidget> {
  String _path = '';

  @override
  Widget build(BuildContext context) {
    _CustomTextBoxSettings s = widget._settings;

    return ListView(children: [
      ListTile(key: UniqueKey(),
          leading: const Text("Text\nTemplate:"),
          title: TextFormField(
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            minLines: 2,
            maxLines: null,
            initialValue: s.template,
            onChanged: (value) => s.template = value
          )
      ),
      ListTile(
        leading: const Text("Signalk Path:"),
        title: SignalkPathDropdownMenu(
          searchable: true,
          widget._controller,
          '',
          '',
          (value) => _path = value,
          listPaths: true),
        trailing: IconButton(onPressed: () {
          setState(() {
            s.template = '${s.template}{$_path}';
          });
        }, icon: const Icon(Icons.add)),
      ),
    ]);
  }
}
