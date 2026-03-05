import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../providers/engine_provider.dart';
import '../../providers/categories_provider.dart';
import '../onboarding/calibration_screen.dart';
import '../../../services/analytics_service.dart';

/// Écran d'analyse des dépenses
class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).screen('Analysis');
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(calibrationDataProvider).currency;
    final categoriesAsync = ref.watch(categoriesProviderProvider);
    final analyticsAsync  = ref.watch(engineAnalyticsProvider(_selectedMonth));

    return Scaffold(
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
                  SizedBox(height: 16),

                  // Month Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            _selectedMonth = DateTime(
                              _selectedMonth.year,
                              _selectedMonth.month - 1,
                            );
                          });
                          ref.read(analyticsServiceProvider).capture(
                            'analysis_month_changed',
                            properties: {
                              'direction': 'prev',
                              'month': DateFormat('yyyy-MM').format(_selectedMonth),
                            },
                          );
                        },
                      ),
                      Text(
                        DateFormat('MMMM yyyy', 'fr_FR').format(_selectedMonth),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right),
                        onPressed: () {
                          final nextMonth = DateTime(
                            _selectedMonth.year,
                            _selectedMonth.month + 1,
                          );
                          if (nextMonth.isBefore(DateTime.now().add(const Duration(days: 1)))) {
                            setState(() {
                              _selectedMonth = nextMonth;
                            });
                            ref.read(analyticsServiceProvider).capture(
                              'analysis_month_changed',
                              properties: {
                                'direction': 'next',
                                'month': DateFormat('yyyy-MM').format(_selectedMonth),
                              },
                            );
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
              child: analyticsAsync.when(
                data: (analytics) {
                  return categoriesAsync.when(
                    data: (categories) {
                      if (analytics == null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.analytics_outlined, size: 48,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                              SizedBox(height: 12),
                              Text('Moteur d\'analyse indisponible',
                                  style: Theme.of(context).textTheme.titleMedium),
                            ],
                          ),
                        );
                      }

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
                                    analytics.totalIncome,
                                    currency,
                                    Theme.of(context).colorScheme.primary,
                                    Icons.arrow_upward,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _buildSummaryCard(
                                    context,
                                    'Dépenses',
                                    analytics.totalExpenses,
                                    currency,
                                    Theme.of(context).colorScheme.primary,
                                    Icons.arrow_downward,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 12),

                            _buildSummaryCard(
                              context,
                              'Solde',
                              analytics.net,
                              currency,
                              Theme.of(context).colorScheme.primary,
                              analytics.net >= 0 ? Icons.trending_up : Icons.trending_down,
                            ),

                            SizedBox(height: 32),

                            // Expenses by Category
                            if (analytics.byCategory.isNotEmpty) ...[
                              Text(
                                'Dépenses par catégorie',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: 16),

                              ...analytics.byCategory.map((stat) {
                                final category = categories.firstWhere(
                                  (c) => c.id.toString() == stat.category || c.name == stat.category,
                                  orElse: () => categories.first,
                                );
                                return _buildCategoryBar(
                                  context,
                                  category.name,
                                  stat.total,
                                  stat.pctOfBudget * 100,
                                  currency,
                                  category.type,
                                  category.icon,
                                );
                              }),
                            ] else ...[
                              Center(
                                child: Column(
                                  children: [
                                    SizedBox(height: 48),
                                    Icon(
                                      Icons.pie_chart_outline,
                                      size: 64,
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Aucune dépense ce mois-ci',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            SizedBox(height: 32),
                          ],
                        ),
                      );
                    },
                    loading: () => Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('Erreur de chargement')),
                  );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(child: Text('Erreur de chargement')),
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
                SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
            SizedBox(height: 8),
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
    String iconName,
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
                      UIHelpers.getIconForCategory(iconName, categoryType),
                      color: UIHelpers.getCategoryColor(categoryType),
                      size: 20,
                    ),
                    SizedBox(width: 8),
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
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        UIHelpers.getCategoryColor(categoryType),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
