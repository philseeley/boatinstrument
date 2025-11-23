import 'dart:async';

import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:format/format.dart' as fmt;
import 'package:json_annotation/json_annotation.dart';

part 'date_time_box.g.dart';

@JsonSerializable()
class _DateTimeSettings {
  String dateFormat;

  _DateTimeSettings({
    this.dateFormat = 'yyyy-MM-dd'
  });
}

@JsonSerializable()
class _DateTimePerBoxSettings {
  bool showDate;
  bool showTime;
  bool utc;
  String timeFormat;
  bool showUTCButton;

  _DateTimePerBoxSettings({
    this.showDate = true,
    this.showTime = true,
    this.utc = false,
    this.timeFormat = 'HH:mm:ss',
    this.showUTCButton = false
  });
}

class DateTimeBox extends BoxWidget {
  static const _help = 'For a full list of formats see https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html';

  late final _DateTimePerBoxSettings _perBoxSettings;

  DateTimeBox(super.config, {super.key})  {
    _perBoxSettings = _$DateTimePerBoxSettingsFromJson(config.settings);
  }

  @override
  State<DateTimeBox> createState() => _DateTimeBoxState();

  static String sid = 'date-time';
  @override
  String get id => sid;

  @override
  bool get hasSettings => true;

  @override
  BoxSettingsWidget getSettingsWidget(Map<String, dynamic> json) {
    return _SettingsWidget(_$DateTimeSettingsFromJson(json));
  }

  @override
  Widget? getSettingsHelp() => const HelpPage(text: _help);

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _PerBoxSettingsWidget(_perBoxSettings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpPage(text: _help);
}

class _DateTimeBoxState extends HeadedTextBoxState<DateTimeBox> {
  _DateTimeSettings _settings = _DateTimeSettings();
  DateTime? _dateTime;
  bool _utc = false;

  @override
  void initState() {
    super.initState();
    _settings = _$DateTimeSettingsFromJson(widget.config.controller.getBoxSettingsJson(widget.id));
    widget.config.controller.configure(onUpdate: _processData, paths: {'navigation.datetime'});
    _utc = widget._perBoxSettings.utc;
  }

  @override
  Widget build(BuildContext context) {
    _DateTimePerBoxSettings perBoxSettings = widget._perBoxSettings;
    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);

    if(widget.config.editMode) {
      _dateTime = widget.config.controller.now();
    }

    text = '';

    if(_dateTime == null) {
      text = '-';
    } else {
      DateTime dt = _utc ? _dateTime!.toUtc() : _dateTime!.toLocal();

      if(perBoxSettings.showDate) {
        text += DateFormat(_settings.dateFormat).format(dt);
      }
      if(perBoxSettings.showTime) {
        if(perBoxSettings.showDate) {
          text += '\n';
        }
        text += DateFormat(perBoxSettings.timeFormat).format(dt);
      }
    }

    header = '${perBoxSettings.showDate?'Date${perBoxSettings.showTime?'/':''}':''}${perBoxSettings.showTime?'Time':''}${(_utc && !widget._perBoxSettings.showUTCButton) ? ' UTC':''}';

    if(widget._perBoxSettings.showUTCButton) {
      actions = [
        TextButton(onPressed: _toggleUTC, child: Text('UTC', style: style.copyWith(decoration: _utc ? null : TextDecoration.lineThrough)))
      ];
    }

    return super.build(context);
  }

  void _toggleUTC() {
    setState(() {
      _utc = !_utc;
    });
  }
  
  void _processData(List<Update> updates) {
    if(updates[0].value == null) {
      _dateTime = null;
    } else {
      try {
        _dateTime = DateTime.parse(updates[0].value);
      } catch (e) {
        widget.config.controller.l.e("Error parsing date/time $updates", error: e);
      }
    }

    if(mounted) {
      setState(() {});
    }
  }
}

class _SettingsWidget extends BoxSettingsWidget {
  final _DateTimeSettings _settings;

  const _SettingsWidget(this._settings);

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$DateTimeSettingsToJson(_settings);
  }

  @override
  createState() => _SettingsState();
}

class _SettingsState extends State<_SettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _DateTimeSettings s = widget._settings;

    return ListView(children: [
      ListTile(
          leading: const Text('Date Format:'),
          title: BiTextFormField(
              initialValue: s.dateFormat,
              onChanged: (value) => s.dateFormat = value)
      ),
    ]);
  }
}

