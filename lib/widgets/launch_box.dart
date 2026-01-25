import 'dart:io';

import 'package:collection/collection.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';

part 'launch_box.g.dart';

@JsonSerializable()
class _LaunchConfig {
  String id;
  String title;
  String icon;
  String image;
  String executable;
  String params;

  _LaunchConfig({
    this.id = '',
    this.title = '',
    this.icon = '',
    this.image = '',
    this.executable = '',
    this.params = '',
  });

  factory _LaunchConfig.fromJson(Map<String, dynamic> json) =>
      _$LaunchConfigFromJson(json);

  Map<String, dynamic> toJson() => _$LaunchConfigToJson(this);
}

@JsonSerializable(explicitToJson: true)
class _LaunchSettings {
  List<_LaunchConfig> configs;

  _LaunchSettings({
    this.configs = const []
  }) {
    if(configs.isEmpty) configs = [];
  }

  factory _LaunchSettings.fromJson(Map<String, dynamic> json) =>
      _$LaunchSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$LaunchSettingsToJson(this);
}

@JsonSerializable()
class _LaunchPerBoxSettings {
  String id;

  _LaunchPerBoxSettings({
    this.id = ''
  });
}

class LaunchBox extends BoxWidget {
  late final _LaunchSettings _settings;
  late final _LaunchPerBoxSettings _perBoxSettings;
  late final _LaunchConfig? _launchConfig;

  LaunchBox(super.config, {super.key})  {
    _perBoxSettings = _$LaunchPerBoxSettingsFromJson(config.settings);
    _settings = _LaunchSettings.fromJson(config.controller.getBoxSettingsJson(id));
    _launchConfig = _settings.configs.firstWhereOrNull ((lc) => lc.id == _perBoxSettings.id);
  }

  @override
  State<LaunchBox> createState() => _LaunchBoxState();

  static String sid = 'launch';
  @override
  String get id => sid;

  @override
  Widget? getHelp() => const HelpPage(text: 'Applications must first be defined in the **Shared Settings** before being selected in the **Per-Box Settings**.');

  @override
  bool get hasSettings => true;

  @override
  BoxSettingsWidget getSettingsWidget(Map<String, dynamic> json) {
    return _SettingsWidget(config.controller, _LaunchSettings.fromJson(json));
  }

  @override
  Widget? getSettingsHelp() => const HelpPage(text: '''At least one of **Title**, **Icon** or **Image** must be defined. The **Image** overrides the **Icon** and if the **Title** is also defined it will be used to head the Launch Box.

The **Parameters** will be split into an argument list at each space. If this does not produce the expected result, e.g. due to quoted parameters, then you should create a script to launch your application as desired and specify this as the executable.

**Note:** once defined, if an **ID** is changed then any **Launch Box** referencing it will need reconfiguring.''');

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _PerBoxSettingsWidget(_settings, _perBoxSettings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpPage(text: 'The application launch configuration must first be defined in the **Shared Settings**.');
}

class _LaunchBoxState extends HeadedTextBoxState<LaunchBox> {

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure();
  }

  @override
  Widget build(BuildContext context) {
    _LaunchConfig? lc = widget._launchConfig;

    if(lc == null) {
      return MaxTextWidget('Define and select an\nApp in the settings');
    } else {
      Widget label;
      if (lc.image.isNotEmpty) {
        label = Image.file(File(lc.image));
      } else if(lc.icon.isNotEmpty) {
        label = MaxTextWidget(String.fromCharCode(awesomeFontData[lc.icon]??0), style: TextStyle(fontFamily: 'Awesome'));
      } else {
        label = MaxTextWidget(lc.title);
      }
      var button = TextButton(onPressed: _launch, child: label);
      if(lc.title.isNotEmpty && (lc.image.isNotEmpty || lc.icon.isNotEmpty)) {
        return HeadedBoxWidget(header: lc.title, body: button);
      } else {
        return Padding(padding: EdgeInsetsGeometry.all(pad), child: button);
      }
    }
  }

