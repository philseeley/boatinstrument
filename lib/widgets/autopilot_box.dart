import 'dart:async';
import 'dart:io';
import 'dart:math' as m;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:slide_to_act/slide_to_act.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';

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
  Widget? getHelp() => const HelpPage(text: 'Ensure the **signalk-autopilot** plugin is installed on SignalK. To be able to control the autopilot, the device must be given "read/write" permission to SignalK.');

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _AutopilotControlPerBoxSettingsWidget(_perBoxSettings);
  }
}

abstract class AutopilotControlBoxState<T extends AutopilotControlBox> extends State<T> {
  bool _locked = true;
  Timer? _lockTimer;

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
            "accept": "application/json"
          },
          body: params
      );

      if(![HttpStatus.ok, HttpStatus.accepted].contains(response.statusCode)) {
        if(mounted) {
          widget.config.controller.showMessage(context, response.reasonPhrase ?? '', error: true);
        }
      }
    } catch (e) {
      widget.config.controller.l.e('Error Sending to WebSocket', error: e);
    }
  }

  Future<void> _adjustHeading(int direction) async {
    await _sendCommand("steering/autopilot/actions/adjustHeading", '{"value": $direction}');
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

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure();
  }

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

@JsonSerializable()
class _AutopilotReefingSettings {
  int upwindAngle;
  int downwindAngle;

  _AutopilotReefingSettings({
    this.upwindAngle = 50,
    this.downwindAngle = 120
  });
}

abstract class AutopilotReefingControlBox extends AutopilotControlBox {
  final bool vertical;

  static const String sid = 'autopilot-control-reefing';
  @override
  String get id => sid;

  AutopilotReefingControlBox(super.config, this.vertical, {super.key});

  @override
  bool get hasSettings => true;

  @override
  BoxSettingsWidget? getSettingsWidget(Map<String, dynamic> json) => _AutopilotReefingBoxSettingsWidget(_$AutopilotReefingSettingsFromJson(json));

  @override
  AutopilotControlBoxState<AutopilotReefingControlBox> createState() => _AutopilotReefingControlBoxState();
}

class _AutopilotReefingControlBoxState extends AutopilotControlBoxState<AutopilotReefingControlBox> {
  _AutopilotReefingSettings _settings = _AutopilotReefingSettings();
  AutopilotState _autopilotState = AutopilotState.standby;
  double? _targetWindAngleApparent;
  double? _targetHeadingTrue;
  double? _targetHeadingMagnetic;
  double? _magneticVariation;
  double? _navigationHeadingTrue;
  double? _windAngleApparent;

  static double? _savedAngle;
  static AutopilotState? _savedState;


  @override
  void initState() {
    super.initState();
    _settings = _$AutopilotReefingSettingsFromJson(widget.config.controller.getBoxSettingsJson(widget.id));
    widget.config.controller.configure(onUpdate: _processData, paths: {
      'steering.autopilot.state',
      'steering.autopilot.target.windAngleApparent',
      'steering.autopilot.target.headingTrue',
      'steering.autopilot.target.headingMagnetic',
      'navigation.magneticVariation',
      'navigation.headingTrue',
      'environment.wind.angleApparent',
    });
  }

  Future<void> _setWindAngle(int desired) async {
    int actual;

    // We need to check we have reached the desired angle as it's possible that N2K messages might
    // have been missed. We check a few times just to make sure.
    int reachedAngleCount = 0;
    do {
      actual = rad2Deg(await widget.config.controller.getPathDouble('steering.autopilot.target.windAngleApparent'));

      if(actual == desired) ++reachedAngleCount;

      int diff = desired - actual;
      int tens = diff ~/ 10;
      int units = diff - (tens*10);

      for(int i=0; i<tens.abs(); ++i) {
        reachedAngleCount = 0;
        _adjustHeading(diff<0?10:-10);        
      }
      for(int i=0; i<units.abs(); ++i) {
        reachedAngleCount = 0;
        _adjustHeading(diff<0?1:-1);        
      }

      await Future.delayed(Duration(milliseconds: 200));
    } while(reachedAngleCount < 3);
  }

