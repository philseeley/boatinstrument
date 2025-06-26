import 'package:flutter/material.dart';
import 'package:format/format.dart' as fmt;
import 'package:boatinstrument/boatinstrument_controller.dart';

abstract class SpeedBox extends DoubleValueBox {

  const SpeedBox(super.config, super.title, super.path, {super.valueToDisplay, super.key}) : super(minLen: 1);

  @override
  double convert(double value) {
    return config.controller.speedToDisplay(value);
  }

  @override
  String units(double value) {
    return config.controller.speedUnits.unit;
  }
}

abstract class DoubleValueBox extends BoxWidget {
  static final Map<String, double> extremeValues = {};

  final String title;
  final String path;
  final int precision;
  final int minLen;
  final double? minValue;
  final double? maxValue;
  final bool angle;
  final bool relativeAngle;
  final bool smoothing;
  final bool portStarboard;
  final bool dataTimeout;
  final DoubleValueToDisplay valueToDisplay;

  const DoubleValueBox(super.config, this.title, this.path, {
    this.precision = 1,
    this.minLen =  2,
    this.minValue,
    this.maxValue,
    this.angle = false,
    this.relativeAngle = false,
    this.smoothing = true,
    this.portStarboard = false,
    this.dataTimeout = true,
    this.valueToDisplay = DoubleValueToDisplay.value,
    super.key});

  @override
  State<DoubleValueBox> createState() => DoubleValueBoxState();

  double extractValue(Update update) {
    return (update.value as num).toDouble();
  }

  double convert(double value);

  String units(double value);

  double get extremeValue => extremeValues.putIfAbsent(id, () => valueToDisplay == DoubleValueToDisplay.minimumValue?double.infinity:0);
  set extremeValue(double value) => extremeValues[id] = value;
}

class DoubleValueBoxState<T extends DoubleValueBox> extends HeadedBoxState<T> {
  double? value;
  double? displayValue;

  @override
  void initState() {
    super.initState();
    widget.config.controller.configure(onUpdate: processUpdates, paths: {widget.path}, dataTimeout: widget.dataTimeout);
  }

  @override
  Widget build(BuildContext context) {
    if(widget.config.editMode) {
      displayValue = 12.3;
    }

    text = (displayValue == null) ?
      '-' :
      fmt.format('{:${widget.minLen+(widget.precision > 0?1:0)+widget.precision}.${widget.precision}f}', widget.portStarboard ? displayValue!.abs() : displayValue!);

    header = '${widget.valueToDisplay.title}${widget.title} ${widget.units(value??0)} ${widget.portStarboard ? val2PS(displayValue??0):''}';

    color = widget.portStarboard ? widget.config.controller.val2PSColor(context, displayValue??0) : null;

    return Stack(children: [
      super.build(context),
      if(widget.valueToDisplay != DoubleValueToDisplay.value) Positioned(top: 0, right: 0, child:
        IconButton(icon: Icon(Icons.restore), onPressed: _resetExtremeValue))
    ]);
  }

  void processUpdates(List<Update>? updates) {
    if(updates == null) {
      value = displayValue = null;
    } else {
      try {
        double next = widget.extractValue(updates[0]);

        if(widget.smoothing) {
          if (widget.angle) {
            value = averageAngle(value ?? next, next,
                smooth: widget.config.controller.valueSmoothing,
                relative: widget.relativeAngle);
          } else {
            value = averageDouble(value ?? next, next,
                smooth: widget.config.controller.valueSmoothing);
          }
        } else {
          value = next;
        }

        if ((widget.minValue != null && value! < widget.minValue!) ||
            (widget.maxValue != null && value! > widget.maxValue!)) {
          if(widget.valueToDisplay == DoubleValueToDisplay.value) displayValue = null;
        } else {
          displayValue = widget.convert(value!);
          if(widget.valueToDisplay != DoubleValueToDisplay.value) {
            if(widget.valueToDisplay == DoubleValueToDisplay.minimumValue) {
              widget.extremeValue = (displayValue! < widget.extremeValue) ? displayValue! : widget.extremeValue;
            } else {
              widget.extremeValue = (displayValue! > widget.extremeValue) ? displayValue! : widget.extremeValue;
            }
            displayValue = widget.extremeValue;
          }
        }
      } catch (e) {
        widget.config.controller.l.e("Error converting $updates", error: e);
      }
    }

    if(mounted) {
      setState(() {});
    }
  }

  void _resetExtremeValue() {
    setState(() {
      widget.extremeValue = (widget.valueToDisplay == DoubleValueToDisplay.minimumValue) ? double.infinity : 0;
    });
  }
}
