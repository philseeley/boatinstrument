import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:json_annotation/json_annotation.dart';

part 'zone_box.g.dart';

enum AlertType implements EnumMenuEntry {
  aws('Apparent Wind Speed', 'environment.wind.speedApparent', true),
  dbs('Depth Below Surface', 'environment.depth.belowSurface', false),
  test('Test One', 'test.one', true),
  dbk('Depth Below Keel', 'environment.depth.belowKeel', false);

  @override
  String get displayName => _displayName;
  final String _displayName;
  final String path;
  final bool increasing;

  const AlertType(this._displayName, this.path, this.increasing);
}

@JsonSerializable()
class _Zone {
  double? lower;
  double? upper;
  NotificationState state;
  String message;

  _Zone({
    this.lower,
    this.upper,
    this.state = NotificationState.normal,
    this.message = ''
  });

  factory _Zone.fromJson(Map<String, dynamic> json) =>
    _$ZoneFromJson(json);

  Map<String, dynamic> toJson({double? upper}) {
    var json = _$ZoneToJson(this);
    if(upper != null) json['upper'] = upper;
    return json;
  }
}

@JsonSerializable(explicitToJson: true)
class _Meta {
  @JsonKey(includeFromJson: false, includeToJson: false)
  _Alert? alert;
  List<_Zone> zones;

  _Meta({
    this.alert,
    this.zones = const []
  }) {
    if(zones.isEmpty) zones = [];
  }

  factory _Meta.fromJson(Map<String, dynamic> json, {_Alert? alert}) {
    var m = _$MetaFromJson(json);
    m.alert = alert;
    return m;
  }

  Map<String, dynamic> toJson() => _$MetaToJson(this);
}

@JsonSerializable(explicitToJson: true)
class _Alert {
  AlertType type;
  late _Meta meta;

  _Alert({
    this.type = AlertType.aws,
    _Meta? meta
  }) {
    this.meta = meta??_Meta();
  }

  factory _Alert.fromJson(Map<String, dynamic> json) =>
      _$AlertFromJson(json);

  Map<String, dynamic> toJson() => _$AlertToJson(this);
}

@JsonSerializable(explicitToJson: true)
class _Settings {
  List<_Alert> alerts;
  bool normalAlert;
  bool alertAlert;
  bool warnAlert;
  bool alarmAlert;
  bool emergencyAlert;

  _Settings({
    this.alerts = const [],
    this.normalAlert = false,
    this.alertAlert = true,
    this.warnAlert = true,
    this.alarmAlert = true,
    this.emergencyAlert = true
  }) {
    if(alerts.isEmpty) alerts = [];
  }

  factory _Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);
}

mixin _UnitConversion {
  BoatInstrumentController get controller;

  String _units(AlertType type) {
    switch(type) {      
      case AlertType.aws:
        return controller.windSpeedUnits.unit;
      case AlertType.dbs:
        return controller.depthUnits.unit;
      case AlertType.test:
        return controller.windSpeedUnits.unit;
      case AlertType.dbk:
        return controller.depthUnits.unit;
    }
  }

  String _toDisplay(AlertType type, double value) {
    switch(type) {      
      case AlertType.aws:
        return controller.windSpeedToDisplay(value).toString();
      case AlertType.dbs:
        return controller.depthToDisplay(value).toString();
      case AlertType.test:
        return controller.windSpeedToDisplay(value).toString();
      case AlertType.dbk:
        return controller.depthToDisplay(value).toString();
    }
  }

  double _fromDisplay(AlertType type, String strValue) {
    var value = double.parse(strValue);
    switch(type) {      
      case AlertType.aws:
        return controller.windSpeedFromDisplay(value);
      case AlertType.dbs:
        return controller.depthFromDisplay(value);
      case AlertType.test:
        return controller.windSpeedFromDisplay(value);
      case AlertType.dbk:
        return controller.depthFromDisplay(value);
    }
  }
}

class ZoneSetupBox extends BoxWidget {

  const ZoneSetupBox(super.config, {super.key});

  @override
  State<ZoneSetupBox> createState() => _ZoneSetupBoxState();

  static String sid = 'zones-setup';
  @override
  String get id => sid;

  @override
  bool get hasSettings => true;

