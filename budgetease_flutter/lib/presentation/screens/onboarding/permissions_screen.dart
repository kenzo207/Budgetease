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

/// Écran 8 : Autorisations SMS (Final)
class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  bool _smsPermissionGranted = false;
  bool _isRequestingPermission = false;
  bool _isSaving = false;

  Future<void> _requestSmsPermission() async {
    setState(() {
      _isRequestingPermission = true;
    });

    // Analytics
    ref.read(analyticsServiceProvider).capture('sms_permission_requested');

    final status = await Permission.sms.request();
    
    setState(() {
      _smsPermissionGranted = status.isGranted;
      _isRequestingPermission = false;
    });

    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission SMS accordée'),
          backgroundColor: AppColors.accentColor,
        ),
      );
    }
  }

  Future<void> _skipAndFinish() async {
    await _saveOnboardingData(smsEnabled: false);
  }

  Future<void> _allowAndFinish() async {
    if (!_smsPermissionGranted) {
      await _requestSmsPermission();
    }
    await _saveOnboardingData(smsEnabled: _smsPermissionGranted);
  }

  Future<void> _saveOnboardingData({required bool smsEnabled}) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final database = AppDatabase();
      
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
            color: _getAccountColor(account.type),
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

      // 6. Navigation vers l'écran principal
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration terminée !'),
            backgroundColor: AppColors.accentColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.errorColor,
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

  String _getAccountColor(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return '#00E676';
      case AccountType.mobileMoney:
        return '#1E88E5';
      case AccountType.bank:
        return '#FF6B6B';
      case AccountType.savings:
        return '#FFD93D';
    }
  }

  @override
  Widget build(BuildContext context) {
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
            'Automatisation des transactions',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Détectez automatiquement vos paiements Mobile Money',
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
                color: AppColors.accentColor.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.sms_outlined,
                size: 60,
                color: AppColors.accentColor,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Explication
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildFeature(
                  Icons.check_circle_outline,
                  'Détection automatique',
                  'Les SMS de MTN, Moov, Orange et Wave sont analysés',
                ),
                const SizedBox(height: 12),
                _buildFeature(
                  Icons.edit_outlined,
                  'Vous gardez le contrôle',
                  'Vous validez chaque transaction avant enregistrement',
                ),
                const SizedBox(height: 12),
                _buildFeature(
                  Icons.security_outlined,
                  '100% Local',
                  'Aucun SMS n\'est envoyé à un serveur',
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          if (_isSaving)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isRequestingPermission ? null : _allowAndFinish,
                    child: Text(_smsPermissionGranted
                        ? 'Terminer'
                        : 'Autoriser et terminer'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isRequestingPermission ? null : _skipAndFinish,
                  child: const Text('Plus tard'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accentColor, size: 24),
        const SizedBox(width: 12),
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
