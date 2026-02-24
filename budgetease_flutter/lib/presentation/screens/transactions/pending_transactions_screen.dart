import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/sms_parser_provider.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/categories_provider.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/tables/pending_transactions_table.dart';
import '../../../data/database/tables/categories_table.dart';
import '../../../core/utils/formatters.dart';
import '../../../services/analytics_service.dart';

class PendingTransactionsScreen extends ConsumerWidget {
  const PendingTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingTransactionsProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).screen('PendingTransactions');
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions SMS'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Scanner les SMS',
            onPressed: () => _scanSms(context, ref),
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundColor,
      body: pendingAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return _buildEmptyState(ref);
          }
          return _buildTransactionList(context, ref, transactions);
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Analyse des SMS...', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.errorColor),
                const SizedBox(height: 16),
                Text('Erreur: $e', textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(pendingTransactionsProvider),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80,
                color: AppColors.accentColor.withValues(alpha: 0.5)),
            const SizedBox(height: 24),
            const Text(
              'Aucune transaction en attente',
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Les SMS Mobile Money détectés apparaîtront ici pour validation.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.sync),
              label: const Text('Scanner maintenant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => ref.read(pendingTransactionsProvider.notifier).scan(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context, WidgetRef ref, List<PendingTransaction> transactions,
  ) {
    return ListView.builder(
      itemCount: transactions.length + 1, // +1 pour le header
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${transactions.length} transaction${transactions.length > 1 ? 's' : ''} à valider',
              style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14,
              ),
            ),
          );
        }
        return _PendingTransactionCard(
          transaction: transactions[index - 1],
        );
      },
    );
  }

  Future<void> _scanSms(BuildContext context, WidgetRef ref) async {
    try {
      ref.read(analyticsServiceProvider).capture(
        'sms_scan_triggered',
        properties: {'source': 'manual'},
      );
      final count = await ref.read(pendingTransactionsProvider.notifier).scan();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(count > 0
                ? '$count nouvelle${count > 1 ? 's' : ''} transaction${count > 1 ? 's' : ''} détectée${count > 1 ? 's' : ''}'
                : 'Aucune nouvelle transaction'),
            backgroundColor: count > 0 ? AppColors.accentColor : AppColors.surfaceColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.errorColor),
        );
      }
    }
  }
}

// ═══════════════════════════════════════════════════════
// CARTE DE TRANSACTION EN ATTENTE
// ═══════════════════════════════════════════════════════

class _PendingTransactionCard extends ConsumerWidget {
  final PendingTransaction transaction;
  const _PendingTransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final momoType = transaction.momoType;
    final isIncome = momoType == MomoTransactionType.transferIn ||
        momoType == MomoTransactionType.deposit;

