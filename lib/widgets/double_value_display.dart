import 'package:flutter/material.dart';
import 'package:sailingapp/boatinstrument_controller.dart';

class DoubleValueDisplay extends BoxWidget {
  final BoatInstrumentController _controller;
  final String _title;
  final String _path;
  final String _units;
  final int _precision;

  const DoubleValueDisplay(this._controller, this._title, this._path, this._units, this._precision, {super.key});

  @override
  State<DoubleValueDisplay> createState() => _DoubleValueDisplayState();

  @override //TODO
  String get id => 'TODO';
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
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(widget._title, style: widget._controller.headTS),
      Text("${(_value??0).toStringAsFixed(widget._precision)} ${widget._units}", style: widget._controller.infoTS)
    ]);
  }

  _processData(List<Update> updates) {
    try {
      // TODO value smoothing.
      _value = (updates[0].value as num).toDouble();
    } catch (e) {
      widget._controller.l.e("Error converting $updates", error: e);
    }

    setState(() {});
  }
}
