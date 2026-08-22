import 'dart:async';
import 'package:flutter/material.dart';

/// An IconButton that fires [onPressed] repeatedly while the user
/// holds it down (press-and-hold-to-repeat), e.g. for +/- steppers,
/// volume controls, scroll buttons, etc.
///
/// - Single tap fires once immediately.
/// - Holding fires again after [initialDelay], then repeats every
///   [repeatInterval] (optionally accelerating via [minInterval]).
class RepeatableIconButton extends StatefulWidget {
  const RepeatableIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.initialDelay = const Duration(milliseconds: 500),
    this.repeatInterval = const Duration(milliseconds: 150),
    this.minInterval = const Duration(milliseconds: 50),
    this.acceleration = 0.90, // multiply interval each tick; 1.0 = no accel
    this.iconSize,
    this.color,
    this.tooltip,
    this.splashRadius,
    this.style,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final Duration initialDelay;
  final Duration repeatInterval;
  final Duration minInterval;
  final double acceleration;
  final double? iconSize;
  final Color? color;
  final String? tooltip;
  final double? splashRadius;
  final ButtonStyle? style;

  @override
  State<RepeatableIconButton> createState() => _RepeatableIconButtonState();
}

class _RepeatableIconButtonState extends State<RepeatableIconButton> {
  Timer? _timer;
  Duration _currentInterval = Duration.zero;
  bool _fired = false; // tracks whether tap-down already fired once

  void _fire() {
    if (!mounted) return;
    widget.onPressed?.call();
  }

  void _startRepeating() {
    _fired = true;
    _fire(); // fire immediately on press

    _currentInterval = widget.repeatInterval;

    _timer = Timer(widget.initialDelay, _scheduleNextRepeat);
  }

  void _scheduleNextRepeat() {
    _fire();

    // Accelerate, clamped to minInterval.
    final nextMs = (_currentInterval.inMilliseconds * widget.acceleration)
        .clamp(widget.minInterval.inMilliseconds, widget.repeatInterval.inMilliseconds)
        .round();
    _currentInterval = Duration(milliseconds: nextMs);

    _timer = Timer(_currentInterval, _scheduleNextRepeat);
  }

  void _stopRepeating() {
    _timer?.cancel();
    _timer = null;
    // _fired = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // Listener gives us reliable down/up/cancel even outside GestureDetector quirks.
      onPointerDown: (_) => _startRepeating(),
      onPointerUp: (_) => _stopRepeating(),
      onPointerCancel: (_) => _stopRepeating(),
      child: IconButton(
        icon: widget.icon,
        iconSize: widget.iconSize,
        color: widget.color,
        tooltip: widget.tooltip,
        splashRadius: widget.splashRadius,
        style: widget.style,
        // onPressed still required for accessibility (screen readers,
        // keyboard activation) but Listener handles the hold-repeat logic.
        // Guard against double-firing when Listener already fired on tap-down.
        onPressed: widget.onPressed==null?null:() {
          if (_fired) {
            // Already fired via Listener's onPointerDown for this press
            // cycle; this is IconButton's synthetic tap callback — ignore
            // it, but reset the flag so the *next* press cycle works.
            _fired = false;
          } else {
            // Reached via keyboard/screen-reader/switch-control activation,
            // which never goes through Listener's pointer events.
            _fire();
          }
        },
      ),
    );
  }
}