  Future<void> _setAngle(bool upwind) async {
    int angle = (upwind?_settings.upwindAngle:_settings.downwindAngle)*((_targetWindAngleApparent??_windAngleApparent??0)<0?-1:1);

    if(await widget.config.controller.askToConfirm(context, 'Set wind angle to ${angle.abs()}$degreesSymbol to ${val2PSString(angle)}')) {
      switch(_autopilotState) {
        case AutopilotState.standby:
          throw Exception('Bad autopilot state');// We shouldn't ever get here.
        case AutopilotState.auto:
        case AutopilotState.route:
          if(_targetHeadingTrue==null && (_targetHeadingMagnetic==null || _magneticVariation==null)) throw Exception('Inconsistent heading data');

          // We can only change to wind angle from auto.
          if(_autopilotState == AutopilotState.route) await _sendCommand('steering/autopilot/state', '{"value": "${AutopilotState.auto.name}"}');
          await _sendCommand('steering/autopilot/state', '{"value": "${AutopilotState.wind.name}"}');
          setState(() {
            _savedAngle = (_targetHeadingTrue!=null)?_targetHeadingTrue!-_magneticVariation!:_targetHeadingMagnetic!;
            _savedState = AutopilotState.auto;
            _autopilotState = AutopilotState.wind;
          });
          break;
        case AutopilotState.wind:
          if(_targetWindAngleApparent==null) throw Exception('Inconsistent wind angle data');

          setState(() {
            _savedAngle = _targetWindAngleApparent;
            _savedState = AutopilotState.wind;
          });
          break;
      }

      await _setWindAngle(angle);
    }
  }

  Future<void> _restoreAngle() async {
    if(_savedAngle == null || _savedState == null) throw Exception('Inconsistent saved state');

    String msg = '';
    if(_savedState == AutopilotState.auto) {
      msg = 'Set heading to ${rad2Deg(_savedAngle!+_magneticVariation!)}$degreesUnits?';
    } else {
      msg = 'Set wind angle to ${rad2Deg(_savedAngle!.abs())}$degreesSymbol to ${val2PSString(_savedAngle!)}';
    }

    if(await widget.config.controller.askToConfirm(context, msg)) {
      await _sendCommand('steering/autopilot/state', '{"value": "${_savedState!.name}"}');
      if(_savedState == AutopilotState.auto) {
        await _sendCommand('steering/autopilot/target/headingMagnetic', '{"value": ${rad2Deg(_savedAngle!)}}');
        _targetWindAngleApparent = null;
      } else {
        await _setWindAngle(rad2Deg(_savedAngle!));
      }

      setState(() {
        _savedAngle = _savedState = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color fc = Theme.of(context).colorScheme.onSurface;
    Color bc = widget.config.controller.val2PSColor(context, 1, none: Colors.grey);

    bool locked = widget._perBoxSettings.enableLock && _locked;
    bool enabledUpwind = (_autopilotState != AutopilotState.standby) && ((_targetWindAngleApparent??_windAngleApparent??0).abs() > deg2Rad(_settings.upwindAngle));
    bool enabledDownwind = (_autopilotState != AutopilotState.standby) && ((_targetWindAngleApparent??_windAngleApparent??180).abs() < deg2Rad(_settings.downwindAngle));

    List<Widget> reefingButtons = [
      if(_savedAngle == null) ElevatedButton(style: ElevatedButton.styleFrom(foregroundColor: fc, backgroundColor: bc),
        onPressed: locked||!enabledUpwind ? null : () {_setAngle(true);},
        child: Text(widget._perBoxSettings.showLabels ? 'Upwind' : 'U'),
      ),
      if(_savedAngle == null) ElevatedButton(style: ElevatedButton.styleFrom(foregroundColor: fc, backgroundColor: bc),
        onPressed: locked||!enabledDownwind ? null : () {_setAngle(false);},
        child: Text(widget._perBoxSettings.showLabels ? 'Downwind' : 'D'),
      ),
      if(_savedAngle != null) Expanded(child: MaxTextWidget(_savedState == AutopilotState.auto ? 'HDG:${rad2Deg(_savedAngle!+(_magneticVariation??0))}':
                                                                                                 'AWA:${rad2Deg(_savedAngle!.abs())}${val2PS(_savedAngle!)}')),
      if(_savedAngle != null) ElevatedButton(style: ElevatedButton.styleFrom(foregroundColor: fc, backgroundColor: bc),
        onPressed: locked ? null : () {_restoreAngle();},
        child: Text(widget._perBoxSettings.showLabels ? 'Restore' : 'R'),
      ),
    ];

    List<Widget> buttons = [];
    if(widget.vertical) {
      buttons.add(Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: reefingButtons));
    } else {
      buttons.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: reefingButtons));
    }

    if(locked) {
      buttons.add(Center(child: Padding(padding: const EdgeInsets.only(left: 20, right: 20),child: SlideAction(
        text: 'Unlock',
        outerColor: Colors.grey,
        onSubmit: () { return _unlock();},
      ))));
    }

    return Padding(padding: EdgeInsetsGeometry.all(5.0), child: Stack(alignment: Alignment.center, children: buttons));
  }

