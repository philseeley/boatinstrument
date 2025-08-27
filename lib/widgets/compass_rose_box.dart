import 'dart:math' as m;

import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:json_annotation/json_annotation.dart';

part 'compass_rose_box.g.dart';

@JsonSerializable()
class _Settings {
  bool showCardinal;
  bool showDegrees;

  _Settings({
    this.showCardinal = true,
    this.showDegrees = false
  });
}

abstract class CompassBox extends BoxWidget {
  late final _Settings _settings;

  CompassBox(super.config, {super.key}) {
    _settings = _$SettingsFromJson(config.settings);
  }

  @override
  Widget? getHelp(BuildContext context) => HelpTextWidget('The Blue marker shows your "Course Over Ground" and the Yellow marker the "Bearing to Next Waypoint".');

  @override
  bool get hasPerBoxSettings => true;

  @override
  BoxSettingsWidget getPerBoxSettingsWidget() {
    return _SettingsWidget(_settings);
  }
}

abstract class CompassBoxState<T> extends State<CompassBox> {
  double? _headingTrue;
  double? _courseOverGroundTrue;
  double? _nextWaypointBearing;

  @override
  void initState() {
    super.initState();

    widget.config.controller.configure(onUpdate: _processData, paths: {
      'navigation.headingTrue',
      'navigation.courseOverGroundTrue',
      'navigation.*.nextPoint.bearingTrue'
    });
  }

