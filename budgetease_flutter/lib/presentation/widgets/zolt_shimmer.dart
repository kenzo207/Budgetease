import 'package:flutter/material.dart';
import '../../core/utils/zolt_animations.dart';

class ZoltShimmer extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;

  const ZoltShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ZoltShimmer> createState() => _ZoltShimmerState();
}

class _ZoltShimmerState extends State<ZoltShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: ZoltAnimations.durationLoop,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final baseColor = isDark ? const Color(0xFF1A1A18) : const Color(0xFFF5F3EE);
    final highlightColor = isDark ? const Color(0xFF2A2A27) : const Color(0xFFFFFFFF);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.1, 0.3, 0.4],
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              transform: _SlidingGradientTransform(_controller.value),
            ),
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2 - 1), 0.0, 0.0);
  }
}
