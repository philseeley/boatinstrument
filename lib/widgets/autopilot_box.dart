import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:slide_to_act/slide_to_act.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';

import '../authorization.dart';

part 'autopilot_box.g.dart';

enum AutopilotState {
  standby('Standby'),
  auto('Auto'),
  route('Track'),
  wind('Vane');

  final String displayName;

  const AutopilotState(this.displayName);
}

@JsonSerializable()
class _Settings extends BoxSettings {
  bool enableLock;
  int lockSeconds;
  String clientID;
  String authToken;

  _Settings({
    this.enableLock = true,
    this.lockSeconds = 3,
    this.clientID = 'boatinstrument-autopilot-1234',//TODO GUID
    this.authToken = ''
  });
}

class AutoPilotControlBox extends BoxWidget {

  final BoatInstrumentController _controller;
  _Settings _editSettings = _Settings();

  AutoPilotControlBox(this._controller, {super.key});

  @override
  State<AutoPilotControlBox> createState() => _AutoPilotControlState();

  static const String sid = 'autopilot-control';
  @override
  String get id => sid;

  @override
  bool get hasSettings => true;

  @override
  Widget getSettingsWidget(Map<String, dynamic> json) {
    _editSettings = _$SettingsFromJson(json);
    return _SettingsWidget(_controller, _editSettings);
  }

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$SettingsToJson(_editSettings);
  }
}

class _AutoPilotControlState extends State<AutoPilotControlBox> {
  _Settings _settings =_Settings();
  bool _locked = true;
  Timer? _lockTimer;

  @override
  void initState() {
    super.initState();
    _settings = _$SettingsFromJson(widget._controller.configure(widget));
  }

  _sendCommand(String path, String params) async {

    if(_settings.enableLock) {
      _unlock();
    }

    try {
      Uri uri = Uri.http(
          widget._controller.signalkServer,
          '/signalk/v1/api/vessels/self/$path');

      http.Response response = await http.put(
          uri,
          headers: {
            "Content-Type": "application/json",
            "accept": "application/json",
            "Authorization": "Bearer ${_settings.authToken}"
          },
          body: params
      );

      if(response.statusCode != 200) {//TODO should be a constant for this
        widget._controller.showMessage(context, response.reasonPhrase ?? '', error: true);
      }
    } catch (e) {
      widget._controller.l.e('Error Sending to WebSocket', error: e);
    }
  }

  _adjustHeading(int direction) async {
    await _sendCommand("steering/autopilot/actions/adjustHeading", '{"value": $direction}');
  }

  _setState(AutopilotState state) async {
    if(await widget._controller.askToConfirm(context, 'Change to "${state.displayName}"?')) {
      print('DONE');
      await _sendCommand("steering/autopilot/state", '{"value": "${state.name}"}');
    }
  }

  _unlock() {
    if(_locked) {
      setState(() {
        _locked = false;
      });
    }

    _lockTimer?.cancel();

    _lockTimer =  Timer(Duration(seconds: _settings.lockSeconds), () {
      setState(() {
        _locked = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    List<Row> controlButtons = [];
    bool disabled = _settings.enableLock && _locked;

    for(int i in [1, 10]) {
      controlButtons.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //TODO button beep
          IconButton(iconSize: 48, onPressed: disabled ? null : () {_adjustHeading(-i);}, icon: const Icon(Icons.chevron_left)),
          Text("$i", style: Theme.of(context).textTheme.titleLarge),
          IconButton(iconSize: 48, onPressed: disabled ? null : () {_adjustHeading(i);}, icon: const Icon(Icons.chevron_right)),
        ]
      ));
    }

    List<Widget> stateButtons = [];
    for(AutopilotState state in AutopilotState.values) {
      stateButtons.add(ElevatedButton(
          onPressed: disabled ? null : () {_setState(state);},
          child: Text(state.displayName),
      ));
    }
    controlButtons.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: stateButtons));
    //TODO would a separate Lock slider for state and numbered/adjusting buttons be better?
    //TODO Or separate these into two Boxes, but then how would the settings work??
    List<Widget> buttons = [Column(children: controlButtons)];
    if(_settings.enableLock && _locked) {
      buttons.add(Center(child: Padding(padding: const EdgeInsets.all(20),child: SlideAction(
        text: "Unlock",
        outerColor: Colors.black,
        onSubmit: () { return _unlock();},
      ))));
    }

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [Stack(alignment: Alignment.center, children:  buttons)]);
  }
}

class _SettingsWidget extends StatefulWidget {
  final BoatInstrumentController _controller;
  final _Settings _settings;

  const _SettingsWidget(this._controller, this._settings);

  @override
  createState() => _SettingsState();
}

