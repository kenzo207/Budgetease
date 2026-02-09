import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgetease_flutter/services/daily_cap_calculator.dart';
import 'package:budgetease_flutter/widgets/liquid_gauge.dart';

/// Flow Screen - Shows daily budget status
class FlowScreen extends StatelessWidget {
  const FlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calculator = Provider.of<DailyCapCalculator>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: FutureBuilder<BudgetStatus>(
          future: calculator.getBudgetStatus('FCFA'),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final status = snapshot.data!;
            final percentage = status.spentPercentage;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Title
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.water_drop_outlined,
                        size: 32,
                        color: Color(0xFF6C63FF),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Daily Flow',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Today\'s Budget',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Liquid Gauge
                  LiquidGauge(
                    dailyCap: status.dailyCap,
                    spent: status.todaySpent,
                    currency: 'FCFA',
                  ),

                  const SizedBox(height: 48),

                  // Stats Cards
                  _buildStatsRow(status),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Add expense
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                          label: const Text('Dépense'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Add income
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Revenu'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsRow(BudgetStatus status) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Daily Cap',
            value: '${status.dailyCap.amount.toStringAsFixed(0)} FCFA',
            icon: Icons.account_balance_wallet,
            color: const Color(0xFF6C63FF),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            label: 'Spent',
            value: '${status.todaySpent.amount.toStringAsFixed(0)} FCFA',
            icon: Icons.trending_down,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
