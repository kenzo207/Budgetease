import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/database/tables/transactions_table.dart';
import '../../../data/database/tables/categories_table.dart';
import '../../../data/database/app_database.dart';
import '../../providers/budget_provider.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/dynamic_card.dart';
import '../../widgets/triage_zone_widget.dart';
import '../onboarding/calibration_screen.dart';
import '../../../services/analytics_service.dart';

/// Écran d'accueil (Dashboard)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _discreteMode = false;

  @override
  void initState() {
    super.initState();
    // Track screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).screen('Home');
    });
  }

  Future<void> _refresh() async {
    // Analytics
    ref.read(analyticsServiceProvider).capture('home_refreshed');
    // Recharger toutes les données essentielles
    ref.invalidate(budgetProviderProvider);
    ref.invalidate(accountsProviderProvider);
    ref.invalidate(transactionsProviderProvider);
    // Attendre un court instant pour l'effet visuel
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _navigateToTransactions() {
    ref.read(navigationIndexProvider.notifier).state = AppTab.transactions.index;
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(calibrationDataProvider).userName;
    final currency = ref.watch(calibrationDataProvider).currency;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryColor,
        backgroundColor: Theme.of(context).cardColor,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: _buildHeader(userName),
              ),

              // Zone de Triage (conditionnelle)
              const SliverToBoxAdapter(
                child: TriageZoneWidget(),
              ),

              // Carrousel de cartes
              SliverToBoxAdapter(
                child: _buildCardsCarousel(currency),
              ),

              // Titre Transactions Récentes + Voir tout
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transactions récentes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: _navigateToTransactions,
                        child: const Text('Voir tout'),
                      ),
                    ],
                  ),
                ),
              ),

              // Liste des transactions récentes
              _buildRecentTransactions(currency),
              
              // Espace pour le scroll
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String userName) {
    final hour = DateTime.now().hour;
    String greeting = 'Bonjour';
    if (hour < 12) {
      greeting = 'Bonjour';
    } else if (hour < 18) {
      greeting = 'Bon après-midi';
    } else {
      greeting = 'Bonsoir';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  userName,
                  style: Theme.of(context).textTheme.displayMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _discreteMode ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              final newMode = !_discreteMode;
              setState(() {
                _discreteMode = newMode;
              });
              // Analytics
              ref.read(analyticsServiceProvider).capture(
                'discrete_mode_toggled',
                properties: {'enabled': newMode},
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardsCarousel(String currency) {
    return SizedBox(
      height: 220,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _buildDailyBudgetCard(currency),
          _buildTotalBalanceCard(currency),
          _buildAccountsCard(currency),
        ],
      ),
    );
  }

  Widget _buildDailyBudgetCard(String currency) {
    final budgetAsync = ref.watch(budgetProviderProvider);

    return budgetAsync.when(
      data: (dailyBudget) {
        final displayAmount = _discreteMode ? '••••' : MoneyFormatter.formatCompact(dailyBudget, currency);
        final budgetColor = dailyBudget < 0 ? AppColors.errorColor : AppColors.primaryColor;

        return _buildCard(
          title: 'Budget Quotidien',
          amount: displayAmount,
          icon: Icons.calendar_today,
          color: budgetColor,
        );
      },
      loading: () => _buildCard(
        title: 'Budget Quotidien',
        amount: '...',
        icon: Icons.calendar_today,
        color: AppColors.primaryColor,
      ),
      error: (e, s) => _buildCard(
        title: 'Budget Quotidien',
        amount: 'Erreur',
        icon: Icons.calendar_today,
        color: AppColors.errorColor,
      ),
    );
  }

  Widget _buildTotalBalanceCard(String currency) {
    final accountsAsync = ref.watch(accountsProviderProvider);

    return accountsAsync.when(
      data: (accounts) {
        final total = accounts.fold<double>(0, (sum, account) => sum + account.currentBalance);
        final displayAmount = _discreteMode ? '••••' : MoneyFormatter.formatCompact(total, currency);

        return _buildCard(
          title: 'Solde Total',
          amount: displayAmount,
          icon: Icons.account_balance_wallet,
          color: AppColors.accentColor,
        );
      },
      loading: () => _buildCard(
        title: 'Solde Total',
        amount: '...',
        icon: Icons.account_balance_wallet,
        color: AppColors.accentColor,
      ),
      error: (e, s) => _buildCard(
        title: 'Solde Total',
        amount: 'Erreur',
        icon: Icons.account_balance_wallet,
        color: AppColors.errorColor,
      ),
    );
  }

  Widget _buildAccountsCard(String currency) {
    final accountsAsync = ref.watch(accountsProviderProvider);

    return accountsAsync.when(
      data: (accounts) {
        return Container(
          width: 280,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance, color: AppColors.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Mes Comptes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (accounts.isEmpty)
                    const Expanded(
                      child: Center(child: Text('Aucun compte')),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: accounts.length > 3 ? 3 : accounts.length,
                        itemBuilder: (context, index) {
                          final account = accounts[index];
                          final displayAmount = _discreteMode
                              ? '••••'
                              : MoneyFormatter.formatCompact(account.currentBalance, currency);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            UIHelpers.getAccountIcon(account.type),
                                            color: UIHelpers.getAccountColor(account.type),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              account.name,
                                              style: Theme.of(context).textTheme.bodyMedium,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                Text(
                                  displayAmount,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => _buildCard(
        title: 'Mes Comptes',
        amount: '...',
        icon: Icons.account_balance,
        color: AppColors.primaryColor,
      ),
      error: (e, s) => _buildCard(
        title: 'Mes Comptes',
        amount: 'Erreur',
        icon: Icons.account_balance,
        color: AppColors.errorColor,
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: DynamicCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                amount,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: color,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(String currency) {
    final transactionsAsync = ref.watch(transactionsProviderProvider);
    final categoriesAsync = ref.watch(categoriesProviderProvider);

    return transactionsAsync.when(
      data: (transactions) {
        final recent = transactions.take(10).toList();
        final categories = categoriesAsync.valueOrNull ?? [];

        if (recent.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune transaction récente',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Ouvrir form ajout transaction
                      },
                      child: const Text('Ajouter une transaction'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final transaction = recent[index];
              final displayAmount = _discreteMode
                  ? '••••'
                  : MoneyFormatter.formatCompact(transaction.amount, currency);

              final category = transaction.categoryId != null
                  ? categories.cast<Category?>().firstWhere(
                        (c) => c?.id == transaction.categoryId,
                        orElse: () => null,
                      )
                  : null;

              final IconData icon;
              final Color color;
              if (category != null) {
                icon = UIHelpers.getIconForCategory(category.icon, category.type);
                color = UIHelpers.getCategoryColor(category.type);
              } else {
                icon = _getTransactionIcon(transaction.type);
                color = _getTransactionColor(transaction.type);
              }

              return ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                ),
                title: Text(
                  category?.name ?? transaction.description ?? 'Transaction',
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  transaction.description != null && category != null
                      ? '${transaction.description} • ${DateFormatter.formatRelative(transaction.date)}'
                      : DateFormatter.formatRelative(transaction.date),
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  '${transaction.type == TransactionType.expense ? '-' : transaction.type == TransactionType.transfer ? '→' : '+'} $displayAmount',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _getTransactionColor(transaction.type),
                      ),
                ),
                onTap: () {
                  // TODO: Afficher détails transaction
                },
              );
            },
            childCount: recent.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        )),
      ),
      error: (e, s) => const SliverToBoxAdapter(
        child: Center(child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('Erreur de chargement des transactions'),
        )),
      ),
    );
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return Icons.arrow_upward;
      case TransactionType.income:
        return Icons.arrow_downward;
      case TransactionType.transfer:
        return Icons.swap_horiz;
    }
  }

  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return AppColors.errorColor;
      case TransactionType.income:
        return AppColors.accentColor;
      case TransactionType.transfer:
        return AppColors.primaryColor;
    }
  }
}
