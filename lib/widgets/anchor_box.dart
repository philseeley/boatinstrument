import 'dart:async';
import 'dart:io';
import 'dart:math' as m;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:nanoid/nanoid.dart';

import '../authorization.dart';
import '../boatinstrument_controller.dart';

part 'anchor_box.g.dart';

@JsonSerializable()
class _AnchorAlarmSettings {
  String clientID;
  String authToken;
  int recordSeconds;
  int recordPoints;

  _AnchorAlarmSettings({
    String? clientID,
    this.authToken = '',
    this.recordSeconds = 10,
    this.recordPoints = 1000
  }) : clientID = clientID??'boatinstrument-anchor-alarm-${customAlphabet('0123456789', 4)}';
}

class _AnchorPainter extends CustomPainter {
  final BuildContext _context;
  final BoatInstrumentController _controller;
  final int? _maxRadius;
  final int _currentRadius;
  final double? _bearingTrue;
  final double _apparentBearing;
  final ll.LatLng? _anchorPosition;
  final List<ll.LatLng> _positions;
  final double? _windAngleApparent;

  const _AnchorPainter(this._controller, this._context, this._maxRadius, this._currentRadius, this._bearingTrue, this._apparentBearing, this._anchorPosition, this._windAngleApparent, this._positions);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    Color maxColor = _controller.val2PSColor(_context, -1, none: Colors.grey);
    Color currentColor = _controller.val2PSColor(_context, 1, none: Colors.grey);
    TextStyle th = Theme.of(_context).textTheme.bodyLarge!;
    TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    try {
      double size = m.min(canvasSize.width, canvasSize.height) /2;

      Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..color = maxColor
        ..strokeWidth = 2.0;

      double ratio = _currentRadius/(_maxRadius??_currentRadius)*size;

      if(_maxRadius != null) canvas.drawCircle(Offset(size, size), size, paint);

      paint.color = currentColor;
      canvas.drawCircle(Offset(size, size), ratio, paint);

      IconData icon = Icons.anchor;
      tp.text = TextSpan(text: String.fromCharCode(icon.codePoint),
          style: TextStyle(fontSize: 30,
              fontFamily: icon.fontFamily,
              color: currentColor));
      tp.layout();
      tp.paint(canvas, Offset(size-tp.size.width / 2, size-tp.size.height / 2));

      if(_bearingTrue != null) {
        canvas.save();
        canvas.translate(size, size);
        canvas.rotate(_bearingTrue! - m.pi);
        canvas.translate(0, ratio);
        canvas.save();
        canvas.rotate((m.pi/2) - _apparentBearing);
        icon = Icons.backspace_outlined;
        tp.text = TextSpan(text: String.fromCharCode(icon.codePoint),
            style: TextStyle(fontSize: 30,
                fontFamily: icon.fontFamily,
                color: currentColor));
        tp.layout();
        tp.paint(canvas, Offset(-tp.size.width / 2, -tp.size.height / 2));
        canvas.drawLine(Offset.zero, Offset(-size, 0), paint);
        canvas.restore();
        if(_windAngleApparent != null) {
          paint.color = Colors.blue;
          canvas.rotate((m.pi/2) + _windAngleApparent! - _apparentBearing);
          canvas.drawLine(Offset.zero, Offset(-size/2, 0), paint);
        }
        canvas.restore();
      }

      if(_anchorPosition != null && _maxRadius != null) {
        paint.color = Colors.blue;
        for(ll.LatLng p in _positions) {
          double d = const ll.Distance().distance(_anchorPosition!, p);
          double b = deg2Rad(const ll.Distance().bearing(_anchorPosition!, p).toInt());
          canvas.save();
          canvas.translate(size, size);
          canvas.rotate(b - m.pi);
          canvas.translate(0, d / (_maxRadius!) * size);
          canvas.drawCircle(Offset.zero, 1, paint);
          canvas.restore();
        }
      }

      // We render the circle sizes last so that they're always readable.
      if(_maxRadius != null) {
        tp.text = TextSpan(text: _maxRadius.toString(), style: th.copyWith(backgroundColor: maxColor));
        tp.layout();
        tp.paint(canvas, Offset((size*2)-tp.size.width, size-tp.size.height/2));
      }

      tp.text = TextSpan(text: _currentRadius.toString(), style: th.copyWith(backgroundColor: currentColor));
      tp.layout();
      tp.paint(canvas, Offset(size-ratio, size-tp.size.height/2));
    } finally {
      tp.dispose();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
    return _AnchorAlarmSettingsWidget(super.config.controller, _$AnchorAlarmSettingsFromJson(json));
  }

