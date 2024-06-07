import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:latlong_formatter/latlong_formatter.dart';

class PositionBox extends BoxWidget {

  const PositionBox(super.config, {super.key});

  @override
  State<PositionBox> createState() => _PositionBoxState();

  static String sid = 'position';
  @override
  String get id => sid;
}

class _PositionBoxState extends State<PositionBox> {
  LatLongFormatter llf = LatLongFormatter('0{lat0d 0m.mmm c}\n{lon0d 0m.mmm c}');
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(widget, onUpdate: _processData, paths: {'navigation.position'});
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
      llf.format(LatLong(_latitude!, _longitude!));

    double fontSize = maxFontSize(text, style,
          (widget.config.constraints.maxHeight - style.fontSize! - (3 * pad)) / 2,
          widget.config.constraints.maxWidth - (2 * pad));

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Text('Position', style: style))]),
      // We need to disable the device text scaling as this interferes with our text scaling.
      Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(pad), child: Text(text, textScaler: TextScaler.noScaling,  style: style.copyWith(fontSize: fontSize)))))

    ]);
  }

  _processData(List<Update> updates) {
    try {
      _latitude = updates[0].value['latitude'];
      _longitude = updates[0].value['longitude'];
    } catch (e) {
      widget.config.controller.l.e("Error converting $updates", error: e);
    }

    if(mounted) {
      setState(() {});
    }
  }
}