    return Card(
      color: AppColors.cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showReviewSheet(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Ligne 1: Type + Montant ──
              Row(
                children: [
                  _buildTypeIcon(momoType),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _typeLabel(momoType),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (transaction.counterpart != null)
                          Text(
                            '${isIncome ? 'De' : 'À'} ${transaction.counterpart}',
                            style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isIncome ? '+' : '-'}${MoneyFormatter.formatCompact(transaction.amount, 'F')}',
                        style: TextStyle(
                          color: isIncome ? AppColors.accentColor : AppColors.errorColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (transaction.fee > 0)
                        Text(
                          'Frais: ${MoneyFormatter.formatCompact(transaction.fee, 'F')}',
                          style: const TextStyle(
                            color: AppColors.textTertiary, fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(color: AppColors.surfaceColor, height: 1),
              const SizedBox(height: 10),

              // ── Ligne 2: Détails (opérateur, date, solde) ──
              Row(
                children: [
                  _chip(transaction.operator),
                  const SizedBox(width: 8),
                  _chip(DateFormatter.formatRelative(
                    transaction.transactionDate ?? transaction.smsDate,
                  )),
                  const Spacer(),
                  if (transaction.balanceAfter != null)
                    Text(
                      'Solde: ${MoneyFormatter.formatCompact(transaction.balanceAfter!, 'F')}',
                      style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 12,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Ligne 3: Actions rapides ──
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Ignorer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.surfaceColor),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () => _rejectTransaction(context, ref),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Valider'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () => _showReviewSheet(context, ref),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon(MomoTransactionType type) {
    final (IconData icon, Color color) = switch (type) {
      MomoTransactionType.transferOut => (Icons.arrow_upward, AppColors.errorColor),
      MomoTransactionType.transferIn => (Icons.arrow_downward, AppColors.accentColor),
      MomoTransactionType.withdrawal => (Icons.money_off, AppColors.warningColor),
      MomoTransactionType.payment => (Icons.shopping_cart, AppColors.errorColor),
      MomoTransactionType.deposit => (Icons.account_balance_wallet, AppColors.accentColor),
      MomoTransactionType.unknown => (Icons.help_outline, AppColors.textSecondary),
    };
    return CircleAvatar(
      radius: 20,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _typeLabel(MomoTransactionType type) {
    return switch (type) {
      MomoTransactionType.transferOut => 'Transfert envoyé',
      MomoTransactionType.transferIn => 'Transfert reçu',
      MomoTransactionType.withdrawal => 'Retrait',
      MomoTransactionType.payment => 'Paiement',
      MomoTransactionType.deposit => 'Dépôt',
      MomoTransactionType.unknown => 'Transaction',
    };
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: const TextStyle(
        color: AppColors.textTertiary, fontSize: 11,
      )),
    );
  }

  void _rejectTransaction(BuildContext context, WidgetRef ref) {
    ref.read(analyticsServiceProvider).capture(
      'sms_transaction_rejected',
      properties: {'type': transaction.momoType.name},
    );
    ref.read(pendingTransactionsProvider.notifier).reject(transaction.id);
  }

  void _showReviewSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TransactionReviewSheet(transaction: transaction),
    );
  }
}

// ═══════════════════════════════════════════════════════
// BOTTOM SHEET DE REVIEW
// ═══════════════════════════════════════════════════════

class _TransactionReviewSheet extends ConsumerStatefulWidget {
  final PendingTransaction transaction;
  const _TransactionReviewSheet({required this.transaction});

  @override
  ConsumerState<_TransactionReviewSheet> createState() =>
      _TransactionReviewSheetState();
}

class _TransactionReviewSheetState
    extends ConsumerState<_TransactionReviewSheet> {
  bool _countsInBudget = true;
  int? _selectedCategoryId;
  int? _selectedAccountId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _countsInBudget = widget.transaction.countsInBudget;
    _selectedAccountId = widget.transaction.suggestedAccountId;
  }

  MomoTransactionType get _momoType => widget.transaction.momoType;

  bool get _isIncome =>
      _momoType == MomoTransactionType.transferIn ||
      _momoType == MomoTransactionType.deposit;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProviderProvider);
    final accountsAsync = ref.watch(accountsProviderProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Barre de drag ──
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Titre ──
              const Text(
                'Valider la transaction',
                style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // ── Résumé de la transaction ──
              _buildSummaryCard(),
              const SizedBox(height: 24),

              // ══════════════════════════════════════
              // TOGGLE "COMPTER DANS LE BUDGET"
              // ══════════════════════════════════════
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _countsInBudget
                        ? AppColors.primaryColor.withValues(alpha: 0.5)
                        : AppColors.surfaceColor,
                  ),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Compter dans le budget ?',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    _countsInBudget
                        ? 'Cette transaction sera incluse dans vos calculs de budget.'
                        : 'Cette transaction sera enregistrée mais n\'affectera pas votre budget.',
                    style: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 12,
                    ),
                  ),
                  value: _countsInBudget,
                  activeColor: AppColors.primaryColor,
                  onChanged: (value) => setState(() => _countsInBudget = value),
                ),
              ),
              const SizedBox(height: 24),

              // ── Sélection du compte ──
              const Text(
                'Compte',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600, fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              accountsAsync.when(
                data: (accounts) => _buildAccountSelector(accounts),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Erreur: $e'),
              ),
              const SizedBox(height: 20),

              // ── Sélection de la catégorie ──
              const Text(
                'Catégorie',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600, fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              categoriesAsync.when(
                data: (categories) => _buildCategorySelector(categories),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Erreur: $e'),
              ),
              const SizedBox(height: 32),

              // ── Boutons ──
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.surfaceColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: (_selectedCategoryId != null &&
                              _selectedAccountId != null &&
                              !_isSubmitting)
                          ? _approve
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.surfaceColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white,
                              ),
                            )
                          : const Text('Confirmer',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard() {
    final tx = widget.transaction;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Montant principal
          Text(
            '${_isIncome ? '+' : '-'}${MoneyFormatter.formatCompact(tx.amount, 'FCFA')}',
            style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold,
              color: _isIncome ? AppColors.accentColor : AppColors.errorColor,
            ),
          ),
          if (tx.fee > 0)
            Text(
              'Frais: ${MoneyFormatter.formatCompact(tx.fee, 'FCFA')}',
              style: const TextStyle(color: AppColors.warningColor, fontSize: 13),
            ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.surfaceColor),
          const SizedBox(height: 8),
          // Détails en grille
          _detailRow('Type', _typeLabel(_momoType)),
          if (tx.counterpart != null)
            _detailRow(_isIncome ? 'De' : 'À', tx.counterpart!),
          if (tx.counterpartPhone != null)
            _detailRow('Téléphone', tx.counterpartPhone!),
          _detailRow('Date',
            DateFormatter.formatWithTime(tx.transactionDate ?? tx.smsDate)),
          _detailRow('Opérateur', tx.operator),
          if (tx.balanceAfter != null)
            _detailRow('Solde après',
              MoneyFormatter.formatCompact(tx.balanceAfter!, 'FCFA')),
          if (tx.momoRef != null)
            _detailRow('Réf. MoMo', tx.momoRef!),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(
            color: AppColors.textTertiary, fontSize: 13,
          )),
          Flexible(
            child: Text(value, textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSelector(List<Account> accounts) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: accounts.map((account) {
        final isSelected = _selectedAccountId == account.id;
        return ChoiceChip(
          label: Text(account.name),
          selected: isSelected,
          selectedColor: AppColors.primaryColor.withValues(alpha: 0.3),
          backgroundColor: AppColors.cardColor,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primaryColor : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? AppColors.primaryColor : AppColors.surfaceColor,
          ),
          onSelected: (_) => setState(() => _selectedAccountId = account.id),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySelector(List<Category> categories) {
    // Filtrer par type: dépense ou revenu
    final filtered = categories.where((c) {
      return _isIncome
          ? c.type == CategoryType.income
          : c.type == CategoryType.expense;
    }).toList();

    if (filtered.isEmpty) {
      return const Text(
        'Aucune catégorie disponible',
        style: TextStyle(color: AppColors.textTertiary),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filtered.map((cat) {
        final isSelected = _selectedCategoryId == cat.id;
        return ChoiceChip(
          avatar: Text(cat.icon, style: const TextStyle(fontSize: 16)),
          label: Text(cat.name),
          selected: isSelected,
          selectedColor: AppColors.primaryColor.withValues(alpha: 0.3),
          backgroundColor: AppColors.cardColor,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primaryColor : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? AppColors.primaryColor : AppColors.surfaceColor,
          ),
          onSelected: (_) => setState(() => _selectedCategoryId = cat.id),
        );
      }).toList(),
    );
  }

  String _typeLabel(MomoTransactionType type) {
    return switch (type) {
      MomoTransactionType.transferOut => 'Transfert envoyé',
      MomoTransactionType.transferIn => 'Transfert reçu',
      MomoTransactionType.withdrawal => 'Retrait',
      MomoTransactionType.payment => 'Paiement',
      MomoTransactionType.deposit => 'Dépôt',
      MomoTransactionType.unknown => 'Transaction',
    };
  }

  Future<void> _approve() async {
    if (_selectedCategoryId == null || _selectedAccountId == null) return;

    setState(() => _isSubmitting = true);

    try {
      ref.read(analyticsServiceProvider).capture(
        'sms_transaction_approved',
        properties: {
          'type': _momoType.name,
          'amount': widget.transaction.amount,
          'counts_in_budget': _countsInBudget,
          'operator': widget.transaction.operator,
        },
      );

      await ref.read(pendingTransactionsProvider.notifier).approve(
        pendingId: widget.transaction.id,
        categoryId: _selectedCategoryId!,
        accountId: _selectedAccountId!,
        countsInBudget: _countsInBudget,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction ajoutée ✓'),
            backgroundColor: AppColors.accentColor,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }
}