  @override
  BoxSettingsWidget getSettingsWidget(Map<String, dynamic> json) {
    return _AlertsSetupSettings(config.controller, _$SettingsFromJson(json));
  }

  @override
  Widget? getHelp() => const HelpPage(url: 'doc:zones.md');

//   @override
//   Widget? getPerBoxSettingsHelp() => const HelpPage(text: '''In **Auto** mode the Rose will switch between the "Normal" and "Close Haul" displays if the needle transitions over 60 degrees for more than the **Auto Switch Delay**.
  
// The **Switch Button** allows you to cycle through the Wind Rose types from the display. If the button is "Unlocked" the display is in "Auto" mode.''');
}

class _ZoneSetupBoxState extends HeadedBoxState<ZoneSetupBox> with _UnitConversion {
  _Settings? _settings;
  List<_Meta>? _metas;

  @override
  BoatInstrumentController get controller => widget.config.controller;

  @override
  void initState() {
    super.initState();
    _settings = _Settings.fromJson(widget.config.controller.getBoxSettingsJson(widget.id));
    widget.config.controller.configure();
    header = 'Alerts';
    if(!widget.config.editMode) actions = [IconButton(onPressed: _edit, icon: Icon(Icons.settings))];
    // _getCurrentAlerts();
  }

  @override
  Widget build(BuildContext context) {
    var editMode = widget.config.editMode;
    var alerts = _settings!.alerts;
    if(editMode && alerts.isEmpty) {
      alerts = [
        // Alarm(id: 't1', time: TimeOfDay(hour: 1, minute: 12)),
        // Alarm(id: 't1', time: TimeOfDay(hour: 1, minute: 12), delta: true)
      ];
    }
    if(_metas == null) {
      _getCurrentAlerts();
      body = Text('Retrieving data');
    } else {
      body = ListView.builder(itemCount: _metas!.length, itemBuilder: (context, i) {
        _Meta m = _metas![i];
        StringBuffer zonesStr = StringBuffer();
        bool first = true;
        for(var z in m.zones) {
          if(!first) zonesStr.writeln();
          zonesStr.write('${_toDisplay(m.alert!.type, z.lower??0)}: ${z.state.displayName}');//TODO
          first = false;
        }
        return ListTile(
          leading: Text('${m.alert!.type.displayName}:'),
          title: Text(zonesStr.toString()),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(onPressed: editMode?null:() {_setZones(m.alert!);}, icon: Icon(Icons.check_circle)),
            IconButton(onPressed: editMode?null:() {_removeZones(m.alert!);}, icon: Icon(Icons.cancel))
          ])
        );
      });
    }
    return super.build(context);
  }

  Uri _metaUri (_Alert alert) {
    Uri uri = widget.config.controller.httpApiUri;
    List<String> ps = [...uri.pathSegments]
      ..removeLast()
      ..addAll(['vessels', 'self'])
      ..addAll(alert.type.path.split('.'))
      ..add('meta');
    return uri.replace(pathSegments: ps);
  }

  Future<Map<String, dynamic>> _getMeta (Uri uri) async {
    try {
      var r = await widget.config.controller.httpGet(uri);

      return json.decode(r.body);
    } catch (e) {
      widget.config.controller.l.e('Failed to retrieve zone meta "$uri', error: e);
      rethrow;
    }
  }

  Future<void> _getCurrentAlerts() async {
    _metas = null;

    List<_Meta> metas = [];
    for(var alert in _settings!.alerts) {
      Uri uri = _metaUri(alert);

      try {
        var data = await _getMeta(uri);
        metas.add(_Meta.fromJson(data, alert: alert));
      } catch(e) {
        // var m = _Meta(zones: []);
        // m.alert = alert;
        metas.add(_Meta(alert: alert, zones: []));
        widget.config.controller.l.e('Failed to get current zone meta', error: e);
      }
    }

    if(mounted) {
      setState(() {
        _metas = metas;
      });
    }
  }

  void _setZones (_Alert alert, {Map<String, dynamic>? existingData}) async {
    Uri uri = _metaUri(alert);

    try {
      // We get the current data so that the other meta fields are not discarded.
      var data = existingData??await _getMeta(uri);

      data['normalMethod'] = [
        'visual',
        if(_settings!.normalAlert) 'sound'
      ];
      data['nominalMethod'] = data['normalMethod'];
      data['alertMethod'] = [
        'visual',
        if(_settings!.alertAlert) 'sound'
      ];
      data['warnMethod'] = [
        'visual',
        if(_settings!.warnAlert) 'sound'
      ];
      data['alarmMethod'] = [
        'visual',
        if(_settings!.alarmAlert) 'sound'
      ];
      data['emergencyMethod'] = [
        'visual',
        if(_settings!.emergencyAlert) 'sound'
      ];

      List<Map<String, dynamic>> jsonZones = [];
      var zones = List<_Zone>.from(alert.meta.zones);
      if(zones.isEmpty || zones[0].lower != 0) {
        var zone = zones.firstOrNull;
        String msg = zone==null?' Normal':' < ${_toDisplay(alert.type, zone.lower??0)}';//TODO
        zones.insert(0, _Zone(lower: 0, state: NotificationState.normal, message: '${alert.type.displayName}$msg'));//TODO
      } 

      for(int z = 0; z<zones.length; ++z) {
        var zone = zones[z];
        if(zone.message.isEmpty) zone.message = '${alert.type.displayName} > ${_toDisplay(alert.type, zone.lower??0)}';//TODO
        jsonZones.add(zone.toJson(upper: z<zones.length-1?zones[z+1].lower:null));
      }

      data['zones'] = jsonZones;

      var r = await widget.config.controller.httpPut(
        uri,
        headers: {
          "Content-Type": "application/json",
          "accept": "application/json"
        },
        body: '{"value": ${json.encode(data)}}'
      );
      if(r.statusCode != 202) {
        if(mounted) widget.config.controller.showMessage(context, r.reasonPhrase??'Failed to update zone "$uri', error: true);
      }

      if(mounted) {
        setState(() {
          _metas = null;
        });
      }
    } catch (e) {
      widget.config.controller.l.e('Unexpected error updating zone "$uri"', error: e);
    }
  }

  void _removeZones (_Alert alert) async {
    Uri uri = _metaUri(alert);
    // Need to keep existing data for other meta fields.
    var existingData = await _getMeta(uri);

    try {

      var r = await widget.config.controller.httpDelete(
        uri,
        headers: {
          "Content-Type": "application/json",
          "accept": "application/json"
        },
      );
      if(r.statusCode != 202) {
        if(mounted) widget.config.controller.showMessage(context, r.reasonPhrase??'Failed to delete zone "$uri', error: true);
      }
    } catch (e) {
      widget.config.controller.l.e('Unexpected error deleting zone "$uri"', error: e);
    }
    
    // Need to set a normal range to stop the server keeping old ranges.
    _Alert removeAlert = _Alert(type: alert.type, meta: _Meta(alert: alert, zones: []));
    _setZones(removeAlert, existingData: existingData);
  }

  void _edit() async {
    if(mounted) await widget.config.controller.showSettingsPage(context, widget);

    _settings = _Settings.fromJson(widget.config.controller.getBoxSettingsJson(widget.id));
    
    widget.config.controller.save();

    if(mounted) {
      setState(() {
        _metas = null;
      });
    }
  }
}

