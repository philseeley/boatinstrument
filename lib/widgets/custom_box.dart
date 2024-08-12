import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../boatinstrument_controller.dart';

part 'custom_box.g.dart';

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
    widget.config.controller.configure(_onUpdate, [widget._settings.path]);
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