  void _processData(List<Update>? updates) {
    if(updates == null) {
      _headingTrue = _courseOverGroundTrue = _nextWaypointBearing = null;
    } else {
      for (Update u in updates) {
        try {
          double next = (u.value as num).toDouble();

          switch (u.path) {
            case 'navigation.headingTrue':
              _headingTrue = averageAngle(_headingTrue ?? next, next,
                smooth: widget.config.controller.valueSmoothing);
              break;
            case 'navigation.courseOverGroundTrue':
              _courseOverGroundTrue = averageAngle(_courseOverGroundTrue ?? next, next,
                smooth: widget.config.controller.valueSmoothing);
              break;
            default:
              if(u.path.endsWith('.nextPoint.bearingTrue')) {
                _nextWaypointBearing = averageAngle(_nextWaypointBearing ?? next, next,
                  smooth: widget.config.controller.valueSmoothing);
              }
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

class _RosePainter extends CustomPainter with DoubleValeBoxPainter {
  final BuildContext _context;
  final _Settings _settings;
  final double _headingTrue;
  final double? _courseOverGroundTrue;
  final double? _nextWaypointBearing;

  _RosePainter(this._context, this._settings, this._headingTrue, this._courseOverGroundTrue, this._nextWaypointBearing);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    ThemeData td = Theme.of(_context);
    Color fg = td.colorScheme.onSurface;
    Color bg = td.colorScheme.surface;
    double size = m.min(canvasSize.width, canvasSize.height);

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = fg
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(size/2, size/2), size/2, paint);
    paint.strokeWidth = 4.0;
    canvas.drawLine(Offset(size/2, 0), Offset(size/2, size/2), paint);

    paintDoubleBox(canvas, _context, 'HDG ${rad2Cardinal(_headingTrue)}', degreesUnits, 3, 0, rad2Deg(_headingTrue).toDouble(), Offset(size/3, size/3), size/3);

    double step = 22.5;
    int highlight = 45;
    if(_settings.showDegrees) {
      step = 10;
      highlight = 30;
    }

    for(double a = 0; a < 360; a += step) {
      paint.strokeWidth = 10.0;
      double width = 0.01;
      if (a % 90 == 0) {
        paint.strokeWidth = 30.0;
        width = 0.03;
      } else if (a % highlight == 0) {
        paint.strokeWidth = 20.0;
        width = 0.02;
      }
    
      canvas.drawArc(const Offset(15.0, 15.0) & Size(size-30.0, size-30.0), deg2Rad(a.toInt()) -_headingTrue-(m.pi/2)-(width/2), width, false, paint);
    }

    _paintMarker(canvas, 0, size, fg, 40);
    _paintMarker(canvas, _nextWaypointBearing, size, Colors.yellow, 30);
    _paintMarker(canvas, _courseOverGroundTrue, size, Colors.blue, 20);

    TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    try {
      TextStyle styleLarge = td.textTheme.displaySmall!.copyWith(backgroundColor: bg);
      TextStyle styleSmall = td.textTheme.bodyLarge!.copyWith(backgroundColor: bg);
      
      canvas.translate(size / 2, size / 2);
      for (double a = 0; a < 360; a += step) {
        TextStyle ts = styleSmall;
        if((_settings.showDegrees && a % 30 == 0) ||
           (!_settings.showDegrees && _settings.showCardinal)) {
          String t = a.toInt().toString();
          if(!_settings.showDegrees) t = rad2Cardinal(deg2Rad(a.toInt()));
          if(a % 90 == 0) {
            if(_settings.showCardinal) t = rad2Cardinal(deg2Rad(a.toInt()));
            ts = styleLarge;
          }
          tp.text = TextSpan(
              text: t,
              style: ts);
          tp.textAlign = TextAlign.center;
          tp.layout();
    
          double x = m.cos(deg2Rad(a.toInt())-_headingTrue - (m.pi / 2)) * (size / 2 - ts.fontSize!-30);
          double y = m.sin(deg2Rad(a.toInt())-_headingTrue - (m.pi / 2)) * (size / 2 - ts.fontSize!-30);
          tp.paint(canvas, Offset(x - tp.size.width / 2, y - tp.size.height / 2));
        }
      }
    } finally {
      tp.dispose();
    }
  }

  void _paintMarker(Canvas canvas, double? angle, double size, Color color, double width) {
    const double s = 50;
    if(angle != null) {
      Paint paint = Paint()
          ..color = color
          ..strokeWidth = 0
          ..style = PaintingStyle.fill;

      Path needle = Path()
        ..moveTo(0.0, -size/2)
        ..lineTo(-width, -size/2+s)
        ..lineTo(width, -size/2+s)
        ..close();

      canvas.save();
      canvas.translate(size / 2, size / 2);
      canvas.rotate(angle -_headingTrue);
      canvas.drawPath(needle, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CompassRoseBox extends CompassBox {

  CompassRoseBox(super.config, {super.key});

  @override
  CompassBoxState<CompassRoseBox> createState() => _CompassRoseBoxState();

  static String sid = 'compass-rose';
  @override
  String get id => sid;
}

class _CompassRoseBoxState extends CompassBoxState<CompassRoseBox> {
  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      _headingTrue = _courseOverGroundTrue = _nextWaypointBearing = deg2Rad(123);
    }

    // We wrap the rose in a RepaintBoundary so that other changes on the screen don't force a repaint.
    return Container(padding: const EdgeInsets.all(5.0), child:
      _headingTrue == null ?
        Center(child: Text('-', style: Theme.of(context).textTheme.displayLarge)) :
        RepaintBoundary(child: CustomPaint(size: Size.infinite, painter: _RosePainter(context, widget._settings, _headingTrue!, _courseOverGroundTrue, _nextWaypointBearing)))
    );
  }
}

class _GaugePainter extends CustomPainter with DoubleValeBoxPainter {
  final BuildContext _context;
  final _Settings _settings;
  final double _headingTrue;
  final double? _courseOverGroundTrue;
  final double? _nextWaypointBearing;

  _GaugePainter(this._context, this._settings, this._headingTrue, this._courseOverGroundTrue, this._nextWaypointBearing);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    Color fg = Theme.of(_context).colorScheme.onSurface;
    Color bg = Theme.of(_context).colorScheme.surface;
    double w = canvasSize.width;
    double h = canvasSize.height;

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = fg
      ..strokeWidth = 2.0;

    double m = w/180;
    for(double a = 0; a < 360; a += 22.5) {
      paint.strokeWidth = 2.0;
      if (a % 90 == 0) {
        paint.strokeWidth = 4.0;
      }
      double x = (a+90-rad2Deg(_headingTrue))%360*m;
      if(x > 0 && x < w) canvas.drawLine(Offset(x, 0.0), Offset(x, h), paint);
    }

    _paintMarker(canvas, 0, w, h, m, fg, 1.0);
    _paintMarker(canvas, _nextWaypointBearing, w, h, m, Colors.yellow, 0.8);
    _paintMarker(canvas, _courseOverGroundTrue, w, h, m, Colors.blue, 0.6);

    TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    try {
      for(double a = 0; a < 360; a += 22.5) {
        double x = (a+90-rad2Deg(_headingTrue))%360*m;
        if(x > 0 && x < w) {
          tp.text = TextSpan(
              text: '${_settings.showCardinal ? '${rad2Cardinal(deg2Rad(a.toInt()))}${_settings.showDegrees?'\n':''}' : ''}${_settings.showDegrees ? '${a.toInt()}' : ''}',
              style: Theme.of(_context).textTheme.bodyMedium!.copyWith(backgroundColor: bg));
          tp.textAlign = TextAlign.center;
          tp.layout();
    
          tp.paint(canvas, Offset(x-(tp.size.width)/2, (h-tp.size.height)/2));
        }
      }
    } finally {
      tp.dispose();
    }

    paintDoubleBox(canvas, _context, 'HDG', degreesUnits, 3, 0, rad2Deg(_headingTrue).toDouble(), Offset(w/2-h/2, 0), h, fill: false);
  }

  void _paintMarker(Canvas canvas, double? angle, double w, double h, double m, Color color, double width) {
    if(angle != null) {
      Paint paint = Paint()
          ..color = color
          ..strokeWidth = 0
          ..style = PaintingStyle.fill;

      double x = (rad2Deg(angle)+90-rad2Deg(_headingTrue))%360*m;

      if(x > w) {
        Path p = Path();
        double o = (h-(h*width))/2;
        if(x-w >= w/2) {
          p.moveTo(0, h/2);
          p.lineTo(50, o);
          p.lineTo(50, h-o);
          p.close();
        } else {
          p.moveTo(w, h/2);
          p.lineTo(w-50, o);
          p.lineTo(w-50, h-o);
          p.close();
        }
        canvas.drawPath(p, paint);
      } else {
        canvas.drawCircle(Offset(x, h/2), h/2*width, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CompassGaugeBox extends CompassBox {

  CompassGaugeBox(super.config, {super.key});

  @override
  CompassBoxState<CompassGaugeBox> createState() => _CompassGaugeBoxState();

  static String sid = 'compass-gauge';
  @override
  String get id => sid;
}

class _CompassGaugeBoxState extends CompassBoxState<CompassGaugeBox> {
  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      _headingTrue = _courseOverGroundTrue = _nextWaypointBearing = deg2Rad(123);
    }

    // We wrap the gauge in a RepaintBoundary so that other changes on the screen don't force a repaint.
    return Container(padding: const EdgeInsets.all(5.0), child:
      _headingTrue == null ?
        Center(child: Text('-', style: Theme.of(context).textTheme.displayLarge)) :
        RepaintBoundary(child: CustomPaint(size: Size.infinite, painter: _GaugePainter(context, widget._settings, _headingTrue!, _courseOverGroundTrue, _nextWaypointBearing)))
    );
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
      SwitchListTile(title: const Text("Display Cardinal Values:"),
          value: s.showCardinal,
          onChanged: (bool value) {
            setState(() {
              s.showCardinal = value;
            });
          }),
      SwitchListTile(title: const Text("Display Degrees:"),
          value: s.showDegrees,
          onChanged: (bool value) {
            setState(() {
              s.showDegrees = value;
            });
          }),
    ]);
  }
}

