import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/formatters.dart';
import '../../models/ghost_money_insight.dart';
import '../../services/database_service.dart';

class GhostMoneyCard extends StatelessWidget {
  final GhostMoneyInsight insight;
  final VoidCallback? onDismiss;

  const GhostMoneyCard({
    super.key,
    required this.insight,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final settings = DatabaseService.settings.values.firstOrNull;
    final currency = settings?.currency ?? 'FCFA';

    // Couleur basée sur la sévérité (sobre)
    Color borderColor;
    Color bgColor;
    
    switch (insight.severity) {
      case 'high':
        borderColor = AppColors.warning;
        bgColor = AppColors.warning.withOpacity(0.05);
        break;
      case 'medium':
        borderColor = AppColors.primary;
        bgColor = AppColors.primary.withOpacity(0.05);
        break;
      default:
        borderColor = AppColors.gray400;
        bgColor = AppColors.gray50;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Petites dépenses répétées',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  color: AppColors.gray600,
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Montant total
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Cette semaine',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                CurrencyFormatter.format(insight.totalAmount, currency),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Nombre de transactions
          Text(
            '${insight.transactionCount} transactions',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Catégories
          if (insight.categoryNames.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: insight.categoryNames.take(3).map((category) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          
          // Impact
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: borderColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cela représente ${insight.percentageOfAvailable.toStringAsFixed(1)}% de votre argent disponible.',
                    style: TextStyle(
                      fontSize: 13,
                      color: borderColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
