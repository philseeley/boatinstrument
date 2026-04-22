import 'dart:async';
import 'dart:io';
import 'dart:math' as m;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../boatinstrument_controller.dart';

part 'anchor_box.g.dart';

@JsonSerializable(explicitToJson: true)
class _AnchorAlarmSettings {
  int recordSeconds;
  int recordPoints;
  double sampleRadius;
  double zoomIncrement;
  SignalkChart signalkChart;
  bool startWithChart;

  _AnchorAlarmSettings({
    this.recordSeconds = 10,
    this.recordPoints = 1000,
    this.sampleRadius = 30,
    this.zoomIncrement = 0.5,
    this.signalkChart = const SignalkChart(),
    this.startWithChart = true
  });

  factory _AnchorAlarmSettings.fromJson(Map<String, dynamic> json) => _$AnchorAlarmSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$AnchorAlarmSettingsToJson(this);
}

class _Map extends StatelessWidget {
  final BoatInstrumentController _controller;
  final SignalkChart _signalkChart;
  final bool _showMap;
  final double _zoom;
  final ll.LatLng _position;
  final ll.LatLng? _anchorPosition;
  final ll.LatLng? _newAnchorPosition;
  final double? _currentRadius;
  final double? _maxRadius;
  final double? _newMaxRadius;
  final double _sampleRadius;
  final Color _currentColor;
  final Color _maxColor;
  final double? _headingTrue;
  final double? _windAngleApparent;
  final List<ll.LatLng> _positions;

  final MapController _mapController = MapController();

  ll.LatLng toLatLong(Offset offset) => _mapController.camera.screenOffsetToLatLng(offset);
  Offset toOffset(ll.LatLng latLong) => _mapController.camera.latLngToScreenOffset(latLong);

  _Map(
    this._controller,
    this._signalkChart,
    this._showMap,
    this._zoom,
    this._position,
    this._anchorPosition,
    this._newAnchorPosition,
    this._currentRadius,
    this._currentColor,
    this._maxRadius,
    this._newMaxRadius,
    this._sampleRadius,
    this._maxColor,
    this._headingTrue,
    this._windAngleApparent,
    this._positions
  );

