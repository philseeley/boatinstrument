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
  List<String> manualPages;
  bool controlPages;
  bool controlRotatePages;
  bool controlBrightness;
  bool enableLock;
  int lockSeconds;

  _RemoteControlSettings({
    this.isGroup = false,
    this.id = '',
    this.manualPages = const [],
    this.controlPages = true,
    this.controlRotatePages = true,
    this.controlBrightness = true,
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

class _RemoteControlBoxState extends HeadedBoxState<RemoteControlBox> {
  bool _locked = true;
  Timer? _lockTimer;
  List<String> _pages = [];

  @override
  void initState() {
    super.initState();

    String type = widget._settings.isGroup?'groups':'devices';
    header = '${widget._settings.isGroup?'GRP':'DEV'}:${widget._settings.id}';

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

    // We need to set the action to null, otherwise on reconnect the
    // receiving app could get the old value and perform the action again.
    // All apps should get the action and then the null, which will be ignored.
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

    if(widget.config.editMode) {
      _pages = ['page 1', 'page 2', 'page 3'];
    }

    List<IconButton> brightnessButtons = [];
    if(s.controlBrightness) {
      brightnessButtons.add(IconButton(onPressed: disabled ? null : () {_sendAction('nightMode', {'on': true});}, icon: const Icon(Icons.mode_night)));
      brightnessButtons.add(IconButton(onPressed: disabled ? null : () {_sendAction('nightMode', {'on': false});}, icon: const Icon(Icons.light_mode)));
      for(int i in BoatInstrumentController.brightnessIcons.keys) {
        brightnessButtons.add(IconButton(
          onPressed: disabled ? null : () {_sendAction('setBrightness', {'level': i});},
          icon: Icon(BoatInstrumentController.brightnessIcons[i])));
      }
    }

    body = Stack(alignment: Alignment.center, children: [
      Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        if(s.controlPages && (_pages.isNotEmpty || s.manualPages.isNotEmpty)) SizedBox(height: 50, child: ListView.separated(
          padding: EdgeInsets.all(5),
          itemCount: s.manualPages.isNotEmpty?s.manualPages.length:_pages.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, i) {return ElevatedButton(
            onPressed: disabled ? null : (){_sendAction('gotoPage', {'page': s.manualPages.isNotEmpty?s.manualPages[i]:_pages[i]});},
            style: ElevatedButton.styleFrom(foregroundColor: fg, backgroundColor: bg),
            child: Text(s.manualPages.isNotEmpty?s.manualPages[i]:_pages[i]));}, separatorBuilder: (context, i){return SizedBox(width: 10);})),
        if(s.controlPages && _pages.isNotEmpty && s.manualPages.isEmpty) Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(iconSize: 48, onPressed: disabled ? null : () {_sendAction('firstPage', {});}, icon: const Icon(Icons.first_page)),
          IconButton(iconSize: 48, onPressed: disabled ? null : () {_sendAction('decPage', {});}, icon: const Icon(Icons.keyboard_arrow_left)),
          IconButton(iconSize: 48, onPressed: disabled ? null : () {_sendAction('incPage', {});}, icon: const Icon(Icons.keyboard_arrow_right)),
          IconButton(iconSize: 48, onPressed: disabled ? null : () {_sendAction('lastPage', {});}, icon: const Icon(Icons.last_page)),
        ]),
        if(s.controlRotatePages) Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          IconButton(iconSize: 48, onPressed: disabled ? null : () {_sendAction('rotatePagesOn', {});}, icon: const Icon(Icons.sync_alt)),
          IconButton(iconSize: 48, onPressed: disabled ? null : () {_sendAction('rotatePagesOff', {});}, icon: const Stack(children: [Icon(Icons.sync_alt), Icon(Icons.close)])),
        ]),
        if(s.controlBrightness) Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: brightnessButtons),
      ]),
      if(disabled) Center(child: Padding(padding: const EdgeInsets.only(left: 20, right: 20),child: SlideAction(
        text: "Unlock",
        outerColor: Colors.grey,
        onSubmit: () { return _unlock();},
      )))
    ]);

    return super.build(context);
  }

  void _processUpdates(List<Update> updates) {
    if(updates[0].value == null) {
      _pages = [];
    } else {
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
  }
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

    return ListView(children: [
      SwitchListTile(title: const Text("Control Group:"),
        value: s.isGroup,
        onChanged: (bool value) {
          setState(() {
            s.isGroup = value;
          });
        }),
      ListTile(
        leading: Text("${s.isGroup?'Group':'Device'} ID:"),
        title: SignalkPathDropdownMenu(key: UniqueKey(),
            widget. _controller,
            s.id,
            '$bi.${s.isGroup?'groups':'devices'}',
            (value) => s.id = value)
      ),
      ListTile(
        leading: const Text("Manual Pages:"),
        title: Text(s.manualPages.isEmpty?'':s.manualPages.reduce((one, two) {return '$one, $two';})),
        trailing: IconButton(onPressed: _editManualPages, icon: Icon(Icons.edit)),
      ),
      SwitchListTile(title: const Text("Control Pages:"),
        value: s.controlPages,
        onChanged: (bool value) {
          setState(() {
            s.controlPages = value;
          });
        }),
      SwitchListTile(title: const Text("Control Rotate Pages:"),
        value: s.controlRotatePages,
        onChanged: (bool value) {
          setState(() {
            s.controlRotatePages = value;
          });
        }),
      SwitchListTile(title: const Text("Control Brightness:"),
        value: s.controlBrightness,
        onChanged: (bool value) {
          setState(() {
            s.controlBrightness = value;
          });
        }),
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
    ]);
  }

  void _editManualPages () async {
    List<String> pages = widget._settings.manualPages;
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return _EditManualPages(pages);
    }));

    setState(() {
      // We remove any empty and duplicate groups.
      pages.removeWhere((g) => g.isEmpty);
      widget._settings.manualPages = pages.toSet().toList();
    });
  }
}

class _EditManualPages extends EditListWidget {
  const _EditManualPages(List<String> list) : super(list, 'Manual Pages', 'Page Name');
}
