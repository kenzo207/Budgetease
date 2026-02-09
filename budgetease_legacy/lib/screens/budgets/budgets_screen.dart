import 'package:flutter/material.dart';
import '../../models/budget.dart';
import '../../models/transaction.dart';
import '../../services/database_service.dart';
import '../../services/calculation_service.dart';
import '../../utils/colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/custom_widgets.dart';
import '../budgets/budget_form_screen.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  List<Budget> _budgets = [];
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final budgetBox = DatabaseService.budgets;
    final transactionBox = DatabaseService.transactions;

    setState(() {
      _budgets = budgetBox.values.toList();
      _transactions = transactionBox.values.toList();
    });
  }

  Future<void> _openBudgetForm([Budget? budget]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetFormScreen(budget: budget),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = DatabaseService.settings.values.firstOrNull;
    final currency = settings?.currency ?? 'FCFA';

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _openBudgetForm(),
          ),
        ],
      ),
      body: _budgets.isEmpty
          ? EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Aucun budget créé',
              subtitle: 'Créez des budgets pour mieux contrôler vos dépenses',
              actionText: 'Créer un budget',
              onAction: () => _openBudgetForm(),
            )
          : RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _budgets.length,
                itemBuilder: (context, index) {
                  final budget = _budgets[index];
                  final progress = CalculationService.getBudgetProgress(
                    budget.category,
                    budget.amount,
                    _transactions,
                    budget.month,
                  );

                  return _buildBudgetCard(budget, progress, currency);
                },
              ),
            ),
    );
  }

  Widget _buildBudgetCard(
    Budget budget,
    Map<String, dynamic> progress,
    String currency,
  ) {
    final spent = progress['spent'] as double;
    final percentage = progress['percentage'] as double;
    final remaining = progress['remaining'] as double;
    final status = progress['status'] as String;

    Color statusColor;
    switch (status) {
      case 'exceeded':
        statusColor = AppColors.danger;
        break;
      case 'warning':
        statusColor = AppColors.warning;
        break;
      default:
        statusColor = AppColors.success;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _openBudgetForm(budget),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.category,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormatter.formatMonth(budget.month),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dépensé: ${CurrencyFormatter.format(spent, currency)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gray600,
                    ),
                  ),
                  Text(
                    'Budget: ${CurrencyFormatter.format(budget.amount, currency)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedProgressBar(
                progress: percentage / 100,
                color: statusColor,
                height: 10,
              ),
              const SizedBox(height: 8),
              Text(
                remaining >= 0
                    ? 'Reste: ${CurrencyFormatter.format(remaining, currency)}'
                    : 'Dépassement: ${CurrencyFormatter.format(-remaining, currency)}',
                style: TextStyle(
                  fontSize: 12,
                  color: remaining >= 0 ? AppColors.success : AppColors.danger,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
