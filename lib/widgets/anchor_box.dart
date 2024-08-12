import 'dart:io';
import 'dart:math' as m;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:nanoid/nanoid.dart';

import '../authorization.dart';
import '../boatinstrument_controller.dart';

part 'anchor_box.g.dart';

@JsonSerializable()
class _AnchorAlarmSettings {
  String clientID;
  String authToken;

  _AnchorAlarmSettings({
    clientID,
    this.authToken = ''
  }) : clientID = clientID??'boatinstrument-anchor-alarm-${customAlphabet('0123456789', 4)}';
}

class _AnchorPainter extends CustomPainter {
  final BuildContext _context;
  final BoatInstrumentController _controller;
  final int _maxRadius;
  final int _currentRadius;
  final double? _bearingTrue;
  final double _apparentBearing;

  const _AnchorPainter(this._controller, this._context, this._maxRadius, this._currentRadius, this._bearingTrue, this._apparentBearing);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    Color maxColor = _controller.val2PSColor(_context, -1, none: Colors.grey);
    Color currentColor = _controller.val2PSColor(_context, 1, none: Colors.grey);
    TextStyle th = Theme.of(_context).textTheme.bodyMedium!;

    double size = m.min(canvasSize.width, canvasSize.height) /2;

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = maxColor
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(size, size), size, paint);

    double ratio = (_currentRadius/_maxRadius)*size;

    paint.color = currentColor;
    canvas.drawCircle(Offset(size, size), ratio, paint);

    TextPainter tp = TextPainter(textDirection: TextDirection.ltr);

    if(_bearingTrue != null) {
      canvas.save();
      canvas.translate(size, size);
      IconData icon = Icons.anchor;
      tp.text = TextSpan(text: String.fromCharCode(icon.codePoint),
          style: TextStyle(fontSize: 30,
              fontFamily: icon.fontFamily,
              color: currentColor));
      tp.layout();
      tp.paint(canvas, Offset(-tp.size.width / 2, -tp.size.height / 2));
      canvas.rotate(_bearingTrue! - m.pi);
      canvas.translate(0, ratio);
      canvas.rotate((m.pi/2) - _apparentBearing);
      icon = Icons.backspace_outlined;
      tp.text = TextSpan(text: String.fromCharCode(icon.codePoint),
          style: TextStyle(fontSize: 30,
              fontFamily: icon.fontFamily,
              color: currentColor));
      tp.layout();
      tp.paint(canvas, Offset(-tp.size.width / 2, -tp.size.height / 2));
      canvas.restore();
    }

    tp.text = TextSpan(text: _maxRadius.toString(), style: th.copyWith(backgroundColor: maxColor));
    tp.layout();
    tp.paint(canvas, Offset((size*2)-tp.size.width, size-tp.size.height/2));
    tp.text = TextSpan(text: _currentRadius.toString(), style: th.copyWith(backgroundColor: currentColor));
    tp.layout();
    tp.paint(canvas, Offset(size-ratio, size-tp.size.height/2));
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
  Widget? getSettingsHelp() {//TODO
    return const Text('''Ensure the signalk-anchoralarm-plugin plugin is installed and configured on signalk.
To be able to set the Anchor Alarm, the device must be given admin permission to signalk. Request an Auth Token and without closing the settings page authorise the device in the signalk web interface. When the Auth Token is shown, the settings page can be closed.
The Client ID can be set to reflect the instrument's location, e.g. "boatinstrument-anchor-alarm-helm". Or the ID can be set to the same value for all instruments to share the same authorisation.''');
  }

  @override
  State<StatefulWidget> createState() => _AnchorState();
}

class _AnchorState extends State<AnchorAlarmBox> {
  static const emergencyState = 'emergency';

