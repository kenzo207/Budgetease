import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/analytics_service.dart';
import 'welcome_screen.dart';
import 'calibration_screen.dart';
import 'financial_rhythm_screen.dart';
import 'accounts_inventory_screen.dart';
import 'fixed_charges_screen.dart';
import 'transport_config_screen.dart';
import 'security_setup_screen.dart';
import 'permissions_screen.dart';

/// Contrôleur de l'onboarding
class OnboardingController extends StateNotifier<int> {
  OnboardingController() : super(0);

  void nextStep() {
    if (state < 7) {
      state++;
    }
  }

  void previousStep() {
    if (state > 0) {
      state--;
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 7) {
      state = step;
    }
  }
}



final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, int>((ref) {
  return OnboardingController();
});

/// Écran principal d'onboarding avec navigation entre les étapes
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(onboardingControllerProvider);

    // Track step view
    ref.listen(onboardingControllerProvider, (previous, next) {
      ref.read(analyticsServiceProvider).capture('onboarding_step_viewed', properties: {
        'step_index': next,
      });
    });

    final screens = [
      const WelcomeScreen(),
      const CalibrationScreen(),
      const FinancialRhythmScreen(),
      const AccountsInventoryScreen(),
      const FixedChargesScreen(),
      const TransportConfigScreen(),
      const SecuritySetupScreen(),
      const PermissionsScreen(),
    ];

    return Scaffold(
      // backgroundColor: AppColors.backgroundColor, // Removed
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(context, currentStep),
            
            // Current screen
            Expanded(
              child: screens[currentStep],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, int currentStep) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(8, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted || isCurrent
                    ? AppColors.primaryColor
                    : Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
