import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nanoid/nanoid.dart';
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
class _Settings {
  bool enableLock;
  int lockSeconds;
  String clientID;
  String authToken;

  _Settings({
    this.enableLock = true,
    this.lockSeconds = 3,
    clientID,
    this.authToken = ''
  }) : clientID = clientID??'boatinstrument-autopilot-${customAlphabet('0123456789', 4)}';
}

class AutoPilotControlBox extends BoxWidget {

  const AutoPilotControlBox(super.config, {super.key});

  @override
  State<AutoPilotControlBox> createState() => _AutoPilotControlState();

  static const String sid = 'autopilot-control';
  @override
  String get id => sid;

  @override
  bool get hasSettings => true;

  @override
  BoxSettingsWidget getSettingsWidget(Map<String, dynamic> json) {
    return _SettingsWidget(super.config.controller, _$SettingsFromJson(json));
  }

  @override
  Widget? getSettingsHelp() {
    return const Text('''Ensure the signalk-autopilot plugin is installed on signalk.
To be able to control the autopilot, the device must be given read/write permission to signalk. Request an Auth Token and without closing the settings page authorise the device in the signalk web interface. When the Auth Token is shown, the settings page can be closed.
The Client ID can be set to reflect the instrument's location, e.g. "boatinstrument-autopilot-helm". Or the ID can be set to the same value for all instruments to share the same authorisation.''');
  }
}

class _AutoPilotControlState extends State<AutoPilotControlBox> {
  _Settings _settings = _Settings();
  bool _locked = true;
  Timer? _lockTimer;

  @override
  void initState() {
    super.initState();
    _settings = _$SettingsFromJson(widget.config.controller.configure(widget));
  }

  _sendCommand(String path, String params) async {

    if(_settings.enableLock) {
      _unlock();
    }

    try {
      Uri uri = Uri.http(
          widget.config.controller.signalkServer,
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

      if(response.statusCode != HttpStatus.ok) {
        if(mounted) {
          widget.config.controller.showMessage(context, response.reasonPhrase ?? '', error: true);
        }
      }
    } catch (e) {
      widget.config.controller.l.e('Error Sending to WebSocket', error: e);
    }
  }

  _adjustHeading(int direction) async {
    await _sendCommand("steering/autopilot/actions/adjustHeading", '{"value": $direction}');
  }

  _autoTack(String direction) async {
    if(await widget.config.controller.askToConfirm(context, 'Tack to "$direction"?')) {
      await _sendCommand("steering/autopilot/actions/tack", '{"value": "$direction"}');
    }
  }

  _setState(AutopilotState state) async {
    if(await widget.config.controller.askToConfirm(context, 'Change to "${state.displayName}"?')) {
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

    controlButtons.add(const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Tack'),
          Text(' 10  '),
          Text(' 1  '),
          Text('  1 '),
          Text('  10 '),
          Text('Tack'),
        ]
    ));
    //TODO Button beep
    controlButtons.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(iconSize: 48, onPressed: disabled ? null : () {_autoTack('port');}, icon: const Icon(Icons.fast_rewind)),
          IconButton(iconSize: 48, onPressed: disabled ? null : () {_adjustHeading(-10);}, icon: const Icon(Icons.keyboard_double_arrow_left)),
          IconButton(iconSize: 48, onPressed: disabled ? null : () {_adjustHeading(-1);}, icon: const Icon(Icons.keyboard_arrow_left)),
          IconButton(iconSize: 48, onPressed: disabled ? null : () {_adjustHeading(1);}, icon: const Icon(Icons.keyboard_arrow_right)),
          IconButton(iconSize: 48, onPressed: disabled ? null : () {_adjustHeading(10);}, icon: const Icon(Icons.keyboard_double_arrow_right)),
          IconButton(iconSize: 48, onPressed: disabled ? null : () {_autoTack('starboard');}, icon: const Icon(Icons.fast_forward)),
        ]
    ));
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
        outerColor: Colors.grey,
        onSubmit: () { return _unlock();},
      ))));
    }

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [Stack(alignment: Alignment.center, children:  buttons)]);
  }
}

class _SettingsWidget extends BoxSettingsWidget {
  final BoatInstrumentController _controller;
  final _Settings _settings;

  const _SettingsWidget(this._controller, this._settings);

  @override
  createState() => _SettingsState();

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$SettingsToJson(_settings);
  }
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
            max: 60.0,
            divisions: 58,
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

  const AutoPilotStatusBox(super.config, {super.key});

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
  double? _targetHeadingTrue;
  double? _targetHeadingMagnetic;
  double? _magneticVariation;
  String? _waypoint;
  double? _crossTrackError;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(widget, onUpdate: _processData, paths: {
      "steering.autopilot.state",
      "navigation.courseOverGroundTrue",
      "steering.autopilot.target.windAngleApparent",
      "environment.wind.angleApparent",
      "navigation.currentRoute.waypoints",
      "navigation.courseGreatCircle.crossTrackError",
      "steering.autopilot.target.headingTrue",
      "steering.autopilot.target.headingMagnetic",
      "navigation.magneticVariation",
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle s = const TextStyle(fontSize: 20);

    List<Widget> pilot = [
      Text("Pilot", style: s),
      Text("State: ${_autopilotState?.displayName ?? 'No State'}", style: s),
    ];

    switch(_autopilotState) {
      case null:
      case AutopilotState.standby:
        break;
      case AutopilotState.auto:
        double? headingTrue = _targetHeadingTrue;
        if(headingTrue == null && (_targetHeadingMagnetic != null &&
            _magneticVariation != null)) {
          headingTrue = _targetHeadingMagnetic! + _magneticVariation!;
        }
        if(headingTrue != null) {
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
        actual.add(Text("XTE: ${convertDistance(widget.config.controller, _crossTrackError!.abs()).toStringAsFixed(2)}${distanceUnits(widget.config.controller, _crossTrackError!)} ${val2PS(_crossTrackError!)}", style: s));
      }
    }

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: pilot),
        Column(children: actual)
      ]),
    ]);
  }

  _processData(List<Update>? updates) {
    if(updates == null) {
      _autopilotState = null;
    } else {
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
                  smooth: widget.config.controller.valueSmoothing);
              break;
            case 'steering.autopilot.target.windAngleApparent':
              _targetWindAngleApparent = (u.value as num).toDouble();
              break;
            case 'environment.wind.angleApparent':
              double waa = (u.value as num).toDouble();
              _windAngleApparent = averageAngle(
                  _windAngleApparent ?? waa, waa,
                  smooth: widget.config.controller.valueSmoothing,
                  relative: true);
              break;
            case 'navigation.currentRoute.waypoints':
              _waypoint = u.value[1]['name'];
              break;
            case 'navigation.courseGreatCircle.crossTrackError':
              _crossTrackError = (u.value as num).toDouble();
              break;
            case 'steering.autopilot.target.headingTrue':
              _targetHeadingTrue = (u.value as num).toDouble();
              break;
            case 'steering.autopilot.target.headingMagnetic':
              _targetHeadingMagnetic = (u.value as num).toDouble();
              break;
            case 'navigation.magneticVariation':
              _magneticVariation = (u.value as num).toDouble();
              break;
            case 'notifications.autopilot.*': //TODO this this need to be a regex or something.
              widget.config.controller.showMessage(
                  context, u.value, error: true);
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
