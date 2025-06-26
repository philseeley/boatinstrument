import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:intl/intl.dart';
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

  _DateTimePerBoxSettings({
    this.showDate = true,
    this.showTime = true,
    this.utc = false,
    this.timeFormat = 'HH:mm:ss'
  });
}

class DateTimeBox extends BoxWidget {
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
  Widget? getSettingsHelp() => const HelpTextWidget('For a full list of formats see https://api.flutter.dev/flutter/intl/DateFormat-class.html');

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _PerBoxSettingsWidget(_perBoxSettings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('For a full list of formats see https://api.flutter.dev/flutter/intl/DateFormat-class.html');
}

class _DateTimeBoxState extends HeadedBoxState<DateTimeBox> {
  _DateTimeSettings _settings = _DateTimeSettings();
  DateTime? _dateTime;

  @override
  void initState() {
    super.initState();
    _settings = _$DateTimeSettingsFromJson(widget.config.controller.getBoxSettingsJson(widget.id));
    widget.config.controller.configure(onUpdate: _processData, paths: {'navigation.datetime'});
  }

  @override
  Widget build(BuildContext context) {
    _DateTimePerBoxSettings perBoxSettings = widget._perBoxSettings;

    if(widget.config.editMode) {
      _dateTime = widget.config.controller.now();
    }

    text = '';
    lines = 1;

    if(_dateTime == null) {
      text = '-';
    } else {
      DateTime dt = perBoxSettings.utc ? _dateTime!.toUtc() : _dateTime!.toLocal();

      if(perBoxSettings.showDate) {
        text += DateFormat(_settings.dateFormat).format(dt);
      }
      if(perBoxSettings.showTime) {
        if(perBoxSettings.showDate) {
          ++lines;
          text += '\n';
        }
        text += DateFormat(perBoxSettings.timeFormat).format(dt);
      }
    }

    header = '${perBoxSettings.showDate?'Date${perBoxSettings.showTime?'/':''}':''}${perBoxSettings.showTime?'Time':''}${perBoxSettings.utc ? ' UTC':''}';

    return super.build(context);
  }

  void _processData(List<Update>? updates) {
    if(updates == null) {
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
          title: TextFormField(
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
      ListTile(
          leading: const Text('Time Format:'),
          title: TextFormField(
              initialValue: s.timeFormat,
              onChanged: (value) => s.timeFormat = value)
      ),
    ]);
  }
}
