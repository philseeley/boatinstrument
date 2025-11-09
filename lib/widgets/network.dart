import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:flutter/material.dart';

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
        Text('Uptime: ${_uptime==null?'-':duration2String(_uptime!)}'),
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
