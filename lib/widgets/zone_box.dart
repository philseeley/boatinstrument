import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:json_annotation/json_annotation.dart';

// part 'wind_rose_box.g.dart';

enum WindRoseType implements EnumMenuEntry {
  normal('Normal'),
  closeHaul('Close Haul'),
  auto('Auto');

  @override
  String get displayName => _displayName;
  final String _displayName;

  const WindRoseType(this._displayName);
}

@JsonSerializable()
class _Settings {
  WindRoseType type;
  bool showLabels;
  bool showButton;
  int autoSwitchingDelay;
  bool showSpeeds;
  bool showTrueWind;
  bool maximizeSpeedBoxes;
  bool trueWindNeedleOnTop;

  _Settings({
    this.type = WindRoseType.normal,
    this.showLabels = true,
    this.showButton = false,
    this.autoSwitchingDelay = 15,
    this.showSpeeds = true,
    this.showTrueWind = true,
    this.maximizeSpeedBoxes = false,
    this.trueWindNeedleOnTop = false
  });
}

class ZoneSetupBox extends BoxWidget {
  late final _Settings _settings;

  ZoneSetupBox(super.config, {super.key}) {
    // _settings = _$SettingsFromJson(config.settings);
  }

  @override
  State<ZoneSetupBox> createState() => _ZoneSetupBoxState();

  static String sid = 'zone-setup';
  @override
  String get id => sid;

  @override
  bool get hasPerBoxSettings => true;

  // @override
  // BoxSettingsWidget getPerBoxSettingsWidget() {
  //   return _SettingsWidget(_settings);
  // }

//   @override
//   Widget? getPerBoxSettingsHelp() => const HelpPage(text: '''In **Auto** mode the Rose will switch between the "Normal" and "Close Haul" displays if the needle transitions over 60 degrees for more than the **Auto Switch Delay**.
  
// The **Switch Button** allows you to cycle through the Wind Rose types from the display. If the button is "Unlocked" the display is in "Auto" mode.''');
}

class _ZoneSetupBoxState extends State<ZoneSetupBox> {

  @override
  void initState() {
    super.initState();
    // Set<String> paths = {
    //   'environment.wind.angleApparent',
    //   'environment.wind.angleTrueWater'
    // };
    // if(widget._settings.showSpeeds) {
    //   paths.addAll({
    //     'environment.wind.speedApparent',
    //     'environment.wind.speedTrue'});
    // }
    widget.config.controller.configure(onUpdate: _processData);
  }

  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      // _windAngleApparent = deg2Rad(123);
      // _windAngleTrue = deg2Rad(90);
      // _windSpeedApparent = _windSpeedTrue = widget.config.controller.windSpeedFromDisplay(12.3);
    }

    return Container(padding: const EdgeInsets.all(5.0), child: IconButton(onPressed: _test, icon: Icon(Icons.set_meal)));
  }

  void _test () {
    print('TEST');
    widget.config.controller.sendMetaUpdate('environment.wind.speedApparent', {
      "zones": [
        { "lower": 7, "state": "warn",  "message": "AWS to high" }
      ]
    });
  }

  void _processData(List<Update> updates) {
    for (Update u in updates) {
      try {
        // double latest = (u.value == null) ? 0 : (u.value as num).toDouble();
        // switch (u.path) {
        //   case 'environment.wind.angleApparent':
        //     if(u.value == null) {
        //       _windAngleApparent = null;
        //     } else {
        //       if(_windAngleApparent == null && widget._settings.type == WindRoseType.auto) {
        //         _displayType = (rad2Deg(latest.abs()) <= 60) ? WindRoseType.closeHaul : WindRoseType.normal;
        //       }

        //       _windAngleApparent = averageAngle(
        //           _windAngleApparent ?? latest, latest,
        //           smooth: widget.config.controller.valueSmoothing,
        //           relative: true);
        //     }
        //     break;
        //   case 'environment.wind.angleTrueWater':
        //     if(u.value == null) {
        //       _windAngleTrue = null;
        //     } else {
        //       _windAngleTrue = averageAngle(
        //           _windAngleTrue ?? latest, latest,
        //           smooth: widget.config.controller.valueSmoothing,
        //           relative: true);
        //     }
        //     break;
        //   case 'environment.wind.speedApparent':
        //     if(u.value == null) {
        //       _windSpeedApparent = null;
        //     } else {
        //       _windSpeedApparent = averageDouble(
        //           _windSpeedApparent ?? latest, latest,
        //           smooth: widget.config.controller.valueSmoothing);
        //     }
        //     break;
        //   case 'environment.wind.speedTrue':
        //     if(u.value == null) {
        //       _windSpeedTrue = null;
        //     } else {
        //       _windSpeedTrue = averageDouble(
        //           _windSpeedTrue ?? latest, latest,
        //           smooth: widget.config.controller.valueSmoothing);
        //     }
        //     break;
        // }
      } catch (e) {
        widget.config.controller.l.e("Error converting $u", error: e);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }
}

// class _SettingsWidget extends BoxSettingsWidget {
//   final _Settings _settings;

//   const _SettingsWidget(this._settings);

//   @override
//   Map<String, dynamic> getSettingsJson() {
//     return _$SettingsToJson(_settings);
//   }

//   @override
//   createState() => _SettingsState();
// }

// class _SettingsState extends State<_SettingsWidget> {

//   @override
//   Widget build(BuildContext context) {
//     _Settings s = widget._settings;

//     return ListView(children: [
//       ListTile(
//           leading: const Text("Type:"),
//           title: EnumDropdownMenu(WindRoseType.values, widget._settings.type, (value) {widget._settings.type = value!;})
//       ),
//       SwitchListTile(title: const Text("Show True Wind:"),
//           value: s.showTrueWind,
//           onChanged: (bool value) {
//             setState(() {
//               s.showTrueWind = value;
//             });
//           }),
//       SwitchListTile(title: const Text("True Needle on Top:"),
//           value: s.trueWindNeedleOnTop,
//           onChanged: (bool value) {
//             setState(() {
//               s.trueWindNeedleOnTop = value;
//             });
//           }),
//       SwitchListTile(title: const Text("Show Speeds:"),
//           value: s.showSpeeds,
//           onChanged: (bool value) {
//             setState(() {
//               s.showSpeeds = value;
//             });
//           }),
//       SwitchListTile(title: const Text("Maximize Speed Boxes:"),
//           value: s.maximizeSpeedBoxes,
//           onChanged: (bool value) {
//             setState(() {
//               s.maximizeSpeedBoxes = value;
//             });
//           }),
//       SwitchListTile(title: const Text("Show Labels:"),
//           value: s.showLabels,
//           onChanged: (bool value) {
//             setState(() {
//               s.showLabels = value;
//             });
//           }),
//       SwitchListTile(title: const Text("Show Switch Button:"),
//           value: s.showButton,
//           onChanged: (bool value) {
//             setState(() {
//               s.showButton = value;
//             });
//           }),
//       ListTile(
//         leading: const Text("Auto Switch Delay:"),
//         title: Slider(
//           min: 1,
//           max: 60,
//           divisions: 12,
//           value: s.autoSwitchingDelay.toDouble(),
//           label: "${s.autoSwitchingDelay}",
//           onChanged: (double value) {
//             setState(() {
//               s.autoSwitchingDelay = value.toInt();
//             });
//           }
//         ),
//         trailing: Text('${s.autoSwitchingDelay} $secondsUnits'),
//       ),
//     ]);
//   }
// }
