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
  double predictionMinutes;
  int vesselTimeout;
  SignalkChart signalkChart;

  _AISDisplaySettings({
    this.showNames = true,
    this.predictionMinutes = 5,
    this.vesselTimeout = 10,
    this.signalkChart = const SignalkChart()
  });

  factory _AISDisplaySettings.fromJson(Map<String, dynamic> json) => _$AISDisplaySettingsFromJson(json);

  Map<String, dynamic> toJson() => _$AISDisplaySettingsToJson(this);
}

class _Vessel {
  String context;
  bool self;
  DateTime? lastSeen;
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

class _ScaleConvert {
  DistanceUnits units;
  double meters;

  _ScaleConvert(this.units, this.meters);
}
final Map<DistanceUnits, _ScaleConvert> _dist2m = {
  DistanceUnits.meters:  _ScaleConvert(DistanceUnits.km, 1000),
  DistanceUnits.km: _ScaleConvert(DistanceUnits.km, 1000),
  DistanceUnits.miles: _ScaleConvert(DistanceUnits.miles, miles2m(1)),
  DistanceUnits.nm: _ScaleConvert(DistanceUnits.nm, nm2m(1)),
  DistanceUnits.nmM: _ScaleConvert(DistanceUnits.nm, nm2m(1))
};

class _Map extends StatelessWidget {
  final BoatInstrumentController _controller;
  final _AISDisplaySettings _settings;
  final Function() _onReady;
  final ll.LatLng _position;
  final double _zoom;
  final double _range;
  final int _numOfRings;
  final Map<String, _Vessel> _vessels;
  final MapController _mapController = MapController();

  _Map(
    this._controller,
    this._settings,
    this._onReady,
    this._position,
    this._zoom,
    this._range,
    this._numOfRings,
    this._vessels,
  );

  static final Map<int, Color> _aisShipTypes = {
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
    var end = FlutterMapMath.destinationPoint(v.position.latitude, v.position.longitude, (v.sog??0) * (_settings.predictionMinutes*60), rad2Deg(v.cogTrue??v.headingTrue).toDouble());

    return Polyline(
      points: [v.position, end],
      color: Colors.yellow
    );
  }

  Polyline _headingLine(MapEntry<String, _Vessel> e) {
    return _polyLine(e.value);
  }

  void _rangeRings(BuildContext context,  List<CircleMarker> rings, List<Marker> ringLabels) {
    TextStyle th = Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.yellow);

    var tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
    try {
      for(int i = 1; i<=_numOfRings; ++i) {
        var ring = _range/_numOfRings*i;
        var distance = ring*_dist2m[_controller.distanceUnits]!.meters;

        rings.add(CircleMarker(
          point: _position,
          radius: distance,
          useRadiusInMeter: true,
          color: Colors.transparent,
          borderColor: Colors.yellow,
          borderStrokeWidth: 2));

        var label = '$ring ';
        tp.text = TextSpan(text: label, style: th);
        tp.layout();

        var labelPos = ll.Distance().offset(_position, distance, 90);

        ringLabels.add(Marker(
          width: tp.width,
          alignment: Alignment.centerLeft,
          point: labelPos,
          child: Text(
            label,
            style: th,
            textScaler: TextScaler.noScaling
          )
        ));
      }
      var label = _dist2m[_controller.distanceUnits]!.units.unit;
      tp.text = TextSpan(text: label, style: th);
      tp.layout();
      
      var distance = _range*_dist2m[_controller.distanceUnits]!.meters;
      double h = m.sqrt(distance*distance*2);

      var labelPos = ll.Distance().offset(_position, h, 45);

      ringLabels.add(Marker(
        width: tp.width,
        alignment: Alignment.centerLeft,
        point: labelPos,
        child: Text(
          label,
          style: th,
          textScaler: TextScaler.noScaling
        )
      ));
    } finally {
      tp.dispose();
    }
  }
  
  void _mapReady() {
    _onReady();
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

      List<CircleMarker> rings = [];
      List<Marker> ringLabels = [];

      _rangeRings(context, rings, ringLabels);

      // Note: the initialCameraFit doesn't work if a mapController is specified and changing the Camera after using
      // the mapController doesn't work and changing the zoom only works if there is a controller. Hence the onMapReady
      // callback process.
      return FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          onMapReady: _mapReady,
          backgroundColor: bgColor,
          initialCenter: _position,
          initialZoom: _zoom,
          interactionOptions: InteractionOptions(
            flags: InteractiveFlag.none
          )
        ),
        children: [
          if(url.isNotEmpty) TileLayer(urlTemplate: url),
          CircleLayer(circles: rings),
          MarkerLayer(markers: ringLabels),
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
  Widget? getHelp() => HelpPage(text: '''The length of the line shows the predicted location of the vessel in a configurable number of minutes time, given its Course and Speed over Ground.

The targets are coloured as:
- Fishing - Orange
- Sailing - Purple
- Pleasure - Blue
- All others - Green
''');

  @override
  bool get hasSettings => true;

  @override
  BoxSettingsWidget getSettingsWidget(Map<String, dynamic> json) {
    return _AISDisplaySettingsWidget(config.controller, _$AISDisplaySettingsFromJson(json));
  }

  @override
  Widget? getSettingsHelp() => HelpPage(text: '''The **COG-SOG Prediction** is the number of minutes to predict the vessel's future position, i.e. the length of the line.

The **Vessel Timeout** is the number of minutes that a vessel will be displayed after its last position report.''');

  @override
  State<StatefulWidget> createState() => _AISDisplayState();
}

class _AISDisplayState extends State<AISDisplayBox> {
  static final Map<String, _Vessel> _vessels = {};

