import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';

class LogDisplay extends StatefulWidget {
  final BoatInstrumentController _controller;

  const LogDisplay(this._controller, {super.key});

  @override
  State<LogDisplay> createState() => _LogDisplayState();
}

class _LogDisplayState extends State<LogDisplay> {

  @override
  Widget build(BuildContext context) {
    List<String> entries = List<String>.from(widget._controller.logBuffer);

    return Scaffold(
      appBar: AppBar(
        title: Text("Log"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {});();
              }),
          IconButton(icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                setState(() {
                  widget._controller.clearLog();
                });();
              }),
        ],
      ),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (BuildContext context, int index) {
          return Text(entries[index]);
        }
      )
    );
  }
}
