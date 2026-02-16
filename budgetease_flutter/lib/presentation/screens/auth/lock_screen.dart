import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/services/security_service.dart';
import 'pin_screen.dart';

/// Écran de verrouillage de l'application
class LockScreen extends StatefulWidget {
  final SecurityService securityService;
  final VoidCallback onUnlocked;

  const LockScreen({
    super.key,
    required this.securityService,
    required this.onUnlocked,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _isAuthenticating = false;
  int _failedAttempts = 0;
  static const int maxAttempts = 5;

  @override
  void initState() {
    super.initState();
    _attemptBiometricAuth();
  }

  Future<void> _attemptBiometricAuth() async {
    final biometricEnabled = await widget.securityService.isBiometricEnabled();
    final biometricAvailable = await widget.securityService.isBiometricAvailable();

    if (biometricEnabled && biometricAvailable) {
      setState(() {
        _isAuthenticating = true;
      });

      final authenticated = await widget.securityService.authenticateWithBiometric(
        reason: 'Déverrouillez BudgetEase pour accéder à vos finances',
      );

      setState(() {
        _isAuthenticating = false;
      });

      if (authenticated) {
        widget.onUnlocked();
      }
    }
  }

  Future<void> _showPinScreen() async {
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

              if (_failedAttempts >= maxAttempts) {
                _showMaxAttemptsDialog();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Code PIN incorrect (${maxAttempts - _failedAttempts} tentatives restantes)',
                    ),
                    backgroundColor: AppColors.errorColor,
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
        title: const Text('Trop de tentatives'),
        content: const Text(
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
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.backgroundColor, // Removed
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
                  color: AppColors.primaryColor.withValues(alpha: 0.2),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 60,
                  color: AppColors.primaryColor,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Titre
              Text(
                'BudgetEase',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              
              const SizedBox(height: 8),
              
              // Sous-titre
              Text(
                'Votre coffre-fort financier',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              
              const SizedBox(height: 64),
              
              // Bouton Biométrie
              FutureBuilder<bool>(
                future: widget.securityService.isBiometricEnabled(),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isAuthenticating ? null : _attemptBiometricAuth,
                          icon: const Icon(Icons.fingerprint),
                          label: const Text('Déverrouiller avec biométrie'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        TextButton(
                          onPressed: _showPinScreen,
                          child: const Text('Utiliser le code PIN'),
                        ),
                      ],
                    );
                  } else {
                    return ElevatedButton.icon(
                      onPressed: _showPinScreen,
                      icon: const Icon(Icons.pin),
                      label: const Text('Entrer le code PIN'),
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
                const Padding(
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
