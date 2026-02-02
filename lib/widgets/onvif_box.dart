import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:easy_onvif/onvif.dart';
import 'package:media_kit/media_kit.dart' as media;
import 'package:media_kit_video/media_kit_video.dart' as video;

part 'onvif_box.g.dart';

@JsonSerializable()
class _ONVIFConfig {
  String id;
  String url;
  String username;
  String password;

  _ONVIFConfig({
    this.id = '',
    this.url = '',
    this.username = '',
    this.password = ''
  });

  factory _ONVIFConfig.fromJson(Map<String, dynamic> json) =>
      _$ONVIFConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ONVIFConfigToJson(this);
}

@JsonSerializable(explicitToJson: true)
class _ONVIFSettings {
  List<_ONVIFConfig> configs;

  _ONVIFSettings({
    this.configs = const []
  }) {
    if(configs.isEmpty) configs = [];
  }

  factory _ONVIFSettings.fromJson(Map<String, dynamic> json) =>
      _$ONVIFSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ONVIFSettingsToJson(this);
}

@JsonSerializable()
class _ONVIFPerBoxSettings {
  String id;

  _ONVIFPerBoxSettings({
    this.id = ''
  });
}

class ONVIFBox extends BoxWidget {
  late final _ONVIFSettings _settings;
  late final _ONVIFPerBoxSettings _perBoxSettings;
  late final _ONVIFConfig? _onvifConfig;

  static String sid = 'onvif';
  @override
  String get id => sid;


  ONVIFBox(super.config, {super.key}) {
    _perBoxSettings = _$ONVIFPerBoxSettingsFromJson(config.settings);
    _settings = _ONVIFSettings.fromJson(config.controller.getBoxSettingsJson(id));
    _onvifConfig = _settings.configs.firstWhereOrNull ((lc) => lc.id == _perBoxSettings.id);
  }

  @override
  State<ONVIFBox> createState() => _ONVIFBoxState();

  @override
  Widget? getHelp() => const HelpPage(text: 'TODO Applications must first be defined in the **Shared Settings** before being selected in the **Per-Box Settings**.');

  @override
  bool get hasSettings => true;

  @override
  BoxSettingsWidget getSettingsWidget(Map<String, dynamic> json) {
    return _SettingsWidget(config.controller, _ONVIFSettings.fromJson(json));
  }

  @override
  Widget? getSettingsHelp() => const HelpPage(text: '''TODO At least one of **Title**, **Icon** or **Image** must be defined. The **Image** overrides the **Icon** and if the **Title** is also defined it will be used to head the Launch Box.

The **Parameters** will be split into an argument list at each space. If this does not produce the expected result, e.g. due to quoted parameters, then you should create a script to launch your application as desired and specify this as the executable.

**Note:** once defined, if an **ID** is changed then any **Launch Box** referencing it will need reconfiguring.''');

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _PerBoxSettingsWidget(_settings, _perBoxSettings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpPage(text: 'TODO The application launch configuration must first be defined in the **Shared Settings**.');
}

class _ONVIFBoxState extends State<ONVIFBox> {
  Onvif? _onvif;
  String? _profileToken;

  late final _player = media.Player();
  late final _controller = video.VideoController(_player);

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure();
    _connect();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    _ONVIFConfig? c = widget._onvifConfig;

    if(c != null) {
      try {
        _onvif = await Onvif.connect(
          host: c.url,
          username: c.username,
          password: c.password,
        );

        var profiles = await _onvif?.media.getProfiles();

        if ((profiles??[]).isNotEmpty) {
          _profileToken = profiles![0].token;
          var uri = await _onvif!.media.getStreamUri(_profileToken!);
          _player.open(media.Media(uri));
        }
      } catch (err) {
        widget.config.controller.l.e('Failed to connect to ONVIF stream ${widget._onvifConfig}', error: err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _ONVIFConfig? c = widget._onvifConfig;
    Widget body = Text('URL: ${c?.url??''}');
    if(!widget.config.editMode && c != null) body = video.Video(controller: _controller, controls: null);
    return HeadedBoxWidget(header: 'Camera:${c?.id??'Select Camera in Settings'}', body: body);
  }
}

class _SettingsWidget extends BoxSettingsWidget {
  final BoatInstrumentController _controller;
  final _ONVIFSettings _settings;

  const _SettingsWidget(this._controller, this._settings);

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$ONVIFSettingsToJson(_settings);
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
              decoration: const InputDecoration(hintText: 'url - required'),
              initialValue: config.url,
              onChanged: (value) => config.url = value),
            BiTextFormField(
              decoration: const InputDecoration(hintText: 'username'),
              initialValue: config.username,
              onChanged: (value) => config.username = value),
            BiTextFormField(
              decoration: const InputDecoration(hintText: 'password'),
              initialValue: config.password,
              onChanged: (value) => config.password = value),
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
    if(widget._settings.configs.every((h) {return h.id.isNotEmpty && h.url.isNotEmpty;})) {
      Navigator.pop(context);
    } else {
      widget._controller.showMessage(context, 'IDs and URLs cannot be blank');
    }
  }

  void _addConfig() {
    setState(() {
      widget._settings.configs.add(_ONVIFConfig());
    });
  }

  Future<void> _deleteConfig(int configNum) async {
    setState(() {
      widget._settings.configs.removeAt(configNum);
    });
  }
}

class _PerBoxSettingsWidget extends BoxSettingsWidget {
  final _ONVIFSettings _settings;
  final _ONVIFPerBoxSettings _perBoxSettings;

  const _PerBoxSettingsWidget(this._settings, this._perBoxSettings);

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$ONVIFPerBoxSettingsToJson(_perBoxSettings);
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
        leading: Text('ONVIF ID:'),
        title: DropdownMenu<String>(
          expandedInsets: EdgeInsets.zero,
          enableSearch: false,
          enableFilter: true,
          requestFocusOnTap: true,
          initialSelection: s.id,
          dropdownMenuEntries: widget._settings.configs.map((_ONVIFConfig v) {
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
