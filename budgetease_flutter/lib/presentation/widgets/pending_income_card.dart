import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/constants/app_constants.dart';
import '../../data/database/tables/recurring_incomes_table.dart';
import '../../data/database/tables/transactions_table.dart';
import '../../data/database/tables/categories_table.dart';
import '../../data/database/app_database.dart';
import '../providers/incomes_provider.dart';
import '../providers/transactions_provider.dart';
import '../providers/accounts_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/database_provider.dart';
import '../../data/database/daos/accounts_dao.dart';
import 'zolt_card.dart';

class PendingIncomeCard extends ConsumerStatefulWidget {
  final RecurringIncome income;
  final String currency;

  const PendingIncomeCard({
    super.key,
    required this.income,
    required this.currency,
  });

  @override
  ConsumerState<PendingIncomeCard> createState() => _PendingIncomeCardState();
}

class _PendingIncomeCardState extends ConsumerState<PendingIncomeCard> {
  bool _isLoading = false;

  Future<void> _markAsReceived() async {
    setState(() => _isLoading = true);
    
    try {
      // 1. Get default income category
      final categoriesAsync = ref.read(categoriesProviderProvider);
      final categories = categoriesAsync.value ?? [];
      final defaultCategory = categories.firstWhere(
        (c) => c.type == CategoryType.income,
        orElse: () => categories.first,
      );

      // 2. Get active accounts to deposit into the primary one
      final accountsAsync = ref.read(accountsProviderProvider);
      final accounts = accountsAsync.value ?? [];
      if (accounts.isEmpty) throw Exception("Aucun compte actif pour le dépôt");
      final primaryAccount = accounts.first;

      // 3. Create the real positive transaction
      await ref.read(transactionsProviderProvider.notifier).createTransaction(
        amount: widget.income.amount,
        type: TransactionType.income,
        accountId: primaryAccount.id,
        categoryId: defaultCategory.id,
        date: DateTime.now(),
        description: 'Rentrée: ${widget.income.name}',
      );
      
      // 4. Update the RecurringIncome nextDepositDate
      DateTime nextDate;
      switch (widget.income.frequency) {
        case IncomeFrequency.daily_x_times:
          // Simplification : day + 1. S'il doit sauter un jour, l'algo pourrait être plus complexe,
          // mais on reporte au lendemain pour l'instant.
          nextDate = widget.income.nextDepositDate.add(const Duration(days: 1));
          break;
        case IncomeFrequency.weekly:
          nextDate = widget.income.nextDepositDate.add(const Duration(days: 7));
          break;
        case IncomeFrequency.monthly:
          nextDate = DateTime(
            widget.income.nextDepositDate.year,
            widget.income.nextDepositDate.month + 1,
            widget.income.nextDepositDate.day,
          );
          break;
      }
      
      final updatedIncome = widget.income.copyWith(nextDepositDate: nextDate);
      await ref.read(incomesNotifierProvider.notifier).updateIncome(updatedIncome);
      
      // Invalidate the provider so the UI hides the card
      ref.invalidate(nextPendingIncomeProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.income.name} a été crédité au solde !'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _delayDeposit() async {
    // Si l'utilisateur n'a pas encore reçu l'argent, on décale au lendemain
    final updatedIncome = widget.income.copyWith(
      nextDepositDate: widget.income.nextDepositDate.add(const Duration(days: 1))
    );
    await ref.read(incomesNotifierProvider.notifier).updateIncome(updatedIncome);
    
    // Invalidate the provider so the UI updates
    ref.invalidate(nextPendingIncomeProvider);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return ZoltCard(
      profile: ZoltCardProfile.semantic,
      semanticLevel: ZoltSemanticLevel.positive,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.download_done, color: primaryColor, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Revenu attendu',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Avez-vous reçu votre ${widget.income.name} (${NumberFormat.decimalPattern('fr').format(widget.income.amount)} ${widget.currency}) ?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              TextButton(
                onPressed: _isLoading ? null : _delayDeposit,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                child: Text('Pas encore'),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _markAsReceived,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: onPrimaryColor,
                  elevation: 0,
                ),
                icon: _isLoading 
                    ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: onPrimaryColor, strokeWidth: 2))
                    : Icon(Icons.check, size: 18),
                label: Text('Oui, reçu'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
