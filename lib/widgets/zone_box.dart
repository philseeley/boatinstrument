import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:json_annotation/json_annotation.dart';

part 'zone_box.g.dart';

enum AlertType implements EnumMenuEntry {
  aws('Apparent Wind Speed', 'environment.wind.speedApparent', true, 0),
  tws('True Wind Speed', 'environment.wind.speedTrue', true, 0),
  dbs('Depth Below Surface', 'environment.depth.belowSurface', false, 0),
  dbk('Depth Below Keel', 'environment.depth.belowKeel', false, 0),
  dbt('Depth Below Transducer', 'environment.depth.belowTransducer', false, 0),
  sog('Speed Over Ground', 'navigation.speedOverGround', true, 0),
  stw('Speed Through Water', 'navigation.speedThroughWater', true, 0),
  wtGt('Water Temperature Increasing', 'environment.water.temperature', true, kelvinOffset),
  wtLt('Water Temperature Decreasing', 'environment.water.temperature', false, kelvinOffset),
  wptDistGc('Waypoint Distance (GC)', 'navigation.courseGreatCircle.nextPoint.distance', false, 0),
  batVoltage('Battery Voltage', 'electrical.batteries', false, 0, item: 'voltage'),
  batCurrent('Battery Current', 'electrical.batteries', false, -1000000, item: 'current'),
  tankFreshwater('Freshwater Tank', 'tanks.freshWater', false, 0, item: 'currentLevel'),
  tankWastewater('Wastewater Tank', 'tanks.wasteWater', true, 0, item: 'currentLevel'),
  tankBlackWater('Black Water Tank', 'tanks.blackWater', true, 0, item: 'currentLevel'),
  tankFuel('Fuel Tank', 'tanks.fuel', false, 0, item: 'currentLevel'),
  tankLubrication('Lubrication Tank', 'tanks.lubrication', false, 0, item: 'currentLevel'),
  ;

  @override
  String get displayName => _displayName;
  final String _displayName;
  final String path;
  final bool increasing;
  final double base;
  final String? item;

  const AlertType(this._displayName, this.path, this.increasing, this.base, {this.item});
}

