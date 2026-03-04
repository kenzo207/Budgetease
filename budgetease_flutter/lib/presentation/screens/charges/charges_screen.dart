import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/ui_helpers.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/daos/recurring_charges_dao.dart';
import '../../../data/database/tables/recurring_charges_table.dart';
import '../../providers/charges_provider.dart';
import '../onboarding/calibration_screen.dart';
import 'charge_form_screen.dart';

class ChargesScreen extends ConsumerWidget {
  const ChargesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chargesAsync = ref.watch(chargesNotifierProvider);
    final currency = ref.watch(calibrationDataProvider).currency;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mes charges fixes'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChargeFormScreen()),
        ),
        icon: Icon(Icons.add),
        label: Text('Ajouter'),
      ),
      body: chargesAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildError(context, ref, e),
        data: (charges) {
          if (charges.isEmpty) return _buildEmpty(context);
          return _buildList(context, ref, charges, currency);
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
            Icon(Icons.receipt_long_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25)),
            SizedBox(height: 20),
            Text('Aucune charge fixe',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Text(
              'Loyer, factures, scolarité...\nTout ce que vous payez régulièrement.',
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
            onPressed: () => ref.invalidate(chargesNotifierProvider),
            child: Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref,
      List<RecurringCharge> charges, String currency) {
    // Total mensuel estimé
    final total = charges.fold<double>(0, (s, c) => s + c.amount);

    return CustomScrollView(
      slivers: [
        // ── Résumé ──
        SliverToBoxAdapter(
          child: _SummaryBanner(total: total, currency: currency),
        ),
        // ── Liste ──
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _ChargeCard(
                charge: charges[i],
                currency: currency,
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChargeFormScreen(charge: charges[i]),
                  ),
                ),
                onMarkPaid: () =>
                    ref.read(chargesNotifierProvider.notifier).markPaid(charges[i].id),
                onDelete: () => _confirmDelete(context, ref, charges[i]),
              ),
              childCount: charges.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, RecurringCharge charge) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Supprimer la charge ?'),
        content: Text(
          '« ${charge.name} » (${charge.amount.toStringAsFixed(0)}) sera supprimée définitivement.',
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
      ref.read(chargesNotifierProvider.notifier).delete(charge.id);
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Theme.of(context).colorScheme.outline, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total à prévoir',
                  style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(height: 4),
              Text(
                '${NumberFormat.decimalPattern('fr').format(total)} $currency',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          Icon(Icons.calendar_today_outlined,
              size: 28,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Widget — Carte d'une charge
// ─────────────────────────────────────────────────────────
class _ChargeCard extends StatelessWidget {
  final RecurringCharge charge;
  final String currency;
  final VoidCallback onEdit;
  final VoidCallback onMarkPaid;
  final VoidCallback onDelete;

  const _ChargeCard({
    required this.charge,
    required this.currency,
    required this.onEdit,
    required this.onMarkPaid,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = charge.dueDate.difference(DateTime.now()).inDays;
    final dailyReserve = RecurringChargesDao.dailyReserveFor(charge);
    final urgencyColor = _urgencyColor(context, daysLeft);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: charge.isPaid
              ? Theme.of(context).colorScheme.outline
              : urgencyColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: urgencyColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_typeIcon(charge.type),
                  size: 20, color: urgencyColor),
            ),
            title: Text(charge.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration:
                          charge.isPaid ? TextDecoration.lineThrough : null,
                    )),
            subtitle: Text(
              charge.isPaid
                  ? '✓ Payée'
                  : daysLeft < 0
                      ? 'En retard de ${-daysLeft}j'
                      : daysLeft == 0
                          ? 'Due aujourd\'hui !'
                          : 'Dans $daysLeft jour${daysLeft > 1 ? 's' : ''}',
              style: TextStyle(
                  color: charge.isPaid
                      ? Theme.of(context).colorScheme.primary
                      : urgencyColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${NumberFormat.decimalPattern('fr').format(charge.amount)} $currency',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (!charge.isPaid)
                  Text(
                    '${NumberFormat.decimalPattern('fr').format(dailyReserve.round())}/j',
                    style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
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
                if (!charge.isPaid)
                  IconButton(
                    onPressed: onMarkPaid,
                    icon: Icon(Icons.check_circle_outline,
                        size: 20, color: Theme.of(context).colorScheme.primary),
                    tooltip: 'Marquer payée',
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

  Color _urgencyColor(BuildContext context, int days) {
    if (days < 0) return Theme.of(context).colorScheme.primary;
    if (days <= 3) return Theme.of(context).colorScheme.primary;
    if (days <= 7) return Theme.of(context).colorScheme.primary;
    return Theme.of(context).colorScheme.primary;
  }

  IconData _typeIcon(ChargeType type) {
    switch (type) {
      case ChargeType.rent:        return Icons.home_outlined;
      case ChargeType.electricity: return Icons.bolt;
      case ChargeType.water:       return Icons.water_drop_outlined;
      case ChargeType.internet:    return Icons.wifi_outlined;
      case ChargeType.school:      return Icons.school_outlined;
      case ChargeType.transport:   return Icons.directions_bus_outlined;
      case ChargeType.other:       return Icons.receipt_outlined;
    }
  }
}
