import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../data/database/tables/transactions_table.dart';
import '../../data/database/tables/categories_table.dart';
import '../../data/database/app_database.dart';
import '../providers/sms_parser_provider.dart';
import '../providers/transactions_provider.dart';
import '../providers/categories_provider.dart';
import '../screens/onboarding/calibration_screen.dart';

/// Widget de la zone de triage pour les transactions SMS détectées
class TriageZoneWidget extends ConsumerWidget {
  const TriageZoneWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingTransactionsProvider);

    return pendingAsync.when(
      data: (pending) {
        if (pending.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.all(16),
          color: AppColors.warningColor.withValues(alpha: 0.1),
          child: InkWell(
            onTap: () {
              _showTriageDialog(context, ref, pending);
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.warningColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notification_important,
                      color: AppColors.warningColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${pending.length} Transaction${pending.length > 1 ? 's' : ''} en attente',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tapez pour qualifier',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  void _showTriageDialog(
    BuildContext context,
    WidgetRef ref,
    List<PendingTransaction> pending,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TriageBottomSheet(pending: pending),
    );
  }
}

/// Bottom Sheet pour qualifier les transactions en attente
class _TriageBottomSheet extends ConsumerStatefulWidget {
  final List<PendingTransaction> pending;

  const _TriageBottomSheet({required this.pending});

  @override
  ConsumerState<_TriageBottomSheet> createState() => _TriageBottomSheetState();
}

class _TriageBottomSheetState extends ConsumerState<_TriageBottomSheet> {
  int _currentIndex = 0;

  PendingTransaction get _current => widget.pending[_currentIndex];

  void _nextTransaction() {
    if (_currentIndex < widget.pending.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _qualifyAsExpense(int categoryId) async {
    final accountId = _current.suggestedAccountId;
    if (accountId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun compte associé. Veuillez lier un compte Mobile Money.'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
      return;
    }

    await ref.read(transactionsProviderProvider.notifier).createTransaction(
          amount: _current.amount,
          type: TransactionType.expense,
          categoryId: categoryId,
          accountId: accountId,
          date: _current.transactionDate ?? _current.smsDate,
          feeAmount: _current.fee > 0 ? _current.fee : null,
          description: 'Via ${_current.operator}',
        );

    await ref.read(pendingTransactionsProvider.notifier).reject(_current.id);
    _nextTransaction();
  }

  Future<void> _qualifyAsIncome(int categoryId) async {
    final accountId = _current.suggestedAccountId;
    if (accountId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun compte associé. Veuillez lier un compte Mobile Money.'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
      return;
    }

    await ref.read(transactionsProviderProvider.notifier).createTransaction(
          amount: _current.amount,
          type: TransactionType.income,
          categoryId: categoryId,
          accountId: accountId,
          date: _current.transactionDate ?? _current.smsDate,
          description: 'Via ${_current.operator}',
        );

    await ref.read(pendingTransactionsProvider.notifier).reject(_current.id);
    _nextTransaction();
  }

  Future<void> _ignore() async {
    await ref.read(pendingTransactionsProvider.notifier).reject(_current.id);
    _nextTransaction();
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(calibrationDataProvider).currency;
    final categoriesAsync = ref.watch(categoriesProviderProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text(
                  'Qualifier la transaction',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_currentIndex + 1} sur ${widget.pending.length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // Transaction info
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _current.operator,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${_current.amount.toStringAsFixed(0)} $currency',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: AppColors.primaryColor,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(_current.smsDate),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (_current.transactionId != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${_current.transactionId}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Actions
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                final expenseCategories = categories
                    .where((c) => c.type == CategoryType.expense)
                    .toList();
                final incomeCategories = categories
                    .where((c) => c.type == CategoryType.income)
                    .toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'C\'est une dépense ?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: expenseCategories.map((category) {
                          return ActionChip(
                            label: Text(category.name),
                            avatar: Text(category.icon),
                            onPressed: () => _qualifyAsExpense(category.id),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'C\'est un revenu ?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: incomeCategories.map((category) {
                          return ActionChip(
                            label: Text(category.name),
                            avatar: Text(category.icon),
                            onPressed: () => _qualifyAsIncome(category.id),
                            backgroundColor: AppColors.accentColor.withValues(alpha: 0.2),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Text('Erreur de chargement'),
            ),
          ),

          // Bouton Ignorer
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextButton(
              onPressed: _ignore,
              child: const Text('Ignorer cette transaction'),
            ),
          ),
        ],
      ),
    );
  }
}
