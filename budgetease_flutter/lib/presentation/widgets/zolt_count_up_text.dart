import 'package:flutter/material.dart';
import '../../core/utils/zolt_animations.dart';

class ZoltCountUpText extends StatefulWidget {
  final double value;
  final String Function(double)? formatValue;
  final TextStyle? style;
  final Widget Function(BuildContext context, double currentValue)? builder;

  const ZoltCountUpText({
    super.key,
    required this.value,
    this.formatValue,
    this.style,
    this.builder,
  });

  @override
  State<ZoltCountUpText> createState() => _ZoltCountUpTextState();
}

class _ZoltCountUpTextState extends State<ZoltCountUpText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldValue = 0;

  @override
  void initState() {
    super.initState();
    _oldValue = 0; 
    _controller = AnimationController(
      vsync: this,
      duration: ZoltAnimations.durationSlow,
    );

    _animation = Tween<double>(begin: _oldValue, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: ZoltAnimations.curveCountUp),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant ZoltCountUpText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _animation = Tween<double>(begin: _oldValue, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: ZoltAnimations.curveCountUp),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentVal = _animation.value;
        if (widget.builder != null) {
          return widget.builder!(context, currentVal);
        }
        final text = widget.formatValue != null 
          ? widget.formatValue!(currentVal)
          : currentVal.toStringAsFixed(0);
        return Text(text, style: widget.style);
      },
    );
  }
}
