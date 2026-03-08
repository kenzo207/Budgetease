import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/database/tables/transactions_table.dart';
import '../../../data/database/tables/categories_table.dart';
import '../../../data/database/app_database.dart';
import '../../providers/engine_provider.dart';
import '../../../engine/engine_output.dart' as eng;
import '../../providers/accounts_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/discrete_mode_provider.dart';
import '../../widgets/zolt_card.dart';
import '../../widgets/action_bottom_sheet.dart';
import '../../widgets/upcoming_charge_card.dart';
import '../../widgets/pending_income_card.dart';
import '../../providers/incomes_provider.dart';
import '../onboarding/calibration_screen.dart';
import '../../../services/analytics_service.dart';

import '../../widgets/app_tutorial.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/zolt_count_up_text.dart';

/// Écran d'accueil (Dashboard)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Plus de state local — le mode discret est global via discreteModeProvider
  
  // Tutorial Keys
  final GlobalKey _dailyBudgetKey = GlobalKey();
  final GlobalKey _totalBalanceKey = GlobalKey();
  final GlobalKey _triageKey = GlobalKey();
  final GlobalKey _zoltMessagesKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Track screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).screen('Home');
      _checkAndShowTutorial();
    });
  }

  Future<void> _checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('has_seen_tutorial') ?? false;
    
    // Pour des raisons de test ou si on veut forcer :
    // await prefs.setBool('has_seen_tutorial', false);
    
    if (!hasSeen && mounted) {
      _showTutorial();
      await prefs.setBool('has_seen_tutorial', true);
    }
  }

  void _showTutorial() {
    AppTutorial.createTutorial(
      context: context,
      ref: ref,
      dailyBudgetKey: _dailyBudgetKey,
      totalBalanceKey: _totalBalanceKey,
      triageKey: _triageKey,
      zoltMessagesKey: _zoltMessagesKey,
      onFinish: () {},
    ).show(context: context);
  }

  Future<void> _refresh() async {
    // Analytics
    ref.read(analyticsServiceProvider).capture('home_refreshed');
    // Recharger toutes les données essentielles
    ref.invalidate(zoltEngineProviderProvider);
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
    final discreteMode = ref.watch(discreteModeProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).cardColor,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(userName, discreteMode)),

              SliverToBoxAdapter(child: _buildBentoLayout(currency, discreteMode)),
              // ── Prédiction fin de cycle ──
              SliverToBoxAdapter(child: _buildPredictionBanner()),
              // ── Messages intelligents du Zolt Engine ──
              SliverToBoxAdapter(
                child: Container(
                  key: _zoltMessagesKey,
                  child: _buildZoltMessages(),
                ),
              ),
              // ── Rentrée d'argent urgente ──
              SliverToBoxAdapter(child: _buildPendingIncome(currency)),
              // ── Charge urgente (auto-hidden si rien dans 7j) ──
              SliverToBoxAdapter(child: UpcomingChargeCard(currency: currency)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Transactions récentes', style: Theme.of(context).textTheme.titleLarge),
                      TextButton(onPressed: _navigateToTransactions, child: Text('Voir tout')),
                    ],
                  ),
                ),
              ),
              _buildRecentTransactions(currency, discreteMode),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String userName, bool discreteMode) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Bonjour' : hour < 18 ? 'Bon apr\u00e8s-midi' : 'Bonsoir';

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: Theme.of(context).textTheme.bodyLarge),
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
              discreteMode ? Icons.visibility_off : Icons.visibility,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            tooltip: discreteMode ? 'Afficher les montants' : 'Masquer les montants',
            onPressed: () {
              final newMode = !discreteMode;
              ref.read(discreteModeProvider.notifier).state = newMode;
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

  Widget _buildPendingIncome(String currency) {
    final pendingAsync = ref.watch(nextPendingIncomeProvider);
    return pendingAsync.when(
      data: (income) {
        if (income == null) return const SizedBox.shrink();
        return PendingIncomeCard(income: income, currency: currency);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Returns color + icon based on message level
  (Color, IconData) _messageStyle(String level) {
    switch (level) {
      case 'Critical':
        return (const Color(0xFFFF5252), Icons.warning_amber_rounded);
      case 'Warning':
        return (const Color(0xFFFFAB40), Icons.info_outline);
      case 'Positive':
        return (const Color(0xFF69F0AE), Icons.thumb_up_outlined);
      default: // Info
        return (Theme.of(context).colorScheme.onSurface, Icons.lightbulb_outline);
    }
  }

  Widget _buildPredictionBanner() {
    final predAsync = ref.watch(enginePredictionProvider);
    return predAsync.when(
      data: (pred) {
        if (pred == null || !pred.isReliable) return const SizedBox.shrink();
        final isDeficit = pred.isDeficit;
        final color = isDeficit ? const Color(0xFFFF5252) : const Color(0xFF69F0AE);
        final icon  = isDeficit ? Icons.trending_down : Icons.trending_up;
        final label = isDeficit
            ? 'Déficit prévu en fin de cycle'
            : 'Fin de cycle estimée positive';
        final amount = isDeficit
            ? '− ${pred.projectedDeficit.toStringAsFixed(0)}'
            : '+ ${pred.projectedFinalBalance.toStringAsFixed(0)}';
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
                ),
              ),
              Text(
                amount,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error:   (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildZoltMessages() {
    final messagesAsync = ref.watch(engineMessagesProvider);

    return messagesAsync.when(
      data: (messages) {
        if (messages.isEmpty) return const SizedBox.shrink();

        // On prend le premier message (le plus important)
        final msg = messages.first;
        final (iconColor, icon) = _messageStyle(msg.level);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: iconColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg.title.isNotEmpty ? msg.title : 'Conseil Zolt',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      msg.body,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBentoLayout(String currency, bool discreteMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
            SizedBox(
              height: 212,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildDailyBudgetCard(currency, discreteMode),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _buildTotalBalanceCard(currency, discreteMode)),
                        const SizedBox(height: 12),
                        Expanded(child: _buildHealthScoreCard()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildAccountsCard(currency, discreteMode),
          ],
        ),
      );
  }

  Widget _buildHealthScoreCard() {
    final healthAsync = ref.watch(engineHealthScoreProvider);
    return healthAsync.when(
      data: (health) {
        if (health.score == 0 && health.grade == 'Fair') return const SizedBox.shrink();
        final color = _healthColor(health.grade);
        
        return ZoltCard(
          profile: ZoltCardProfile.standard,
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SANTÉ',
                style: TextStyle(
                  fontFamily: 'CabinetGrotesk',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${health.score}',
                          style: TextStyle(fontFamily: 'Zodiak', fontSize: 24, fontWeight: FontWeight.w600, color: color),
                        ),
                      ),
                    ),
                    Text(
                      '/100',
                      style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 11, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    health.grade,
                    style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 13, color: color),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const ZoltCard(child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Color _healthColor(String grade) {
    switch (grade) {
      case 'Excellent': return const Color(0xFF16A34A); 
      case 'Good':      return const Color(0xFF4B6E9E); 
      case 'Fair':      return const Color(0xFFD97706); 
      case 'Poor':      return const Color(0xFFDC2626); 
      case 'Critical':  return const Color(0xFFDC2626); 
      default:          return const Color(0xFFD97706);
    }
  }

  Widget _buildDailyBudgetCard(String currency, bool discreteMode) {
    final budgetAsync = ref.watch(engineDailyBudgetProvider);

    return budgetAsync.when(
      data: (dailyBudget) {
        if (discreteMode) {
          return Container(key: _dailyBudgetKey, child: _buildHeroCard(title: 'BUDGET DU JOUR', amountString: '••••', currency: currency, discreteMode: discreteMode));
        } else {
          return Container(key: _dailyBudgetKey, child: _buildHeroCard(title: 'BUDGET DU JOUR', amountValue: dailyBudget, currency: currency, discreteMode: discreteMode));
        }
      },
      loading: () => Container(key: _dailyBudgetKey, child: _buildHeroCard(title: 'BUDGET DU JOUR', amountString: '...', currency: currency, discreteMode: discreteMode)),
      error: (e, s) => Container(key: _dailyBudgetKey, child: _buildHeroCard(title: 'BUDGET DU JOUR', amountString: 'Erreur', currency: currency, discreteMode: discreteMode)),
    );
  }

  Widget _buildHeroCard({
    required String title,
    double? amountValue,
    String? amountString,
    required String currency,
    required bool discreteMode,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFF0D0D0B) : const Color(0xFFF5F3EE);
    final isPlaceholder = amountValue == null && amountString != null && (amountString == '...' || amountString == 'Erreur');
    
    return ZoltCard(
      profile: ZoltCardProfile.hero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'CabinetGrotesk',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
              color: textColor.withValues(alpha: 0.40),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              amountValue != null ? ZoltCountUpText(
                value: amountValue,
                builder: (context, val) {
                  final formatted = MoneyFormatter.formatCompact(val, currency);
                  return RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: formatted,
                          style: TextStyle(fontFamily: 'Zodiak', fontSize: 32, fontWeight: FontWeight.w700, color: textColor),
                        ),
                        if (!discreteMode && !isPlaceholder)
                          TextSpan(
                            text: ' $currency',
                            style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 13, fontWeight: FontWeight.w500, color: textColor.withValues(alpha: 0.55)),
                          ),
                      ],
                    ),
                  );
                },
              ) : RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: amountString ?? '',
                      style: TextStyle(fontFamily: 'Zodiak', fontSize: 32, fontWeight: FontWeight.w700, color: textColor),
                    ),
                    if (!discreteMode && !isPlaceholder)
                      TextSpan(
                        text: ' $currency',
                        style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 13, fontWeight: FontWeight.w500, color: textColor.withValues(alpha: 0.55)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 3,
                width: double.infinity,
                decoration: BoxDecoration(color: textColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(1.5)),
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 80, 
                  height: 3,
                  decoration: BoxDecoration(color: textColor, borderRadius: BorderRadius.circular(1.5)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Il te reste ${amountValue != null ? MoneyFormatter.formatCompact(amountValue, currency) : amountString}',
                style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 13, color: textColor.withValues(alpha: 0.65)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBalanceCard(String currency, bool discreteMode) {
    final accountsAsync = ref.watch(accountsProviderProvider);
    return accountsAsync.when(
      data: (accounts) {
        final total = accounts.fold<double>(0, (sum, a) => sum + a.currentBalance);
        if (discreteMode) {
          return Container(key: _totalBalanceKey, child: _buildStandardMiniCard(title: 'SOLDE TOTAL', amountString: '••••', currency: currency));
        } else {
          return Container(key: _totalBalanceKey, child: _buildStandardMiniCard(title: 'SOLDE TOTAL', amountValue: total, currency: currency));
        }
      },
      loading: () => Container(key: _totalBalanceKey, child: _buildStandardMiniCard(title: 'SOLDE TOTAL', amountString: '...', currency: currency)),
      error: (e, s) => Container(key: _totalBalanceKey, child: _buildStandardMiniCard(title: 'SOLDE TOTAL', amountString: 'Erreur', currency: currency)),
    );
  }

  Widget _buildStandardMiniCard({required String title, double? amountValue, String? amountString, required String currency}) {
    return ZoltCard(
      profile: ZoltCardProfile.standard,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.4, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: amountValue != null 
              ? ZoltCountUpText(
                  value: amountValue,
                  formatValue: (val) => MoneyFormatter.formatCompact(val, currency),
                  style: TextStyle(fontFamily: 'Zodiak', fontSize: 24, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                )
              : Text(
                  amountString ?? '',
                  style: TextStyle(fontFamily: 'Zodiak', fontSize: 24, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsCard(String currency, bool discreteMode) {
    final accountsAsync = ref.watch(accountsProviderProvider);

    return accountsAsync.when(
      data: (accounts) {
        return ZoltCard(
          profile: ZoltCardProfile.standard,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Prevent the Column from trying to expand infinitely
            children: [
              Text(
                'MES COMPTES',
                style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.4, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
              ),
              const SizedBox(height: 12),
              if (accounts.isEmpty)
                const Center(child: Text('Aucun compte'))
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        accounts.length > 3 ? 5 : accounts.length * 2 - 1,
                        (index) {
                          if (index % 2 != 0) {
                            return Expanded(child: Center(child: Container(width: 1, height: 24, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1))));
                          }
                          final accountIndex = index ~/ 2;
                          final account = accounts[accountIndex];
                          final displayAmount = discreteMode
                              ? '••••'
                              : MoneyFormatter.formatCompact(account.currentBalance, currency);
                          
                          return Expanded(
                            flex: 2,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: UIHelpers.getAccountColor(account.type).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    UIHelpers.getAccountIcon(account.type),
                                    color: UIHelpers.getAccountColor(account.type),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        account.name,
                                        style: TextStyle(
                                          fontFamily: 'CabinetGrotesk', 
                                          fontSize: 13, 
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        displayAmount,
                                        style: TextStyle(
                                          fontFamily: 'Zodiak', 
                                          fontSize: 14, 
                                          fontWeight: FontWeight.w500, 
                                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ), // Closes List.generate
                ), // Closes Row
            ], // Closes Column children
          ), // Closes Column
        ); // Closes ZoltCard
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Widget _buildRecentTransactions(String currency, bool discreteMode) {
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
                    Icon(Icons.receipt_long_outlined, size: 64, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
                    SizedBox(height: 16),
                    Text('Aucune transaction', style: Theme.of(context).textTheme.bodyLarge),
                    SizedBox(height: 8),
                    Text(
                      'Appuyez sur + pour ajouter votre premi\u00e8re transaction',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: Icon(Icons.add),
                      label: Text('Ajouter une transaction'),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const ActionBottomSheet(),
                        );
                      },
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
              final displayAmount = discreteMode
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
      error: (e, s) => SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(Icons.wifi_off_outlined, size: 48, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
                SizedBox(height: 12),
                Text('Impossible de charger les transactions', textAlign: TextAlign.center),
                SizedBox(height: 16),
                TextButton.icon(
                  icon: Icon(Icons.refresh, size: 18),
                  label: Text('Réessayer'),
                  onPressed: () {
                    ref.invalidate(transactionsProviderProvider);
                    ref.invalidate(accountsProviderProvider);
                    ref.invalidate(zoltEngineProviderProvider);
                  },
                ),
              ],
            ),
          ),
        ),
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
        return Theme.of(context).colorScheme.primary;
      case TransactionType.income:
        return Theme.of(context).colorScheme.primary;
      case TransactionType.transfer:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
