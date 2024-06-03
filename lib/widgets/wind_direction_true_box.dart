import 'dart:math';

import 'package:flutter/material.dart';
import 'package:format/format.dart' as fmt;
import 'package:boatinstrument/boatinstrument_controller.dart';

class WindDirectionTrueBox extends BoxWidget {

  const WindDirectionTrueBox(super.controller, _, super.constraints, {super.key});

  @override
  State<WindDirectionTrueBox> createState() => _WindDirectionTrueBoxState();

  static String sid = 'wind-direction-true';
  @override
  String get id => sid;
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
    widget.controller.configure(widget, onUpdate: _processData, paths: {'environment.wind.directionTrue'});
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.0);
    const double pad = 5.0;

    String text = (_direction == null) ?
      '-' : fmt.format('{:${3}d}', rad2Deg(_direction));

    double fontSize = 14.0;
    if(widget.constraints != null) {
      fontSize = maxFontSize(text, style,
          (widget.constraints!.maxHeight - style.fontSize! - (3 * pad)),
          widget.constraints!.maxWidth - (2 * pad));
    }

    const f = (2*pi)/16;
    String cardinal = (_direction == null) ? '' : _cardinalDirections[((_direction!+(f/2))/f).toInt()];

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [Padding(padding: const EdgeInsets.only(top: pad, left: pad), child: Text('TWD deg $cardinal', style: style))]),
      // We need to disable the device text scaling as this interferes with our text scaling.
      Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(pad), child: Text(text, textScaler: TextScaler.noScaling,  style: style.copyWith(fontSize: fontSize)))))

    ]);
  }

  _processData(List<Update> updates) {
    try {
      double next = (updates[0].value as num).toDouble();

      _direction = averageDouble(_direction ?? next, next, smooth: widget.controller.valueSmoothing);
    } catch (e) {
      widget.controller.l.e("Error converting $updates", error: e);
    }

    if(mounted) {
      setState(() {});
    }
  }
}
