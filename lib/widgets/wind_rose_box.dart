import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wind_rose_box.g.dart';

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

class _RosePainter extends CustomPainter {
  final BoatInstrumentController _controller;
  final BuildContext _context;
  final _Settings _settings;
  final WindRoseType _type;

  _RosePainter(this._controller, this._context, this._settings, this._type);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    Color fg = Theme.of(_context).colorScheme.onSurface;
    double size = min(canvasSize.width, canvasSize.height);

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = fg
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(size/2, size/2), size/2, paint);

    int multi = 1;
    if(_type == WindRoseType.closeHaul) {
      multi = 2;
    }
    paint..strokeWidth = 20.0..color = _controller.val2PSColor(_context, 1, none: Colors.grey);
    canvas.drawArc(const Offset(10.0, 10.0) & Size(size-20.0, size-20.0), deg2Rad((20*multi).toInt())-(pi/2), deg2Rad((40*multi).toInt()), false, paint);
    paint.color = _controller.val2PSColor(_context, -1, none: Colors.grey);
    canvas.drawArc(const Offset(10.0, 10.0) & Size(size-20.0, size-20.0), deg2Rad((-20*multi).toInt())-(pi/2), deg2Rad((-40*multi).toInt()), false, paint);
    paint.color = fg;

    for(int a = 0; a <= 180; a += 10) {
      paint.strokeWidth = 10.0;
      double width = 0.01;
      if (a % 30 == 0) {
        paint.strokeWidth = 20.0;
        width = 0.02;
      }

      int adjustedA = a;
      if(_type == WindRoseType.closeHaul) {
        if(a <= 60) {
          adjustedA *= 2;
        } else {
          adjustedA -= 60;
          adjustedA ~/= 2;
          adjustedA += 120;
        }
      }

      canvas.drawArc(const Offset(10.0, 10.0) & Size(size-20.0, size-20.0), deg2Rad(adjustedA)-(pi/2)-(width/2), width, false, paint);
      canvas.drawArc(const Offset(10.0, 10.0) & Size(size-20.0, size-20.0), deg2Rad(-adjustedA)-(pi/2)-(width/2), width, false, paint);
    }

    if(_settings.showLabels) {
      TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
      try {
        canvas.translate(size / 2, size / 2);
        for (int a = 0; a <= 180; a += 30) {
          tp.text = TextSpan(
              text: a.toString(),
              style: Theme.of(_context).textTheme.bodyMedium);
          tp.layout();

          int adjustedA = a;
          if (_type == WindRoseType.closeHaul) {
            if (a <= 60) {
              adjustedA *= 2;
            } else {
              adjustedA -= 60;
              adjustedA ~/= 2;
              adjustedA += 120;
            }
          }

          double x = cos(deg2Rad(adjustedA) - (pi / 2)) * (size / 2 - 40.0);
          double y = sin(deg2Rad(adjustedA) - (pi / 2)) * (size / 2 - 40.0);
          tp.paint(
              canvas, Offset(x - tp.size.width / 2, y - tp.size.height / 2));
          tp.paint(
              canvas, Offset(-x - tp.size.width / 2, y - tp.size.height / 2));
        }
      } finally {
        tp.dispose();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SpeedPainter extends CustomPainter with DoubleValeBoxPainter {
  static GaugeOrientation? _orientation;
  Offset _apparentSpeedLoc = Offset(0, 0);
  Offset _trueSpeedLoc = Offset(0, 0);

  static const double _hubWidth = 12;
  final BoatInstrumentController _controller;
  final BuildContext _context;
  final bool _close;
  final bool _showTrueWind;
  final bool _maximizeSpeedBoxes;
  final double _apparentDirection;
  final double? _apparentSpeed;
  final double? _trueSpeed;

  _SpeedPainter(this._controller, this._context, WindRoseType type, this._showTrueWind, this._maximizeSpeedBoxes, this._apparentDirection, this._apparentSpeed, this._trueSpeed) : _close = type == WindRoseType.closeHaul;

  void _calcSpeedLoc (double centre, double speedSize) {
    switch (_orientation) {
      case null:
      case GaugeOrientation.down:
        if(_showTrueWind) {
          _apparentSpeedLoc = Offset(centre-_hubWidth-speedSize, centre+_hubWidth);
          _trueSpeedLoc = Offset(centre+_hubWidth, centre+_hubWidth);
        } else {
          _apparentSpeedLoc = Offset(centre-(speedSize/2), centre+_hubWidth);
        }
        break;
      case GaugeOrientation.up:
      if(_showTrueWind) {
        _apparentSpeedLoc = Offset(centre-_hubWidth-speedSize, centre-_hubWidth-speedSize);
        _trueSpeedLoc = Offset(centre+_hubWidth, centre-_hubWidth-speedSize);
      } else {
        _apparentSpeedLoc = Offset(centre-(speedSize/2), centre-_hubWidth-speedSize);
      }
      break;
    case GaugeOrientation.right:
      if(_showTrueWind) {
        _apparentSpeedLoc = Offset(centre+_hubWidth, centre-_hubWidth-speedSize);
        _trueSpeedLoc = Offset(centre+_hubWidth, centre+_hubWidth);
      } else {
        _apparentSpeedLoc = Offset(centre+_hubWidth, centre-(speedSize/2));
      }
      break;
    case GaugeOrientation.left:
      if(_showTrueWind) {
        _apparentSpeedLoc = Offset(centre-_hubWidth-speedSize, centre-_hubWidth-speedSize);
        _trueSpeedLoc = Offset(centre-_hubWidth-speedSize, centre+_hubWidth);
      } else {
        _apparentSpeedLoc = Offset(centre-_hubWidth-speedSize, centre-(speedSize/2));
      }
    }
  }

  @override
  void paint(Canvas canvas, Size canvasSize) {
    double centre = min(canvasSize.width, canvasSize.height)/2;
    TextStyle style = Theme.of(_context).textTheme.bodyMedium!.copyWith(height: 1.0);

    double speedSize = centre-_hubWidth-40;
    if(_showTrueWind) {
      speedSize = sqrt(((centre-style.fontSize!-_hubWidth)*(centre-style.fontSize!-_hubWidth))/2);
    }
    if(_maximizeSpeedBoxes) speedSize = centre-_hubWidth;

    switch (_orientation) {
      case null:
        _orientation = GaugeOrientation.down;
      case GaugeOrientation.down:
        if(_apparentDirection > deg2Rad(_close ? 40 : 80)) {
          _orientation = GaugeOrientation.left;
        } else if(_apparentDirection < deg2Rad(_close ? -40 : -80)) {
          _orientation = GaugeOrientation.right;
        }
        break;
      case GaugeOrientation.left:
        if(_apparentDirection < deg2Rad(10)) {
          _orientation = GaugeOrientation.down;
        } else if(_apparentDirection > deg2Rad(170)) {
          _orientation = GaugeOrientation.up;
        }
        break;
      case GaugeOrientation.up:
        if(_apparentDirection.abs() < deg2Rad(_close ? 50 : 100)) {
          if(_apparentDirection > 0) {
            _orientation = GaugeOrientation.left;
          } else {
            _orientation = GaugeOrientation.right;
          }
        }
        break;
      case GaugeOrientation.right:
        if(_apparentDirection > deg2Rad(-10)) {
          _orientation = GaugeOrientation.down;
        } else if(_apparentDirection < deg2Rad(-170)) {
          _orientation = GaugeOrientation.up;
        }
    }

    _calcSpeedLoc(centre, speedSize);

    paintDoubleBox(canvas, _context, 'AWS', _controller.windSpeedUnits.unit, 2, 0, (_apparentSpeed == null)?_apparentSpeed:_controller.windSpeedToDisplay(_apparentSpeed), _apparentSpeedLoc, speedSize);

    if(_showTrueWind) {
      paintDoubleBox(canvas, _context, 'TWS', _controller.windSpeedUnits.unit, 2, 0, (_trueSpeed == null)?_trueSpeed:_controller.windSpeedToDisplay(_trueSpeed), _trueSpeedLoc, speedSize); 
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _NeedlePainter extends CustomPainter {

  final WindRoseType _type;
  final Color _color;
  final double _angle;

  _NeedlePainter(this._type, this._color, this._angle);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    double size = min(canvasSize.width, canvasSize.height);
    double nW = size/20;
    nW = min(nW, 10);

    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = _color;

    Path needle = Path()
      ..moveTo(-nW, 0.0)
      ..lineTo(0.0, -size/2)
      ..lineTo(nW, 0.0)
      ..moveTo(0.0, 0.0)
      ..addArc(Offset(-nW, -nW) & Size(nW*2, nW*2), 0.0, pi)
      ..close();

    int adjustedA = rad2Deg(_angle);
    if(_type == WindRoseType.closeHaul) {
      if(adjustedA.abs() <= 60) {
        adjustedA *= 2;
      } else {
        adjustedA -= (_angle < 0) ? -60 : 60;
        adjustedA ~/= 2;
        adjustedA += (_angle < 0) ? -120 : 120;
      }
    }

    canvas.translate(size/2, size/2);
    canvas.rotate(deg2Rad(adjustedA));
    canvas.drawPath(needle, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WindRoseBox extends BoxWidget {
  late final _Settings _settings;

   WindRoseBox(super.config, {super.key}) {
    _settings = _$SettingsFromJson(config.settings);
  }

  @override
  State<WindRoseBox> createState() => _WindRoseBoxState();

  static String sid = 'wind-rose';
  @override
  String get id => sid;

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _SettingsWidget(_settings);
  }

  @override
  Widget? getPerBoxSettingsHelp() => const HelpTextWidget('''In "Auto" mode the Rose will switch between the "Normal" and "Close Haul" displays if the needle transitions over 60 degrees for more than the "Auto Switch Delay".
  
The Switch Button allows you to cycle through the Wind Rose types from the display. If the button is "Unlocked" the display is in "Auto" mode.''');
}

class _WindRoseBoxState extends State<WindRoseBox> {
  double? _windAngleApparent;
  double? _windAngleTrue;
  double? _windSpeedApparent;
  double? _windSpeedTrue;
  WindRoseType _displayType = WindRoseType.normal;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    Set<String> paths = {
      'environment.wind.angleApparent',
      'environment.wind.angleTrueWater'
    };
    if(widget._settings.showSpeeds) {
      paths.addAll({
        'environment.wind.speedApparent',
        'environment.wind.speedTrue'});
    }
    widget.config.controller.configure(onUpdate: _processData, paths: paths);
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      _windAngleApparent = deg2Rad(123);
      _windAngleTrue = deg2Rad(90);
      _windSpeedApparent = _windSpeedTrue = widget.config.controller.windSpeedFromDisplay(12.3);
    }

    if(widget._settings.type == WindRoseType.auto) {
      if((_displayType == WindRoseType.normal && rad2Deg(_windAngleApparent).abs() <= 60) ||
         (_displayType == WindRoseType.closeHaul && rad2Deg(_windAngleApparent).abs() > 60)) {
        _autoTimer ??= Timer(Duration(seconds: widget._settings.autoSwitchingDelay), () {
          _displayType = (_displayType == WindRoseType.normal) ? WindRoseType.closeHaul : WindRoseType.normal;
        });
      } else {
        _autoTimer?.cancel();
        _autoTimer = null;
      }
    } else {
      _autoTimer?.cancel();
      _autoTimer = null;

      _displayType = widget._settings.type;
    }

    List<Widget> stack = [
      CustomPaint(size: Size.infinite, painter: _RosePainter(widget.config.controller, context, widget._settings, _displayType))
    ];

    if(widget._settings.showTrueWind && _windAngleTrue != null && !widget._settings.trueWindNeedleOnTop) {
      stack.add(CustomPaint(size: Size.infinite, painter: _NeedlePainter(_displayType, Colors.yellow, _windAngleTrue!)));
    }

    if(widget._settings.showSpeeds) {
      stack.add(CustomPaint(size: Size.infinite, painter: _SpeedPainter(widget.config.controller, context, _displayType, widget._settings.showTrueWind, widget._settings.maximizeSpeedBoxes, _windAngleApparent??0, _windSpeedApparent, _windSpeedTrue)));
    }

    if(widget._settings.showTrueWind && _windAngleTrue != null && widget._settings.trueWindNeedleOnTop) {
      stack.add(CustomPaint(size: Size.infinite, painter: _NeedlePainter(_displayType, Colors.yellow, _windAngleTrue!)));
    }

    if(_windAngleApparent != null) {
      stack.add(CustomPaint(size: Size.infinite, painter: _NeedlePainter(_displayType, Colors.blue, _windAngleApparent!)));
    }

    if(widget._settings.showButton) {
      stack.add(Positioned(right: 0, bottom: 0, child:
      IconButton(icon: Icon((widget._settings.type == WindRoseType.auto) ? Icons.lock_open : Icons.lock),
          onPressed: _cycleType))
      );
    }

    // We wrap the rose in a RepaintBoundary so that other changes on the screen don't force a repaint.
    return Container(padding: const EdgeInsets.all(5.0), child: RepaintBoundary(child: Stack(children: stack)));
  }

  void _cycleType () {
    setState(() {
      int i = widget._settings.type.index;
      ++i;
      i = (i >= WindRoseType.values.length) ? 0 : i;
      widget._settings.type = WindRoseType.values[i];
    });
  }

  void _processData(List<Update>? updates) {
    if(updates == null) {
      _windAngleApparent = _windAngleTrue = _windSpeedApparent = _windSpeedTrue = null;
    } else {
      for (Update u in updates) {
        try {
          switch (u.path) {
            case 'environment.wind.angleApparent':
              double latest = (u.value as num).toDouble();

              if(_windAngleApparent == null && widget._settings.type == WindRoseType.auto) {
                _displayType = (rad2Deg(latest.abs()) <= 60) ? WindRoseType.closeHaul : WindRoseType.normal;
              }

              _windAngleApparent = averageAngle(
                  _windAngleApparent ?? latest, latest,
                  smooth: widget.config.controller.valueSmoothing,
                  relative: true);
              break;
            case 'environment.wind.angleTrueWater':
              double latest = (u.value as num).toDouble();
              _windAngleTrue = averageAngle(
                  _windAngleTrue ?? latest, latest,
                  smooth: widget.config.controller.valueSmoothing,
                  relative: true);
              break;
            case 'environment.wind.speedApparent':
              double latest = (u.value as num).toDouble();
              _windSpeedApparent = averageDouble(
                  _windSpeedApparent ?? latest, latest,
                  smooth: widget.config.controller.valueSmoothing);
              break;
            case 'environment.wind.speedTrue':
              double latest = (u.value as num).toDouble();
              _windSpeedTrue = averageDouble(
                  _windSpeedTrue ?? latest, latest,
                  smooth: widget.config.controller.valueSmoothing);
              break;
          }
        } catch (e) {
          widget.config.controller.l.e("Error converting $u", error: e);
        }
      }
    }

    if (mounted) {
      setState(() {});
    }
  }
}

class _SettingsWidget extends BoxSettingsWidget {
  final _Settings _settings;

  const _SettingsWidget(this._settings);

  @override
  Map<String, dynamic> getSettingsJson() {
    return _$SettingsToJson(_settings);
  }

  @override
  createState() => _SettingsState();
}

class _SettingsState extends State<_SettingsWidget> {

  @override
  Widget build(BuildContext context) {
    _Settings s = widget._settings;

    return ListView(children: [
      ListTile(
          leading: const Text("Type:"),
          title: EnumDropdownMenu(WindRoseType.values, widget._settings.type, (value) {widget._settings.type = value!;})
      ),
      SwitchListTile(title: const Text("Show True Wind:"),
          value: s.showTrueWind,
          onChanged: (bool value) {
            setState(() {
              s.showTrueWind = value;
            });
          }),
      SwitchListTile(title: const Text("True Needle on Top:"),
          value: s.trueWindNeedleOnTop,
          onChanged: (bool value) {
            setState(() {
              s.trueWindNeedleOnTop = value;
            });
          }),
      SwitchListTile(title: const Text("Show Speeds:"),
          value: s.showSpeeds,
          onChanged: (bool value) {
            setState(() {
              s.showSpeeds = value;
            });
          }),
      SwitchListTile(title: const Text("Maximize Speed Boxes:"),
          value: s.maximizeSpeedBoxes,
          onChanged: (bool value) {
            setState(() {
              s.maximizeSpeedBoxes = value;
            });
          }),
      SwitchListTile(title: const Text("Show Labels:"),
          value: s.showLabels,
          onChanged: (bool value) {
            setState(() {
              s.showLabels = value;
            });
          }),
      SwitchListTile(title: const Text("Show Switch Button:"),
          value: s.showButton,
          onChanged: (bool value) {
            setState(() {
              s.showButton = value;
            });
          }),
      ListTile(
        leading: const Text("Auto Switch Delay:"),
        title: Slider(
            min: 1,
            max: 60,
            divisions: 60,
            value: s.autoSwitchingDelay.toDouble(),
            label: "${s.autoSwitchingDelay}",
            onChanged: (double value) {
              setState(() {
                s.autoSwitchingDelay = value.toInt();
              });
            }),
      ),
    ]);
  }
}
