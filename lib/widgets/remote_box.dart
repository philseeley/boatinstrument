import 'dart:async';

import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';

part 'remote_box.g.dart';

@JsonSerializable()
class _RemoteControlSettings {
  bool isGroup;
  String id;
  bool enableLock;
  int lockSeconds;

  _RemoteControlSettings({
    this.isGroup = false,
    this.id = '',
    this.enableLock = false,
    this.lockSeconds = 5
  });
}

class RemoteControlBox extends BoxWidget {
  late final _RemoteControlSettings _settings;

  static const String sid = 'remote-control';
  @override
  String get id => sid;

  RemoteControlBox(super.config, {super.key}) {
    _settings = _$RemoteControlSettingsFromJson(config.settings);
  }

  @override
  Widget? getHelp() => const HelpPage(url: 'doc:remote-control.md');

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _RemoteControlSettingsWidget(config.controller, _settings);
  }

  @override
  State<RemoteControlBox> createState() => _RemoteControlBoxState();
}

class _RemoteControlBoxState extends State<RemoteControlBox> {
  bool _locked = true;
  Timer? _lockTimer;
  List<String> _pages = [];

  @override
  void initState() {
    super.initState();

    String type = widget._settings.isGroup?'groups':'devices';
    Set<String> paths = {};

    if(widget._settings.id.isNotEmpty) paths.add('$bi.$type.${widget._settings.id}.pages');

    widget.config.controller.configure(paths: paths, dataType: SignalKDataType.static, onUpdate: _processUpdates);
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    super.dispose();
  }
  
  void _sendAction(String action, Map<String, dynamic> params) {

    if(widget.config.editMode) {
      return;
    }

    if(widget._settings.enableLock) {
      _unlock();
    }

    params.addAll({'id': action});
    widget.config.controller.sendUpdate('$bi.${widget._settings.isGroup?'groups':'devices'}.${widget._settings.id}.action', params);
    widget.config.controller.sendUpdate('$bi.${widget._settings.isGroup?'groups':'devices'}.${widget._settings.id}.action', null);
  }

  Future<void> _unlock() async {
    if(_locked) {
      setState(() {
        _locked = false;
      });
    }

    _lockTimer?.cancel();

    _lockTimer =  Timer(Duration(seconds: widget._settings.lockSeconds), () {
      if(mounted) {
        setState(() {
          _locked = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _RemoteControlSettings s = widget._settings;
    bool disabled = s.enableLock && _locked;

    Color fg = Theme.of(context).colorScheme.onSurface;
    Color bg = widget.config.controller.val2PSColor(context, 1, none: Colors.grey);

    return Padding(padding: EdgeInsetsGeometry.all(5), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      HeaderText('${s.isGroup?'GRP':'DEV'}:${s.id}'),
      Stack(alignment: Alignment.center, children: [
        Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(height: 50, child: ListView.separated(
            padding: EdgeInsets.all(5),
            itemCount: _pages.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, i) {return ElevatedButton(
              onPressed: disabled ? null : (){_sendAction('gotoPage', {'page': _pages[i]});},
              style: ElevatedButton.styleFrom(foregroundColor: fg, backgroundColor: bg),
              child: Text(_pages[i]));}, separatorBuilder: (context, i){return SizedBox(width: 10);})),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(iconSize: 48, onPressed: disabled ? null : () {_sendAction('firstPage', {});}, icon: const Icon(Icons.first_page)),
            IconButton(iconSize: 48, onPressed: disabled ? null : () {_sendAction('decPage', {});}, icon: const Icon(Icons.keyboard_arrow_left)),
            IconButton(iconSize: 48, onPressed: disabled ? null : () {_sendAction('incPage', {});}, icon: const Icon(Icons.keyboard_arrow_right)),
            IconButton(iconSize: 48, onPressed: disabled ? null : () {_sendAction('lastPage', {});}, icon: const Icon(Icons.last_page)),
          ]),
        ]),
        if(disabled) Center(child: Padding(padding: const EdgeInsets.only(left: 20, right: 20),child: SlideAction(
          text: "Unlock",
          outerColor: Colors.grey,
          onSubmit: () { return _unlock();},
        )))
      ]),
    ]));
  }

  void _processUpdates(List<Update> updates) {
    for (Update u in updates) {
      try {
        if(u.path.endsWith('.pages')) {
          _pages = (u.value as List<dynamic>).cast<String>();
        }
      } catch (e) {
        widget.config.controller.l.e("Error converting $u", error: e);
      }
    }

    if(mounted) {
      setState(() {});
    }
  }

  void x(){}
}

class _RemoteControlSettingsWidget extends BoxSettingsWidget {
  final BoatInstrumentController _controller;
  final _RemoteControlSettings _settings;

  const _RemoteControlSettingsWidget(this._controller, this._settings);

  @override
  createState() => _RemoteControlSettingsState();

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$RemoteControlSettingsToJson(_settings);
  }
}

class _RemoteControlSettingsState extends State<_RemoteControlSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _RemoteControlSettings s = widget._settings;

    List<Widget> list = [
      SwitchListTile(title: const Text("Control Group:"),
        value: s.isGroup,
        onChanged: (bool value) {
          setState(() {
            s.isGroup = value;
          });
        }),
      ListTile(
        leading: Text("${s.isGroup?'Group':'Device'} ID:"),
        title: SignalkPathDropdownMenu(
            widget. _controller,
            s.id,
            '$bi.${s.isGroup?'groups':'devices'}',
            (value) => s.id = value)
      ),
      SwitchListTile(title: const Text("Enable Control Lock:"),
        value: s.enableLock,
        onChanged: (bool value) {
          setState(() {
            s.enableLock = value;
          });
        }),
      ListTile(
        leading: const Text("Lock Timeout:"),
        title: Slider(
          min: 2.0,
          max: 120.0,
          divisions: 58,
          value: s.lockSeconds.toDouble(),
          label: "${s.lockSeconds.toInt()}s",
          onChanged: (double value) {
            setState(() {
              s.lockSeconds = value.toInt();
            });
          }),
      ),
    ];

    return ListView(children: list);
  }
}
