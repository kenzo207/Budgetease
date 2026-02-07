import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart'; // Temporarily disabled
import 'package:budgetease_flutter/services/daily_cap_calculator.dart';
import 'package:budgetease_flutter/utils/money.dart';
import 'dart:math' as math;

/// Liquid Gauge widget - Main visual component showing Daily Cap
class LiquidGauge extends StatefulWidget {
  final Money dailyCap;
  final Money spent;
  final String currency;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const LiquidGauge({
    super.key,
    required this.dailyCap,
    required this.spent,
    required this.currency,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<LiquidGauge> createState() => _LiquidGaugeState();
}

class _LiquidGaugeState extends State<LiquidGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.dailyCap - widget.spent;
    final fillPercentage = widget.dailyCap.isZero
        ? 0.0
        : (remaining.amount / widget.dailyCap.amount).clamp(0.0, 1.0);

    // Calculate state colors
    final gaugeState = _calculateGaugeState(fillPercentage);

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: gaugeState.color.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E1E1E),
                border: Border.all(
                  color: gaugeState.color.withOpacity(0.5),
                  width: 3,
                ),
              ),
            ),

            // Liquid fill
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return ClipOval(
                  child: Container(
                    width: 280,
                    height: 280,
                    child: CustomPaint(
                      painter: LiquidPainter(
                        fillPercentage: fillPercentage,
                        color: gaugeState.color,
                        waveAnimation: _animationController.value,
                        agitation: gaugeState.agitation,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Amount text overlay
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Main amount
                Text(
                  remaining.amount.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),

                // Currency
                Text(
                  widget.currency,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                // Percentage indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(fillPercentage * 100).toStringAsFixed(0)}% restant',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Status emoji
                Text(
                  gaugeState.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    // .animate().scale(  // Temporarily disabled
    //       duration: 600.ms,
    //       curve: Curves.elasticOut,
    //     );
  }

  _GaugeState _calculateGaugeState(double fillPercentage) {
    if (fillPercentage > 0.7) {
      return _GaugeState(
        color: const Color(0xFF4CAF50), // Green
        agitation: 0.0,
        emoji: '😊',
        status: 'Calme',
      );
    } else if (fillPercentage > 0.3) {
      return _GaugeState(
        color: const Color(0xFFFF9800), // Orange
        agitation: 0.5,
        emoji: '😐',
        status: 'Attention',
      );
    } else {
      return _GaugeState(
        color: const Color(0xFFF44336), // Red
        agitation: 1.0,
        emoji: '😰',
        status: 'Critique',
      );
    }
  }
}

class _GaugeState {
  final Color color;
  final double agitation;
  final String emoji;
  final String status;

  _GaugeState({
    required this.color,
    required this.agitation,
    required this.emoji,
    required this.status,
  });
}

/// Custom painter for liquid wave effect
class LiquidPainter extends CustomPainter {
  final double fillPercentage;
  final Color color;
  final double waveAnimation;
  final double agitation;

  LiquidPainter({
    required this.fillPercentage,
    required this.color,
    required this.waveAnimation,
    required this.agitation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Wave parameters
    final waveHeight = 10.0 + (agitation * 20); // More agitation = bigger waves
    final waveLength = size.width / 2;
    final liquidHeight = size.height * (1 - fillPercentage);

    path.moveTo(0, liquidHeight);

    // Create wave using sine curve
    for (double x = 0; x <= size.width; x += 1) {
      final waveOffset = waveAnimation * 2 * math.pi;
      final y = liquidHeight +
          math.sin((x / waveLength * 2 * math.pi) + waveOffset) * waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Add second wave for depth
    final paint2 = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, liquidHeight);

    for (double x = 0; x <= size.width; x += 1) {
      final waveOffset = waveAnimation * 2 * math.pi + math.pi;
      final y = liquidHeight +
          math.sin((x / waveLength * 2 * math.pi) + waveOffset) *
              (waveHeight * 0.7);
      path2.lineTo(x, y);
    }

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(LiquidPainter oldDelegate) {
    return oldDelegate.fillPercentage != fillPercentage ||
        oldDelegate.waveAnimation != waveAnimation ||
        oldDelegate.agitation != agitation;
  }
}
