import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/constants/app_constants.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/tables/settings_table.dart';
import '../../../data/database/tables/accounts_table.dart';
import '../../../data/database/tables/recurring_charges_table.dart';
import '../onboarding/onboarding_screen.dart';
import 'calibration_screen.dart';
import 'financial_rhythm_screen.dart';
import 'accounts_inventory_screen.dart';
import 'fixed_charges_screen.dart';
import 'transport_config_screen.dart';
import '../main_screen.dart';
import '../../../services/analytics_service.dart';
import '../../providers/database_provider.dart';

/// Écran 9 : Confirmation finale et sauvegarde
class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  bool _isSaving = false;

  Future<void> _finish() async {
    // Vérifier si la permission SMS est déjà accordée (depuis MomoSetupScreen)
    final smsStatus = await Permission.sms.status;
    await _saveOnboardingData(smsEnabled: smsStatus.isGranted);
  }

  Future<void> _saveOnboardingData({required bool smsEnabled}) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final database = ref.read(databaseProvider);
      
      // 1. Récupérer toutes les données de configuration
      final calibration = ref.read(calibrationDataProvider);
      final cycle = ref.read(financialCycleProvider);
      final accounts = ref.read(accountsToCreateProvider);
      final charges = ref.read(chargesToCreateProvider);
      final transport = ref.read(transportConfigProvider);

      // 2. Mettre à jour les paramètres
      // D'abord supprimer les anciens paramètres pour éviter les doublons
      await database.delete(database.settings).go();

      await database.into(database.settings).insert(
        SettingsCompanion.insert(
          userName: calibration.userName,
          currency: Value(calibration.currency),
          financialCycle: cycle ?? FinancialCycle.monthly,
          transportMode: transport?.mode ?? TransportMode.none,
          dailyTransportCost: transport?.dailyCost != null 
              ? Value(transport!.dailyCost!) 
              : const Value.absent(),
          transportDaysPerWeek: transport?.daysPerWeek != null
              ? Value(transport!.daysPerWeek!)
              : const Value.absent(),
          smsParsingEnabled: Value(smsEnabled),
          onboardingCompleted: const Value(true),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        mode: InsertMode.replace,
      );

      // 3. Créer les comptes
      // Supprimer les anciens comptes
      await database.delete(database.accounts).go();
      
      for (final account in accounts) {
        await database.into(database.accounts).insert(
          AccountsCompanion.insert(
            name: _getAccountName(account.type, account.operator),
            type: account.type,
            currentBalance: Value(account.balance),
            icon: _getAccountIcon(account.type),
            color: _getAccountColor(context, account.type),
            operator: account.operator != null 
                ? Value(account.operator!) 
                : const Value.absent(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }

      // 4. Créer les charges fixes
      // Supprimer les anciennes charges
      await database.delete(database.recurringCharges).go();

      for (final charge in charges) {
        await database.into(database.recurringCharges).insert(
          RecurringChargesCompanion.insert(
            name: charge.name,
            type: charge.type,
            amount: charge.amount,
            dueDate: charge.dueDate ?? DateTime.now(),
            cycle: ChargeCycle.monthly,
            createdAt: DateTime.now(),
          ),
        );
      }

      // 5. Analytics — onboarding completed
      ref.read(analyticsServiceProvider).capture(
        'onboarding_completed',
        properties: {
          'currency': calibration.currency,
          'accounts_count': accounts.length,
          'charges_count': charges.length,
          'sms_enabled': smsEnabled,
          'has_transport': transport != null,
        },
      );
      // Identifier l'utilisateur avec son prénom dans PostHog
      await ref.read(analyticsServiceProvider).identifyWithName(
        calibration.userName,
        extraProperties: {
          'currency': calibration.currency,
          'onboarding_completed': true,
        },
      );

      // 6. Navigation vers l'écran principal
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Configuration terminée !', style: TextStyle(color: Colors.white)),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  String _getAccountName(AccountType type, String? operator) {
    switch (type) {
      case AccountType.cash:
        return 'Espèces';
      case AccountType.mobileMoney:
        return operator ?? 'Mobile Money';
      case AccountType.bank:
        return 'Compte Bancaire';
      case AccountType.savings:
        return 'Épargne';
    }
  }

  String _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return '💵';
      case AccountType.mobileMoney:
        return '📱';
      case AccountType.bank:
        return '🏦';
      case AccountType.savings:
        return '🐷';
    }
  }

  String _getAccountColor(BuildContext context, AccountType type) {
    // Convertir la couleur primaire du thème en chaîne HEX ("#AARRGGBB")
    final color = Theme.of(context).colorScheme.primary;
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
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

          const Spacer(),

          // Illustration
          Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          SizedBox(height: 32),

          Text(
            'Tout est prêt !',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            'Votre profil financier est configuré. Zolt va maintenant initialiser votre espace.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 32),

          // Résumé rapide
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildFeature(
                  Icons.account_balance_wallet_outlined,
                  'Comptes configurés',
                  'Vos soldes sont enregistrés localement',
                ),
                SizedBox(height: 12),
                _buildFeature(
                  Icons.lock_outline,
                  'Sécurité activée',
                  'PIN ou biométrie protège l\'accès',
                ),
                SizedBox(height: 12),
                _buildFeature(
                  Icons.sms_outlined,
                  'Détection SMS',
                  'Les transactions Mobile Money seront capturées automatiquement',
                ),
              ],
            ),
          ),

          const Spacer(),

          if (_isSaving)
            Center(child: CircularProgressIndicator())
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _finish,
                child: Text('Lancer Zolt'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        SizedBox(width: 12),
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
