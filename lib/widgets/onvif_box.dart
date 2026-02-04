import 'package:collection/collection.dart';
import 'package:easy_onvif/shared.dart';
import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:easy_onvif/onvif.dart';
import 'package:media_kit/media_kit.dart' as media;
import 'package:media_kit_video/media_kit_video.dart' as video;

part 'onvif_box.g.dart';

@JsonSerializable()
class ONVIFConfig {
  String id;
  String url;
  String username;
  String password;

  ONVIFConfig({
    this.id = '',
    this.url = '',
    this.username = '',
    this.password = ''
  });

  factory ONVIFConfig.fromJson(Map<String, dynamic> json) =>
      _$ONVIFConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ONVIFConfigToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ONVIFSettings {
  List<ONVIFConfig> configs;

  ONVIFSettings({
    this.configs = const []
  }) {
    if(configs.isEmpty) configs = [];
  }

  factory ONVIFSettings.fromJson(Map<String, dynamic> json) =>
      _$ONVIFSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ONVIFSettingsToJson(this);
}

@JsonSerializable()
class ONVIFPerBoxSettings {
  String id;
  bool showTitle;
  bool showControls;
  bool showHomeButton;

  ONVIFPerBoxSettings({
    this.id = '',
    this.showTitle = true,
    this.showControls = true,
    this.showHomeButton = true
  });
}

abstract class ONVIFBox extends BoxWidget {
  late final ONVIFSettings _settings;
  late final ONVIFPerBoxSettings _perBoxSettings;
  late final ONVIFConfig? _onvifConfig;

  static String sid = 'onvif';
  @override
  String get id => sid;

  ONVIFBox(super.config, {super.key}) {
    _perBoxSettings = _$ONVIFPerBoxSettingsFromJson(config.settings);
    _settings = ONVIFSettings.fromJson(config.controller.getBoxSettingsJson(sid));
    _onvifConfig = _settings.configs.firstWhereOrNull ((lc) => lc.id == _perBoxSettings.id);
  }

  @override
  Widget? getHelp() => const HelpPage(text: '''Cameras must first be defined in the **Shared Settings** before being selected in the **Per-Box Settings**.

**Note:** only **ONVIF** cameras are supported.''');

  @override
  bool get hasSettings => true;

  @override
  BoxSettingsWidget getSettingsWidget(Map<String, dynamic> json) {
    return _SettingsWidget(config.controller, ONVIFSettings.fromJson(json));
  }

  @override
  Widget? getSettingsHelp() => const HelpPage(text: '**Note:** once defined, if an **ID** is changed then any referencing Box will need reconfiguring.');

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _PerBoxSettingsWidget(_settings, _perBoxSettings, this is ONVIFDisplayBox);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpPage(text: 'The Camera must first be defined in the **Shared Settings**.');
}

abstract class _ONVIFBoxState<T extends ONVIFBox> extends State<T> {
  Onvif? _onvif;
  String? _profileToken;

  String get _header => 'Camera:${widget._onvifConfig?.id??'Select Camera in Settings'}';

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure();
    _connect();
  }

  Future<void> _connect() async {
    ONVIFConfig? c = widget._onvifConfig;

    if(c != null) {
      try {
        _onvif = await Onvif.connect(
          host: c.url,
          username: c.username,
          password: c.password,
        );

        var profiles = await _onvif?.media.getProfiles();

        if ((profiles??[]).isNotEmpty) {
          setState(() {
            _profileToken = profiles!.first.token;
          });
        }
      } catch (err) {
        widget.config.controller.l.e('Failed to connect to ONVIF camera ${widget._onvifConfig?.url}', error: err);
      }
    }
  }

