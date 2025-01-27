import 'package:boatinstrument/widgets/double_value_box.dart';

class RPiCPUTemperatureBox extends DoubleValueBox {
  static const String sid = 'rpi-cpu-temperature';
  @override
  String get id => sid;

  const RPiCPUTemperatureBox(config, {super.key}) : super(config, 'RPi CPU Temp', 'environment.rpi.cpu.temperature', dataTimeout: false);

  @override
  double convert(double value) {
    return config.controller.temperatureToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.temperatureUnits.unit;
  }
}