class _AlertsSetupSettings extends BoxSettingsWidget {
  final BoatInstrumentController _controller;
  final _Settings _settings;

  const _AlertsSetupSettings(this._controller, this._settings);
  
  @override
  Map<String, dynamic> getSettingsJson() {
    return _settings.toJson();
  }

  @override
  State<_AlertsSetupSettings> createState() => __AlertsSetupSettingsState();
}

class __AlertsSetupSettingsState extends State<_AlertsSetupSettings> with _UnitConversion {

  @override
  BoatInstrumentController get controller => widget._controller;

  @override
  Widget build(BuildContext context) {
    _Settings s = widget._settings;

    return PopScope(canPop: false, onPopInvokedWithResult: (didPop, result) {if(didPop) return; _checkPaths();}, child: Column(children: [
      Row(children: [
        IconButton(tooltip: 'Add Alert', icon: const Icon(Icons.add), onPressed: _addAlert),
      ]),
      Expanded(child: ListView.builder(itemCount: s.alerts.length, itemBuilder: (context, a) {
        var alert = s.alerts[a];
        List<Widget> zones = [];
        for(int z = 0; z<alert.meta.zones.length; ++z) {
          var zone = alert.meta.zones[z];
          zones.add(Row(children: [
            Expanded(child: Padding(padding: EdgeInsets.all(pad), child: BiTextFormField(
              decoration: InputDecoration(labelText: '${_units(alert.type)}:'),
              keyboardType: TextInputType.number,
              inputFormatters: [BiTextFormField.doubleOnly],
              initialValue: _toDisplay(alert.type, zone.lower??0),//TODO
              onChanged: (value) => zone.lower = _fromDisplay(alert.type, value)
            ))),
            Expanded(child: Padding(padding: EdgeInsets.all(pad), child: EnumDropdownMenu(
              NotificationState.values,
              zone.state,
              (v) {zone.state = v!;}
            ))),
            Expanded(child: Padding(padding: EdgeInsets.all(pad), child: BiTextFormField(
              decoration: InputDecoration(labelText: 'Message:'),
              initialValue: zone.message,
              onChanged: (value) => zone.message = value
            ))),
            IconButton(onPressed: () {_deleteZone(alert, z);}, icon: Icon(Icons.delete))
          ]));
        }
        return Column(children: [
          ListTile(
            leading: IconButton(tooltip: 'Audio Settings', icon: const Icon(Icons.notifications), onPressed: () {_audioSettings(alert);}),
            title: EnumDropdownMenu(AlertType.values, alert.type, (v) {alert.type = v!;}),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(onPressed: () {_addZone(alert);}, icon: Icon(Icons.add)),
                IconButton(onPressed: () {_deleteAlert(a);}, icon: Icon(Icons.delete))
            ])),
          Column(children: zones)
        ]);
      }))
    ]));
  }

  void _checkPaths () {//TODO check for duplicate paths
    Navigator.pop(context);
    // if(widget._settings.timers.every((timer) {return timer.id.isNotEmpty;})) {
    //   Navigator.pop(context);
    // } else {
    //   widget._controller.showMessage(context, 'Timer IDs cannot be blank');
    // }
  }

  void _audioSettings(_Alert alert) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
          return _AudioSettings(widget._settings);
        })
      );
  }

  void _addAlert() {
    setState(() {
      widget._settings.alerts.add(_Alert());
    });
  }

  Future<void> _deleteAlert(int i) async {
    setState(() {
      widget._settings.alerts.removeAt(i);
    });
  }

  void _addZone(_Alert alert) {
    setState(() {
      alert.meta.zones.add(_Zone(lower: 0, state: NotificationState.warn, message: ''));//TODO
    });
  }

  void _deleteZone(_Alert alert, int z) {
    setState(() {
      alert.meta.zones.removeAt(z);
    });
  }
}

