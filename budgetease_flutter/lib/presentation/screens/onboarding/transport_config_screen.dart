import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/database/tables/settings_table.dart';
import '../onboarding/onboarding_screen.dart';
import 'calibration_screen.dart';

/// Modèle pour la configuration du transport
class TransportConfig {
  final TransportMode mode;
  final double? dailyCost;
  final int? daysPerWeek;
  final double? fixedAmount;

  TransportConfig({
    required this.mode,
    this.dailyCost,
    this.daysPerWeek,
    this.fixedAmount,
  });
}

/// Provider pour la configuration du transport
final transportConfigProvider = StateProvider<TransportConfig?>((ref) => null);

/// Écran 6 : Configuration du Transport
class TransportConfigScreen extends ConsumerStatefulWidget {
  const TransportConfigScreen({super.key});

  @override
  ConsumerState<TransportConfigScreen> createState() =>
      _TransportConfigScreenState();
}

class _TransportConfigScreenState extends ConsumerState<TransportConfigScreen> {
  TransportMode _selectedMode = TransportMode.none;
  final _dailyCostController = TextEditingController();
  final _fixedAmountController = TextEditingController();
  int _daysPerWeek = 5;

  @override
  void dispose() {
    _dailyCostController.dispose();
    _fixedAmountController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    if (_selectedMode == TransportMode.none) return true;
    if (_selectedMode == TransportMode.fixed) {
      return _fixedAmountController.text.isNotEmpty;
    }
    if (_selectedMode == TransportMode.daily) {
      return _dailyCostController.text.isNotEmpty;
    }
    return false;
  }

  void _onContinue() {
    TransportConfig? config;

    if (_selectedMode == TransportMode.daily) {
      final dailyCost = double.tryParse(_dailyCostController.text);
      if (dailyCost != null) {
        config = TransportConfig(
          mode: _selectedMode,
          dailyCost: dailyCost,
          daysPerWeek: _daysPerWeek,
        );
      }
    } else if (_selectedMode == TransportMode.fixed) {
      final fixedAmount = double.tryParse(_fixedAmountController.text);
      if (fixedAmount != null) {
        config = TransportConfig(
          mode: _selectedMode,
          fixedAmount: fixedAmount,
        );
      }
    } else {
      config = TransportConfig(mode: TransportMode.none);
    }

    ref.read(transportConfigProvider.notifier).state = config;
    ref.read(onboardingControllerProvider.notifier).nextStep();
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(calibrationDataProvider).currency;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              ref.read(onboardingControllerProvider.notifier).previousStep();
            },
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Comment gérez-vous vos frais de transport ?',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Le transport est souvent une charge quotidienne cachée',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Option A: Fixe
                  _buildModeCard(
                    mode: TransportMode.fixed,
                    title: 'Abonnement / Fixe',
                    subtitle: 'Ex: Plein d\'essence mensuel, abonnement bus',
                    icon: Icons.credit_card,
                    child: _selectedMode == TransportMode.fixed
                        ? Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextField(
                              controller: _fixedAmountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Montant mensuel',
                                suffixText: currency,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          )
                        : null,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Option B: Quotidien
                  _buildModeCard(
                    mode: TransportMode.daily,
                    title: 'Quotidien',
                    subtitle: 'Ex: Taxi, moto-taxi, bus quotidien',
                    icon: Icons.directions_bus,
                    child: _selectedMode == TransportMode.daily
                        ? Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _dailyCostController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Combien par jour ?',
                                    suffixText: currency,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Combien de jours par semaine ?',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    Slider(
                                      value: _daysPerWeek.toDouble(),
                                      min: 1,
                                      max: 7,
                                      divisions: 6,
                                      label: '$_daysPerWeek jours',
                                      onChanged: (value) {
                                        setState(() {
                                          _daysPerWeek = value.toInt();
                                        });
                                      },
                                    ),
                                    Center(
                                      child: Text(
                                        '$_daysPerWeek jours / semaine',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : null,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Option C: Aucun
                  _buildModeCard(
                    mode: TransportMode.none,
                    title: 'Pas de transport',
                    subtitle: 'Je n\'ai pas de frais de transport réguliers',
                    icon: Icons.not_interested,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canContinue ? _onContinue : null,
              child: const Text('Continuer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required TransportMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? child,
  }) {
    final isSelected = _selectedMode == mode;

    return Card(
      color: isSelected ? AppColors.primaryColor.withOpacity(0.2) : null,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMode = mode;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 32,
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
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
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
              if (child != null) child,
            ],
          ),
        ),
      ),
    );
  }
}
