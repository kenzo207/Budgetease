import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../onboarding/onboarding_screen.dart';

/// Écran 1 : Bienvenue & Confidentialité
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          
          // Logo/Icône
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor.withOpacity(0.2),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              size: 60,
              color: AppColors.primaryColor,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Titre
          Text(
            'Votre coffre-fort financier',
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Sous-titre
          Text(
            'Vos données sont chiffrées et stockées uniquement sur cet appareil.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Points clés
          _buildFeaturePoint(
            context,
            Icons.lock_outline,
            '100% Local',
            'Aucune connexion serveur',
          ),
          
          const SizedBox(height: 12),
          
          _buildFeaturePoint(
            context,
            Icons.shield_outlined,
            'Chiffrement AES-256',
            'Sécurité maximale',
          ),
          
          const SizedBox(height: 12),
          
          _buildFeaturePoint(
            context,
            Icons.visibility_off_outlined,
            'Zéro Tracking',
            'Vos finances restent privées',
          ),
          
          const Spacer(),
          
          // Bouton d'action
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(onboardingControllerProvider.notifier).nextStep();
              },
              child: const Text('Commencer la configuration'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePoint(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accentColor, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
