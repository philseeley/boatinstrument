import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
          IconButton(tooltip: 'Share', icon: const Icon(Icons.share),
              onPressed: () {
                _share(entries);
              },
          ),
          IconButton(tooltip: 'Refresh', icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {});();
              }),
          IconButton(tooltip: 'Clear', icon: const Icon(Icons.delete_sweep),
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
    await SharePlus.instance.share(ShareParams(text: entries.join('\n'), subject: 'Boat Instrument Log'));
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

class _NotificationItem {
  String path;
  NotificationStatus status;

  _NotificationItem(this.path, this.status);
}

class NotificationLogDisplay extends StatefulWidget {
  final Map<String, NotificationStatus> _notifications;

  const NotificationLogDisplay(this._notifications, {super.key});

  @override
  State<NotificationLogDisplay> createState() => _NotificationLogDisplayState();
}

class _NotificationLogDisplayState extends State<NotificationLogDisplay> {
  final dateFmt = DateFormat("yyyy-MM-dd kk:mm:ss");

  @override
  Widget build(BuildContext context) {
    List<_NotificationItem> notifications = [];

    for(String path in widget._notifications.keys) {
      notifications.add(_NotificationItem(path, widget._notifications[path]!));
    }

    notifications.sort((a, b) => b.status.last.compareTo(a.status.last));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (BuildContext context, int index) {
          _NotificationItem ni = notifications[index];
          return ListTile(
            leading: Text(dateFmt.format(ni.status.last)),
            title: Row(children: [
              Text(ni.status.message),
              if(ni.status.mute) Icon(Icons.volume_off)
            ]),
            subtitle: Text('${ni.status.state.name}(${ni.status.count}) ${ni.path}'));
        }
      )
    );
  }
}
