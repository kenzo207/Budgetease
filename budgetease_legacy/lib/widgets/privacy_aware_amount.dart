import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgetease_flutter/providers/privacy_mode_provider.dart';

/// Widget that displays amount with privacy mode support (blur when enabled)
class PrivacyAwareAmount extends StatelessWidget {
  final double amount;
  final String currency;
  final TextStyle? style;
  final bool showCurrency;

  const PrivacyAwareAmount({
    super.key,
    required this.amount,
    required this.currency,
    this.style,
    this.showCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    final privacyMode = context.watch<PrivacyModeProvider>().isPrivacyMode;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: privacyMode
          ? _buildBlurredAmount(context)
          : _buildVisibleAmount(context),
    );
  }

  Widget _buildBlurredAmount(BuildContext context) {
    return ImageFiltered(
      key: const ValueKey('blurred'),
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Text(
        _formatPlaceholder(),
        style: style ?? const TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildVisibleAmount(BuildContext context) {
    return Text(
      key: const ValueKey('visible'),
      _formatAmount(),
      style: style,
    );
  }

  String _formatAmount() {
    final formatted = _formatCurrency(amount, currency);
    return showCurrency ? formatted : amount.toStringAsFixed(0);
  }

  String _formatPlaceholder() {
    // Generate placeholder with same number of digits
    final digits = amount.abs().toInt().toString().length;
    final placeholder = '•' * digits;
    return showCurrency ? '$placeholder $currency' : placeholder;
  }

  String _formatCurrency(double amount, String currency) {
    switch (currency) {
      case 'FCFA':
        return '${amount.toStringAsFixed(0)} FCFA';
      case 'NGN':
        return '₦${amount.toStringAsFixed(2)}';
      case 'GHS':
        return 'GH₵${amount.toStringAsFixed(2)}';
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'EUR':
        return '€${amount.toStringAsFixed(2)}';
      default:
        return '${amount.toStringAsFixed(2)} $currency';
    }
  }
}

/// Privacy toggle button for AppBar
class PrivacyToggleButton extends StatelessWidget {
  const PrivacyToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final privacyMode = context.watch<PrivacyModeProvider>();

    return IconButton(
      icon: Icon(
        privacyMode.isPrivacyMode ? Icons.visibility_off : Icons.visibility,
      ),
      tooltip: privacyMode.isPrivacyMode 
        ? 'Afficher les montants' 
        : 'Masquer les montants',
      onPressed: () {
        privacyMode.toggle();
      },
    );
  }
}

/// Wrapper for any widget to blur when privacy mode is on
class PrivacyWrapper extends StatelessWidget {
  final Widget child;
  final bool blurWhenPrivate;

  const PrivacyWrapper({
    super.key,
    required this.child,
    this.blurWhenPrivate = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!blurWhenPrivate) return child;

    final privacyMode = context.watch<PrivacyModeProvider>().isPrivacyMode;

    if (!privacyMode) return child;

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: child,
    );
  }
}
