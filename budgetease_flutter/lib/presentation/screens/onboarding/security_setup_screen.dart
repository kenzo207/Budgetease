import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../auth/pin_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../../providers/security_provider.dart';

/// Écran 7 : Configuration de la Sécurité (Bloquant)
class SecuritySetupScreen extends ConsumerStatefulWidget {
  const SecuritySetupScreen({super.key});

  @override
  ConsumerState<SecuritySetupScreen> createState() =>
      _SecuritySetupScreenState();
}

class _SecuritySetupScreenState extends ConsumerState<SecuritySetupScreen> {
  bool _isSettingUp = false;
  // ignore: unused_field
  bool _securityConfigured = false;

  Future<void> _setupBiometric() async {
    setState(() {
      _isSettingUp = true;
    });

    final securityService = ref.read(securityServiceProvider);
    
    final authenticated = await securityService.authenticateWithBiometric(
      reason: 'Configurer la biométrie pour BudgetEase',
    );

    if (authenticated) {
      await securityService.enableBiometric();
      setState(() {
        _securityConfigured = true;
        _isSettingUp = false;
      });
      _onContinue();
    } else {
      setState(() {
        _isSettingUp = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentification biométrique échouée'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  Future<void> _setupPin() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PinScreen(
          mode: PinScreenMode.create,
          title: 'Créez votre code PIN',
          onPinEntered: (pin) async {
            final securityService = ref.read(securityServiceProvider);
            await securityService.setPin(pin);
            Navigator.pop(context, true);
          },
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _securityConfigured = true;
      });
      _onContinue();
    }
  }

  void _onContinue() {
    ref.read(onboardingControllerProvider.notifier).nextStep();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              ref.read(onboardingControllerProvider.notifier).previousStep();
            },
          ),
          
          SizedBox(height: 24),
          
          Text(
            'Verrouillage de l\'application',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          
          SizedBox(height: 8),
          
          Text(
            'Protégez vos données financières',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          
          const Spacer(),
          
          // Illustration
          Center(
            child: Container(
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
          ),
          
          SizedBox(height: 32),
          
          // Message d'avertissement
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_outlined, color: Theme.of(context).colorScheme.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vous devez configurer une méthode de sécurité pour continuer',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Bouton Biométrie
          FutureBuilder<bool>(
            future: ref.read(securityServiceProvider).isBiometricAvailable(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSettingUp ? null : _setupBiometric,
                        icon: Icon(Icons.fingerprint),
                        label: Text('Activer la biométrie'),
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isSettingUp ? null : _setupPin,
                        icon: Icon(Icons.pin),
                        label: Text('Créer un code PIN'),
                      ),
                    ),
                  ],
                );
              } else {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSettingUp ? null : _setupPin,
                    icon: Icon(Icons.pin),
                    label: Text('Créer un code PIN'),
                  ),
                );
              }
            },
          ),
          
          if (_isSettingUp)
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
