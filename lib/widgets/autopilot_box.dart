import 'dart:async';
import 'dart:io';
import 'dart:math' as m;

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
class _AutopilotControlSettings {
  String clientID;
  String authToken;

  _AutopilotControlSettings({
    String? clientID,
    this.authToken = ''
  }) : clientID = clientID??'boatinstrument-autopilot-${customAlphabet('0123456789', 4)}';
}

@JsonSerializable()
class _AutopilotControlPerBoxSettings {
  bool enableLock;
  int lockSeconds;
  bool showLabels;

  _AutopilotControlPerBoxSettings({
    this.enableLock = true,
    this.lockSeconds = 5,
    this.showLabels = true
  });
}

abstract class AutopilotControlBox extends BoxWidget {
  late final _AutopilotControlPerBoxSettings _perBoxSettings;

  static const String sid = 'autopilot-control';
  @override
  String get id => sid;

  AutopilotControlBox(super.config, {super.key}) {
    _perBoxSettings = _$AutopilotControlPerBoxSettingsFromJson(config.settings);
  }

  @override
  bool get hasSettings => true;

  @override
  BoxSettingsWidget getSettingsWidget(Map<String, dynamic> json) {
    return _AutopilotControlSettingsWidget(super.config.controller, _$AutopilotControlSettingsFromJson(json));
  }

  @override
  Widget? getSettingsHelp() => const HelpPage(text: '''Ensure the **signalk-autopilot** plugin is installed on signalk.
To be able to control the autopilot, the device must be given "read/write" permission to signalk. Request an **Auth Token** and without closing the settings page authorise the device in the signalk web interface. When the **Auth Token** is shown, the settings page can be closed.
The Client ID can be set to reflect the instrument's location, e.g. "boatinstrument-autopilot-helm". Or the ID can be set to the same value for all instruments to share the same authorisation.''');

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _AutopilotControlPerBoxSettingsWidget(_perBoxSettings);
  }
}

abstract class AutopilotControlBoxState<T extends AutopilotControlBox> extends State<T> {
  _AutopilotControlSettings _settings = _AutopilotControlSettings();
  bool _locked = true;
  Timer? _lockTimer;

  @override
  void initState() {
    super.initState();
    _settings = _$AutopilotControlSettingsFromJson(widget.config.controller.getBoxSettingsJson(widget.id));
    widget.config.controller.configure();
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _sendCommand(String path, String params) async {

    if(widget.config.editMode) {
      return;
    }

    if(widget._perBoxSettings.enableLock) {
      _unlock();
    }

    try {
      Uri uri = widget.config.controller.httpApiUri.replace(
          path: '${widget.config.controller.httpApiUri.path}vessels/self/$path');

      http.Response response = await widget.config.controller.httpPut(
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

  Future<void> _unlock() async {
    if(_locked) {
      setState(() {
        _locked = false;
      });
    }

    _lockTimer?.cancel();

    _lockTimer =  Timer(Duration(seconds: widget._perBoxSettings.lockSeconds), () {
      if(mounted) {
        setState(() {
          _locked = true;
        });
      }
    });
  }
}

abstract class AutopilotStateControlBox extends AutopilotControlBox {
  final bool vertical;

  AutopilotStateControlBox(super.config, this.vertical, {super.key});

  @override
  AutopilotControlBoxState<AutopilotStateControlBox> createState() => _AutopilotStateControlBoxState();
}

class _AutopilotStateControlBoxState extends AutopilotControlBoxState<AutopilotStateControlBox> {

  Future<void> _setState(AutopilotState state) async {
    if(await widget.config.controller.askToConfirm(context, 'Change to "${state.displayName}"?')) {
      await _sendCommand("steering/autopilot/state", '{"value": "${state.name}"}');
    }
  }

  @override
  Widget build(BuildContext context) {

    bool disabled = widget._perBoxSettings.enableLock && _locked;

    List<Widget> stateButtons = [];
    for(AutopilotState state in AutopilotState.values) {
      Color fc = Theme.of(context).colorScheme.onSurface;
      Color bc = widget.config.controller.val2PSColor(context, state == AutopilotState.standby?-1:1, none: Colors.grey);
      stateButtons.add(ElevatedButton(style: ElevatedButton.styleFrom(foregroundColor: fc, backgroundColor: bc),
        onPressed: disabled ? null : () {_setState(state);},
        child: Text(widget._perBoxSettings.showLabels ? state.displayName : state.displayName.substring(0, 1)),
      ));
    }

    List<Widget> buttons = [];
    if(widget.vertical) {
      buttons.add(Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: stateButtons));
    } else {
      buttons.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: stateButtons));
    }

    if(disabled) {
      buttons.add(Center(child: Padding(padding: const EdgeInsets.only(left: 20, right: 20),child: SlideAction(
        text: "Unlock",
        outerColor: Colors.grey,
        onSubmit: () { return _unlock();},
      ))));
    }

    return Stack(alignment: Alignment.center, children: buttons);
  }
}

class AutopilotStateControlHorizontalBox extends AutopilotStateControlBox {

