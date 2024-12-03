import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

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
          IconButton(icon: const Icon(Icons.share),
              onPressed: () {
                _share(entries);
              },
          ),
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

  void _share (List<String> entries) async {
    await Share.share(entries.join('\n'), subject: 'Boat Instrument Log');
  }
}

class ChangeLogPage extends StatefulWidget {
  const ChangeLogPage({super.key});

  
  @override
  State<ChangeLogPage> createState() => _ChangeLogState();
}

class _ChangeLogState extends State<ChangeLogPage> {
  static Text? _log;

  @override
  void initState() {
    super.initState();
    _loadLog();
  }
  
  _loadLog() async {
    if(_log == null) {
      String s = await rootBundle.loadString('assets/changelog');
      setState(() {
        _log = Text(s);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(_log == null) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Change Log')),
      body: SingleChildScrollView(child: _log!));
  }
}