  void _launch() async {
    if(widget.config.editMode) return;

    _LaunchConfig lc = widget._launchConfig!;
    CircularLogger l = widget.config.controller.l;

    var exec = '"${lc.executable} ${lc.params}"';
    l.i('Launching $exec');

    try {
      var r = await Process.run(lc.executable, lc.params.isEmpty?[]:lc.params.split(' '));

      if(r.exitCode == 0) {
        l.i('$exec exited successfully');
      } else {
        l.e('$exec, exit code ${r.exitCode} output "${r.stdout}" error "${r.stderr}"');
      }
    } catch (e) {
      l.e('Exception trying to run $exec', error: e);
    }
  }  
}

class _SettingsWidget extends BoxSettingsWidget {
  final BoatInstrumentController _controller;
  final _LaunchSettings _settings;

  const _SettingsWidget(this._controller, this._settings);

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$LaunchSettingsToJson(_settings);
  }

  @override
  createState() => _SettingsState();
}

class _SettingsState extends State<_SettingsWidget> {

  @override
  Widget build(BuildContext context) {
    var s = widget._settings;

    List<Widget> configList = [];
    for(int c=0; c<s.configs.length; ++c) {
      var config = s.configs[c];
      configList.add(Divider(thickness: 3, color: Theme.of(context).colorScheme.secondary));
      configList.add(ListTile(key: UniqueKey(),
          title: Column(children: [
            BiTextFormField(
              decoration: const InputDecoration(hintText: 'id - required'),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(idChars))],
              initialValue: config.id,
              onChanged: (value) => config.id = value),
            BiTextFormField(
              decoration: const InputDecoration(hintText: 'title - required if no icon or image'),
              initialValue: config.title,
              onChanged: (value) => config.title = value),
            ListTile(leading: Text('Icon:'), title: AwesomeFontDropdownMenu(config.icon, (icon) {config.icon = icon;})),
            BiTextFormField(
              decoration: const InputDecoration(hintText: '/path/to/image.[png|jpg] - required if no title or icon'),
              initialValue: config.image,
              onChanged: (value) => config.image = value),
            BiTextFormField(
              decoration: const InputDecoration(hintText: '/path/to/executable - required'),
              initialValue: config.executable,
              onChanged: (value) => config.executable = value),
            BiTextFormField(
              decoration: const InputDecoration(hintText: 'parameters'),
              initialValue: config.params,
              onChanged: (value) => config.params = value),
          ]),
          trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () {_deleteConfig(c);})
      ));
    }

    return PopScope(canPop: false, onPopInvokedWithResult: (didPop, result) {if(didPop) return; _checkConfigs();}, child: Column(children: [
      Row(children: [IconButton(onPressed: _addConfig, icon: Icon(Icons.add))]),
      Expanded(child: ListView(children: configList))
    ]));
  }

  void _checkConfigs () {
    if(widget._settings.configs.every((h) {return h.id.isNotEmpty && h.executable.isNotEmpty &&
       (h.title.isNotEmpty || h.icon.isNotEmpty || h.image.isNotEmpty);})) {
      Navigator.pop(context);
    } else {
      widget._controller.showMessage(context, 'IDs, Executables and Title or Image cannot be blank');
    }
  }

  void _addConfig() {
    setState(() {
      widget._settings.configs.add(_LaunchConfig());
    });
  }

  Future<void> _deleteConfig(int configNum) async {
    setState(() {
      widget._settings.configs.removeAt(configNum);
    });
  }
}

class _PerBoxSettingsWidget extends BoxSettingsWidget {
  final _LaunchSettings _settings;
  final _LaunchPerBoxSettings _perBoxSettings;

  const _PerBoxSettingsWidget(this._settings, this._perBoxSettings);

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$LaunchPerBoxSettingsToJson(_perBoxSettings);
  }

  @override
  createState() => _PerBoxSettingsState();
}

class _PerBoxSettingsState extends State<_PerBoxSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    var s = widget._perBoxSettings;

    return ListView(children: [
      ListTile(
        leading: Text('Launch ID:'),
        title: DropdownMenu<String>(
          expandedInsets: EdgeInsets.zero,
          enableSearch: false,
          enableFilter: true,
          requestFocusOnTap: true,
          initialSelection: s.id,
          dropdownMenuEntries: widget._settings.configs.map((_LaunchConfig v) {
            return DropdownMenuEntry<String>(
              style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.grey)),
              value: v.id,
              label: v.id);}).toList(),
          onSelected: (value) {
            s.id = value??'';
          },
        )
      ),
    ]);
  }
}
