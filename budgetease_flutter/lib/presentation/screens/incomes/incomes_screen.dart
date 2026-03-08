import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import "../../../core/utils/ui_helpers.dart";
import '../../../core/utils/zolt_colors.dart';

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

    final zolt = context.zolt;

    return Scaffold(
      backgroundColor: zolt.bg,
      appBar: AppBar(
        backgroundColor: zolt.bg,
        elevation: 0,
        titleSpacing: 16,
        title: Text(
          'Revenus réguliers',
          style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 24, fontWeight: FontWeight.w700, color: zolt.textPrimary),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IncomeFormScreen())),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: ZoltTokens.positive, borderRadius: BorderRadius.circular(10)),
                child: const Icon(LucideIcons.plus, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
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
    final zolt = context.zolt;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: zolt.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ENTRÉES PREV. / MOIS',
                style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.4, color: zolt.text3),
              ),
              const SizedBox(height: 4),
              Text(
                '+ ${NumberFormat.decimalPattern('fr').format(total)} $currency',
                style: TextStyle(fontFamily: 'Zodiak', fontSize: 22, fontWeight: FontWeight.w700, color: ZoltTokens.positive),
              ),
            ],
          ),
          Icon(LucideIcons.trendingUp, size: 24, color: ZoltTokens.positive),
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
    final dateFormatter = DateFormat('dd MMM yyyy', 'fr');
    final isPending = income.nextDepositDate.isBefore(DateTime.now()) || DateUtils.isSameDay(income.nextDepositDate, DateTime.now());
    final zolt = context.zolt;
    final borderColor = isPending ? ZoltTokens.positive : Colors.transparent;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: zolt.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: isPending ? 1.5 : 0),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: ZoltTokens.positiveMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Icon(_typeIconLucide(income.type), size: 18, color: ZoltTokens.positive)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          income.name,
                          style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 13, fontWeight: FontWeight.w500, color: zolt.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _frequencyString(income),
                          style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 11, color: zolt.text3),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+ ${NumberFormat.decimalPattern('fr').format(income.amount)}',
                        style: TextStyle(fontFamily: 'Zodiak', fontSize: 14, fontWeight: FontWeight.w700, color: ZoltTokens.positive),
                      ),
                      Text(
                        isPending ? "Attendue aujourd'hui" : 'Prévu le ${dateFormatter.format(income.nextDepositDate)}',
                        style: TextStyle(
                          fontFamily: 'CabinetGrotesk',
                          fontSize: 10,
                          color: isPending ? ZoltTokens.positive : zolt.text3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(LucideIcons.edit2, size: 17, color: zolt.text3),
                  tooltip: 'Modifier',
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(LucideIcons.trash2, size: 17, color: ZoltTokens.critical),
                  tooltip: 'Supprimer',
                  visualDensity: VisualDensity.compact,
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

  IconData _typeIconLucide(IncomeCategory type) {
    switch (type) {
      case IncomeCategory.pocket_money: return LucideIcons.wallet;
      case IncomeCategory.salary:       return LucideIcons.briefcase;
      case IncomeCategory.freelance:    return LucideIcons.laptop;
      case IncomeCategory.business:     return LucideIcons.store;
      case IncomeCategory.allowance:    return LucideIcons.users;
      case IncomeCategory.other:        return LucideIcons.coins;
    }
  }
}
