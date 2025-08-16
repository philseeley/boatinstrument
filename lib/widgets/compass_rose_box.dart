import 'dart:math';

import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';

abstract class CompassBox extends BoxWidget {

  const CompassBox(super.config, {super.key});

  @override
  Widget? getHelp(BuildContext context) => HelpTextWidget('The Blue marker shows your "Course Over Ground" and the Yellow marker the "Bearing to Next Waypoint".');
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
  final double _headingTrue;
  final double? _courseOverGroundTrue;
  final double? _nextWaypointBearing;

  _RosePainter(this._context, this._headingTrue, this._courseOverGroundTrue, this._nextWaypointBearing);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    Color fg = Theme.of(_context).colorScheme.onSurface;
    Color bg = Theme.of(_context).colorScheme.surface;
    double size = min(canvasSize.width, canvasSize.height);

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = fg
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(size/2, size/2), size/2, paint);
    paint.strokeWidth = 4.0;
    canvas.drawLine(Offset(size/2, 0), Offset(size/2, size), paint);
    canvas.drawLine(Offset(0, size/2), Offset(size, size/2), paint);
    canvas.drawLine(Offset(size*0.2, size*0.2), Offset(size*0.8, size*0.8), paint);
    canvas.drawLine(Offset(size*0.2, size*0.8), Offset(size*0.8, size*0.2), paint);

    paintDoubleBox(canvas, _context, 'HDG', degreesUnits, 3, 0, rad2Deg(_headingTrue).toDouble(), Offset(size/3, size/3), size/3);

    for(int a = 0; a < 360; a += 10) {
      paint.strokeWidth = 10.0;
      double width = 0.01;
      if (a % 30 == 0) {
        paint.strokeWidth = 20.0;
        width = 0.02;
      }
    
      canvas.drawArc(const Offset(10.0, 10.0) & Size(size-20.0, size-20.0), deg2Rad(a)-_headingTrue-(pi/2)-(width/2), width, false, paint);
    }

    _paintMarker(canvas, _nextWaypointBearing, size, Colors.yellow, 30);
    _paintMarker(canvas, _courseOverGroundTrue, size, Colors.blue, 20);

    TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    try {
      canvas.translate(size / 2, size / 2);
      for (int a = 0; a < 360; a += 30) {
        tp.text = TextSpan(
            text: a.toString(),
            style: Theme.of(_context).textTheme.bodyMedium!.copyWith(backgroundColor: bg));
        tp.layout();
  
        double x = cos(deg2Rad(a)-_headingTrue - (pi / 2)) * (size / 2 - 40.0);
        double y = sin(deg2Rad(a)-_headingTrue - (pi / 2)) * (size / 2 - 40.0);
        tp.paint(
            canvas, Offset(x - tp.size.width / 2, y - tp.size.height / 2));
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

  const CompassRoseBox(super.config, {super.key});

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
        RepaintBoundary(child: CustomPaint(size: Size.infinite, painter: _RosePainter(context, _headingTrue!, _courseOverGroundTrue, _nextWaypointBearing)))
    );
  }
}

class _GaugePainter extends CustomPainter with DoubleValeBoxPainter {
  final BuildContext _context;
  final double _headingTrue;
  final double? _courseOverGroundTrue;
  final double? _nextWaypointBearing;

  _GaugePainter(this._context, this._headingTrue, this._courseOverGroundTrue, this._nextWaypointBearing);

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
    for(int a = 0; a < 360; a += 10) {
      paint.strokeWidth = 2.0;
      if (a % 30 == 0) {
        paint.strokeWidth = 4.0;
      }
      double x = (a+90-rad2Deg(_headingTrue))%360*m;
      if(x > 0 && x < w) canvas.drawLine(Offset(x, 0.0), Offset(x, h), paint);
    }

    _paintMarker(canvas, _nextWaypointBearing, w, h, m, Colors.yellow, 0.8);
    _paintMarker(canvas, _courseOverGroundTrue, w, h, m, Colors.blue, 0.6);

    TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    try {
      for(int a = 0; a < 360; a += 10) {
        double x = (a+90-rad2Deg(_headingTrue))%360*m;
        if(x > 0 && x < w) {
          tp.text = TextSpan(
            text: a.toString(),
            style: Theme.of(_context).textTheme.bodyMedium!.copyWith(backgroundColor: bg));
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

  const CompassGaugeBox(super.config, {super.key});

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
        RepaintBoundary(child: CustomPaint(size: Size.infinite, painter: _GaugePainter(context, _headingTrue!, _courseOverGroundTrue, _nextWaypointBearing)))
    );
  }
}