  @override
  Widget build(BuildContext context) {
    double maxTextWidth = 0;
    double currentTextWidth = 0;
    Color bgColor = Theme.of(context).colorScheme.surface;
    TextStyle th = Theme.of(context).textTheme.bodyMedium!;
    var tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
    var maxRadiusText = _controller.shortDistanceToDisplay((_maxRadius??0)).round().toString();
    var currentRadiusText = _controller.shortDistanceToDisplay(_currentRadius??_sampleRadius).round().toString();
    try {
      tp.text = TextSpan(text: maxRadiusText, style: th);
      tp.layout();
      maxTextWidth = tp.width;

      tp.text = TextSpan(text: currentRadiusText, style: th);
      tp.layout();
      currentTextWidth = tp.width;
    } finally {
      tp.dispose();
    }

    var maxRadiusPos = (_maxRadius == null)?ll.LatLng(0, 0):ll.Distance().offset(_newAnchorPosition??_anchorPosition??_position, _newMaxRadius??_maxRadius!, 90);
    var currentRadiusPos = ll.Distance().offset(_anchorPosition??_position, _currentRadius??_sampleRadius, 270);

    String url = '';
    if(_showMap && _signalkChart.defined) {
      if(_signalkChart.proxy && _controller.httpApiUri.host.isNotEmpty) {
        // We don't use the Uri.replace() method as this performs URL encoding,
        // e.g. replaces'{' with '%7B', which isn't the template format.
        url = '${_controller.httpApiUri.origin}${_signalkChart.tilemapUrl}';
      } else {
        url = _signalkChart.tilemapUrl;
      }
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        backgroundColor: bgColor,
        initialCenter: _anchorPosition??_position,
        initialZoom: _zoom,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.none
        )
      ),
      children: [
        if(url.isNotEmpty) TileLayer(urlTemplate: url),
        CircleLayer(circles: [
          if(_maxRadius != null) CircleMarker(point: _newAnchorPosition??_anchorPosition??_position, radius: _newMaxRadius??_maxRadius!, useRadiusInMeter: true, borderColor: _maxColor, color: Colors.transparent, borderStrokeWidth: 2),
          if(_currentRadius != null) CircleMarker(point: _anchorPosition??_position, radius: _currentRadius!, useRadiusInMeter: true, borderColor: _currentColor, color: Colors.transparent, borderStrokeWidth: 2),
          if(_currentRadius == null && _maxRadius == null) CircleMarker(point: _position, radius: _sampleRadius, useRadiusInMeter: true, borderColor: _currentColor, color: Colors.transparent, borderStrokeWidth: 2),
        ]),
        PolylineLayer(polylines: [
          if(_positions.isNotEmpty) Polyline(points: _positions, color: Colors.yellow),
          if(_maxRadius != null && _headingTrue != null) Polyline(color: _currentColor, strokeWidth: 2, points: [_position, ll.Distance().offset(_position, _maxRadius!, rad2Deg(_headingTrue))]),
          if(_maxRadius != null && _headingTrue != null && _windAngleApparent != null) Polyline(color: Colors.blue, strokeWidth: 2, points: [_position, ll.Distance().offset(_position, _maxRadius!/2, rad2Deg(_headingTrue!+_windAngleApparent!))])
        ]),
        MarkerLayer(markers: [
          if(_anchorPosition != null) Marker(point: _newAnchorPosition??_anchorPosition!, child: Icon(Icons.anchor, color: _currentColor)),
          Marker(point: _position, child: Transform.rotate(angle: (_headingTrue??0), child: Icon(_headingTrue == null?Icons.highlight_off:Icons.navigation, color: _currentColor))),
          if(_maxRadius != null) Marker(width: maxTextWidth, alignment: Alignment.centerLeft, point: maxRadiusPos, child: Text(maxRadiusText, style: th.copyWith(backgroundColor: _maxColor), textScaler: TextScaler.noScaling)),
          if(_currentRadius != null) Marker(width: currentTextWidth, alignment: Alignment.centerRight, point: currentRadiusPos, child: Text(currentRadiusText, style: th.copyWith(backgroundColor: _currentColor), textScaler: TextScaler.noScaling)),
          if(_currentRadius == null && _maxRadius == null) Marker(width: currentTextWidth, alignment: Alignment.centerRight, point: currentRadiusPos, child: Text(currentRadiusText, style: th.copyWith(backgroundColor: _currentColor), textScaler: TextScaler.noScaling))
        ])
      ],
    );
  }
}

class AnchorAlarmBox extends BoxWidget {
  static const sid = 'anchor-alarm';
  @override
  String get id => sid;

  const AnchorAlarmBox(super.config, {super.key});

  @override
  bool get hasSettings => true;

  @override
  BoxSettingsWidget getSettingsWidget(Map<String, dynamic> json) {
    return _AnchorAlarmSettingsWidget(config.controller, _$AnchorAlarmSettingsFromJson(json));
  }

  @override
  Widget? getHelp() => HelpPage(url: 'doc:anchor-alarm.md');

  @override
  State<AnchorAlarmBox> createState() => _AnchorState();
}

class _AnchorState extends State<AnchorAlarmBox> {
  static const int _radiusIncrement = 5;

  late final _AnchorAlarmSettings _settings;
  ll.LatLng? _position;
  ll.LatLng? _anchorPosition;
  ll.LatLng? _newAnchorPosition;
  double? _headingTrue;
  double? _windAngleApparent;
  double? _maxRadius;
  double? _newMaxRadius;
  double? _currentRadius;
  bool _unlocked = false;
  Timer? _lockTimer;
  static final List<ll.LatLng> _positions = [];
  late DateTime _lastPositionTime;
  static double _zoom = 19;
  bool _showMap = false;
  _Map? _map;

  @override
  void initState() {
    super.initState();
    _lastPositionTime = widget.config.controller.now();

    _settings = _AnchorAlarmSettings.fromJson(widget.config.controller.getBoxSettingsJson(widget.id));
    widget.config.controller.configure(onUpdate: _onUpdate, paths: {
      'navigation.position',
      'navigation.headingTrue',
      'environment.wind.angleApparent',
      'navigation.anchor.position',
      'navigation.anchor.maxRadius',
      'navigation.anchor.currentRadius'
    });
    _showMap = _settings.signalkChart.defined && _settings.startWithChart;
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    super.dispose();
  }