  static const String sid = 'autopilot-control-state-horizontal';

  AutopilotStateControlHorizontalBox(BoxWidgetConfig config, {super.key}) : super(config, false);
}

class AutopilotStateControlVerticalBox extends AutopilotStateControlBox {

  static const String sid = 'autopilot-control-state-vertical';

  AutopilotStateControlVerticalBox(BoxWidgetConfig config, {super.key}) : super(config, true);
}

abstract class AutopilotHeadingControlBox extends AutopilotControlBox {

  AutopilotHeadingControlBox(super.config, {super.key});
}

abstract class _AutopilotHeadingControlBoxState<T extends AutopilotHeadingControlBox> extends AutopilotControlBoxState<T> {

  Future<void> _adjustHeading(int direction) async {
    await _sendCommand("steering/autopilot/actions/adjustHeading", '{"value": $direction}');
  }

  Future<void> _autoTack(String direction) async {
    if(await widget.config.controller.askToConfirm(context, 'Tack to "$direction"?')) {
      await _sendCommand("steering/autopilot/actions/tack", '{"value": "$direction"}');
    }
  }
}

class AutopilotHeadingControlHorizontalBox extends AutopilotHeadingControlBox {
  AutopilotHeadingControlHorizontalBox(super.config, {super.key});

  @override
  AutopilotControlBoxState<AutopilotHeadingControlHorizontalBox> createState() => _AutopilotHeadingControlHorizontalBoxState();

  static const String sid = 'autopilot-control-heading-horizontal';
}

class _AutopilotHeadingControlHorizontalBoxState extends _AutopilotHeadingControlBoxState<AutopilotHeadingControlHorizontalBox> {

  @override
  Widget build(BuildContext context) {

    bool disabled = widget._perBoxSettings.enableLock && _locked;
    List<Row> controlButtons = [];

    if(widget._perBoxSettings.showLabels) {
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
    }

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

    List<Widget> buttons = [Column(children: controlButtons)];
    if(disabled) {
      buttons.add(Center(child: Padding(padding: const EdgeInsets.only(left: 20, right: 20),child: SlideAction(
        text: "Unlock",
        outerColor: Colors.grey,
        onSubmit: () { return _unlock();},
      ))));
    }

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [Stack(alignment: Alignment.center, children:  buttons)]);
  }
}

class AutopilotHeadingControlVerticalBox extends AutopilotHeadingControlBox {
  AutopilotHeadingControlVerticalBox(super.config, {super.key});

  @override
  AutopilotControlBoxState<AutopilotHeadingControlVerticalBox> createState() => _AutopilotHeadingControlVerticalBoxState();

  static const String sid = 'autopilot-control-heading-vertical';
}

class _AutopilotHeadingControlVerticalBoxState extends _AutopilotHeadingControlBoxState<AutopilotHeadingControlVerticalBox> {

  @override
  Widget build(BuildContext context) {

    bool disabled = widget._perBoxSettings.enableLock && _locked;
    List<Row> controlButtons = [];

    controlButtons.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      IconButton(iconSize: 48, onPressed: disabled ? null : () {_adjustHeading(-1);}, icon: const Icon(Icons.keyboard_arrow_left)),
      Text(widget._perBoxSettings.showLabels ? '1' : ''),
      IconButton(iconSize: 48, onPressed: disabled ? null : () {_adjustHeading(1);}, icon: const Icon(Icons.keyboard_arrow_right))
    ]));
    controlButtons.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      IconButton(iconSize: 48, onPressed: disabled ? null : () {_adjustHeading(-10);}, icon: const Icon(Icons.keyboard_double_arrow_left)),
      Text(widget._perBoxSettings.showLabels ? '10' : ''),
      IconButton(iconSize: 48, onPressed: disabled ? null : () {_adjustHeading(10);}, icon: const Icon(Icons.keyboard_double_arrow_right))
    ]));
    controlButtons.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      IconButton(iconSize: 48, onPressed: disabled ? null : () {_autoTack('port');}, icon: const Icon(Icons.fast_rewind)),
      Text(widget._perBoxSettings.showLabels ? 'Tack' : ''),
      IconButton(iconSize: 48, onPressed: disabled ? null : () {_autoTack('starboard');}, icon: const Icon(Icons.fast_forward))
    ]));

    List<Widget> buttons = [Column(children: controlButtons)];
    if(disabled) {
      buttons.add(Center(child: Padding(padding: const EdgeInsets.only(left: 20, right: 20),child: SlideAction(
        text: "Unlock",
        outerColor: Colors.grey,
        onSubmit: () { return _unlock();},
      ))));
    }

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [Stack(alignment: Alignment.center, children:  buttons)]);
  }
}

