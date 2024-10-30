import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:boatinstrument/widgets/gauge_box.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'electrical_box.g.dart';

@JsonSerializable()
class _VoltMeterSettings {
  String id;

  _VoltMeterSettings({this.id = ''});
}

class VoltMeterBox extends DoubleValueSemiGaugeBox {
  static const sid = 'electrical-battery-voltage';
  @override
  String get id => sid;

  const VoltMeterBox(config, {super.key, super.minValue = 10, super.maxValue = 14, super.ranges = const [
    GuageRange(10, 12, Colors.red),
    GuageRange(12, 13, Colors.orange),
    GuageRange(13, 14, Colors.green)
  ]}) : super(config, 'Battery', GaugeOrientation.up, 'fred');

  @override
  double convert(double value) {
    return value;
  }
  
  @override
  String units(double value) {
    return 'V';
  }

  @override
  bool get hasSettings => true;

  @override
  BoxSettingsWidget getSettingsWidget(Map<String, dynamic> json) {
    return _VoltMeterSettingsWidget(_$VoltMeterSettingsFromJson(json));
  }

  @override
  Widget? getSettingsHelp() => const HelpTextWidget('For a path of "electrical.batteries.start.voltage" the ID is "start"');

  @override
  DoubleValueSemiGaugeBoxState<VoltMeterBox> createState() => _VoltMeterState();
}

class _VoltMeterState extends DoubleValueSemiGaugeBoxState<VoltMeterBox> {
  late final _VoltMeterSettings _settings;

  _VoltMeterState() : super(configure: false);

  @override
  void initState() {
    super.initState();
    _settings = _$VoltMeterSettingsFromJson(widget.config.controller.getBoxSettingsJson(widget.id));
    widget.config.controller.configure(onUpdate: processUpdates, paths: { 'electrical.batteries.${_settings.id}.voltage' });
  }

  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      displayValue = 12.3;
    }
    // displayValue = 11;
    value = 12.8;
    return super.build(context);
  }

  // void _onUpdate(List<Update>? updates) {
  //   if(updates == null) {
  //     _maxRadius = _currentRadius = _bearingTrue = _apparentBearing = null;
  //   } else {
  //     for (Update u in updates) {
  //       try {
  //         switch (u.path) {
  //           case 'navigation.position':
  //             DateTime now = DateTime.now();
  //             if(now.difference(_lastPositionTime) >= Duration(seconds: _settings.recordSeconds)) {
  //               _lastPositionTime = now;

  //               _positions.add(ll.LatLng(
  //                   (u.value['latitude'] as num).toDouble(),
  //                   (u.value['longitude'] as num).toDouble()));

  //               if (_positions.length > _settings.recordPoints) {
  //                 _positions.removeRange(0, _settings.recordPoints ~/ 10);
  //               }
  //             }
  //             break;
  //           case 'navigation.anchor.position':
  //             _anchorPosition = ll.LatLng((u.value['latitude'] as num).toDouble(), (u.value['longitude'] as num).toDouble());
  //             break;
  //           case 'navigation.anchor.maxRadius':
  //             try {
  //               _maxRadius = (u.value as num).round();
  //             } catch (_){
  //               // This only happens if the Anchor Alarm webapp is used.
  //               _maxRadius = int.parse(u.value as String);
  //             }
  //             break;
  //           case 'navigation.anchor.currentRadius':
  //             _currentRadius = (u.value as num).round();
  //             // Make sure we have a radius to avoid div-by-zero error.
  //             _currentRadius = _currentRadius == 0 ? 1 : _currentRadius;
  //             break;
  //           case 'navigation.anchor.bearingTrue':
  //             _bearingTrue = (u.value as num).toDouble()-m.pi;
  //             break;
  //           case 'navigation.anchor.apparentBearing':
  //             _apparentBearing = (u.value as num).toDouble();
  //             break;
  //         }
  //       } catch (e) {
  //         widget.config.controller.l.e("Error converting $u", error: e);
  //       }
  //     }
  //   }

  //   if(mounted) {
  //     setState(() {});
  //   }
  // }
}

class _VoltMeterSettingsWidget extends BoxSettingsWidget {
  final _VoltMeterSettings _settings;

  const _VoltMeterSettingsWidget(this._settings);

  @override
  createState() => _AnchorAlarmSettingsState();

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$VoltMeterSettingsToJson(_settings);
  }
}

class _AnchorAlarmSettingsState extends State<_VoltMeterSettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _VoltMeterSettings s = widget._settings;

    List<Widget> list = [
      ListTile(
          leading: const Text("Battery ID:"),
          title: TextFormField(
              initialValue: s.id,
              onChanged: (value) => s.id = value)
      ),
    ];

    return ListView(children: list);
  }
}
