import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../data/database/app_database.dart';
import '../providers/phase7_providers.dart';

/// Widget pour afficher une alerte Ghost Money
class GhostMoneyCard extends ConsumerWidget {
  final Insight insight;

  const GhostMoneyCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: AppColors.cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.warningColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warningColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '👻',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Argent Fantôme Détecté',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.warningColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Micro-dépenses répétées',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Détails
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transactions',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${insight.transactionCount}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.warningColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Montant total',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${insight.totalAmount.toStringAsFixed(0)} FCFA',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.warningColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Impact budget',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${insight.percentageOfAvailable.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.errorColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Message
            Text(
              'Ces petites dépenses s\'accumulent et représentent une part significative de votre budget disponible.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            
            const SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Dismiss insight
                      ref.read(insightsServiceProvider).dismissInsight(insight.id);
                      ref.invalidate(activeInsightsProvider);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.textTertiary),
                    ),
                    child: const Text('Compris'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Naviguer vers transactions
                      Navigator.pushNamed(context, '/transactions');
                    },
                    child: const Text('Voir détails'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