  @override
  Widget? getHelp(BuildContext context) => HelpPage(url: 'doc:anchor-alarm.md');

  @override
  Widget? getSettingsHelp() => const HelpPage(text: '''To be able to set the Anchor Alarm, the device must be given "admin" permission to signalk. Request an **Auth Token** and without closing the settings page authorise the device in the signalk web interface. When the **Auth Token** is shown, the settings page can be closed.

The **Client ID** can be set to reflect the instrument's location, e.g. "boatinstrument-anchor-alarm-helm". Or the ID can be set to the same value for all instruments to share the same authorisation.
''');

  @override
  State<StatefulWidget> createState() => _AnchorState();
}

class _AnchorState extends State<AnchorAlarmBox> {
  late final _AnchorAlarmSettings _settings;
  ll.LatLng? _anchorPosition;
  double? _windAngleApparent;
  int? _maxRadius;
  int? _currentRadius;
  double? _bearingTrue;
  double? _apparentBearing;
  bool _unlocked = false;
  Offset _startDragOffset = Offset.zero;
  Timer? _lockTimer;
  static final List<ll.LatLng> _positions = [];
  late DateTime _lastPositionTime;

  @override
  void initState() {
    super.initState();
    _lastPositionTime = widget.config.controller.now();

    _settings = _$AnchorAlarmSettingsFromJson(widget.config.controller.getBoxSettingsJson(widget.id));
    widget.config.controller.configure(onUpdate: _onUpdate, paths: {
      'navigation.position',
      'environment.wind.angleApparent',
      'navigation.anchor.*'
    });
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      _maxRadius = 100;
      _currentRadius = 80;
      _bearingTrue = deg2Rad(45);
      _apparentBearing = deg2Rad(45);
      _windAngleApparent = deg2Rad(45);
    }

    Color dropColor = widget.config.controller.val2PSColor(context, 1, none: Colors.grey);
    Color raiseColor = widget.config.controller.val2PSColor(context, -1, none: Colors.grey);