  late final _AISDisplaySettings _settings;
  Timer? _lockTimer;
  double _zoom = 14;
  static double _range = 2;
  int _numOfRings = 1;
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

  void _changeRange(bool increase) {
    if(widget.config.editMode) return;
    _range = increase?_range*2:_range/2;
    _range = _range<0.5?0.5:_range;
    _onReady();
  }

  // We can't use the MapController until we're told the map's ready.
  void _onReady() {
    var self = _vessels[widget.config.controller.selfURN];
    if(self != null) {
      var camera = _map!._mapController.camera;
      var size = camera.size;

      double range = widget.config.editMode?1:_range;
      double distance = range*_dist2m[widget.config.controller.distanceUnits]!.meters;
      double h = m.sqrt(distance*distance*2);

      var cameraFit = CameraFit.coordinates(padding: EdgeInsets.all(20), coordinates: [
        ll.Distance().offset(self.position, h, 135),
        ll.Distance().offset(self.position, h, 315),
      ]);

      var newCamera = cameraFit.fit(camera);

      setState(() {
        _zoom = newCamera.zoom;
        // Assuming minimum distance between rings is 100 pixels.
        _numOfRings = (m.min(size.width, size.height)/2/100).floor();
        // Adjust to get on a 1/4 boundary.
        var adjust = range/_numOfRings/0.25;
        adjust = adjust.floorToDouble() * 0.25;
        // But for 0.75 scale up.
        adjust = adjust>0.5?adjust.ceilToDouble():adjust;
        // Avoid dev-by-zero.
        adjust = adjust>0?adjust:0.25;
        // Apply adjustment.
        _numOfRings = (range / adjust).toInt();
        // We want an even number of rings.
        _numOfRings = _numOfRings.isEven?_numOfRings:_numOfRings-1;
        // But we want at least 1 ring.
        _numOfRings = _numOfRings<1?1:_numOfRings;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var bg = Theme.of(context).colorScheme.onSurface;
    var self = _vessels[widget.config.controller.selfURN];
    var vessels = _vessels;
    var range = _range;
    if(widget.config.editMode) {
      self = _Vessel('self', true, ll.LatLng(50.618210, -2.246792), cogTrue: deg2Rad(45), sog: 0.5);
      vessels = {
        'self': self,
        'billy-do': _Vessel('billy-do', false, ll.LatLng(50.60795, -2.246792), name: 'Billy Do', cogTrue: deg2Rad(90), sog: 1)
      };
      range = 1;
    }

    _map = null;
    if(TickerMode.of(context) && self != null) {
      _map = _Map(
        widget.config.controller,
        _settings,
        _onReady,
        self.position,
        _zoom,
        range,
        _numOfRings,
        vessels
      );
    }

    return Padding(padding: const EdgeInsets.all(pad), child: Column(children: [
      Expanded(child: Stack(children: [
        if(_map != null) AbsorbPointer(child: _map!),
        if(_map != null) Positioned(bottom: pad, right: pad, child: Column(spacing: pad, children: [
            _button(() {_changeRange(false);}, bg, iconData: Icons.add),
            _button(() {_changeRange(true);}, bg, iconData: Icons.remove)
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
    var now = c.now();

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
            v.lastSeen = now;
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

    _vessels.removeWhere((context, v) {
      return v.lastSeen==null?true:now.difference(v.lastSeen!) > Duration(minutes: _settings.vesselTimeout);
    });

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
        leading: const Text("COG-SOG Prediction:"),
        title: Slider(
          min: 0,
          max: 20,
          divisions: 4,
          value: s.predictionMinutes,
          label: "${s.predictionMinutes.toInt()}",
          onChanged: (double value) {
            setState(() {
              s.predictionMinutes = value;
            });
          }),
        trailing: Text('mins'),
      ),
      ListTile(
        leading: const Text("Vessel Timeout:"),
        title: Slider(
          min: 5,
          max: 30,
          divisions: 5,
          value: s.vesselTimeout.toDouble(),
          label: s.vesselTimeout.toString(),
          onChanged: (double value) {
            setState(() {
              s.vesselTimeout = value.toInt();
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
