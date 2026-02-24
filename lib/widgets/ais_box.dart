import 'dart:async';
import 'dart:math' as m;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../boatinstrument_controller.dart';

part 'ais_box.g.dart';

@JsonSerializable(explicitToJson: true)
class _AISDisplaySettings {
  bool showNames;
  double minutes;
  SignalkChart signalkChart;

  _AISDisplaySettings({
    this.showNames = true,
    this.minutes = 5,
    this.signalkChart = const SignalkChart()
  });

  factory _AISDisplaySettings.fromJson(Map<String, dynamic> json) => _$AISDisplaySettingsFromJson(json);

  Map<String, dynamic> toJson() => _$AISDisplaySettingsToJson(this);
}

class _Vessel {
  String context;
  bool self;
  ll.LatLng position;
  String? name;
  double? headingTrue;
  double? cogTrue;
  double? sog;
  int? aisShipType;
  String? airShipTypeName;
  String? state;

  _Vessel(this.context, this.self, this.position, {this.name, this.cogTrue, this.sog});
}

class _Map extends StatelessWidget {
  final BoatInstrumentController _controller;
  final _AISDisplaySettings _settings;
  final double _zoom;
  final ll.LatLng _position;
  final Map<String, _Vessel> _vessels;

  final _mapController = MapController();

  _Map(
    this._controller,
    this._settings,
    this._zoom,
    this._position,
    this._vessels
  );

  static final _aisShipTypes = {
    0: Colors.green, // Default
    30: Colors.orange, // Fishing
    36: Colors.purple, // Sailing
    37: Colors.blue, // Pleasure
  };

  Marker _marker(_Vessel v, TextPainter tp, TextStyle ts) {
    var label = '\n\n${v.name??''}';
    tp.text = TextSpan(text: label, style: ts);
    tp.layout();
    var s = m.max(tp.width, tp.height*3);

    var color = _aisShipTypes[v.aisShipType??0]??_aisShipTypes[0];

    return Marker(width:s , height: s,
      point: v.position,
      child: Stack(alignment: AlignmentGeometry.center, children: [
        Transform.rotate(angle: v.headingTrue??v.cogTrue??0, child: Icon(Icons.navigation, color: v.self?Colors.red:color)),
        if(v.state == 'moored') Icon(Icons.circle, color: Colors.black, size: 10),
        if(_settings.showNames && !v.self) Text(label, style: ts, textScaler: TextScaler.noScaling)  
      ])
    );
  }

  Polyline _polyLine(_Vessel v) {
    var end = FlutterMapMath.destinationPoint(v.position.latitude, v.position.longitude, (v.sog??0) * (_settings.minutes*60), rad2Deg(v.cogTrue??v.headingTrue).toDouble());

    return Polyline(
      points: [v.position, end],
      color: Colors.yellow
    );
  }

  Polyline _headingLine(MapEntry<String, _Vessel> e) {
    return _polyLine(e.value);
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = Theme.of(context).colorScheme.surface;
    TextStyle ts = Theme.of(context).textTheme.bodyMedium!;
    var tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
    try {
      String url = '';
      if(_settings.signalkChart.tilemapUrl.isNotEmpty) {
        if(_settings.signalkChart.proxy) {
          // We don't use the Uri.replace() method as this performs URL encoding,
          // e.g. replaces'{' with '%7B', which the server doesn't like.
          url = '${_controller.httpApiUri.origin}${_settings.signalkChart.tilemapUrl}';
        } else {
          url = _settings.signalkChart.tilemapUrl;
        }
      }

      return FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          keepAlive: true,
          backgroundColor: bgColor,
          initialCenter: _position,
          initialZoom: _zoom,
          interactionOptions: InteractionOptions(
            flags: InteractiveFlag.none
          )
        ),
        children: [
          if(url.isNotEmpty) TileLayer(urlTemplate: url),
          MarkerLayer(markers: _vessels.entries.map((e) {return _marker(e.value, tp, ts);}).toList()),
          PolylineLayer(polylines: _vessels.entries.map(_headingLine).toList()),
        ]
      );
    } finally {
      tp.dispose();
    }
  }
}

class AISDisplayBox extends BoxWidget {
  static const sid = 'ais-display';
  @override
  String get id => sid;

  const AISDisplayBox(super.config, {super.key});

  @override
  bool get hasSettings => true;

  @override
  BoxSettingsWidget getSettingsWidget(Map<String, dynamic> json) {
    return _AISDisplaySettingsWidget(config.controller, _$AISDisplaySettingsFromJson(json));
  }

  @override
  Widget? getHelp() => HelpPage(url: 'doc:anchor-alarm.md');

  @override
  State<StatefulWidget> createState() => _AISDisplayState();
}

class _AISDisplayState extends State<AISDisplayBox> {
  static final Map<String, _Vessel> _vessels = {};

  late final _AISDisplaySettings _settings;
  Timer? _lockTimer;
  static double _zoom = 14;
  _Map? _map;

