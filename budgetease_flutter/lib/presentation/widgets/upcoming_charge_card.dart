import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/recurring_charges_dao.dart';
import '../../data/database/tables/recurring_charges_table.dart';
import '../providers/charges_provider.dart';
import '../screens/charges/charges_screen.dart';
import 'zolt_card.dart';

/// Widget HomeScreen — affiche la charge la plus urgente (≤ 7 jours)
/// Ne s'affiche pas s'il n'y a aucune charge urgente.
class UpcomingChargeCard extends ConsumerWidget {
  final String currency;

  const UpcomingChargeCard({super.key, required this.currency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urgentAsync = ref.watch(mostUrgentChargeProvider);

    return urgentAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (charge) {
        if (charge == null) return const SizedBox.shrink();

        final daysLeft = charge.dueDate.difference(DateTime.now()).inDays;

        // On n'affiche que si la charge est dans les 7 prochains jours
        if (daysLeft > 7) return const SizedBox.shrink();

        return _ChargeAlertCard(
          charge: charge,
          daysLeft: daysLeft,
          currency: currency,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChargesScreen()),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// Card visuelle
// ─────────────────────────────────────────────────────────
class _ChargeAlertCard extends StatelessWidget {
  final RecurringCharge charge;
  final int daysLeft;
  final String currency;
  final VoidCallback onTap;

  const _ChargeAlertCard({
    required this.charge,
    required this.daysLeft,
    required this.currency,
    required this.onTap,
  });

  Color _getColor(BuildContext context) {
    // Dans le thème Pure B&W, on utilise la couleur primaire qui contraste avec le Scaffold
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final _color = _getColor(context);
    final dailyReserve = RecurringChargesDao.dailyReserveFor(charge);
    final cs = Theme.of(context).colorScheme;
    final fmt = NumberFormat.decimalPattern('fr');

    final label = daysLeft < 0
        ? 'En retard de ${-daysLeft} jour${-daysLeft > 1 ? 's' : ''}'
        : daysLeft == 0
            ? 'Due aujourd\'hui !'
            : 'Dans $daysLeft jour${daysLeft > 1 ? 's' : ''}';

    return ZoltCard(
      profile: ZoltCardProfile.semantic,
      semanticLevel: ZoltSemanticLevel.critical,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      onTap: onTap,
      child: Row(
          children: [
            // Icône urgence
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.notifications_outlined, color: _color, size: 20),
            ),
            SizedBox(width: 12),

            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    charge.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: _color,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '$label · Réserve: ${fmt.format(dailyReserve.round())} $currency/j',
                    style: TextStyle(
                      fontSize: 12,
                      color: _color.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Montant
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  fmt.format(charge.amount.toInt()),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  currency,
                  style: TextStyle(
                      fontSize: 11,
                      color: _color.withValues(alpha: 0.7)),
                ),
              ],
            ),

            SizedBox(width: 6),
            Icon(Icons.chevron_right, color: _color.withValues(alpha: 0.6)),
          ],
        ),
    );
  }
}
