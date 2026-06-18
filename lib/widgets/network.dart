import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StarlinkBox extends BoxWidget {
  static const sid = 'starlink';
  @override
  String get id => sid;

  const StarlinkBox(super.config, {super.key});

  @override
  State<StatefulWidget> createState() => _StarlinkBoxState();

  @override
  Widget? getHelp() => const HelpPage(text: 'Ensure the **signalk-starlink** plugin is installed on signalk. The gauge shows the percentage of obstructions.');
}

class _StarlinkBoxState extends State<StarlinkBox> with DoubleValeBoxPainter {
  String? _hardware;
  String? _status;
  Duration? _uptime;
  String? _countryCode;
  double? _fractionObstructed;
  Color? _unobstructedColor;
  Color? _obstructedColor;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(onUpdate: _onUpdate, paths: { 'network.providers.starlink.*' }, dataType: SignalKDataType.infrequent);
  }

  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      _hardware = "actuated";
      _status = 'offline';
      _uptime = Duration(hours: 12, minutes: 18);
      _countryCode = 'XZ';
      _fractionObstructed = 0.123;
    }

    if(_unobstructedColor == null) {
      _unobstructedColor = widget.config.controller.val2PSColor(context, 1, none: Colors.white);
      _obstructedColor = widget.config.controller.val2PSColor(context, -1, none: Colors.black);
    }

    Widget main = Container();
    if(_hardware != null) {
      String filename = 'standard.png';

      if(_hardware!.startsWith('mini')) {
        filename = 'mini.png';
      } else if(_hardware!.startsWith('rev4_hp_')) {
        filename = 'performance-gen3.png';
      } else if(_hardware!.startsWith('rev_hp1')) {
        filename = 'performance-gen2.png';
      } else if(_hardware!.startsWith('rev3')) {
        filename = 'standard-actuated.png';
      }

      main = Image(width: double.infinity, image: AssetImage('assets/starlink/$filename'));
    }

    return Container(
      padding: const EdgeInsets.all(5.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Starlink: ${_status??'-'} ${_countryCode??''}'),
        Expanded(child: main),
        if(_fractionObstructed != null) Container(decoration: BoxDecoration(border: BoxBorder.all(width: 2.0, color: Colors.grey)), child: LinearProgressIndicator(value: 1.0-(_fractionObstructed??1.0), color: _unobstructedColor, backgroundColor: _obstructedColor, minHeight: 10)),
        Text('Uptime: ${_uptime==null?'-':duration2HumanString(_uptime!)}'),
      ])
    );
  }

  void _onUpdate(List<Update> updates) {
    if(updates[0].value == null) {
      _hardware = _status = _uptime = _countryCode = _fractionObstructed = null;
    } else {
      for (Update u in updates) {
        try {
          switch (u.path) {
            case 'network.providers.starlink.hardware':
              _hardware = u.value as String;
              break;
            case 'network.providers.starlink.status':
              _status = u.value as String;
              break;
            case 'network.providers.starlink.uptime':
              _uptime = Duration(seconds: int.parse(u.value as String));
              break;
            case 'network.providers.starlink.country_code':
              _countryCode = u.value as String;
              break;
            case 'network.providers.starlink.fraction_obstructed':
              _fractionObstructed = (u.value as num).toDouble();
              break;
          }
        } catch (e) {
          widget.config.controller.l.e("Error converting $u", error: e);
        }
      }
    }

    if(mounted) {
      setState(() {});
    }
  }
}

class NoForeignLandBox extends BoxWidget {
  static const sid = 'noforeignland';
  @override
  String get id => sid;

  const NoForeignLandBox(super.config, {super.key});

  @override
  State<NoForeignLandBox> createState() => _NoForeignLandBNoxState();

  @override
  Widget? getHelp() => const HelpPage(text: '''Ensure the **@noforeignland/signalk-to-noforeignland** plugin is installed and configured on SignalK.
  
Press and hold the ![delta](assets/icons/__THEME__/change_history.png) button to show how long ago the location save or upload occurred.''');
}

class _NoForeignLandBNoxState extends HeadedBoxState<NoForeignLandBox> {
  DateTime? _savePoint;
  DateTime? _sentToApi;
  String? _source;
  int _statusBoolean = 1;
  bool _showDelta = false;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(onUpdate: _onUpdate, paths: {'noforeignland.*'}, dataType: SignalKDataType.static);
    actions = [
      GestureDetector(
        onTapDown: (_) => _setShowDelta(true),
        onTapUp: (_) => _setShowDelta(false),
        onTapCancel: () => _setShowDelta(false),
        child: Icon(Icons.change_history),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    var now = widget.config.controller.now();
    var textBgColor = Theme.of(context).colorScheme.surface;

    var oldest = _savePoint??_sentToApi??now;
    String dateFmt = (oldest.month != now.month || oldest.day != now.day)?'MMM-dd ':'';
    DateFormat fmt = DateFormat('${dateFmt}HH:mm');

    header = 'NFL: ${_statusBoolean==0?'Ok':'Error'} ${_source??''}';

    var text = 'Saved: ${_fmtDateTime(now, fmt, _savePoint)}\nSent:  ${_fmtDateTime(now, fmt, _sentToApi)}';

    body =  Stack(alignment: AlignmentGeometry.center, children: [
      Image(image: AssetImage('assets/noforeignland.png')),
      MaxTextWidget(text, textBgColor: textBgColor)
    ]);

    return super.build(context);
  }

  void _setShowDelta(bool value) {
    setState(() {
      _showDelta = value;
    });
  }

  String _fmtDateTime(DateTime now, DateFormat fmt, DateTime? dt) {
    return dt==null?'-':_showDelta?duration2HumanString(now.difference(dt.toLocal())):fmt.format(dt.toLocal());
  }
  
  void _onUpdate(List<Update> updates) {
    for (Update u in updates) {
      try {
        switch (u.path) {
          case 'noforeignland.savepoint':
            _savePoint = u.value==null?null:DateTime.parse(u.value);
            break;
          case 'noforeignland.sent_to_api':
            _sentToApi = u.value==null?null:DateTime.parse(u.value);
            break;
          case 'noforeignland.source':
            _source = u.value;
            break;
          case 'noforeignland.status_boolean':
            _statusBoolean = u.value==null?1:(u.value as num).toInt();
            break;
        }
      } catch (e) {
        widget.config.controller.l.e("Error converting $u", error: e);
      }
    }

    if(mounted) {
      setState(() {});
    }
  }
}
