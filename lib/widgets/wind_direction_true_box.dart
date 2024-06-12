import 'dart:math';

import 'package:flutter/material.dart';
import 'package:format/format.dart' as fmt;
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wind_direction_true_box.g.dart';

@JsonSerializable()
class _Settings {
  bool cardinalPrimary;

  _Settings({this.cardinalPrimary = false});
}

class WindDirectionTrueBox extends BoxWidget {
  late _Settings _settings;

  WindDirectionTrueBox(super.config, {super.key})  {
    _settings = _$SettingsFromJson(config.settings);
  }

  @override
  State<WindDirectionTrueBox> createState() => _WindDirectionTrueBoxState();

  static String sid = 'wind-direction-true';
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

class _WindDirectionTrueBoxState extends State<WindDirectionTrueBox> {
  static const List<String> _cardinalDirections = [
   'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S',
   'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW', 'N'
  ];

  double? _direction;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(widget, onUpdate: _processData, paths: {'environment.wind.directionTrue'});
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);
    const double pad = 5.0;

    if(widget.config.editMode) {
      _direction = deg2Rad(123);
    }

    String direction = (_direction == null) ?
      '-' : fmt.format('{:${3}d}', rad2Deg(_direction));

    const f = (2*pi)/16;
    String cardinal = (_direction == null) ? '-' : _cardinalDirections[((_direction!+(f/2))/f).toInt()];

    String primaryText = direction;
    String subText = cardinal;
    if(widget._settings.cardinalPrimary) {
      primaryText = cardinal;
      subText = direction;
    }

    double fontSize = maxFontSize(primaryText, style,
          (widget.config.constraints.maxHeight - style.fontSize! - (3 * pad)),
          widget.config.constraints.maxWidth - (2 * pad));

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Text('TWD deg $subText', style: style))]),
      // We need to disable the device text scaling as this interferes with our text scaling.
      Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(pad), child: Text(primaryText, textScaler: TextScaler.noScaling,  style: style.copyWith(fontSize: fontSize)))))

    ]);
  }

  _processData(List<Update>? updates) {
    if(updates == null) {
      _direction = null;
    } else {
      try {
        double next = (updates[0].value as num).toDouble();

        _direction = averageAngle(_direction ?? next, next,
            smooth: widget.config.controller.valueSmoothing);
      } catch (e) {
        widget.config.controller.l.e("Error converting $updates", error: e);
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
      SwitchListTile(title: const Text("Primary Cardinal:"),
          value: s.cardinalPrimary,
          onChanged: (bool value) {
            setState(() {
              s.cardinalPrimary = value;
            });
          }),
    ]);
  }
}
