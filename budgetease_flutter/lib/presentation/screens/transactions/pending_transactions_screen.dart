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
        title: Text('Transactions SMS'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            tooltip: 'Scanner les SMS',
            onPressed: () => _scanSms(context, ref),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: pendingAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return _buildEmptyState(context, ref);
          }
          return _buildTransactionList(context, ref, transactions);
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Analyse des SMS...', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
            ],
          ),
        ),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.primary),
                SizedBox(height: 16),
                Text('Erreur: $e', textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(pendingTransactionsProvider),
                  child: Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
            SizedBox(height: 24),
            Text(
              'Aucune transaction en attente',
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Les SMS Mobile Money détectés apparaîtront ici pour validation.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.sync),
              label: Text('Scanner maintenant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14,
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
      final result = await ref.read(pendingTransactionsProvider.notifier).scan();
      if (context.mounted) {
        final String msg;
        if (!result.hasActivity) {
          msg = 'Aucune nouvelle transaction';
        } else if (result.pendingAdded == 0) {
          msg = '${result.autoApproved} transaction${result.autoApproved > 1 ? 's' : ''} traitée${result.autoApproved > 1 ? 's' : ''} automatiquement ✓';
        } else if (result.autoApproved == 0) {
          msg = '${result.pendingAdded} transaction${result.pendingAdded > 1 ? 's' : ''} à valider';
        } else {
          msg = '${result.autoApproved} auto-traitée${result.autoApproved > 1 ? 's' : ''}, ${result.pendingAdded} à valider';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: result.hasActivity
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Theme.of(context).colorScheme.primary),
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
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                  _buildTypeIcon(context, momoType),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _typeLabel(momoType),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (transaction.counterpart != null)
                          Text(
                            '${isIncome ? 'De' : 'À'} ${transaction.counterpart}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13,
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
                          color: isIncome ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (transaction.fee > 0)
                        Text(
                          'Frais: ${MoneyFormatter.formatCompact(transaction.fee, 'F')}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 10),
              Divider(color: Theme.of(context).colorScheme.surface, height: 1),
              SizedBox(height: 10),

              // ── Ligne 2: Détails (opérateur, date, solde) ──
              Row(
                children: [
                  _chip(context, transaction.operator),
                  SizedBox(width: 4),
                  _chip(context, DateFormatter.formatRelative(
                    transaction.transactionDate ?? transaction.smsDate,
                  )),
                  const Spacer(),
                  if (transaction.balanceAfter != null)
                    Text(
                      'Solde: ${MoneyFormatter.formatCompact(transaction.balanceAfter!, 'F')}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 12,
                      ),
                    ),
                ],
              ),

              SizedBox(height: 12),

              // ── Ligne 3: Actions rapides ──
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.close, size: 18),
                      label: Text('Ignorer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        side: BorderSide(color: Theme.of(context).colorScheme.surface),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () => _rejectTransaction(context, ref),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.check, size: 18),
                      label: Text('Valider'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
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

  Widget _buildTypeIcon(BuildContext context, MomoTransactionType type) {
    final (IconData icon, Color color) = switch (type) {
      MomoTransactionType.transferOut => (Icons.arrow_upward, Theme.of(context).colorScheme.primary),
      MomoTransactionType.transferIn => (Icons.arrow_downward, Theme.of(context).colorScheme.primary),
      MomoTransactionType.withdrawal => (Icons.money_off, Theme.of(context).colorScheme.primary),
      MomoTransactionType.payment => (Icons.shopping_cart_outlined, Theme.of(context).colorScheme.primary),
      MomoTransactionType.deposit => (Icons.account_balance_wallet_outlined, Theme.of(context).colorScheme.primary),
      MomoTransactionType.unknown => (Icons.help_outline, Theme.of(context).colorScheme.onSurface),
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

  Widget _chip(BuildContext context, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 11,
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
  bool _hasSuggestedCategory = false; // garde un suivi de la suggestion auto

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

  /// Suggère automatiquement la meilleure catégorie pour ce type de transaction.
  /// Logique à 3 niveaux :
  ///   1. Match par mot-clé dans le nom de catégorie
  ///   2. Première catégorie isDefault du bon type
  ///   3. Première catégorie du bon type
  void _suggestCategory(List<Category> allCategories) {
    if (_hasSuggestedCategory) return;

    // Filtrer par type income/expense
    final filtered = allCategories.where((c) {
      return _isIncome
          ? c.type == CategoryType.income
          : c.type == CategoryType.expense;
    }).toList();

    if (filtered.isEmpty) return;

    // Niveau 1 : match par mot-clé selon le type MoMo
    final keywords = _keywordsForType(_momoType);
    Category? best;
    for (final keyword in keywords) {
      best = filtered.where((c) =>
        c.name.toLowerCase().contains(keyword)
      ).firstOrNull;
      if (best != null) break;
    }

    // Niveau 2 : catégorie par défaut du bon type
    best ??= filtered.where((c) => c.isDefault).firstOrNull;

    // Niveau 3 : première du bon type
    best ??= filtered.firstOrNull;

    if (best != null) {
      setState(() {
        _selectedCategoryId = best!.id;
        _hasSuggestedCategory = true;
      });
    }
  }

  /// Mots-clés à chercher dans les noms de catégories selon le type MoMo
  List<String> _keywordsForType(MomoTransactionType type) {
    return switch (type) {
      MomoTransactionType.transferOut => ['transfert', 'envoi', 'virement'],
      MomoTransactionType.transferIn  => ['transfert', 'revenu', 'reçu', 'salaire'],
      MomoTransactionType.withdrawal  => ['retrait', 'espèces', 'cash'],
      MomoTransactionType.payment     => ['paiement', 'achat', 'courses', 'commerce'],
      MomoTransactionType.deposit     => ['dépôt', 'depot', 'revenu', 'salaire'],
      MomoTransactionType.unknown     => [],
    };
  }

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
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // ── Titre ──
              Text(
                'Valider la transaction',
                style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 24),

              // ── Résumé de la transaction ──
              _buildSummaryCard(),
              SizedBox(height: 24),

              // ══════════════════════════════════════
              // TOGGLE "COMPTER DANS LE BUDGET"
              // ══════════════════════════════════════
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _countsInBudget
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                        : Theme.of(context).colorScheme.surface,
                  ),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Compter dans le budget ?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    _countsInBudget
                        ? 'Cette transaction sera incluse dans vos calculs de budget.'
                        : 'Cette transaction sera enregistrée mais n\'affectera pas votre budget.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 12,
                    ),
                  ),
                  value: _countsInBudget,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) => setState(() => _countsInBudget = value),
                ),
              ),
              SizedBox(height: 24),

              // ── Sélection du compte ──
              Text(
                'Compte',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600, fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              accountsAsync.when(
                data: (accounts) => _buildAccountSelector(accounts),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Erreur: $e'),
              ),
              SizedBox(height: 20),

              // ── Sélection de la catégorie ──
              Text(
                'Catégorie',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600, fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              categoriesAsync.when(
                data: (categories) {
                  // Déclencher la suggestion auto (appel idempotent)
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _suggestCategory(categories);
                  });
                  return _buildCategorySelector(categories);
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Erreur: $e'),
              ),
              SizedBox(height: 32),

              // ── Boutons ──
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        side: BorderSide(color: Theme.of(context).colorScheme.surface),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('Annuler'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: (_selectedCategoryId != null &&
                              _selectedAccountId != null &&
                              !_isSubmitting)
                          ? _approve
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Theme.of(context).colorScheme.surface,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white,
                              ),
                            )
                          : Text('Confirmer',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Montant principal
          Text(
            '${_isIncome ? '+' : '-'}${MoneyFormatter.formatCompact(tx.amount, 'FCFA')}',
            style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold,
              color: _isIncome ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
            ),
          ),
          if (tx.fee > 0)
            Text(
              'Frais: ${MoneyFormatter.formatCompact(tx.fee, 'FCFA')}',
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13),
            ),
          SizedBox(height: 12),
          Divider(color: Theme.of(context).colorScheme.surface),
          SizedBox(height: 8),
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
          Text(label, style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 13,
          )),
          Flexible(
            child: Text(value, textAlign: TextAlign.end,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface, fontSize: 13,
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
          selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          labelStyle: TextStyle(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
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
      return Text(
        'Aucune catégorie disponible',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filtered.map((cat) {
        final isSelected = _selectedCategoryId == cat.id;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            ChoiceChip(
              avatar: Text(cat.icon, style: const TextStyle(fontSize: 16)),
              label: Text(cat.name),
              selected: isSelected,
              selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              labelStyle: TextStyle(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
              ),
              onSelected: (_) => setState(() {
                _selectedCategoryId = cat.id;
                _hasSuggestedCategory = true; // l'utilisateur a fait un choix explicite
              }),
            ),
            // Badge "suggestion" discret sur la catégorie auto-sélectionnée
            if (isSelected && _hasSuggestedCategory && _selectedCategoryId == cat.id)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Auto',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
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
          SnackBar(
            content: Text('Transaction ajoutée ✓'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }
}