  void _toggleMap() {
    if(widget.config.editMode) return;
    setState(() {
      _showMap = !_showMap;
    });
  }

  void _changeZoom(int direction) {
    if(widget.config.editMode) return;
    setState(() {
      _zoom += direction * _settings.zoomIncrement;
    });
  }

  void _resetZoom() {
    if(widget.config.editMode && _position != null) return;

    double max = m.max(_maxRadius??_currentRadius??_settings.sampleRadius, _currentRadius??_settings.sampleRadius);
    double h = m.sqrt(max*max*2);
    var cameraFit = CameraFit.coordinates(padding: EdgeInsets.all(50), coordinates: [
      ll.Distance().offset(_anchorPosition??_position!, h, 135),
      ll.Distance().offset(_anchorPosition??_position!, h, 315),
    ]);

    var camera = cameraFit.fit(_map!._mapController.camera);

    setState(() {
      _zoom = camera.zoom;
    });
  }

  @override
  Widget build(BuildContext context) {
    var bg = Theme.of(context).colorScheme.onSurface;
    var dropColor = widget.config.controller.val2PSColor(context, 1, none: Colors.grey);
    var raiseColor = widget.config.controller.val2PSColor(context, -1, none: Colors.grey);

    var zoom = _zoom;
    if(widget.config.editMode) {
      _position = ll.LatLng(50.61795, -2.246792);
      _anchorPosition = ll.LatLng(50.618210, -2.246792);
      _maxRadius = 45;
      _currentRadius = 30;
      _headingTrue = deg2Rad(45);
      _windAngleApparent = deg2Rad(-30);
      zoom = 17.5;
    }

    _map = null;
    if(TickerMode.valuesOf(context).enabled && _position != null) {
      _map = _Map(
        widget.config.controller,
        _settings.signalkChart,
        _showMap,
        zoom,
        _position!,
        _anchorPosition,
        _newAnchorPosition,
        _currentRadius,
        dropColor,
        _maxRadius,
        _newMaxRadius,
        _settings.sampleRadius,
        raiseColor,
        _headingTrue,
        _windAngleApparent,
        _positions
      );
    }

    return Padding(padding: const EdgeInsets.all(pad), child: Column(children: [
      Expanded(child: Stack(children: [
        if(_map != null) GestureDetector(onPanStart: _unlocked?_panStart:null, onPanUpdate: _unlocked?_panUpdate:null, onPanEnd: _unlocked?_panEnd:null, child: AbsorbPointer(child: _map!)),
        Positioned(top: pad, left: pad, right: pad, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _button(_map==null?null:_toggleLocked, dropColor, iconData: _unlocked?Icons.lock_open:Icons.lock),
          _button(_maxRadius==null?_drop:null, dropColor, iconData: Icons.anchor),
          _button((_currentRadius!=null && _maxRadius == null)?_setMaxRadius:null, dropColor, iconData: Icons.highlight_off),
          _button(_maxRadius==null?null:() {_changeMaxRadius(-_radiusIncrement);}, dropColor, iconData: Icons.remove),
          _button(_maxRadius==null?null:() {_changeMaxRadius(_radiusIncrement);}, dropColor, iconData: Icons.add),
          _button(_unlocked?_raise:null, raiseColor, iconStack: Stack(children: [Icon(Icons.anchor), Icon(Icons.close)])),
        ])),
        if(_map != null) Positioned(bottom: pad, right: pad, child: Column(spacing: pad, children: [
            if(_settings.signalkChart.defined) _button(_toggleMap, bg, iconStack: Stack(children: [Icon(Icons.map), if(!_showMap) Icon(Icons.close)])),
            _button(() {_changeZoom(1);}, bg, iconData: Icons.add),
            _button(_resetZoom, bg, iconData: Icons.all_out),
            _button(() {_changeZoom(-1);}, bg, iconData: Icons.remove)
        ])),
      ]))
    ]));
  }

  IconButton _button(Function()? onPressed, Color color, {IconData? iconData, Stack? iconStack}) {
    return IconButton.filled(onPressed: onPressed, icon: iconStack??Icon(iconData), style: IconButton.styleFrom(backgroundColor: color, foregroundColor: Theme.of(context).colorScheme.surface));
  }

  void _panStart(DragStartDetails d) {
    if(_maxRadius != null) {
      var maxRadiusPos = _map!.toOffset(ll.Distance().offset(_anchorPosition!, _maxRadius!, 90));
      var box = Rect.fromCircle(center: maxRadiusPos, radius: 30);
      if(box.contains(d.localPosition)) {
        setState(() {
          _newMaxRadius = ll.Distance().distance(_anchorPosition!, _map!.toLatLong(d.localPosition));
        });
        return;
      }
    }
    var size = _map!._mapController.camera.size;
    var box = Rect.fromCircle(center: Offset(size.width/2, size.height/2), radius: 30);
    if(box.contains(d.localPosition)) {
      setState(() {
        _newAnchorPosition = _map!.toLatLong(d.localPosition);
      });
    }
  }

  void _panUpdate(DragUpdateDetails d) {
    if(_newAnchorPosition != null) {
      setState(() {
        _newAnchorPosition = _map!.toLatLong(d.localPosition);
      });
    }
    if(_newMaxRadius != null) {
        setState(() {
          _newMaxRadius = ll.Distance().distance(_anchorPosition!, _map!.toLatLong(d.localPosition));
        });
    }
  }

  void _panEnd(DragEndDetails d) {
    if(_newAnchorPosition != null) {
      _sendCommand('setAnchorPosition',
          '{"position": {"latitude": ${_newAnchorPosition!.latitude}, "longitude": ${_newAnchorPosition!.longitude}}}');
      _newAnchorPosition = null;
    }
    if(_newMaxRadius != null) {
      _resizeMaxRadius(_newMaxRadius!);
      _newMaxRadius = null;
    }
  }

  void _toggleLocked () {
    if(widget.config.editMode) return;
    setState(() {
      _unlocked = !_unlocked;
    });
    _setLockTimer();
  }

  void _setLockTimer() {
    _lockTimer?.cancel();
    if(_unlocked) {
      _lockTimer = Timer(const Duration(minutes: 2), () {
        _unlocked = false;
        if(mounted) {
          setState(() {});
        }
      });
    }
  }

  void _drop() {
    _sendCommand('dropAnchor', '');
  }

  void _setMaxRadius() {
    _setLockTimer();
    _sendCommand('setRadius', '');
  }

  void _resizeMaxRadius(double newMaxRadius) {
    if(newMaxRadius < _currentRadius!) newMaxRadius = _currentRadius!+_radiusIncrement;

    _sendCommand('setRadius', '{"radius": ${newMaxRadius.round()}}');
  }

  void _changeMaxRadius(int amount) {
    _resizeMaxRadius(_maxRadius!+amount);
  }

  void _raise() async {
    if(await widget.config.controller.askToConfirm(context, 'Raise Anchor?', alwaysAsk: true)) {
      await _sendCommand('raiseAnchor', '');
      setState(() {
        _unlocked = false;
        _anchorPosition = _maxRadius = _currentRadius = null;
      });
    }
  }

  Future<void> _sendCommand(String path, String params) async {
    if(widget.config.editMode) return;

    try {
      Uri uri = widget.config.controller.httpApiUri.replace(
          path: '/plugins/anchoralarm/$path');

      http.Response response = await widget.config.controller.httpPost(
          uri,
          headers: {
            "Content-Type": "application/json",
            "accept": "application/json"
          },
          body: params
      );

      if(response.statusCode != HttpStatus.ok) {
        if(mounted) {
          widget.config.controller.showMessage(context, response.reasonPhrase ?? '', error: true);
        }
      }
    } catch (e) {
      widget.config.controller.l.e('Error posting to server', error: e);
    }
  }

  void _onUpdate(List<Update> updates) {
    for (Update u in updates) {
      try {
        switch (u.path) {
          case 'navigation.position':
            if(u.value == null) {
              _position = null;
            } else {
              _position = ll.LatLng(
                    (u.value['latitude'] as num).toDouble(),
                    (u.value['longitude'] as num).toDouble());

              DateTime now = widget.config.controller.now();
              if(now.difference(_lastPositionTime) >= Duration(seconds: _settings.recordSeconds)) {
                _lastPositionTime = now;
                _positions.add(_position!);

                if (_positions.length > _settings.recordPoints) {
                  _positions.removeRange(0, _settings.recordPoints ~/ 10);
                }
              }
            }
            break;
          case 'navigation.headingTrue':
            _headingTrue = (u.value == null) ? null : (u.value as num).toDouble();
            break;
          case 'environment.wind.angleApparent':
            if(u.value == null) {
              _windAngleApparent = null;
            } else {
              double v = (u.value as num).toDouble();
              _windAngleApparent = (u.value == null) ? null : averageAngle(_windAngleApparent ?? v, v,
                smooth: widget.config.controller.valueSmoothing, relative: true);
            }
            break;
          case 'navigation.anchor.position':
            _anchorPosition = (u.value == null) ? null : ll.LatLng((u.value['latitude'] as num).toDouble(), (u.value['longitude'] as num).toDouble());
            break;
          case 'navigation.anchor.maxRadius':
              if(u.value == null) {
                _maxRadius = null;
              } else {
                try {
                  _maxRadius = (u.value as num).toDouble();
                } catch (_){
                  // This only happens if the Anchor Alarm webapp is used.
                  _maxRadius = double.parse(u.value as String);
                }
              }
            break;
          case 'navigation.anchor.currentRadius':
            if(u.value == null) {
              _currentRadius = null;
            } else {
              _currentRadius = (u.value as num).toDouble();
              // Make sure we have a radius to avoid div-by-zero error.
              _currentRadius = _currentRadius == 0 ? 1 : _currentRadius;
            }
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

class _AnchorAlarmSettingsWidget extends BoxSettingsWidget {
  final BoatInstrumentController _controller;
  final _AnchorAlarmSettings _settings;

  const _AnchorAlarmSettingsWidget(this._controller, this._settings);

  @override
  createState() => _AnchorAlarmSettingsState();

  @override
  Map<String, dynamic> getSettingsJson() {
    return _settings.toJson();
  }
}

class _AnchorAlarmSettingsState extends State<_AnchorAlarmSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _AnchorAlarmSettings s = widget._settings;
    var c = widget._controller;

    List<Widget> list = [
      ListTile(
        leading: const Text("Record Position Period:"),
        title: Slider(
          min: 1,
          max: 60,
          divisions: 6,
          value: s.recordSeconds.toDouble(),
          label: "${s.recordSeconds}",
          onChanged: (double value) {
            setState(() {
              s.recordSeconds = value.toInt();
            });
          }
        ),
        trailing: Text('${s.recordSeconds} $secondsUnits'),
      ),
      ListTile(
        leading: const Text("Record Points:"),
        title: Slider(
          min: 100,
          max: 10000,
          divisions: 99,
          value: s.recordPoints.toDouble(),
          label: "${s.recordPoints}",
          onChanged: (double value) {
            setState(() {
              s.recordPoints = value.toInt();
            });
          }
        ),
        trailing: Text(s.recordPoints.toString()),
      ),
      ListTile(
        title: Text('Records for ${(s.recordSeconds*s.recordPoints/60/60).toStringAsFixed(2)} hours'),
      ),
      ListTile(
        leading: const Text("Sample Radius:"),
        title: Slider(
          min: 20,
          max: 200,
          divisions: 18,
          value: s.sampleRadius,
          label: c.shortDistanceToDisplay(s.sampleRadius).round().toString(),
          onChanged: (double value) {
            setState(() {
              s.sampleRadius = value;
            });
          }
        ),
        trailing: Text('${c.shortDistanceToDisplay(s.sampleRadius).round()} ${c.shortDistanceUnitsToDisplay()}'),
      ),
      ListTile(
        leading: const Text("Zoom Increment:"),
        title: Slider(
          min: 0.25,
          max: 2,
          divisions: 7,
          value: s.zoomIncrement.toDouble(),
          label: "${s.zoomIncrement}",
          onChanged: (double value) {
            setState(() {
              s.zoomIncrement = value;
            });
          }
        ),
        trailing: Text(s.zoomIncrement.toString()),
      ),
      ListTile(
        leading: const Text("SignalK Chart:"),
        title: SignalkChartsDropdownMenu(
          widget._controller,
          s.signalkChart,
          (value) {
            setState(() {
              s.signalkChart = value;
            });
          }
        )
      ),
      if(s.signalkChart.defined) SwitchListTile(title: const Text("Show Map on Start:"),
        value: s.startWithChart,
        onChanged: (bool value) {
          setState(() {
            s.startWithChart = value;
          });
        }
      ),
    ];

    return ListView(children: list);
  }
}
