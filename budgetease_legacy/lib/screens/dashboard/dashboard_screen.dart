import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../services/database_service.dart';
import '../../services/calculation_service.dart';
import '../../models/category.dart';
import '../../widgets/common/custom_widgets.dart';
import '../../widgets/dashboard/dashboard_widgets.dart';
import '../../widgets/dashboard/smart_dashboard_widgets.dart';
import '../../services/advisor_service.dart';
import '../../services/fixed_charge_service.dart';
import '../transactions/transaction_form_screen.dart';
import '../transactions/history_screen.dart';
import '../budgets/budgets_screen.dart';
import '../fixed_charges/fixed_charges_screen.dart';
import '../insights/insights_screen.dart';
import '../../utils/constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  Future<void> _openTransactionForm() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const TransactionFormScreen(),
      ),
    );

    if (result == true && mounted) {
      setState(() {}); // Refresh data
    }
  }

  void _onTabChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardTab(key: ValueKey(_selectedIndex)),
      HistoryScreen(key: ValueKey(_selectedIndex)),
      BudgetsScreen(key: ValueKey(_selectedIndex)),
      const SettingsTab(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _openTransactionForm,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Transaction',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTabChanged,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.gray600,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'Historique',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Budgets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Paramètres',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  String _selectedPeriod = 'month';

  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'day':
        return DateTime(now.year, now.month, now.day);
      case 'week':
        return now.subtract(Duration(days: now.weekday - 1));
      case 'month':
      default:
        return DateTime(now.year, now.month, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = DatabaseService.settings.values.firstOrNull;
    final currency = settings?.currency ?? 'FCFA';
    
    final transactions = DatabaseService.transactions.values.toList();
    final activeFixedCharges = FixedChargeService.getActiveCharges();
    final startDate = _getStartDate();
    final endDate = DateTime.now();

    final totals = CalculationService.getPeriodTotals(transactions, startDate, endDate);
    final topCategories = CalculationService.getTopCategories(transactions, startDate, endDate);

    // Smart Calculations
    final totalFixedCharges = FixedChargeService.getMonthlyFixedChargesAmount();
    final savingsGoal = 0.0; // TODO: Implement Savings Module
    
    final realBudget = CalculationService.getRealAvailableBudget(
      totals['income'] ?? 0,
      totalFixedCharges,
      totals['expenses'] ?? 0,
      savingsGoal,
    );

    final dailyCap = AdvisorService.getRecommendedDailyCap();
    final advice = AdvisorService.getAdvice();

    final sosAmount = settings?.sosAmount ?? 0.0;
    final isSosActive = sosAmount > 0;
    final appBarColor = isSosActive ? AppColors.danger : AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: appBarColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Image.asset(
                    'assets/images/logo.png',
                    height: 24,
                    width: 24,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isSosActive ? 'MODE SOS ACTIF' : 'BudgetEase',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                        appBarColor, 
                        isSosActive ? Colors.red.shade900 : AppColors.primaryHover
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(isSosActive ? Icons.warning : Icons.sos, color: Colors.white),
                onPressed: () async {
                    if (isSosActive) {
                        final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                                title: const Text('Désactiver SOS ?'),
                                content: const Text('Tout va mieux ?'),
                                actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Non')),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Oui')),
                                ],
                            ),
                        );
                        if (confirm == true) {
                            await AdvisorService.deactivateSOS();
                            setState(() {});
                        }
                    } else {
                        final controller = TextEditingController();
                        final amount = await showDialog<double>(
                            context: context,
                            builder: (context) => AlertDialog(
                                title: const Text('Mode SOS 🚨'),
                                content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        const Text('Combien devez-vous réserver d\'urgence ?'),
                                        TextField(
                                            controller: controller,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(suffixText: 'FCFA'),
                                        ),
                                    ],
                                ),
                                actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                                    TextButton(
                                        onPressed: () => Navigator.pop(context, double.tryParse(controller.text)), 
                                        child: const Text('Activer SOS', style: TextStyle(color: Colors.red))
                                    ),
                                ],
                            ),
                        );
                        if (amount != null && amount > 0) {
                            await AdvisorService.activateSOS(amount);
                            setState(() {});
                        }
                    }
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                onSelected: (value) => setState(() => _selectedPeriod = value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'day', child: Text('Jour')),
                  const PopupMenuItem(value: 'week', child: Text('Semaine')),
                  const PopupMenuItem(value: 'month', child: Text('Mois')),
                ],
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Smart Summary
                SmartSummaryCard(
                  realAvailable: realBudget['ard'] ?? 0,
                  fixedCharges: realBudget['fixed'] ?? 0,
                  savings: realBudget['saved'] ?? 0,
                  currency: currency,
                  dailyCap: dailyCap,
                ),
                const SizedBox(height: 24),

                // Smart Advice (if any)
                if (advice.isNotEmpty) ...[
                  ...advice.map((rule) => SmartAdviceWidget(rule: rule)),
                  // const SizedBox(height: 24), // Spacing handled by widget margin
                ],

                // Quick Stats
                Row(
                  children: [
                    Expanded(
                      child: QuickStatCard(
                        label: 'Transactions',
                        value: transactions.length.toString(),
                        icon: Icons.receipt_long,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: QuickStatCard(
                        label: 'Budgets',
                        value: DatabaseService.budgets.length.toString(),
                        icon: Icons.savings,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Section Header
                const Text(
                  'Top Catégories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Categories or Empty State
                if (topCategories.isEmpty)
                  EmptyState(
                    icon: Icons.pie_chart_outline,
                    title: 'Aucune transaction',
                    subtitle: 'Commencez à enregistrer vos dépenses',
                  )
                else
                  ...topCategories.map((cat) => CategoryCard(
                        name: cat['category'] as String,
                        icon: DatabaseService.categories.values
                            .firstWhere(
                              (c) => c.name == cat['category'],
                              orElse: () => DatabaseService.categories.values.last,
                            )
                            .icon,
                        amount: cat['amount'] as double,
                        percentage: cat['percentage'] as double,
                        currency: currency,
                      )),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Historique'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filters
            },
          ),
        ],
      ),
      body: EmptyState(
        icon: Icons.history,
        title: 'Aucune transaction',
        subtitle: 'Vos transactions apparaîtront ici',
        actionText: 'Ajouter une transaction',
        onAction: () {
          // TODO: Add transaction
        },
      ),
    );
  }
}

