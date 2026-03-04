import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/database/tables/accounts_table.dart';
import '../onboarding/onboarding_screen.dart';
import 'calibration_screen.dart';

/// Modèle pour un compte à créer
class AccountToCreate {
  final AccountType type;
  final double balance;
  final String? operator;

  AccountToCreate({
    required this.type,
    required this.balance,
    this.operator,
  });
}

/// Provider pour les comptes à créer
final accountsToCreateProvider =
    StateProvider<List<AccountToCreate>>((ref) => []);

/// Écran 4 : Inventaire des Comptes
class AccountsInventoryScreen extends ConsumerStatefulWidget {
  const AccountsInventoryScreen({super.key});

  @override
  ConsumerState<AccountsInventoryScreen> createState() =>
      _AccountsInventoryScreenState();
}

class _AccountsInventoryScreenState
    extends ConsumerState<AccountsInventoryScreen> {
  final Map<AccountType, bool> _selectedAccounts = {};
  final Map<AccountType, TextEditingController> _amountControllers = {};

  static const _momoTypes = [AccountType.mobileMoney];

  @override
  void initState() {
    super.initState();
    for (var type in AccountType.values) {
      if (_momoTypes.contains(type)) continue; // MoMo géré par MomoSetupScreen
      _amountControllers[type] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double get _totalBalance {
    double total = 0.0;
    _selectedAccounts.forEach((type, isSelected) {
      if (isSelected) {
        final amount = double.tryParse(_amountControllers[type]!.text) ?? 0.0;
        total += amount;
      }
    });
    return total;
  }

  bool get _canContinue => _selectedAccounts.values.any((selected) => selected);

  void _onContinue() {
    final accounts = <AccountToCreate>[];
    
    _selectedAccounts.forEach((type, isSelected) {
      if (isSelected) {
        final amount = double.tryParse(_amountControllers[type]!.text) ?? 0.0;
        accounts.add(AccountToCreate(
          type: type,
          balance: amount,
        ));
      }
    });

    ref.read(accountsToCreateProvider.notifier).state = accounts;
    ref.read(onboardingControllerProvider.notifier).nextStep();
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(calibrationDataProvider).currency;

    return Column(
      children: [
        // Header
        Padding(
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
                'Vos autres comptes',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              SizedBox(height: 6),
              Text(
                "Esp\u00e8ces, banque, \u00e9pargne. Le compte Mobile Money a \u00e9t\u00e9 configur\u00e9 \u00e0 l'\u00e9tape pr\u00e9c\u00e9dente.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),

        // Liste des comptes
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildAccountCard(
                AccountType.cash,
                'Espèces (Cash)',
                Icons.payments_outlined,
                currency,
              ),
              _buildAccountCard(
                AccountType.bank,
                'Compte Bancaire',
                Icons.account_balance_outlined,
                currency,
              ),
              _buildAccountCard(
                AccountType.savings,
                'Épargne',
                Icons.savings_outlined,
                currency,
              ),
            ],
          ),
        ),

        // Footer avec total
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Patrimoine Total',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${_totalBalance.toStringAsFixed(0)} $currency',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canContinue ? _onContinue : null,
                  child: Text('Continuer'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard(
    AccountType type,
    String name,
    IconData icon,
    String currency, {
    bool hasOperator = false, // paramètre gardé pour compatibilité future
  }) {
    final isSelected = _selectedAccounts[type] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CheckboxListTile(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  _selectedAccounts[type] = value!;
                });
              },
              title: Row(
                children: [
                  Icon(icon),
                  SizedBox(width: 12),
                  Text(name),
                ],
              ),
              contentPadding: EdgeInsets.zero,
            ),
            if (isSelected) ...[
              SizedBox(height: 8),
              TextField(
                controller: _amountControllers[type],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant',
                  suffixText: currency,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