  late final _AnchorAlarmSettings _settings;
  int? _maxRadius;
  int? _currentRadius;
  double? _bearingTrue;
  double? _apparentBearing;
  bool _silenceAlarm = false;
  AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _settings = _$AnchorAlarmSettingsFromJson(widget.config.controller.getBoxSettingsJson(widget.id));
    widget.config.controller.configure(_onUpdate, [
      'navigation.anchor.*',
      'notifications.navigation.anchor']);
    player.setSource(AssetSource('alarm.wav'));
  }

  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      _maxRadius = 100;
      _currentRadius = 80;
      _bearingTrue = deg2Rad(45);
      _apparentBearing = deg2Rad(45);
    }

    Color dropColor = widget.config.controller.val2PSColor(context, 1, none: Colors.grey);
    Color raiseColor = widget.config.controller.val2PSColor(context, -1, none: Colors.grey);

    List<Widget> col = [
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        IconButton(onPressed: _toggleAlarm, icon: Icon(_silenceAlarm ? Icons.notifications_off_outlined : Icons.notifications_outlined, color: dropColor)),
        IconButton(onPressed: _drop, icon: Icon(Icons.keyboard_double_arrow_down, color: dropColor)),
        IconButton(onPressed: _setRadius, icon: Icon(Icons.circle_outlined, color: dropColor)),
        IconButton(onPressed: () {_changeRadius(-5);}, icon: Icon(Icons.remove, color: dropColor)),
        IconButton(onPressed: () {_changeRadius(5);}, icon: Icon(Icons.add, color: dropColor)),
        IconButton(onPressed: _raise, icon: Icon(Icons.keyboard_double_arrow_up, color: raiseColor)),
      ]),
    ];

    if(_maxRadius != null && _currentRadius != null) {
      col.add(Expanded(
          child: RepaintBoundary(child: CustomPaint(size: Size.infinite,
              painter: _AnchorPainter(widget.config.controller, context, _maxRadius!, _currentRadius!, _bearingTrue, _apparentBearing??0)))),
      );
    }
    return Padding(padding: const EdgeInsets.all(5), child: Column(children: col));
  }

  void _toggleAlarm () {
    setState(() {
      _silenceAlarm = !_silenceAlarm;
    });
    if(_silenceAlarm) {
      player.stop();
    }
  }
  void _drop() {
    _sendCommand('dropAnchor', '');
  }

  void _setRadius() {
    _sendCommand('setRadius', '');
  }

  void _changeRadius(int amount) {
    _sendCommand('setRadius', '{"radius": ${(_maxRadius??0)+amount}}');
  }

  void _raise() async {
    if(await widget.config.controller.askToConfirm(context, 'Raise Anchor?', alwaysAsk: true)) {
      await _sendCommand('raiseAnchor', '');
      setState(() {
        _maxRadius = _currentRadius = null;
      });
    }
  }

  _sendCommand(String path, String params) async {
    if(widget.config.editMode) {
      return;
    }

    try {
      Uri uri = widget.config.controller.httpApiUri.replace(
          path: '/plugins/anchoralarm/$path');

      http.Response response = await http.post(
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
      widget.config.controller.l.e('Error Sending to WebSocket', error: e);
    }
  }

  void _alarm(String state, bool emergency) {
    if (!_silenceAlarm || !emergency) {
      if (emergency) {
        player.resume();
      } else {
        player.stop();
      }
      widget.config.controller.showMessage(context,
          'Anchor: $state',
          millisecondsDuration: emergency ? 500 : 4000,
          error: emergency);
    }
  }

  void _onUpdate(List<Update>? updates) {
    if(updates == null) {
      _maxRadius = _currentRadius = _bearingTrue = _apparentBearing = null;
    } else {
      for (Update u in updates) {
        try {
          switch (u.path) {
            case 'navigation.anchor.maxRadius':
              try {
                _maxRadius = (u.value as num).toInt();
              } catch (_){
                //TODO this only happens if the Anchor Alarm webapp is used.
                _maxRadius = int.parse(u.value as String);
              }
              break;
            case 'navigation.anchor.currentRadius':
              _currentRadius = (u.value as num).toInt();
              break;
            case 'navigation.anchor.bearingTrue':
              _bearingTrue = (u.value as num).toDouble()-m.pi;
              break;
            case 'navigation.anchor.apparentBearing':
              _apparentBearing = (u.value as num).toDouble();
              break;
            case 'notifications.navigation.anchor':
              String state = u.value['state'];
              _alarm(state, state == emergencyState);
              break;
          }
        } catch (e) {
          widget.config.controller.l.e("Error converting $u", error: e);
        }
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