class BudgetsTab extends StatelessWidget {
  const BudgetsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // TODO: Create budget
            },
          ),
        ],
      ),
      body: EmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Aucun budget créé',
        subtitle: 'Créez des budgets pour mieux contrôler vos dépenses',
        actionText: 'Créer un budget',
        onAction: () {
          // TODO: Create budget
        },
      ),
    );
  }
}

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    final settings = DatabaseService.settings.values.firstOrNull;
    final currency = settings?.currency ?? 'FCFA';
    final notificationEnabled = settings?.notificationEnabled ?? false;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Général',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.lock_clock_outlined, color: AppColors.primary),
                  ),
                  title: const Text('Charges Fixes'),
                  subtitle: const Text('Loyers, abonnements...'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FixedChargesScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.attach_money, color: AppColors.primary),
                  ),
                  title: const Text('Devise'),
                  subtitle: Text(currency),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final newCurrency = await showDialog<String>(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text('Choisir une devise'),
                        children: currencyOptions.map((option) {
                          return SimpleDialogOption(
                            onPressed: () => Navigator.pop(context, option['value']),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(option['label']!),
                            ),
                          );
                        }).toList(),
                      ),
                    );

                    if (newCurrency != null && settings != null) {
                      settings.currency = newCurrency;
                      await settings.save();
                      setState(() {});
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.calendar_today, color: AppColors.primary),
                  ),
                  title: const Text('Période de Budget'),
                  subtitle: Text(
                    settings?.budgetPeriod == 'daily' ? 'Journalier' :
                    settings?.budgetPeriod == 'weekly' ? 'Hebdomadaire' : 'Mensuel'
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final newPeriod = await showDialog<String>(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text('Choisir une période'),
                        children: [
                          SimpleDialogOption(
                            onPressed: () => Navigator.pop(context, 'daily'),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('Journalier'),
                            ),
                          ),
                          SimpleDialogOption(
                            onPressed: () => Navigator.pop(context, 'weekly'),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('Hebdomadaire'),
                            ),
                          ),
                          SimpleDialogOption(
                            onPressed: () => Navigator.pop(context, 'monthly'),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('Mensuel'),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (newPeriod != null && settings != null) {
                      settings.budgetPeriod = newPeriod;
                      await settings.save();
                      setState(() {});
                    }
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.notifications, color: AppColors.warning),
                  ),
                  title: const Text('Notifications'),
                  subtitle: const Text('Rappel quotidien'),
                  value: notificationEnabled,
                  onChanged: (value) {
                    // TODO: Toggle notifications
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Données',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.file_download, color: AppColors.success),
                  ),
                  title: const Text('Exporter en CSV'),
                  subtitle: const Text('Télécharger vos données'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Export CSV
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline, color: AppColors.danger),
                  ),
                  title: const Text(
                    'Réinitialiser les données',
                    style: TextStyle(color: AppColors.danger),
                  ),
                  subtitle: const Text('Supprimer toutes les données'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Reset data
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'À propos',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Version'),
                    Text(
                      '1.0.0',
                      style: TextStyle(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
