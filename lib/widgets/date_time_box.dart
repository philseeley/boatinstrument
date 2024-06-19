import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'date_time_box.g.dart';

@JsonSerializable()
class _Settings {
  bool showDate;
  bool showTime;
  bool utc;
  String dateFormat;
  String timeFormat;

  _Settings({
    this.showDate = true,
    this.showTime = true,
    this.utc = false,
    this.dateFormat = 'yyyy-MM-dd',
    this.timeFormat = 'HH:mm:ss'
  });
}

class DateTimeBox extends BoxWidget {
  late _Settings _settings;

  DateTimeBox(super.config, {super.key})  {
    _settings = _$SettingsFromJson(config.settings);
  }

  @override
  State<DateTimeBox> createState() => _DateTImeBoxState();

  static String sid = 'date-time';
  @override
  String get id => sid;

  @override
  bool get hasPerBoxSettings => true;

  @override
  Widget getPerBoxSettingsWidget() {
    return _SettingsWidget(_settings);
  }

  @override
  Map<String, dynamic> getPerBoxSettingsJson() {
    return _$SettingsToJson(_settings);
  }
}

class _DateTImeBoxState extends State<DateTimeBox> {
  DateTime? _dateTime;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(widget, onUpdate: _processData, paths: {'navigation.datetime'});
  }

  @override
  Widget build(BuildContext context) {
    _Settings s = widget._settings;

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
      DateTime dt = s.utc ? _dateTime!.toUtc() : _dateTime!.toLocal();

      if(s.showDate) {
        dateTimeString += DateFormat(s.dateFormat).format(dt);
      }
      if(s.showTime) {
        if(s.showDate) {
          ++lines;
          dateTimeString += '\n';
        }
        dateTimeString += DateFormat(s.timeFormat).format(dt);
      }
    }

    double fontSize = maxFontSize(dateTimeString, style,
        ((widget.config.constraints.maxHeight - style.fontSize! - (3 * pad)) / lines),
        widget.config.constraints.maxWidth - (2 * pad));

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Text('Date/Time', style: style))]),
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

class _SettingsWidget extends StatefulWidget {
  final _Settings _settings;

  const _SettingsWidget(this._settings);

  @override
  createState() => _SettingsState();
}

class _SettingsState extends State<_SettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _Settings s = widget._settings;

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
          leading: const Text('Date Format:'),
          title: TextFormField(
              initialValue: s.dateFormat,
              onChanged: (value) => s.dateFormat = value)
      ),
      ListTile(
          leading: const Text('Time Format:'),
          title: TextFormField(
              initialValue: s.timeFormat,
              onChanged: (value) => s.timeFormat = value)
      ),
      const ListTile(
          leading: Text('For a full list of formats see https://api.flutter.dev/flutter/intl/DateFormat-class.html'),
      ),
    ]);
  }
}
