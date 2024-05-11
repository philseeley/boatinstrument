import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';

class LogDisplay extends StatefulWidget {

  const LogDisplay({super.key});

  @override
  State<LogDisplay> createState() => _LogDisplayState();
}

class _LogDisplayState extends State<LogDisplay> {

  @override
  Widget build(BuildContext context) {
    List<String> entries = List<String>.from(CircularLogOutput.logBuffer);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Log"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {});();
              }),
          IconButton(icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                setState(() {
                  CircularLogOutput.clearLog();
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
