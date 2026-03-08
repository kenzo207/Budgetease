import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import "../../../core/utils/ui_helpers.dart";

import '../../../core/constants/app_constants.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/tables/recurring_incomes_table.dart';
import '../../providers/incomes_provider.dart';
import '../onboarding/calibration_screen.dart';
import 'income_form_screen.dart';

class IncomesScreen extends ConsumerWidget {
  const IncomesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomesAsync = ref.watch(incomesNotifierProvider);
    final currency = ref.watch(calibrationDataProvider).currency;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes revenus réguliers'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const IncomeFormScreen()),
        ),
        icon: Icon(Icons.add),
        label: Text('Ajouter'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: incomesAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildError(context, ref, e),
        data: (incomes) {
          if (incomes.isEmpty) return _buildEmpty(context);
          return _buildList(context, ref, incomes, currency);
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25)),
            SizedBox(height: 20),
            Text('Aucun revenu régulier',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Text(
              'Argent de poche, salaire, paie hebdomadaire...\nAjoutez vos entrées d\'argent prévisibles.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object e) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.primary),
          SizedBox(height: 12),
          Text('Erreur : $e'),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => ref.invalidate(incomesNotifierProvider),
            child: Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref,
      List<RecurringIncome> incomes, String currency) {
    
    // Total estimé par mois
    double totalMonthly = 0.0;
    for (final inc in incomes) {
      if (!inc.isActive) continue;
      if (inc.frequency == IncomeFrequency.monthly) {
        totalMonthly += inc.amount;
      } else if (inc.frequency == IncomeFrequency.weekly) {
        totalMonthly += inc.amount * 4.33; // moyenne par mois
      } else if (inc.frequency == IncomeFrequency.daily_x_times) {
        totalMonthly += (inc.amount * (inc.daysPerWeek ?? 1)) * 4.33;
      }
    }

    return CustomScrollView(
      slivers: [
        // ── Résumé ──
        SliverToBoxAdapter(
          child: _SummaryBanner(total: totalMonthly, currency: currency),
        ),
        // ── Liste ──
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _IncomeCard(
                income: incomes[i],
                currency: currency,
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IncomeFormScreen(income: incomes[i]),
                  ),
                ),
                onDelete: () => _confirmDelete(context, ref, incomes[i]),
              ),
              childCount: incomes.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, RecurringIncome income) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Supprimer ce revenu ?'),
        content: Text(
          '« ${income.name} » (${income.amount.toStringAsFixed(0)}) ne sera plus anticipé par le moteur.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok == true) {
      ref.read(incomesNotifierProvider.notifier).deleteIncome(income.id);
    }
  }
}

// ─────────────────────────────────────────────────────────
// Widget — Banner résumé total
// ─────────────────────────────────────────────────────────
class _SummaryBanner extends StatelessWidget {
  final double total;
  final String currency;

  const _SummaryBanner({required this.total, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Entrées prévues (Mensuel est.)',
                  style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(height: 4),
              Text(
                '+ ${NumberFormat.decimalPattern('fr').format(total)} $currency',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          Icon(Icons.trending_up_outlined,
              size: 28,
              color: Theme.of(context).colorScheme.primary),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Widget — Carte d'un revenu
// ─────────────────────────────────────────────────────────
class _IncomeCard extends StatelessWidget {
  final RecurringIncome income;
  final String currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _IncomeCard({
    required this.income,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final Formatter = DateFormat('dd MMM yyyy', 'fr');
    final isPending = income.nextDepositDate.isBefore(DateTime.now()) || DateUtils.isSameDay(income.nextDepositDate, DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPending 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
          width: isPending ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_typeIcon(income.type),
                  size: 20, color: Theme.of(context).colorScheme.primary),
            ),
            title: Text(income.name,
                style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(
              _frequencyString(income),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+ ${NumberFormat.decimalPattern('fr').format(income.amount)}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
                ),
                Text(
                  isPending ? 'Attendue aujourd\'hui' : 'Prévu le : ${Formatter.format(income.nextDepositDate)}',
                  style: TextStyle(
                      fontSize: 11,
                      color: isPending ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ),
          // ── Actions ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                  tooltip: 'Modifier',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline,
                      size: 18, color: Theme.of(context).colorScheme.primary),
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _frequencyString(RecurringIncome income) {
    switch (income.frequency) {
      case IncomeFrequency.monthly:
        return 'Mensuel';
      case IncomeFrequency.weekly:
        return 'Hebdomadaire';
      case IncomeFrequency.daily_x_times:
        final d = income.daysPerWeek ?? 1;
        return '$d fois par semaine';
    }
  }

  IconData _typeIcon(IncomeCategory type) {
    switch (type) {
      case IncomeCategory.pocket_money: return Icons.account_balance_wallet_outlined;
      case IncomeCategory.salary:       return Icons.work_outline;
      case IncomeCategory.freelance:    return Icons.laptop_mac_outlined;
      case IncomeCategory.business:     return Icons.storefront_outlined;
      case IncomeCategory.allowance:    return Icons.family_restroom_outlined;
      case IncomeCategory.other:        return Icons.monetization_on_outlined;
    }
  }
}