class _PerBoxSettingsWidget extends BoxSettingsWidget {
  final _DateTimePerBoxSettings _perBoxSettings;

  const _PerBoxSettingsWidget(this._perBoxSettings);

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$DateTimePerBoxSettingsToJson(_perBoxSettings);
  }

  @override
  createState() => _PerBoxSettingsState();
}

class _PerBoxSettingsState extends State<_PerBoxSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _DateTimePerBoxSettings s = widget._perBoxSettings;

    return ListView(children: [
      SwitchListTile(title: const Text('Show Date:'),
          value: s.showDate,
          onChanged: (bool value) {
            setState(() {
              s.showDate = value;
            });
          }),
      SwitchListTile(title: const Text('Show Time:'),
          value: s.showTime,
          onChanged: (bool value) {
            setState(() {
              s.showTime = value;
            });
          }),
      SwitchListTile(title: const Text('UTC:'),
          value: s.utc,
          onChanged: (bool value) {
            setState(() {
              s.utc = value;
            });
          }),
      SwitchListTile(title: const Text('Show UTC Button:'),
          value: s.showUTCButton,
          onChanged: (bool value) {
            setState(() {
              s.showUTCButton = value;
            });
          }),
      ListTile(
          leading: const Text('Time Format:'),
          title: BiTextFormField(
              initialValue: s.timeFormat,
              onChanged: (value) => s.timeFormat = value)
      ),
    ]);
  }
}

@JsonSerializable()
class _TimerDisplaySettings {
  String id;
  NotificationState notificationState;
   bool allowRestart;
   bool allowStop;

  _TimerDisplaySettings({
    this.id = '',
    this.notificationState = NotificationState.warn,
    this.allowRestart = true,
    this.allowStop = false
  });
}

class TimerDisplayBox extends BoxWidget {
  late final _TimerDisplaySettings _perBoxSettings;

  static String sid = 'timer-display';
  @override
  String get id => sid;

  TimerDisplayBox(super.config, {super.key})  {
    _perBoxSettings = _$TimerDisplaySettingsFromJson(config.settings);
  }

  @override
  State<TimerDisplayBox> createState() => _TimerDisplayBoxState();

  @override
  Widget? getHelp() => const HelpPage(url: 'doc:timers.md');

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _TimerDisplaySettingsWidget(config.controller, _perBoxSettings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpPage(text: '''Timers must first be defined and activated using the **Timers Setup** Box.

The Restart and Stop buttons will only be displayed for Delta Timers.

Setting the **Alert Level** to "Normal" or "Nominal" will disable the audio alarm.

**Note:** audio will only sound when the **Timer Display** Box is visible on the current Page.''');
  }

class _TimerDisplayBoxState extends HeadedTextBoxState<TimerDisplayBox> {
  _Timer? _timer;
  DateTime? _expires;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    scrolling = true;
    if(!widget.config.editMode) {
      actions = [
        IconButton(onPressed: widget._perBoxSettings.allowStop?_stop:null, icon: Icon(Icons.stop)),
        IconButton(onPressed: widget._perBoxSettings.allowRestart?_restart:null, icon: Icon(Icons.restore))
      ];
    }
    widget.config.controller.configure(onUpdate: _processData, paths: {'$bi.timers.${widget._perBoxSettings.id}'}, dataType: SignalKDataType.static);
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      _expires = widget.config.controller.now().add(Duration(minutes: 123));
    }

    String expiresStr = _expires==null?'':TimeOfDayConverter.timeFormat.format(_expires!.toLocal());
    String deltaStr = _timer!=null && _timer!.delta?' ${TimeOfDayConverter().toJson(_timer!.time)} $deltaChar':'';

    header = 'Timer:${widget._perBoxSettings.id} $expiresStr$deltaStr';

    if(widget._perBoxSettings.id.isEmpty) {
      text = 'Select a Timer\nin the settings';      
    } else {
      if(!widget.config.editMode) {
        actions[0] = IconButton(onPressed: (_timer!=null&&widget._perBoxSettings.allowStop)?_stop:null, icon: Icon(Icons.stop));
        actions[1] = IconButton(onPressed: (_timer!=null&&widget._perBoxSettings.allowRestart)?_restart:null, icon: Icon(Icons.restore));
      }

      Duration? d = _expires?.difference(widget.config.controller.now());

      text = d==null?'-':duration2HumanString(d);
      color = null;
      if(d!=null && d.isNegative) {
        color = widget.config.controller.val2PSColor(context, -1);
        if(widget._perBoxSettings.notificationState.soundFile!=null) widget.config.controller.playSoundFile(widget._perBoxSettings.notificationState.soundFile!);
      }
    }