    return Padding(padding: const EdgeInsets.all(5), child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        IconButton(onPressed: _toggleLocked, icon: Icon(_unlocked ? Icons.lock_open : Icons.lock, color: dropColor)),
        IconButton(onPressed: _maxRadius == null ? _drop : null, icon: Icon(Icons.anchor, color: dropColor)),
        IconButton(onPressed: (_currentRadius != null && _maxRadius == null) ? _setMaxRadius : null, icon: Icon(Icons.highlight_off, color: dropColor)),
        IconButton(onPressed: _maxRadius == null ? null : () {_changeRadius(-5);}, icon: Icon(Icons.remove, color: dropColor)),
        IconButton(onPressed: _maxRadius == null ? null : () {_changeRadius(5);}, icon: Icon(Icons.add, color: dropColor)),
        IconButton(onPressed: _unlocked ? _raise : null, icon: Stack(children: [Icon(Icons.anchor, color: raiseColor), Icon(Icons.close, color: raiseColor)])),
      ]),
      if(_currentRadius != null)
        Expanded(child: GestureDetector(onPanDown: _unlocked ? _startDrag : null, onPanEnd: _unlocked ? _stopDrag : null,
          child: ClipRect(
            child: RepaintBoundary(child: CustomPaint(size: Size.infinite,
              painter: _AnchorPainter(
                widget.config.controller,
                context,
                _maxRadius,
                _currentRadius!,
                _bearingTrue,
                _apparentBearing??0,
                _anchorPosition,
                _windAngleApparent,
                _positions
              )
            ))
          )
        ))
    ]));
  }

  void _startDrag(DragDownDetails details) {
    _setLockTimer();
    _startDragOffset = details.localPosition;
  }

  void _stopDrag(DragEndDetails details) {
    _setLockTimer();
    Offset diff = details.localPosition - _startDragOffset;
    double size = m.min(widget.config.constraints.maxWidth,
        widget.config.constraints.maxHeight) / 2;

    double ratio = (_maxRadius??_currentRadius!) / size;

    ll.LatLng newPosition = const ll.Distance().offset(
        _anchorPosition!, diff.distance * ratio,
        rad2Deg(diff.direction + (m.pi / 2)));

    _sendCommand('setAnchorPosition',
        '{"position": {"latitude": ${newPosition.latitude}, "longitude": ${newPosition.longitude}}}');
  }

  void _toggleLocked () {
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

  void _changeRadius(int amount) {
    int newMaxRadius = _maxRadius!+amount;

    if(newMaxRadius > _currentRadius! || amount > 0) {
      _sendCommand('setRadius', '{"radius": $newMaxRadius}');
    }
  }

  void _raise() async {
    if(await widget.config.controller.askToConfirm(context, 'Raise Anchor?', alwaysAsk: true)) {
      await _sendCommand('raiseAnchor', '');
      setState(() {
        _maxRadius = _currentRadius = null;
      });
    }
  }

  Future<void> _sendCommand(String path, String params) async {
    if(widget.config.editMode) {
      return;
    }

    try {
      Uri uri = widget.config.controller.httpApiUri.replace(
          path: '/plugins/anchoralarm/$path');

      http.Response response = await widget.config.controller.httpPost(
          uri,
          headers: {
            "Content-Type": "application/json",
            "accept": "application/json",
            "Authorization": "Bearer ${_settings.authToken}"
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
            if(u.value != null) {
              DateTime now = widget.config.controller.now();
              if(now.difference(_lastPositionTime) >= Duration(seconds: _settings.recordSeconds)) {
                _lastPositionTime = now;

                _positions.add(ll.LatLng(
                    (u.value['latitude'] as num).toDouble(),
                    (u.value['longitude'] as num).toDouble()));

                if (_positions.length > _settings.recordPoints) {
                  _positions.removeRange(0, _settings.recordPoints ~/ 10);
                }
              }
            }
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
                  _maxRadius = (u.value as num).round();
                } catch (_){
                  // This only happens if the Anchor Alarm webapp is used.
                  _maxRadius = int.parse(u.value as String);
                }
              }
            break;
          case 'navigation.anchor.currentRadius':
            if(u.value == null) {
              _currentRadius = null;
            } else {
              _currentRadius = (u.value as num).round();
              // Make sure we have a radius to avoid div-by-zero error.
              _currentRadius = _currentRadius == 0 ? 1 : _currentRadius;
            }
            break;
          case 'navigation.anchor.bearingTrue':
            _bearingTrue = (u.value == null) ? null : (u.value as num).toDouble()-m.pi;
            break;
          case 'navigation.anchor.apparentBearing':
            _apparentBearing = (u.value == null) ? null : (u.value as num).toDouble();
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
    return _$AnchorAlarmSettingsToJson(_settings);
  }
}

class _AnchorAlarmSettingsState extends State<_AnchorAlarmSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _AnchorAlarmSettings s = widget._settings;

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
            }),
        trailing: const Text('sec'),
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
            }),
      ),
      ListTile(
        title: Text('Records for ${(s.recordSeconds*s.recordPoints/60/60).toStringAsFixed(2)} hours'),
      ),
      ListTile(
          leading: const Text("Client ID:"),
          title: TextFormField(
              initialValue: s.clientID,
              onChanged: (value) => s.clientID = value)
      ),
      ListTile(
          leading: const Text("Request Auth Token:"),
          title: IconButton(onPressed: _requestAuthToken, icon: const Icon(Icons.login))
      ),
      ListTile(
          leading: const Text("Auth token:"),
          title: Text(s.authToken)
      ),
    ];

    return ListView(children: list);
  }

  void _requestAuthToken() async {
    SignalKAuthorization(widget._controller).request(widget._settings.clientID, "Boat Instrument - Anchor Alarm",
            (authToken) {
          setState(() {
            widget._settings.authToken = authToken;
          });
        },
            (msg) {
          if (mounted) {
            setState(() {
              widget._settings.authToken = msg;
            });
          }
        });

    setState(() {
      widget._settings.authToken = 'PENDING - keep this page open until request approved';
    });
  }
}