  @override
  void initState() {
    super.initState();

    _settings = _AISDisplaySettings.fromJson(widget.config.controller.getBoxSettingsJson(widget.id));
    widget.config.controller.configure(onUpdate: _onUpdate, onlySelf: false, paths: {
      'navigation.position',
      'navigation.headingTrue',
      'navigation.courseOverGroundTrue',
      'navigation.speedOverGround',
      'design.aisShipType',
      'navigation.state'
    });
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    super.dispose();
  }

  void _changeZoom(int direction) {
    if(widget.config.editMode) return;
    setState(() {
      _zoom += direction;
    });
  }

  @override
  Widget build(BuildContext context) {
    var bg = Theme.of(context).colorScheme.onSurface;
    var self = _vessels[widget.config.controller.selfURN];
    var vessels = _vessels;
    var zoom = _zoom;
    if(widget.config.editMode) {
      self = _Vessel('self', true, ll.LatLng(50.618210, -2.246792), cogTrue: deg2Rad(45), sog: 0.25);
      vessels = {
        'self': self,
        'billy-do': _Vessel('billy-do', false, ll.LatLng(50.61795, -2.246792), name: 'Billy Do', cogTrue: deg2Rad(90), sog: 0.5)
      };
      zoom = 17.5;
    }

    _map = null;
    if(self != null) {
      _map = _Map(
        widget.config.controller,
        _settings,
        zoom,
        self.position,
        vessels
      );
    }

    return Padding(padding: const EdgeInsets.all(pad), child: Column(children: [
      Expanded(child: Stack(children: [
        if(_map != null) AbsorbPointer(child: _map!),
        if(_map != null) Positioned(bottom: pad, right: pad, child: Column(spacing: pad, children: [
            _button(() {_changeZoom(1);}, bg, iconData: Icons.add),
            _button(() {_changeZoom(-1);}, bg, iconData: Icons.remove)
        ])),
      ]))
    ]));
  }

  IconButton _button(Function()? onPressed, Color color, {IconData? iconData, Stack? iconStack}) {
    return IconButton.filled(onPressed: onPressed, icon: iconStack??Icon(iconData), style: IconButton.styleFrom(backgroundColor: color, foregroundColor: Theme.of(context).colorScheme.surface));
  }

  Future<void> _getVesselName(String context) async {
    _vessels[context]!.name = await widget.config.controller.getPathString('name', context: context);
  }

  Future<void> _onUpdate(List<Update> updates) async {
    var c = widget.config.controller;

    for (Update u in updates) {
      try {
        if(u.value == null) continue;
        var v = _vessels[u.context];
        switch (u.path) {
          case 'navigation.position':
            var position = ll.LatLng(
                    (u.value['latitude'] as num).toDouble(),
                    (u.value['longitude'] as num).toDouble());

            if(v == null) {
              v = _Vessel(u.context, u.context == c.selfURN, position);
              _vessels[u.context] = v;
            }
            v.position = position;
            if(v.name == null) _getVesselName(u.context);
            break;
          case 'navigation.headingTrue':
            if(v == null) return;
            v.headingTrue = (u.value as num).toDouble();
            break;
          case 'navigation.courseOverGroundTrue':
            if(v == null) return;
            v.cogTrue = (u.value as num).toDouble();
            break;
          case 'navigation.speedOverGround':
            if(v == null) return;
            v.sog = (u.value as num).toDouble();
            break;
          case 'design.aisShipType':
            if(v == null) return;
            v.airShipTypeName = u.value['name'];
            v.aisShipType = (u.value['id'] as num).toInt();
            break;
          case 'navigation.state':
            if(v == null) return;
            v.state = u.value;
            break;
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

class _AISDisplaySettingsWidget extends BoxSettingsWidget {
  final BoatInstrumentController _controller;
  final _AISDisplaySettings _settings;

  const _AISDisplaySettingsWidget(this._controller, this._settings);

  @override
  createState() => _AISDisplaySettingsState();

  @override
  Map<String, dynamic> getSettingsJson() {
    return _settings.toJson();
  }
}

class _AISDisplaySettingsState extends State<_AISDisplaySettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _AISDisplaySettings s = widget._settings;

    List<Widget> list = [
      SwitchListTile(
        title: const Text("Show Names:"),
        value: s.showNames,
        onChanged: (bool value) {
          setState(() {
            s.showNames = value;
          });
        }
      ),
      ListTile(
        leading: const Text("COG-Speed Prediction:"),
        title: Slider(
          min: 0,
          max: 20,
          divisions: 4,
          value: s.minutes.toDouble(),
          label: "${s.minutes.toInt()}",
          onChanged: (double value) {
            setState(() {
              s.minutes = value;
            });
          }),
        trailing: Text('mins'),
      ),
      ListTile(
        leading: const Text("SignalK Chart:"),
        title: SignalkChartsDropdownMenu(
          widget._controller,
          s.signalkChart,
          (value) {s.signalkChart = value;}
        )
      )
    ];

    return ListView(children: list);
  }
}
