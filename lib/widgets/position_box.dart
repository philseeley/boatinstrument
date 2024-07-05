import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:latlong_formatter/latlong_formatter.dart';

part 'position_box.g.dart';

@JsonSerializable()
class _Settings {
  String latFormat;
  String lonFormat;

  _Settings({
    this.latFormat = '0{lat0d 0m.mmm c}',
    this.lonFormat = '{lon0d 0m.mmm c}'
  });
}

class PositionBox extends BoxWidget {

  const PositionBox(super.config, {super.key});

  @override
  State<PositionBox> createState() => _PositionBoxState();

  static String sid = 'position';
  @override
  String get id => sid;

  @override
  bool get hasSettings => true;

  @override
  BoxSettingsWidget getSettingsWidget(Map<String, dynamic> json) {
    return _SettingsWidget(_$SettingsFromJson(json));
  }

  @override
  Widget? getSettingsHelp() => const Text('For a full list of formats see https://pub.dev/packages/latlong_formatter');
}

class _PositionBoxState extends State<PositionBox> {
  _Settings _settings = _Settings();
  LatLongFormatter _llf = LatLongFormatter('');
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _settings = _$SettingsFromJson(widget.config.controller.configure(widget, onUpdate: _processData, paths: {'navigation.position'}));
    _llf = LatLongFormatter('${_settings.latFormat}\n${_settings.lonFormat}');
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);
    const double pad = 5.0;

    if(widget.config.editMode) {
      _latitude = _longitude = 0;
    }
    String text = (_latitude == null || _longitude == null) ?
      '--- --.--- -\n--- --.--- -' :
      _llf.format(LatLong(_latitude!, _longitude!));

    double fontSize = maxFontSize(text, style,
          (widget.config.constraints.maxHeight - style.fontSize! - (3 * pad)) / 2,
          widget.config.constraints.maxWidth - (2 * pad));

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Text('Position', style: style))]),
      // We need to disable the device text scaling as this interferes with our text scaling.
      Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(pad), child: Text(text, textScaler: TextScaler.noScaling,  style: style.copyWith(fontSize: fontSize)))))

    ]);
  }

  _processData(List<Update>? updates) {
    if(updates == null) {
      _latitude = _longitude = null;
    } else {
      try {
        _latitude = updates[0].value['latitude'];
        _longitude = updates[0].value['longitude'];
      } catch (e) {
        widget.config.controller.l.e("Error converting $updates", error: e);
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

    List<Widget> list = [
      ListTile(
          leading: const Text("Lat Format:"),
          title: TextFormField(
              initialValue: s.latFormat,
              onChanged: (value) => s.latFormat = value)
      ),
      ListTile(
          leading: const Text("Long Format:"),
          title: TextFormField(
              initialValue: s.lonFormat,
              onChanged: (value) => s.lonFormat = value)
      ),
    ];

    return ListView(children: list);
  }
}