    return super.build(context);
  }

  void _restart () {
    _TimersSetupBoxState.start(widget.config.controller, _timer!);
  }

  void _stop () {
    _TimersSetupBoxState.stop(widget.config.controller, _timer!);
  }

  void _processData(List<Update> updates) {
    if(updates[0].value == null) {
      _timer = _expires = null;
      _updateTimer?.cancel();
      _updateTimer = null;
    } else {
      try {
        dynamic v = updates[0].value;

        _timer = null;
        _expires = DateTime.tryParse(v['expires']??'');
        _updateTimer?.cancel();
        _updateTimer = null;

        if(_expires != null) {
          _timer = _Timer(
            id: widget._perBoxSettings.id,
            time: TimeOfDayConverter().fromJson(v['time']),
            delta: v['delta']
          );
          
          _updateTimer = Timer.periodic(Duration(seconds: 1), (_) {if(mounted) setState(() {});});
        }
      } catch (e) {
        widget.config.controller.l.e("Error parsing date/time $updates", error: e);
      }
    }

    if(mounted) {
      setState(() {});
    }
  }
}

class _TimerDisplaySettingsWidget extends BoxSettingsWidget {
  final BoatInstrumentController _controller;
  final _TimerDisplaySettings _settings;

  const _TimerDisplaySettingsWidget(this._controller, this._settings);

  @override
  createState() => _TimerDisplaySettingsState();

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$TimerDisplaySettingsToJson(_settings);
  }
}

class _TimerDisplaySettingsState extends State<_TimerDisplaySettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _TimerDisplaySettings s = widget._settings;

    return ListView(children: [
      ListTile(
        leading: Text("Timer ID:"),
        title: SignalkPathDropdownMenu(
          widget._controller,
          s.id,
          '$bi.timers',
          (value) => s.id = value)
      ),
      ListTile(
          leading: const Text("Alert Level:"),
          title: EnumDropdownMenu(
            NotificationState.values,
            s.notificationState,
            (v) {
              setState(() {
                s.notificationState = v!;
              });
            })
      ),
      SwitchListTile(title: const Text("Allow Restart:"),
        value: s.allowRestart,
        onChanged: (bool value) {
          setState(() {
            s.allowRestart = value;
          });
        }
      ),
      SwitchListTile(title: const Text("Allow Stop:"),
        value: s.allowStop,
        onChanged: (bool value) {
          setState(() {
            s.allowStop = value;
          });
        }
      )
    ]);
  }
}

@JsonSerializable()
@TimeOfDayConverter()
class _Timer {
  String id;
  TimeOfDay time;
  bool delta;

  _Timer({
    this.id = '',
    this.time = const TimeOfDay(hour: 0, minute: 0),
    this.delta = false});

  factory _Timer.fromJson(Map<String, dynamic> json) =>
      _$TimerFromJson(json);

  Map<String, dynamic> toJson() => _$TimerToJson(this);
}

@JsonSerializable(explicitToJson: true)
class _TimersSettings {
  late List<_Timer> timers;

  _TimersSettings({
     this.timers = const []}) {
       if(timers.isEmpty) timers = [];
    }

  factory _TimersSettings.fromJson(Map<String, dynamic> json) =>
      _$TimersSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$TimersSettingsToJson(this);
}

class TimersSetupBox extends BoxWidget {

  static String sid = 'timers-setup';
  @override
  String get id => sid;

  const TimersSetupBox(super.config, {super.key});
  
  @override
  State<TimersSetupBox> createState() => _TimersSetupBoxState();

  @override
  Widget? getHelp() => const HelpPage(url: 'doc:timers.md');

  @override
  bool get hasSettings => true;

  @override
  BoxSettingsWidget getSettingsWidget(Map<String, dynamic> json) {
    return _TimersSetupSettings(config.controller, _TimersSettings.fromJson(json));
  }
}

class _TimersSetupBoxState extends HeadedBoxState<TimersSetupBox> {
  _TimersSettings? _settings;

