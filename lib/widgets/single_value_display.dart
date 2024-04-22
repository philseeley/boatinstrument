import 'package:flutter/material.dart';
import 'package:sailingapp/sailingapp_controller.dart';
import 'package:sailingapp/settings.dart';

class SingleValueDisplay extends StatefulWidget {
  final SailingAppController _controller;
  final Settings _settings;
  final String _title;
  final String _path;
  final String _units;
  final int _precision;

  const SingleValueDisplay(this._controller, this._settings, this._title, this._path, this._units, this._precision, {super.key});

  @override
  State<SingleValueDisplay> createState() => _SingleValueDisplayState();
}

class _SingleValueDisplayState extends State<SingleValueDisplay> {
  double? _value;

  @override
  void initState() {
    super.initState();
    widget._controller.configure(widget, _processData, { widget._path });
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
      _value = updates[0].value;
    } catch (e) {
      widget._controller.l.e("Error converting $updates: $e");
    }

    setState(() {});
  }
}
