import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/database/tables/transactions_table.dart'; // For TransactionType enum
import '../../providers/transactions_provider.dart';
import '../../providers/categories_provider.dart';
import '../onboarding/calibration_screen.dart';

/// Écran d'analyse des dépenses
class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(calibrationDataProvider).currency;
    final transactionsAsync = ref.watch(transactionsProviderProvider);
    final categoriesAsync = ref.watch(categoriesProviderProvider);

    return Scaffold(
      // backgroundColor: AppColors.backgroundColor, // Removed to use theme
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analyse',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  // Month Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            _selectedMonth = DateTime(
                              _selectedMonth.year,
                              _selectedMonth.month - 1,
                            );
                          });
                        },
                      ),
                      Text(
                        DateFormat('MMMM yyyy', 'fr_FR').format(_selectedMonth),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          final nextMonth = DateTime(
                            _selectedMonth.year,
                            _selectedMonth.month + 1,
                          );
                          if (nextMonth.isBefore(DateTime.now().add(const Duration(days: 1)))) {
                            setState(() {
                              _selectedMonth = nextMonth;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: transactionsAsync.when(
                data: (transactions) {
                  return categoriesAsync.when(
                    data: (categories) {
                      // Filter transactions for selected month
                      final startOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
                      final endOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);
                      
                      final monthTransactions = transactions.where((t) {
                        return t.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
                               t.date.isBefore(endOfMonth.add(const Duration(seconds: 1)));
                      }).toList();

                      // Calculate totals
                      final totalExpenses = monthTransactions
                          .where((t) => t.type == TransactionType.expense)
                          .fold<double>(0.0, (sum, t) => sum + t.amount);
                      
                      final totalIncome = monthTransactions
                          .where((t) => t.type == TransactionType.income)
                          .fold<double>(0.0, (sum, t) => sum + t.amount);
                      
                      final balance = totalIncome - totalExpenses;

                      // Group expenses by category
                      final expensesByCategory = <int, double>{};
                      for (var transaction in monthTransactions) {
                        if (transaction.type == TransactionType.expense) {
                          expensesByCategory[transaction.categoryId!] = 
                              (expensesByCategory[transaction.categoryId] ?? 0) + transaction.amount;
                        }
                      }

                      // Sort categories by amount
                      final sortedCategories = expensesByCategory.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Summary Cards
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryCard(
                                    context,
                                    'Revenus',
                                    totalIncome,
                                    currency,
                                    AppColors.accentColor,
                                    Icons.arrow_upward,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildSummaryCard(
                                    context,
                                    'Dépenses',
                                    totalExpenses,
                                    currency,
                                    AppColors.errorColor,
                                    Icons.arrow_downward,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            
                            _buildSummaryCard(
                              context,
                              'Solde',
                              balance,
                              currency,
                              balance >= 0 ? AppColors.accentColor : AppColors.errorColor,
                              balance >= 0 ? Icons.trending_up : Icons.trending_down,
                            ),

                            const SizedBox(height: 32),

                            // Expenses by Category
                            if (sortedCategories.isNotEmpty) ...[
                              Text(
                                'Dépenses par catégorie',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              
                              ...sortedCategories.map((entry) {
                                final category = categories.firstWhere(
                                  (c) => c.id == entry.key,
                                  orElse: () => categories.first,
                                );
                                final percentage = (entry.value / totalExpenses * 100);
                                
                                return _buildCategoryBar(
                                  context,
                                  category.name,
                                  entry.value,
                                  percentage,
                                  currency,
                                  category.type,
                                );
                              }),
                            ] else ...[
                              Center(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 48),
                                    Icon(
                                      Icons.pie_chart_outline,
                                      size: 64,
                                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Aucune dépense ce mois-ci',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 32),
                          ],
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => const Center(child: Text('Erreur de chargement')),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Erreur de chargement')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    double amount,
    String currency,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${amount.toStringAsFixed(0)} $currency',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBar(
    BuildContext context,
    String categoryName,
    double amount,
    double percentage,
    String currency,
    dynamic categoryType,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      UIHelpers.getCategoryIcon(categoryType),
                      color: UIHelpers.getCategoryColor(categoryType),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      categoryName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Text(
                  '${amount.toStringAsFixed(0)} $currency',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: AppColors.surfaceColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        UIHelpers.getCategoryColor(categoryType),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
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
