import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/database/tables/settings_table.dart';
import '../onboarding/onboarding_screen.dart';

/// Provider pour le cycle financier sélectionné
final financialCycleProvider = StateProvider<FinancialCycle?>((ref) => null);

/// Écran 3 : Rythme Financier
class FinancialRhythmScreen extends ConsumerWidget {
  const FinancialRhythmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCycle = ref.watch(financialCycleProvider);

    final cycles = [
      CycleOption(
        cycle: FinancialCycle.monthly,
        title: 'Mensuel',
        subtitle: 'Salariés - Remise à zéro à date fixe',
        icon: Icons.calendar_month,
      ),
      CycleOption(
        cycle: FinancialCycle.weekly,
        title: 'Hebdomadaire',
        subtitle: 'Commerçants - Remise à zéro le lundi',
        icon: Icons.calendar_view_week,
      ),
      CycleOption(
        cycle: FinancialCycle.daily,
        title: 'Journalier',
        subtitle: 'Travailleurs journaliers - Remise à zéro chaque matin',
        icon: Icons.calendar_today,
      ),
      CycleOption(
        cycle: FinancialCycle.irregular,
        title: 'Irrégulier',
        subtitle: 'Freelance - Pas de cycle, gestion au solde réel',
        icon: Icons.trending_up,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bouton retour
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              ref.read(onboardingControllerProvider.notifier).previousStep();
            },
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'À quelle fréquence recevez-vous votre revenu principal ?',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView.builder(
              itemCount: cycles.length,
              itemBuilder: (context, index) {
                final option = cycles[index];
                final isSelected = selectedCycle == option.cycle;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: isSelected
                      ? AppColors.primaryColor.withOpacity(0.2)
                      : null,
                  child: InkWell(
                    onTap: () {
                      ref.read(financialCycleProvider.notifier).state =
                          option.cycle;
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Icon(
                            option.icon,
                            size: 40,
                            color: isSelected
                                ? AppColors.primaryColor
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  option.subtitle,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primaryColor,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedCycle != null
                  ? () {
                      ref
                          .read(onboardingControllerProvider.notifier)
                          .nextStep();
                    }
                  : null,
              child: const Text('Continuer'),
            ),
          ),
        ],
      ),
    );
  }
}

class CycleOption {
  final FinancialCycle cycle;
  final String title;
  final String subtitle;
  final IconData icon;

  CycleOption({
    required this.cycle,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
