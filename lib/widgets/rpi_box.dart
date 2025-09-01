import 'dart:math' as m;

import 'package:boatinstrument/boatinstrument_controller.dart';
import 'package:boatinstrument/widgets/double_value_box.dart';
import 'package:boatinstrument/widgets/gauge_box.dart';
import 'package:flutter/material.dart';

const String _help = 'Ensure the signalk-raspberry-pi-monitoring plugin is installed on signalk.';

class RPiCPUTemperatureBox extends DoubleValueBox {
  static const String sid = 'rpi-cpu-temperature';
  @override
  String get id => sid;

  const RPiCPUTemperatureBox(BoxWidgetConfig config, {super.key}) : super(config, 'RPi CPU Temp', 'environment.rpi.cpu.temperature', dataType: SignalKDataType.infrequent);

  @override
  double convert(double value) {
    return config.controller.temperatureToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.temperatureUnits.unit;
  }

  @override
  Widget? getHelp(BuildContext context) => const HelpTextWidget(_help);
}

class RPiGPUTemperatureBox extends DoubleValueBox {
  static const String sid = 'rpi-gpu-temperature';
  @override
  String get id => sid;

  const RPiGPUTemperatureBox(BoxWidgetConfig config, {super.key}) : super(config, 'RPi GPU Temp', 'environment.rpi.gpu.temperature', dataType: SignalKDataType.infrequent);

  @override
  double convert(double value) {
    return config.controller.temperatureToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.temperatureUnits.unit;
  }

  @override
  Widget? getHelp(BuildContext context) => const HelpTextWidget(_help);
}

class RPiCPUUtilisationBox extends DoubleValueSemiGaugeBox {
  static const String sid = 'rpi-cpu-utilisation';
  @override
  String get id => sid;

  const RPiCPUUtilisationBox(BoxWidgetConfig config, {super.key}) : super(
    config,
    'RPi CPU',
    GaugeOrientation.up,
    'environment.rpi.cpu.utilisation',
    maxValue: 1,
    step: 0.25,
    dataType: SignalKDataType.infrequent,
    smoothing: false,
    ranges: const [
      GaugeRange(0, 0.5, Colors.green),
      GaugeRange(0.5, 0.75, Colors.orange),
      GaugeRange(0.75, 1, Colors.red)
    ]);

  @override
  double convert(double value) {
    return value*100;
  }

  @override
  String units(double value) {
    return '%';
  }

  @override
  Widget? getHelp(BuildContext context) => const HelpTextWidget(_help);
}

class RPiMemoryUtilisationBox extends DoubleValueBarGaugeBox {
  static const String sid = 'rpi-memory-utilisation';
  @override
  String get id => sid;

  const RPiMemoryUtilisationBox(BoxWidgetConfig config, {super.key}) : super(
    config,
    'RPi Memory',
    'environment.rpi.memory.utilisation',
    maxValue: 1,
    step: 0.2,
    dataType: SignalKDataType.infrequent,
    smoothing: false,
    ranges: const [
      GaugeRange(0, 0.9, Colors.green),
      GaugeRange(0.9, 1, Colors.red)
    ]);

  @override
  double convert(double value) {
    return value*100;
  }

  @override
  String units(double value) {
    return '%';
  }

  @override
  Widget? getHelp(BuildContext context) => const HelpTextWidget(_help);
}

class RPiSDUtilisationBox extends DoubleValueBarGaugeBox {
  static const String sid = 'rpi-sd-utilisation';
  @override
  String get id => sid;

  const RPiSDUtilisationBox(BoxWidgetConfig config, {super.key}) : super(
    config,
    'RPi SD',
    'environment.rpi.sd.utilisation',
    maxValue: 1,
    step: 0.1,
    dataType: SignalKDataType.infrequent,
    smoothing: false,
    ranges: const [
      GaugeRange(0, 0.7, Colors.green),
      GaugeRange(0.7, 0.9, Colors.orange),
      GaugeRange(0.9, 1, Colors.red)
    ]);

  @override
  double convert(double value) {
    return value*100;
  }

  @override
  String units(double value) {
    return '%';
  }

  @override
  Widget? getHelp(BuildContext context) => const HelpTextWidget(_help);
}

class _RPiDataPainter extends CustomPainter with DoubleValeBoxPainter {
  final BuildContext _context;
  final BoatInstrumentController _controller;
  final double? _cpuTemperature;
  final double? _gpuTemperature;
  final double? _cpuUtilisation;
  final double? _memoryUtilisation;

  const _RPiDataPainter(this._controller, this._context, this._cpuTemperature, this._gpuTemperature, this._cpuUtilisation, this._memoryUtilisation);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    double w = canvasSize.width;
    double h = canvasSize.height;
    double size = m.min(w, h)/2;
    paintDoubleBox(canvas, _context, 'CPU Temp', _controller.temperatureUnits.unit, 2, 1, _cpuTemperature, Offset(0.0, 0.0), size);
    paintDoubleBox(canvas, _context, 'GPU Temp', _controller.temperatureUnits.unit, 2, 1, _gpuTemperature, Offset(w-size, 0.0), size);
    paintDoubleBox(canvas, _context, 'CPU', '%', 2, 0, _cpuUtilisation!=null ? _cpuUtilisation!*100 : _cpuUtilisation, Offset(0.0, h-size), size);
    paintDoubleBox(canvas, _context, 'Mem', '%', 2, 0, _memoryUtilisation!=null ? _memoryUtilisation!*100 : _memoryUtilisation, Offset(w-size, h-size), size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RaspberryPiBox extends BoxWidget {
  static const sid = 'rpi';
  @override
  String get id => sid;

  const RaspberryPiBox(super.config, {super.key});

  @override
  State<StatefulWidget> createState() => _RaspberryPiBoxState();

  @override
  Widget? getHelp(BuildContext context) => const HelpTextWidget(_help);
}

class _RaspberryPiBoxState extends State<RaspberryPiBox> with DoubleValeBoxPainter {
  double? _cpuTemperature;
  double? _gpuTemperature;
  double? _cpuUtilisation;
  double? _memoryUtilisation;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(onUpdate: _onUpdate, paths: { 'environment.rpi.*' }, dataType: SignalKDataType.infrequent);
  }

  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      _cpuTemperature = _gpuTemperature = widget.config.controller.temperatureFromDisplay(12.3);
      _cpuUtilisation = _memoryUtilisation = 0.12;
    }

    List<Widget> stack = [
      Center(child: Image(image: AssetImage('assets/raspberry-pi.jpg'))),
      CustomPaint(size: Size.infinite, painter: _RPiDataPainter(widget.config.controller, context, _cpuTemperature, _gpuTemperature, _cpuUtilisation, _memoryUtilisation))
    ];
    return Container(padding: const EdgeInsets.all(5.0), child: RepaintBoundary(child: Stack(children: stack)));
  }

  void _onUpdate(List<Update> updates) {
    BoatInstrumentController controller = widget.config.controller;

    if(updates[0].value == null) {
      _cpuTemperature = _gpuTemperature = _cpuUtilisation = _memoryUtilisation = null;
    } else {
      for (Update u in updates) {
        try {
          double value = (u.value as num).toDouble();
          switch (u.path) {
            case 'environment.rpi.cpu.temperature':
              _cpuTemperature = controller.temperatureToDisplay(value);
              break;
            case 'environment.rpi.gpu.temperature':
              _gpuTemperature = controller.temperatureToDisplay(value);
              break;
            case 'environment.rpi.cpu.utilisation':
              _cpuUtilisation = value;
              break;
            case 'environment.rpi.memory.utilisation':
              _memoryUtilisation = value;
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
