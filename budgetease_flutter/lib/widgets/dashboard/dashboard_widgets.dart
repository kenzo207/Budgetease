import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/formatters.dart';

class SummaryCard extends StatelessWidget {
  final double income;
  final double expenses;
  final double balance;
  final String currency;

  const SummaryCard({
    super.key,
    required this.income,
    required this.expenses,
    required this.balance,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildRow(
              'Revenus',
              CurrencyFormatter.format(income, currency),
              AppColors.success,
              Icons.arrow_upward,
            ),
            const Divider(height: 32),
            _buildRow(
              'Dépenses',
              CurrencyFormatter.format(expenses, currency),
              AppColors.danger,
              Icons.arrow_downward,
            ),
            const Divider(height: 32),
            _buildRow(
              'Solde',
              CurrencyFormatter.format(balance, currency),
              AppColors.primary,
              Icons.account_balance_wallet,
              isLarge: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String amount,
    Color color,
    IconData icon, {
    bool isLarge = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: isLarge ? 24 : 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isLarge ? 16 : 14,
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                amount,
                style: TextStyle(
                  fontSize: isLarge ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String name;
  final String icon;
  final double amount;
  final double percentage;
  final String currency;

  const CategoryCard({
    super.key,
    required this.name,
    required this.icon,
    required this.amount,
    required this.percentage,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(amount, currency),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 8,
                backgroundColor: AppColors.gray200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const QuickStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
