import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/analytics_service.dart';

/// Écran de saisie du code PIN
class PinScreen extends ConsumerStatefulWidget {
  final PinScreenMode mode;
  final String? title;
  final String? subtitle;
  final Function(String pin)? onPinEntered;
  final VoidCallback? onCancel;

  const PinScreen({
    super.key,
    required this.mode,
    this.title,
    this.subtitle,
    this.onPinEntered,
    this.onCancel,
  });

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> with SingleTickerProviderStateMixin {
  String _pin = '';
  String? _confirmPin;
  bool _isError = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    if (_pin.length >= 6) return;

    setState(() {
      _pin += number;
      _isError = false;
    });

    // Vibration légère
    HapticFeedback.lightImpact();

    // Vérifier si le PIN est complet
    if (_pin.length >= 4) {
      _handlePinComplete();
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;

    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _isError = false;
    });

    HapticFeedback.selectionClick();
  }

  void _handlePinComplete() {
    switch (widget.mode) {
      case PinScreenMode.create:
        if (_confirmPin == null) {
          // Première saisie, demander confirmation
          setState(() {
            _confirmPin = _pin;
            _pin = '';
          });
        } else {
          // Vérifier la correspondance
          if (_pin == _confirmPin) {
            // Analytics
            ref.read(analyticsServiceProvider).capture('pin_created');
            widget.onPinEntered?.call(_pin);
          } else {
            _showError('Les codes PIN ne correspondent pas');
            setState(() {
              _confirmPin = null;
              _pin = '';
            });
          }
        }
        break;

      case PinScreenMode.verify:
        // Analytics tracked by the caller (lock_screen) based on result
        widget.onPinEntered?.call(_pin);
        break;

      case PinScreenMode.change:
        // Analytics
        ref.read(analyticsServiceProvider).capture('pin_changed');
        widget.onPinEntered?.call(_pin);
        break;
    }
  }

  void _showError(String message) {
    setState(() {
      _isError = true;
    });

    HapticFeedback.heavyImpact();
    _shakeController.forward(from: 0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorColor,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _pin = '';
          _isError = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.backgroundColor, // Removed
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.onCancel != null
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onCancel,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            
            // Titre
            Text(
              widget.title ?? _getDefaultTitle(),
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Sous-titre
            if (widget.subtitle != null || _confirmPin != null)
              Text(
                widget.subtitle ?? 'Confirmez votre code PIN',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            
            const SizedBox(height: 48),
            
            // Indicateurs de PIN
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_isError ? _shakeAnimation.value : 0, 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _pin.length
                          ? (_isError ? AppColors.errorColor : AppColors.primaryColor)
                          : Theme.of(context).dividerColor,
                      border: Border.all(
                        color: _isError
                            ? AppColors.errorColor
                            : (index < _pin.length
                                ? AppColors.primaryColor
                                : Theme.of(context).dividerColor),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            const Spacer(),
            
            // Clavier numérique
            _buildNumericKeypad(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getDefaultTitle() {
    switch (widget.mode) {
      case PinScreenMode.create:
        return _confirmPin == null ? 'Créez votre code PIN' : 'Confirmez votre code PIN';
      case PinScreenMode.verify:
        return 'Entrez votre code PIN';
      case PinScreenMode.change:
        return 'Nouveau code PIN';
    }
  }

  Widget _buildNumericKeypad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildKeypadRow(['1', '2', '3']),
          const SizedBox(height: 16),
          _buildKeypadRow(['4', '5', '6']),
          const SizedBox(height: 16),
          _buildKeypadRow(['7', '8', '9']),
          const SizedBox(height: 16),
          _buildKeypadRow(['', '0', 'backspace']),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        if (number.isEmpty) {
          return const SizedBox(width: 80, height: 80);
        }

        if (number == 'backspace') {
          return _buildKeypadButton(
            onPressed: _onBackspace,
            child: const Icon(Icons.backspace_outlined, size: 28),
          );
        }

        return _buildKeypadButton(
          onPressed: () => _onNumberPressed(number),
          child: Text(
            number,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeypadButton({
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardColor,
        ),
        child: Center(child: child),
      ),
    );
  }
}

/// Modes d'utilisation de l'écran PIN
enum PinScreenMode {
  create,  // Créer un nouveau PIN
  verify,  // Vérifier le PIN existant
  change,  // Changer le PIN
}