class _AutopilotControlSettingsWidget extends BoxSettingsWidget {
  final BoatInstrumentController _controller;
  final _AutopilotControlSettings _settings;

  const _AutopilotControlSettingsWidget(this._controller, this._settings);

  @override
  createState() => _AutopilotControlSettingsState();

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$AutopilotControlSettingsToJson(_settings);
  }
}

class _AutopilotControlSettingsState extends State<_AutopilotControlSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _AutopilotControlSettings s = widget._settings;

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
          leading: const Text("Auth Token:"),
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

class _AutopilotControlPerBoxSettingsWidget extends BoxSettingsWidget {
  final _AutopilotControlPerBoxSettings _settings;

  const _AutopilotControlPerBoxSettingsWidget(this._settings);

  @override
  createState() => _AutopilotControlPerBoxSettingsState();

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$AutopilotControlPerBoxSettingsToJson(_settings);
  }
}

class _AutopilotControlPerBoxSettingsState extends State<_AutopilotControlPerBoxSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _AutopilotControlPerBoxSettings s = widget._settings;

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
      SwitchListTile(title: const Text("Show Labels:"),
          value: s.showLabels,
          onChanged: (bool value) {
            setState(() {
              s.showLabels = value;
            });
          }),
    ];

    return ListView(children: list);
  }
}

class AutopilotStatusBox extends BoxWidget {
  static const String sid = 'autopilot-status';

  const AutopilotStatusBox(super.config, {super.key});

  @override
  State<AutopilotStatusBox> createState() => _AutopilotStatusState();

  @override
  String get id => sid;
}

class _AutopilotStatusState extends HeadedBoxState<AutopilotStatusBox> {
  AutopilotState? _autopilotState;
  double? _targetWindAngleApparent;
  double? _targetHeadingTrue;
  double? _targetHeadingMagnetic;
  double? _magneticVariation;
  String? _waypoint;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(onUpdate: _processData, paths: {
      "steering.autopilot.state",
      "steering.autopilot.target.windAngleApparent",
      "navigation.currentRoute.waypoints",
      "steering.autopilot.target.headingTrue",
      "steering.autopilot.target.headingMagnetic",
      "navigation.magneticVariation",
    });
  }

  @override
  Widget build(BuildContext context) {
    color = null;
    String target = '';
    switch(_autopilotState) {
      case null:
        break;
      case AutopilotState.standby:
        color = Colors.red;
        break;
      case AutopilotState.auto:
        double? headingTrue = _targetHeadingTrue;
        if(headingTrue == null && (_targetHeadingMagnetic != null &&
            _magneticVariation != null)) {
          headingTrue = (_targetHeadingMagnetic! + _magneticVariation!) % (m.pi*2);
        }
        if(headingTrue != null) {
          target = 'HDG: ${rad2Deg(headingTrue)}';
        }
        break;
      case AutopilotState.route:
        target = 'WPT: $_waypoint';
        break;
      case AutopilotState.wind:
        int targetWindAngleApparent = rad2Deg(_targetWindAngleApparent);
        target = 'AWA: ${targetWindAngleApparent.abs()} ${val2PS(targetWindAngleApparent)}';
        break;
    }

    header = 'Autopilot';
    text = '${_autopilotState?.displayName ?? '-'}\n$target';

    return super.build(context);
  }

  void _processData(List<Update> updates) {
    for (Update u in updates) {
      try {
        switch (u.path) {
          case 'steering.autopilot.state':
            _autopilotState = (u.value == null) ? null : AutopilotState.values.byName(u.value);
            break;
          case 'steering.autopilot.target.windAngleApparent':
            _targetWindAngleApparent = (u.value == null) ? null : (u.value as num).toDouble();
            break;
          case 'navigation.currentRoute.waypoints':
            _waypoint = (u.value == null) ? null : u.value[1]['name'];
            break;
          case 'steering.autopilot.target.headingTrue':
            _targetHeadingTrue = (u.value == null) ? null : (u.value as num).toDouble();
            break;
          case 'steering.autopilot.target.headingMagnetic':
            _targetHeadingMagnetic = (u.value == null) ? null : (u.value as num).toDouble();
            break;
          case 'navigation.magneticVariation':
            _magneticVariation = (u.value == null) ? null : (u.value as num).toDouble();
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