class _SettingsState extends State<_SettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _Settings s = widget._settings;

    List<Widget> list = [
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
            max: 20.0,
            divisions: 18,
            value: s.lockSeconds.toDouble(),
            label: "${s.lockSeconds.toInt()}s",
            onChanged: (double value) {
              setState(() {
                s.lockSeconds = value.toInt();
              });
            }),
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
    SignalKAuthorization(widget._controller).request(widget._settings.clientID, "Boat Instrument - Autopilot Control",
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

class AutoPilotStatusBox extends BoxWidget {
  static const String sid = 'autopilot-display';

  final BoatInstrumentController controller;

  const AutoPilotStatusBox(this.controller, {super.key});

  @override
  State<AutoPilotStatusBox> createState() => _AutoPilotDisplayState();

  @override
  String get id => sid;
}

class _AutoPilotDisplayState extends State<AutoPilotStatusBox> {
  AutopilotState? _autopilotState;
  double? _courseOverGroundTrue;
  double? _targetWindAngleApparent;
  double? _windAngleApparent;
  double? _targetHeadingMagnetic;
  double? _magneticVariation;
  String? _waypoint;
  double? _crossTrackError;
  double? _rudderAngle;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.controller.configure(widget, onUpdate: _processData, paths: {
      "steering.autopilot.state",
      "navigation.courseOverGroundTrue",
      "steering.autopilot.target.windAngleApparent",
      "environment.wind.angleApparent",
      "navigation.currentRoute.waypoints",
      "navigation.courseGreatCircle.crossTrackError",
      "steering.autopilot.target.headingMagnetic",
      "navigation.magneticVariation",
      "steering.rudderAngle",
    });
  }

  @override
  Widget build(BuildContext context) {
    BoatInstrumentController c = widget.controller;
    TextStyle s = widget.controller.headTS; //TODO we should be able to set the font size for the whole widget using a Theme.

    List<Widget> pilot = [
      Text("Pilot", style: s),
      Text("State: ${_autopilotState?.displayName ?? 'No State'}", style: s),
    ];

    switch(_autopilotState) {
      case null:
      case AutopilotState.standby:
        break;
      case AutopilotState.auto:
        if(_targetHeadingMagnetic != null &&
            _magneticVariation != null) {
          double headingTrue = _targetHeadingMagnetic! + _magneticVariation!;
          pilot.add(Text("HDG: ${rad2Deg(headingTrue)}", style: s));
        }
        break;
      case AutopilotState.route:
        pilot.add(Text("WPT: $_waypoint", style: s));
        break;
      case AutopilotState.wind:
        int targetWindAngleApparent = rad2Deg(_targetWindAngleApparent);
        pilot.add(Text("AWA: ${targetWindAngleApparent.abs()} ${val2PS(targetWindAngleApparent)}", style: s));
        break;
    }

    List<Widget> actual = [
      Text("Actual", style: s),
      Text("COG: ${_courseOverGroundTrue == null ? '' : rad2Deg(_courseOverGroundTrue)}", style: s),
      Text("AWA: ${_windAngleApparent == null ? '' : rad2Deg(_windAngleApparent!.abs())} ${val2PS(_windAngleApparent??0)}", style: s),
    ];

    if((_autopilotState??AutopilotState.standby) == AutopilotState.route) {
      if(_crossTrackError != null) {
        actual.add(Text("XTE: ${meters2NM(_crossTrackError!.abs()).toStringAsFixed(2)} ${val2PS(_crossTrackError!)}", style: s));
      }
    }

    const rudderStr = '===================='; // 40 degrees
    double rudderAngle = _rudderAngle??0;
    int rudderAngleLen = rad2Deg(rudderAngle.abs());
    rudderAngleLen = ((rudderAngleLen.toDouble()/40.0)*rudderStr.length).toInt();

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: pilot),
        Column(children: actual)
      ]),
      Row(children: [
        Expanded(child: Text(rudderStr.substring(0, rudderAngle < 0 ? rudderAngleLen : 0), style: c.headTS.apply(color: Colors.red), textAlign: TextAlign.right)),
        Expanded(child: Text(rudderStr.substring(0, rudderAngle > 0 ? rudderAngleLen : 0), style: c.headTS.apply(color: Colors.green))),
      ]),
      Text(_error??'', style: c.headTS.apply(color: Colors.red))
    ]);
  }

  _processData(List<Update> updates) {
    for (Update u in updates) {
      try {
        switch (u.path) {
          case 'steering.autopilot.state':
            _autopilotState = AutopilotState.values.byName(u.value);
            break;
          case 'navigation.courseOverGroundTrue':
            double cogLatest = (u.value as num).toDouble();
            _courseOverGroundTrue = averageAngle(
                _courseOverGroundTrue ?? cogLatest, cogLatest,
                smooth: widget.controller.valueSmoothing);
            break;
          case 'steering.autopilot.target.windAngleApparent':
            _targetWindAngleApparent = (u.value as num).toDouble();
            break;
          case 'environment.wind.angleApparent':
            double waa = (u.value as num).toDouble();
            _windAngleApparent = averageAngle(
                _windAngleApparent ?? waa, waa,
                smooth: widget.controller.valueSmoothing, relative: true);
            break;
          case 'navigation.currentRoute.waypoints':
            _waypoint = u.value[1]['name'];
            break;
          case 'navigation.courseGreatCircle.crossTrackError':
            _crossTrackError = (u.value as num).toDouble();
            break;
          case 'steering.autopilot.target.headingMagnetic':
            _targetHeadingMagnetic = (u.value as num).toDouble();
            break;
          case 'navigation.magneticVariation':
            _magneticVariation = (u.value as num).toDouble();
            break;
          case 'steering.rudderAngle':
            _rudderAngle = (u.value as num).toDouble();
            break;
          case 'notifications.autopilot.*':
          //TODO
            break;
        }
      } catch (e) {
        widget.controller.l.e("Error converting $u", error: e);
      }
    }

    if(mounted) {
      setState(() {});
    }
  }
}