class _AudioSettings extends StatefulWidget {
  final _Settings _settings;

  const _AudioSettings(this._settings);
  
  @override
  State<_AudioSettings> createState() => __AudioSettingsState();
}

class __AudioSettingsState extends State<_AudioSettings> {

  @override
  Widget build(BuildContext context) {
    var s = widget._settings;

    return Scaffold(appBar: AppBar(title: Text('Audio Settings')), body: ListView(children: [
      SwitchListTile(
        title: const Text("Normal/Nominal:"),
        value: s.normalAlert,
        onChanged: (bool value) {
          setState(() {
            s.normalAlert = value;
          });
        }
      ),
      SwitchListTile(
        title: const Text("Alert:"),
        value: s.alertAlert,
        onChanged: (bool value) {
          setState(() {
            s.alertAlert = value;
          });
        }
      ),
      SwitchListTile(
        title: const Text("Warn:"),
        value: s.warnAlert,
        onChanged: (bool value) {
          setState(() {
            s.warnAlert = value;
          });
        }
      ),
      SwitchListTile(
        title: const Text("Alarm:"),
        value: s.alarmAlert,
        onChanged: (bool value) {
          setState(() {
            s.alarmAlert = value;
          });
        }
      ),
      SwitchListTile(
        title: const Text("Emergency:"),
        value: s.emergencyAlert,
        onChanged: (bool value) {
          setState(() {
            s.emergencyAlert = value;
          });
        }
      ),
    ]));
  }
}
