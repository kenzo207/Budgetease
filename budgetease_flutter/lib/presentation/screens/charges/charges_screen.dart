import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/utils/zolt_colors.dart';

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

    final zolt = context.zolt;

    return Scaffold(
      backgroundColor: zolt.bg,
      appBar: AppBar(
        backgroundColor: zolt.bg,
        elevation: 0,
        titleSpacing: 16,
        title: Text(
          'Charges fixes',
          style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 24, fontWeight: FontWeight.w700, color: zolt.textPrimary),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChargeFormScreen())),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: ZoltTokens.brand, borderRadius: BorderRadius.circular(10)),
                child: const Icon(LucideIcons.plus, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
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
                'TOTAL CE CYCLE',
                style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.4, color: zolt.text3),
              ),
              const SizedBox(height: 4),
              Text(
                '${NumberFormat.decimalPattern('fr').format(total)} $currency',
                style: TextStyle(fontFamily: 'Zodiak', fontSize: 22, fontWeight: FontWeight.w700, color: ZoltTokens.critical),
              ),
            ],
          ),
          Icon(LucideIcons.repeat, size: 24, color: zolt.text3),
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
    final urgencyColor = _urgencyColor(daysLeft);
    final zolt = context.zolt;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: zolt.surface,
        borderRadius: BorderRadius.circular(14),
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
                      color: urgencyColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Icon(_typeIconLucide(charge.type), size: 18, color: urgencyColor)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          charge.name,
                          style: TextStyle(
                            fontFamily: 'CabinetGrotesk',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: zolt.textPrimary,
                            decoration: charge.isPaid ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          charge.isPaid
                              ? 'Payée ✓'
                              : daysLeft < 0
                                  ? 'En retard de ${-daysLeft}j'
                                  : daysLeft == 0
                                      ? "Due aujourd'hui !"
                                      : 'Dans $daysLeft jour${daysLeft > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontFamily: 'CabinetGrotesk',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: charge.isPaid ? ZoltTokens.positive : urgencyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${NumberFormat.decimalPattern('fr').format(charge.amount)} $currency',
                        style: TextStyle(fontFamily: 'Zodiak', fontSize: 14, fontWeight: FontWeight.w700, color: zolt.textPrimary),
                      ),
                      if (!charge.isPaid)
                        Text(
                          '${NumberFormat.decimalPattern('fr').format(dailyReserve.round())}/j',
                          style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 11, color: zolt.text3),
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
                if (!charge.isPaid)
                  IconButton(
                    onPressed: onMarkPaid,
                    icon: Icon(LucideIcons.checkCircle, size: 18, color: ZoltTokens.positive),
                    tooltip: 'Marquer payée',
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

  Color _urgencyColor(int days) {
    if (days < 0) return ZoltTokens.critical;
    if (days <= 3) return ZoltTokens.critical;
    if (days <= 7) return ZoltTokens.warning;
    return ZoltTokens.positive;
  }

  IconData _typeIconLucide(ChargeType type) {
    switch (type) {
      case ChargeType.rent:        return LucideIcons.home;
      case ChargeType.electricity: return LucideIcons.zap;
      case ChargeType.water:       return LucideIcons.droplets;
      case ChargeType.internet:    return LucideIcons.wifi;
      case ChargeType.school:      return LucideIcons.graduationCap;
      case ChargeType.transport:   return LucideIcons.bus;
      case ChargeType.other:       return LucideIcons.receipt;
    }
  }
}
