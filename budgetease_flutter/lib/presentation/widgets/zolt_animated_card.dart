import 'package:flutter/material.dart';
import '../../core/utils/zolt_animations.dart';

class ZoltAnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const ZoltAnimatedCard({super.key, required this.child, this.onTap});

  @override
  State<ZoltAnimatedCard> createState() => _ZoltAnimatedCardState();
}

class _ZoltAnimatedCardState extends State<ZoltAnimatedCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: ZoltAnimations.durationFast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: ZoltAnimations.curveTap),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    if (widget.onTap != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