  void _processData(List<Update> updates) {
    for (Update u in updates) {
      try {
        switch (u.path) {
          case 'steering.autopilot.state':
            var newAutopilotState = (u.value == null) ? AutopilotState.standby : AutopilotState.values.byName(u.value);
            // If the state changes, then we reset.
            if(newAutopilotState != _autopilotState) _savedAngle = _savedState = null;
            _autopilotState = newAutopilotState;
            break;
          case 'steering.autopilot.target.windAngleApparent':
            _targetWindAngleApparent = (u.value == null) ? null : (u.value as num).toDouble();
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
          case 'navigation.headingTrue':
            if (u.value == null) {
              _navigationHeadingTrue = null;
            } else {
              var next = (u.value as num).toDouble();
              _navigationHeadingTrue = averageDouble(
                _navigationHeadingTrue ?? next, next,
                smooth: widget.config.controller.valueSmoothing);
            }
            break;
          case 'environment.wind.angleApparent':
            if (u.value == null) {
              _windAngleApparent = null;
            } else {
              var next = (u.value as num).toDouble();
              _windAngleApparent = averageAngle(
                _windAngleApparent ?? next, next,
                smooth: widget.config.controller.valueSmoothing,
                relative: true);
            }
            break;
        }
      } catch (e) {
        widget.config.controller.l.e('Error converting $u', error: e);
      }
    }

    if(mounted) {
      setState(() {});
    }
  }
}

class AutopilotReefingControlHorizontalBox extends AutopilotReefingControlBox {

  static const String sid = 'autopilot-control-reefing-horizontal';

  AutopilotReefingControlHorizontalBox(BoxWidgetConfig config, {super.key}) : super(config, false);
}

class AutopilotReefingControlVerticalBox extends AutopilotReefingControlBox {

  static const String sid = 'autopilot-control-reefing-vertical';

  AutopilotReefingControlVerticalBox(BoxWidgetConfig config, {super.key}) : super(config, true);
}

class _AutopilotReefingBoxSettingsWidget extends BoxSettingsWidget {
  final _AutopilotReefingSettings _settings;

  const _AutopilotReefingBoxSettingsWidget(this._settings);

  @override
  createState() => _AutopilotReefingBoxSettingsState();

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$AutopilotReefingSettingsToJson(_settings);
  }
}

class _AutopilotReefingBoxSettingsState extends State<_AutopilotReefingBoxSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _AutopilotReefingSettings s = widget._settings;

    return ListView(children: [
      ListTile(
        leading: const Text('Upwind Angle:  '),
        title: Slider(
            min: 10,
            max: 90,
            divisions: 8,
            value: s.upwindAngle.toDouble(),
            label: s.upwindAngle.toString(),
            onChanged: (double value) {
              setState(() {
                s.upwindAngle = value.toInt();
              });
            }),
      ),
      ListTile(
        leading: const Text('Downwind Angle:'),
        title: Slider(
            min: 90,
            max: 150,
            divisions: 6,
            value: s.downwindAngle.toDouble(),
            label: s.downwindAngle.toString(),
            onChanged: (double value) {
              setState(() {
                s.downwindAngle = value.toInt();
              });
            }),
      ),
    ]);
  }
}














abstract class AutopilotHeadingControlBox extends AutopilotControlBox {

  AutopilotHeadingControlBox(super.config, {super.key});
}

abstract class _AutopilotHeadingControlBoxState<T extends AutopilotHeadingControlBox> extends AutopilotControlBoxState<T> {

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure();
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

class _AutopilotStatusState extends HeadedTextBoxState<AutopilotStatusBox> {
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
