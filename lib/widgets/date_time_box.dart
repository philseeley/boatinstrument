import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'date_time_box.g.dart';

@JsonSerializable()
class _Settings {
  String dateFormat;

  _Settings({
    this.dateFormat = 'yyyy-MM-dd'
  });
}

@JsonSerializable()
class _PerBoxSettings {
  bool showDate;
  bool showTime;
  bool utc;
  String timeFormat;

  _PerBoxSettings({
    this.showDate = true,
    this.showTime = true,
    this.utc = false,
    this.timeFormat = 'HH:mm:ss'
  });
}

class DateTimeBox extends BoxWidget {
  late final _PerBoxSettings _perBoxSettings;

  DateTimeBox(super.config, {super.key})  {
    _perBoxSettings = _$PerBoxSettingsFromJson(config.settings);
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
    return _SettingsWidget(_$SettingsFromJson(json));
  }

  @override
  Widget? getSettingsHelp() => const Text('For a full list of formats see https://api.flutter.dev/flutter/intl/DateFormat-class.html');

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _PerBoxSettingsWidget(_perBoxSettings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const Text('For a full list of formats see https://api.flutter.dev/flutter/intl/DateFormat-class.html');
}

class _DateTimeBoxState extends State<DateTimeBox> {
  _Settings _settings = _Settings();
  DateTime? _dateTime;

  @override
  void initState() {
    super.initState();
    _settings = _$SettingsFromJson(widget.config.controller.getBoxSettingsJson(widget.id));
    widget.config.controller.configure(_processData, ['navigation.datetime']);
  }

  @override
  Widget build(BuildContext context) {
    _PerBoxSettings perBoxSettings = widget._perBoxSettings;

    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);
    const double pad = 5.0;

    if(widget.config.editMode) {
      _dateTime = DateTime.now();
    }

    String dateTimeString = '';
    int lines = 1;

    if(_dateTime == null) {
      dateTimeString = '-';
    } else {
      DateTime dt = perBoxSettings.utc ? _dateTime!.toUtc() : _dateTime!.toLocal();

      if(perBoxSettings.showDate) {
        dateTimeString += DateFormat(_settings.dateFormat).format(dt);
      }
      if(perBoxSettings.showTime) {
        if(perBoxSettings.showDate) {
          ++lines;
          dateTimeString += '\n';
        }
        dateTimeString += DateFormat(perBoxSettings.timeFormat).format(dt);
      }
    }

    double fontSize = maxFontSize(dateTimeString, style,
        ((widget.config.constraints.maxHeight - style.fontSize! - (3 * pad)) / lines),
        widget.config.constraints.maxWidth - (2 * pad));

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Text('Date/Time${perBoxSettings.utc ? ' UTC':''}', style: style))]),
      // We need to disable the device text scaling as this interferes with our text scaling.
      Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(pad), child: Text(dateTimeString, textScaler: TextScaler.noScaling,  style: style.copyWith(fontSize: fontSize)))))
    ]);
  }

  _processData(List<Update>? updates) {
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
  final _Settings _settings;

  const _SettingsWidget(this._settings);

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$SettingsToJson(_settings);
  }

  @override
  createState() => _SettingsState();
}

class _SettingsState extends State<_SettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _Settings s = widget._settings;

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
  final _PerBoxSettings _perBoxSettings;

  const _PerBoxSettingsWidget(this._perBoxSettings);

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$PerBoxSettingsToJson(_perBoxSettings);
  }

  @override
  createState() => _PerBoxSettingsState();
}

class _PerBoxSettingsState extends State<_PerBoxSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _PerBoxSettings s = widget._perBoxSettings;

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