mixin _UnitConversion {
  BoatInstrumentController get controller;

  Uri _metaUri (_Alert alert) {
    Uri uri = controller.httpApiUri;
    List<String> ps = [...uri.pathSegments]
      ..removeLast()
      ..addAll(['vessels', 'self'])
      ..addAll(alert.type.path.split('.'));

    if(alert.type.item != null) {
      if(alert.id == null) throw Exception('ID not set for Alert ${alert.type.displayName}');

      ps..add(alert.id!)
      ..add(alert.type.item!);
    }
    ps.add('meta');

    return uri.replace(pathSegments: ps);
  }

  String _units(AlertType type) {
    switch(type) {
      case AlertType.aws:
      case AlertType.tws:
        return controller.windSpeedUnits.unit;
      case AlertType.dbs:
      case AlertType.dbk:
      case AlertType.dbt:
        return controller.depthUnits.unit;
      case AlertType.sog:
      case AlertType.stw:
        return controller.speedUnits.unit;
      case AlertType.wtGt:
      case AlertType.wtLt:
        return controller.temperatureUnits.unit;
      case AlertType.wptDistGc:
        return controller.distanceUnits.unit;
      case AlertType.batVoltage:
        return voltageUnits;
      case AlertType.batCurrent:
        return currentUnits;
      case AlertType.tankFreshwater:
      case AlertType.tankWastewater:
      case AlertType.tankBlackWater:
      case AlertType.tankFuel:
      case AlertType.tankLubrication:
        return capacityUnits;
    }
  }

  String _toDisplay(AlertType type, double value) {
    switch(type) {
      case AlertType.aws:
      case AlertType.tws:
        return controller.windSpeedToDisplay(value).toString();
      case AlertType.dbs:
      case AlertType.dbk:
      case AlertType.dbt:
        return controller.depthToDisplay(value).toString();
      case AlertType.sog:
      case AlertType.stw:
        return controller.speedToDisplay(value).toString();
      case AlertType.wtGt:
      case AlertType.wtLt:
        return controller.temperatureToDisplay(value).toString();
      case AlertType.wptDistGc:
        return controller.distanceToDisplay(value, fixed: true).toString();
      case AlertType.batVoltage:
      case AlertType.batCurrent:
        return value.toString();
      case AlertType.tankFreshwater:
      case AlertType.tankWastewater:
      case AlertType.tankBlackWater:
      case AlertType.tankFuel:
      case AlertType.tankLubrication:
        return capacityToDisplay(value).toString();
    }
  }

  double _fromDisplay(AlertType type, String strValue) {
    var value = double.parse(strValue);
    switch(type) {
      case AlertType.aws:
      case AlertType.tws:
        return controller.windSpeedFromDisplay(value);
      case AlertType.dbs:
      case AlertType.dbk:
      case AlertType.dbt:
        return controller.depthFromDisplay(value);
      case AlertType.sog:
      case AlertType.stw:
        return controller.speedFromDisplay(value);
      case AlertType.wtGt:
      case AlertType.wtLt:
        return controller.temperatureFromDisplay(value);
      case AlertType.wptDistGc:
        return controller.distanceFromDisplay(value);
      case AlertType.batVoltage:
      case AlertType.batCurrent:
        return value;
      case AlertType.tankFreshwater:
      case AlertType.tankWastewater:
      case AlertType.tankBlackWater:
      case AlertType.tankFuel:
      case AlertType.tankLubrication:
        return capacityFromDisplay(value);
    }
  }
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

  Map<String, dynamic> toJson() {
    var json = _$ZoneToJson(this);
    if(lower == null) json.remove('lower');
    if(upper == null) json.remove('upper');
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

@JsonSerializable()
class _AlertZone {
  double value;
  NotificationState state;
  String message;

  _AlertZone({
    this.value = 0,
    this.state = NotificationState.warn,
    this.message = ''
  });

  factory _AlertZone.fromJson(Map<String, dynamic> json) =>
    _$AlertZoneFromJson(json);

  Map<String, dynamic> toJson() {
    return _$AlertZoneToJson(this);
  }
}

@JsonSerializable(explicitToJson: true)
class _Alert {
  AlertType type;
  String? id;
  List<_AlertZone> zones;

  _Alert({
    this.type = AlertType.aws,
    this.id,
    this.zones = const []
  }) {
    if(zones.isEmpty) zones = [];
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

  @override
  Widget? getSettingsHelp() => const HelpPage(url: 'doc:zones.md');
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
  }

  @override
  Widget build(BuildContext context) {
    var editMode = widget.config.editMode;
    var alerts = _settings!.alerts;
    if(_metas == null) {
      _getCurrentAlerts();
      body = Text(alerts.isEmpty?'No Alerts defined\nin Settings':'Retrieving data');
    } else {
      body = ListView.builder(itemCount: _metas!.length, itemBuilder: (context, i) {
        _Meta m = _metas![i];
        StringBuffer zonesStr = StringBuffer();
        bool first = true;
        for(var z in m.zones) {
          if(!first) zonesStr.writeln();
          zonesStr.write('${_toDisplay(m.alert!.type, m.alert!.type.increasing?z.lower??m.alert!.type.base:z.upper??double.infinity)}: ${z.state.displayName}');
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

      // We make a copy as we might be adding a "Normal" zone.
      var zones = List<_AlertZone>.from(alert.zones);
      var lastZone = alert.type.increasing?zones.firstOrNull:zones.lastOrNull;
      String msg = lastZone==null?'Normal':'${alert.type.increasing?'<':'>'} ${_toDisplay(alert.type, lastZone.value)}';
      zones.insert(alert.type.increasing?0:zones.length, _AlertZone(value: alert.type.increasing?alert.type.base:lastZone?.value??alert.type.base, state: NotificationState.normal, message: '${alert.type.displayName} $msg'));

      List<Map<String, dynamic>> jsonZones = [];
      for(int z = 0; z<zones.length; ++z) {
        var zone = zones[z];
        if(zone.message.isEmpty) zone.message = '${alert.type.displayName} ${alert.type.increasing?'>':'<'} ${_toDisplay(alert.type, zone.value)}';
        var jsonZone = _Zone(
          lower: z>0 || zones.length==1?zone.value:null,
          upper: z<zones.length-1?zones[z+1].value:null,
          state: zone.state,
          message: zone.message
        );
        if(!alert.type.increasing) {
          jsonZone = _Zone(
            lower: zones.length==1?zone.value:(z>0?zones[z-1].value:null),
            upper: z<zones.length-1?zone.value:null,
            state: zone.state,
            message: zone.message
          );
        }
        jsonZones.add(jsonZone.toJson());
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
      if(![HttpStatus.ok, HttpStatus.accepted].contains(r.statusCode)) {
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

    // We have to completely delete the metadata otherwise a change of zones does not get applied.
    try {
      var r = await widget.config.controller.httpDelete(
        uri,
        headers: {
          "Content-Type": "application/json",
          "accept": "application/json"
        },
      );
      if(![HttpStatus.ok, HttpStatus.accepted].contains(r.statusCode)) {
        if(mounted) widget.config.controller.showMessage(context, r.reasonPhrase??'Failed to delete zone "$uri', error: true);
      }
    } catch (e) {
      widget.config.controller.l.e('Unexpected error deleting zone "$uri"', error: e);
    }
    
    // Need to set a normal range to stop the server keeping old ranges.
    _Alert removeAlert = _Alert(type: alert.type, zones: [], id: alert.id);
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
        IconButton(tooltip: 'Audio Settings', icon: const Icon(Icons.notifications), onPressed: () {_audioSettings();}),
      ]),
      Expanded(child: ListView.builder(itemCount: s.alerts.length, itemBuilder: (context, a) {
        var alert = s.alerts[a];
        List<Widget> zones = [];
        for(int z = 0; z<alert.zones.length; ++z) {
          var zone = alert.zones[z];
          zones.add(Row(children: [
            Expanded(child: Padding(padding: EdgeInsets.all(pad), child: BiTextFormField(
              decoration: InputDecoration(labelText: '${_units(alert.type)}:'),
              keyboardType: TextInputType.number,
              inputFormatters: [BiTextFormField.doubleOnly],
              initialValue: _toDisplay(alert.type, zone.value),
              onChanged: (value) => zone.value = _fromDisplay(alert.type, value)
            ))),
            Expanded(child: Padding(padding: EdgeInsets.all(pad), child: EnumDropdownMenu(
              NotificationState.values,
              zone.state,
              (v) {zone.state = v!;}
            ))),
            IconButton(tooltip: 'Delete threshold', onPressed: () {_deleteZone(alert, z);}, icon: Icon(Icons.delete))
          ]));
        }
        return Column(children: [
          ListTile(
            leading: IconButton(tooltip: 'Add threshold', onPressed: () {_addZone(alert);}, icon: Icon(Icons.add)),
            title: EnumDropdownMenu(AlertType.values, alert.type, (v) {
              setState(() {
                alert.zones.clear();
                alert.type = v!;
              });
            }),
            trailing: IconButton(tooltip: 'Delete Alert', onPressed: () {_deleteAlert(a);}, icon: Icon(Icons.delete))
          ),
          if(alert.type.item != null) ListTile(
            leading: Text("ID:"),
            title: SignalkPathDropdownMenu(
              widget._controller,
              alert.id??'',
              alert.type.path,
              (value) => alert.id = value)
          ),
          Column(children: zones)
        ]);
      }))
    ]));
  }

  void _checkPaths () {
    bool duplicates = false;
    var alerts = widget._settings.alerts;
    for(int a1=0; a1<alerts.length; ++a1) {
      for(int a2=a1+1; a2<alerts.length; ++a2) {
        if(alerts[a1].type == alerts[a2].type) {
          duplicates = true;
          break;
        }
      }
      if(duplicates) break;
    }
    if(!duplicates) {
      // Applying Zones to the server assumes they are already ordered.
      for(var alert in widget._settings.alerts) {
        alert.zones.sort((a, b) => a.value.compareTo(b.value));
      }
      Navigator.pop(context);
    } else {
      widget._controller.showMessage(context, 'Alerts can only be defined once');
    }
  }

  void _audioSettings() async {
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
    if(await widget._controller.askToConfirm(context, 'Also delete from server config file?')) {
      var alert = widget._settings.alerts[i];

      Uri uri = _metaUri(alert);
      try {
        var r = await widget._controller.httpDelete(
          uri,
          headers: {
            "Content-Type": "application/json",
            "accept": "application/json"
          },
        );
        if(![HttpStatus.ok, HttpStatus.accepted].contains(r.statusCode)) {
          if(mounted) widget._controller.showMessage(context, r.reasonPhrase??'Failed to delete zone from file "$uri', error: true);
        }
      } catch (e) {
        widget._controller.l.e('Unexpected error deleting zone from file "$uri"', error: e);
      }
    }
    setState(() {
      widget._settings.alerts.removeAt(i);
    });
  }

  void _addZone(_Alert alert) {
    setState(() {
      alert.zones.add(_AlertZone(value: alert.type.base));
    });
  }

  void _deleteZone(_Alert alert, int z) {
    setState(() {
      alert.zones.removeAt(z);
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
