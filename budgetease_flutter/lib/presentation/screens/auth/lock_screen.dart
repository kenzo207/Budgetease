import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/services/security_service.dart';
import 'pin_screen.dart';
import '../../../services/analytics_service.dart';

/// Écran de verrouillage de l'application
class LockScreen extends ConsumerStatefulWidget {
  final SecurityService securityService;
  final VoidCallback onUnlocked;

  const LockScreen({
    super.key,
    required this.securityService,
    required this.onUnlocked,
  });

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  bool _isAuthenticating = false;
  int _failedAttempts = 0;
  static const int maxAttempts = 5;

  @override
  void initState() {
    super.initState();
    // Analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).capture('lock_screen_viewed');
    });
    _attemptBiometricAuth();
  }

  Future<void> _attemptBiometricAuth() async {
    final biometricEnabled = await widget.securityService.isBiometricEnabled();
    final biometricAvailable = await widget.securityService.isBiometricAvailable();

    if (biometricEnabled && biometricAvailable) {
      setState(() {
        _isAuthenticating = true;
      });

      // Analytics
      ref.read(analyticsServiceProvider).capture('biometric_attempted');

      final authenticated = await widget.securityService.authenticateWithBiometric(
        reason: 'Déverrouillez BudgetEase pour accéder à vos finances',
      );

      setState(() {
        _isAuthenticating = false;
      });

      if (authenticated) {
        // Analytics
        ref.read(analyticsServiceProvider).capture('biometric_success');
        widget.onUnlocked();
      } else {
        // Analytics
        ref.read(analyticsServiceProvider).capture('biometric_failed');
      }
    }
  }

  Future<void> _showPinScreen() async {
    // Analytics
    ref.read(analyticsServiceProvider).capture('pin_fallback_triggered');

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PinScreen(
          mode: PinScreenMode.verify,
          title: 'Déverrouillez BudgetEase',
          onPinEntered: (pin) async {
            final isValid = await widget.securityService.verifyPin(pin);
            
            if (isValid) {
              Navigator.pop(context, true);
            } else {
              setState(() {
                _failedAttempts++;
              });

              // Analytics
              ref.read(analyticsServiceProvider).capture(
                'pin_verify_failure',
                properties: {'attempts': _failedAttempts},
              );

              if (_failedAttempts >= maxAttempts) {
                _showMaxAttemptsDialog();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Code PIN incorrect (${maxAttempts - _failedAttempts} tentatives restantes)',
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              }
              
              Navigator.pop(context, false);
            }
          },
        ),
      ),
    );

    if (result == true) {
      widget.onUnlocked();
    }
  }

  void _showMaxAttemptsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Trop de tentatives'),
        content: Text(
          'Vous avez dépassé le nombre maximum de tentatives. '
          'Veuillez réessayer dans 30 secondes.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _failedAttempts = 0;
              });
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Removed
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icône
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              
              SizedBox(height: 64),
              
              // Bouton Biométrie
              FutureBuilder<bool>(
                future: widget.securityService.isBiometricEnabled(),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isAuthenticating ? null : _attemptBiometricAuth,
                          icon: Icon(Icons.fingerprint),
                          label: Text('Déverrouiller avec biométrie'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 16),
                        
                        TextButton(
                          onPressed: _showPinScreen,
                          child: Text('Utiliser le code PIN'),
                        ),
                      ],
                    );
                  } else {
                    return ElevatedButton.icon(
                      onPressed: _showPinScreen,
                      icon: Icon(Icons.pin),
                      label: Text('Entrer le code PIN'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    );
                  }
                },
              ),
              
              if (_isAuthenticating)
                Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
