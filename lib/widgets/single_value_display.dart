import 'package:flutter/material.dart';
import 'package:sailingapp/sailingapp_controller.dart';

class DoubleValueDisplay extends StatefulWidget {
  final SailingAppController _controller;
  final String _title;
  final String _path;
  final String _units;
  final int _precision;

  const DoubleValueDisplay(this._controller, this._title, this._path, this._units, this._precision, {super.key});

  @override
  State<DoubleValueDisplay> createState() => _DoubleValueDisplayState();
}

class _DoubleValueDisplayState extends State<DoubleValueDisplay> {
  double? _value;

  @override
  void initState() {
    super.initState();
    widget._controller.configure((DoubleValueDisplay).toString(), widget, _processData, { widget._path });
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(children: [
      Text(widget._title, style: widget._controller.headTS),
      Text("${(_value??0).toStringAsFixed(widget._precision)} ${widget._units}", style: widget._controller.infoTS)
    ]));
  }

  _processData(List<Update> updates) {
    try {
      // The '* 1.0' forces the result to be a double as sometimes the value is 0 and therefore an int.
      _value = updates[0].value * 1.0;
    } catch (e) {
      widget._controller.l.e("Error converting $updates", error: e);
    }

    setState(() {});
  }
}