  Widget _ptzControls() {
    if(_profileToken == null) {
      return Text('Connecting...');
    } else {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _controlButton(Icons.keyboard_arrow_left, -1, 0, 0),
      ]),
      Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _controlButton(Icons.keyboard_arrow_up, 0, 1, 0),
        widget._perBoxSettings.showHomeButton?_controlButton(Icons.home, 0, 0, 0, home: true):Icon(null, size: buttonIconSize),
        _controlButton(Icons.keyboard_arrow_down, 0, -1, 0),
      ]),
      Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _controlButton(Icons.add, 0, 0, 1),
        _controlButton(Icons.keyboard_arrow_right, 1, 0, 0),
        _controlButton(Icons.remove, 0, 0, -1),
      ]),
    ]);
    }
  }

  Widget _controlButton(IconData icon, int pan, int tilt, int zoom, {bool home = false}) {
    var enabled = _profileToken != null;

    return GestureDetector(
      onTapDown: enabled?(_) => home?_gotoHome():_startPTZ(pan, tilt, zoom):null,
      onTapCancel: (enabled&&!home)?_stopPTZ:null,
      child: IconButton(
        iconSize: buttonIconSize,
        onPressed: enabled?() {}:null,
        icon: Icon(icon),
      )
    );
  }

  void _gotoHome() {
    if(widget.config.editMode) return;

    _onvif?.ptz.gotoHomePosition(_profileToken!);
  }

  void _startPTZ(int pan, int tilt, int zoom) {
    if(widget.config.editMode) return;

    _onvif?.ptz.continuousMove(_profileToken!, velocity: PtzSpeed(
      panTilt: Vector2D(
        x: pan * 0.5,   // pan speed
        y: tilt * 0.5,  // tilt speed
      ),
      zoom: Vector1D(x: zoom * 0.5)
    ));
  }

  void _stopPTZ() {
    if(widget.config.editMode) return;

    _onvif?.ptz.stop(_profileToken!);
  }
}

class ONVIFDisplayBox extends ONVIFBox {
  static String sid = 'onvif-display';

  ONVIFDisplayBox(super.config, {super.key});

  @override
  State<ONVIFDisplayBox> createState() => _ONVIFDisplayBoxState();
}

class _ONVIFDisplayBoxState extends _ONVIFBoxState<ONVIFDisplayBox> {
  late final _player = media.Player();
  late final _controller = video.VideoController(_player);

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _connectVideoStream() async {
    var uri = await _onvif!.media.getStreamUri(_profileToken!);
    _player.open(media.Media(uri));
  }

  @override
  Widget build(BuildContext context) {
    ONVIFConfig? c = widget._onvifConfig;

    bool connected = _profileToken != null;
    if(connected) _connectVideoStream();

    Widget body = Text('$_header\nCamera:URL: ${c?.url??''}');

    if(!widget.config.editMode && c != null) {
      body = Stack(alignment: AlignmentGeometry.center, children: [
        video.Video(controller: _controller, controls: null),
        if(widget._perBoxSettings.showControls) Opacity(opacity: connected?0.5:1.0, child: _ptzControls())
    ]);
    }
    return widget._perBoxSettings.showTitle?
      HeadedBoxWidget(header: _header, body: body):
      body;
  }
}

class ONVIFControlBox extends ONVIFBox {
  static String sid = 'onvif-control';

  ONVIFControlBox(super.config, {super.key});

  @override
  State<ONVIFControlBox> createState() => _ONVIFControlBoxState();
}

class _ONVIFControlBoxState extends _ONVIFBoxState<ONVIFControlBox> {
  @override
  Widget build(BuildContext context) {
    return widget._perBoxSettings.showTitle || widget.config.editMode?
      HeadedBoxWidget(
        header: _header,
        body: _ptzControls()
      ):
      Center(child: _ptzControls());
  }
}

class _SettingsWidget extends BoxSettingsWidget {
  final BoatInstrumentController _controller;
  final ONVIFSettings _settings;

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
      widget._settings.configs.add(ONVIFConfig());
    });
  }

  Future<void> _deleteConfig(int configNum) async {
    setState(() {
      widget._settings.configs.removeAt(configNum);
    });
  }
}

class _PerBoxSettingsWidget extends BoxSettingsWidget {
  final ONVIFSettings _settings;
  final ONVIFPerBoxSettings _perBoxSettings;
  final bool _display;

  const _PerBoxSettingsWidget(this._settings, this._perBoxSettings, this._display);

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
          dropdownMenuEntries: widget._settings.configs.map((ONVIFConfig v) {
            return DropdownMenuEntry<String>(
              style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(Colors.grey)),
              value: v.id,
              label: v.id);}).toList(),
          onSelected: (value) {
            s.id = value??'';
          },
        )
      ),
      SwitchListTile(title: const Text("Show Title:"),
        value: s.showTitle,
        onChanged: (bool value) {
          setState(() {
            s.showTitle = value;
          });
        }
      ),
      if(widget._display) SwitchListTile(title: const Text("Show Controls:"),
        value: s.showControls,
        onChanged: (bool value) {
          setState(() {
            s.showControls = value;
          });
        }
      ),
      if(s.showControls) SwitchListTile(title: const Text("Show Home Button:"),
        value: s.showHomeButton,
        onChanged: (bool value) {
          setState(() {
            s.showHomeButton = value;
          });
        }
      ),
    ]);
  }
}