  @override
  void initState() {
    super.initState();
    _settings = _TimersSettings.fromJson(widget.config.controller.getBoxSettingsJson(widget.id));
    widget.config.controller.configure();
    header = 'Timers';
    if(!widget.config.editMode) actions = [IconButton(onPressed: _edit, icon: Icon(Icons.settings))];
  }

  @override
  Widget build(BuildContext context) {
    var editMode = widget.config.editMode;
    var timers = _settings!.timers;
    if(editMode && timers.isEmpty) {
      timers = [
        _Timer(id: 't1', time: TimeOfDay(hour: 1, minute: 12)),
        _Timer(id: 't1', time: TimeOfDay(hour: 1, minute: 12), delta: true)
      ];
    }
    body = ListView.builder(itemCount: timers.length, itemBuilder: (context, i) {
        _Timer timer = timers[i];
        return ListTile(key: UniqueKey(),
          leading: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(onPressed: editMode?null:() {start(widget.config.controller, timer);}, icon: Icon(Icons.play_arrow)),
            IconButton(onPressed: editMode?null:() {stop(widget.config.controller, timer);}, icon: Icon(Icons.stop))
          ]),
          title: Row(children: [Text('${TimeOfDayConverter.format(timer.time)} '), Icon(timer.delta?Icons.change_history:Icons.timer), Text(' ${timer.id}')]),
        );
      });

    return super.build(context);
  }

  void _edit() async {
    if(mounted) await widget.config.controller.showSettingsPage(context, widget);

    _settings = _TimersSettings.fromJson(widget.config.controller.getBoxSettingsJson(widget.id));
    
    widget.config.controller.save();

    setState(() {});
  }

  static void start(BoatInstrumentController controller, _Timer timer) {
    DateTime now = controller.now();
    DateTime expires = timer.delta?
      now.add(Duration(hours: timer.time.hour, minutes: timer.time.minute)):
      DateTime(now.year, now.month, now.day, timer.time.hour, timer.time.minute);

    if(expires.isBefore(now)) expires = expires.add(Duration(days: 1));

    controller.sendUpdate('$bi.timers.${timer.id}', {
      'time': TimeOfDayConverter.format(timer.time),
      'delta': timer.delta,
      'expires': expires.toUtc().toIso8601String()
    });
  }

  static void stop(BoatInstrumentController controller, _Timer timer) {
    controller.sendUpdate('$bi.timers.${timer.id}', {
      'time': TimeOfDayConverter.format(timer.time),
      'delta': timer.delta,
      'expires': null
    });
  }
}

class _TimersSetupSettings extends BoxSettingsWidget {
  final BoatInstrumentController _controller;
  final _TimersSettings _settings;

  const _TimersSetupSettings(this._controller, this._settings);
  
  @override
  Map<String, dynamic> getSettingsJson() {
    return _settings.toJson();
  }

  @override
  State<_TimersSetupSettings> createState() => _TimersSetupSettingsState();
}

class _TimersSetupSettingsState extends State<_TimersSetupSettings> {

  @override
  Widget build(BuildContext context) {
    _TimersSettings s = widget._settings;
    Color fg = Theme.of(context).colorScheme.onSurface;
    Color bg = widget._controller.val2PSColor(context, 1, none: Colors.grey);

    List<ListTile> items = [];
    for(int i=0; i<s.timers.length; ++i) {
      _Timer timer = s.timers[i];
      items.add(ListTile(
        key: UniqueKey(),
        leading: Row(mainAxisSize: MainAxisSize.min, children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(foregroundColor: fg, backgroundColor: bg),
            child: Text(TimeOfDayConverter.format(timer.time)),
            onPressed: () { _selectTime(timer);}
          ),
          IconButton(onPressed: () {setState(() {timer.delta = !timer.delta;});}, icon: Icon(timer.delta?Icons.change_history:Icons.timer))
        ]),
        title: BiTextFormField(
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(idChars))],
          decoration: const InputDecoration(hintText: 'id'),
          initialValue: timer.id,
          onChanged: (value) => timer.id = value),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(onPressed: () {_deleteTimer(i);}, icon: Icon(Icons.delete)),
          ReorderableDragStartListener(index: i, child: const Icon(Icons.drag_handle))
        ])
      ));
    }

    return PopScope(canPop: false, onPopInvokedWithResult: (didPop, result) {if(didPop) return; _checkIDs();}, child: Column(children: [
      Row(children: [
        IconButton(tooltip: 'Add Timer', icon: const Icon(Icons.add),onPressed: _addTimer),
      ]),
      Expanded(child: ReorderableListView(buildDefaultDragHandles: false, children: items, onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          _Timer t = s.timers.removeAt(oldIndex);
          s.timers.insert(newIndex, t);
        });
      }))
    ]));
  }

  void _checkIDs () {
    if(widget._settings.timers.every((timer) {return timer.id.isNotEmpty;})) {
      Navigator.pop(context);
    } else {
      widget._controller.showMessage(context, 'Timer IDs cannot be blank');
    }
  }

  void _addTimer() {
    setState(() {
      widget._settings.timers.add(_Timer());
    });
  }

  Future<void> _deleteTimer(int i) async {
    setState(() {
      widget._settings.timers.removeAt(i);
    });
  }

  Future<void> _selectTime (_Timer timer) async {
    TimeOfDay? tod = await showTimePicker(context: context, initialTime: timer.time);
    if(tod != null) {
      setState(() {
        timer.time = tod;
      });
    }
  }
}

