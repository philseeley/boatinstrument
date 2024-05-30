import 'dart:math';

import 'package:flutter/material.dart';
import 'package:boatinstrument/boatinstrument_controller.dart';

enum WindRoseType {
  normal,
  closeHaul,
  auto
}

class _RosePainter extends CustomPainter {
  final BuildContext _context;
  final WindRoseType _type;

  _RosePainter(this._context, this._type);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    Color fg = Theme.of(_context).colorScheme.onSurface;
    double size = min(canvasSize.width, canvasSize.height);
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = fg
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(size/2, size/2), size/2, paint);
    paint..strokeWidth = 20.0..color = Colors.green;
    canvas.drawArc(const Offset(10.0, 10.0) & Size(size-20.0, size-20.0), deg2Rad(20)-(pi/2), deg2Rad(40), false, paint);
    paint.color = Colors.red;
    canvas.drawArc(const Offset(10.0, 10.0) & Size(size-20.0, size-20.0), deg2Rad(300)-(pi/2), deg2Rad(40), false, paint);
    paint.color = fg;
    for(int a = 0; a < 360; a += 10) {
      paint.strokeWidth = 10.0;
      if (a % 30 == 0) {
        paint.strokeWidth = 20.0;
      }
      canvas.drawArc(const Offset(10.0, 10.0) & Size(size-20.0, size-20.0), deg2Rad(a)-(pi/2)-0.005, 0.01, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NeedlePainter extends CustomPainter {

  final Color _color;
  final double _angle;

  _NeedlePainter(this._color, this._angle);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    double size = min(canvasSize.width, canvasSize.height);
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = _color;

    Path needle = Path()
      ..moveTo(-10.0, 0.0)
      ..lineTo(0.0, -size/2)
      ..lineTo(10.0, 0.0)
      ..moveTo(0.0, 0.0)
      ..addArc(const Offset(-10, -10.0) & const Size(20.0, 20.0), 0.0, pi)
      ..close();
    canvas.translate(size/2, size/2);
    canvas.rotate(_angle);
    canvas.drawPath(needle, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WindRoseCHBox extends WindRoseBox {
  const WindRoseCHBox(super.controller, super._, super.constraints, {super.type = WindRoseType.closeHaul, super.key});

  static String sid = 'wind-rose-ch';
  @override
  String get id => sid;
}

class WindRoseBox extends BoxWidget {
  final WindRoseType _type;

  const WindRoseBox(super.controller, _, super.constraints, {type = WindRoseType.normal, super.key}) : _type = type;

  @override
  State<WindRoseBox> createState() => _WindRoseBoxState();

  static String sid = 'wind-rose';
  @override
  String get id => sid;
}

class _WindRoseBoxState extends State<WindRoseBox> {
  double? _windAngleApparent;
  double? _windAngleTrue;

  @override
  void initState() {
    super.initState();
    widget.controller.configure(widget, onUpdate: _processData, paths: {
      'environment.wind.angleApparent',
      'environment.wind.angleTrueWater'
    });
  }

  @override
  Widget build(BuildContext context) {
    double angleApparent = _windAngleApparent??0.0;
    double angleTrue = _windAngleTrue??0.0;

    List<Widget> stack = [
      CustomPaint(size: Size.infinite, painter: _RosePainter(context, widget._type))
    ];

    if(_windAngleTrue != null) {
      stack.add(CustomPaint(size: Size.infinite, painter: _NeedlePainter(Colors.yellow, angleTrue)));
    }

    if(_windAngleApparent != null) {
      stack.add(CustomPaint(size: Size.infinite, painter: _NeedlePainter(Colors.blue, angleApparent)));
    }
    return Container(padding: const EdgeInsets.all(20.0), child: Stack(children: stack));
  }

  _processData(List<Update> updates) {
    for (Update u in updates) {
      try {
        switch (u.path) {
          case 'environment.wind.angleApparent':
            double latest = (u.value as num).toDouble();
            _windAngleApparent = averageAngle(
                _windAngleApparent ?? latest, latest,
                smooth: widget.controller.valueSmoothing);
            break;
          case 'environment.wind.angleTrueWater':
            double latest = (u.value as num).toDouble();
            _windAngleTrue = averageAngle(
                _windAngleTrue ?? latest, latest,
                smooth: widget.controller.valueSmoothing);
            break;
        }
      } catch (e) {
        widget.controller.l.e("Error converting $u", error: e);
      }

      if (mounted) {
        setState(() {});
      }
    }
  }
}