class StopwatchBox extends BoxWidget {

  static String sid = 'stopwatch';
  @override
  String get id => sid;

  const StopwatchBox(super.config, {super.key});

  @override
  Widget? getHelp() => const HelpPage(text: 'The list of lap times can be switched between delta or absolute times by clicking on the ![request](assets/icons/__THEME__/timer.png) or ![request](assets/icons/__THEME__/change_history.png) list header.');

  @override
  State<StopwatchBox> createState() => _StopwatchBoxState();
}

class _StopwatchBoxState extends State<StopwatchBox> {
  static Duration _duration = Duration();
  static DateTime? _startTime;
  static bool _paused = false;
  static final List<Duration> _laps = [];
  static bool _deltaLaps = true;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure();
    if(!_paused) _startTimer();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(_startTime!= null) _duration = widget.config.controller.now().difference(_startTime!);

    StringBuffer lapsList = StringBuffer();
    for(int i=0; i<_laps.length; ++i) {
      Duration d = _laps[i];
      if(_deltaLaps && i > 0) d -= _laps[i-1];
      lapsList.writeln(fmt.format('{:2d}: {}', i, duration2String(d)));
    }

    return Padding(padding: EdgeInsets.all(5), child: Column(children: [
      Expanded(child: Row(children: [
        Expanded(child: MaxTextWidget(duration2String(_duration))),
        if(lapsList.isNotEmpty) Column(children: [
          IconButton(onPressed: _toggleDeltaLaps, icon: Icon(_deltaLaps?Icons.change_history:Icons.timer)),
          Expanded(child: SingleChildScrollView(child: Text(lapsList.toString())))
        ])
      ])),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        IconButton(onPressed: _start, icon: Icon(_startTime!=null||_paused?Icons.restore:Icons.play_arrow)),
        IconButton(onPressed: _startTime!=null || _paused?_togglePause:null, icon: Icon(_paused?Icons.not_started:Icons.pause)),
        IconButton(onPressed: _startTime!=null?_lap:null, icon: Icon(Icons.list)),
        IconButton(onPressed: _startTime!=null?_stop:null, icon: Icon(Icons.stop))
      ])
    ]));
  }

  void _start ({bool restart = true}) {
    setState(() {
      if(!restart && _paused) {
        _startTime = widget.config.controller.now().subtract(_duration);
      } else {
        _laps.clear();
        _startTime = widget.config.controller.now();
      }
      _paused = false;
    });
    _startTimer();
  }

  void _togglePause () {
    _stopTimer();

    setState(() {
      if(_paused) {
        _start(restart: false);
      } else {
        _startTime = null;
        _paused = true;
      }
    });
  }

  void _lap () {
    setState(() {
      _laps.add(_duration);
    });
  }

  void _stop () {
    setState(() {
      _startTime = null;
      _paused = false;
    });
    _stopTimer();
  }

  void _toggleDeltaLaps () {
    setState(() {
      _deltaLaps = !_deltaLaps;
    });
  }

  void _startTimer() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(Duration(seconds: 1), (_) {if(mounted) setState(() {});});
  }

  void _stopTimer () {
    _updateTimer?.cancel();
    _updateTimer = null;
  }
}
