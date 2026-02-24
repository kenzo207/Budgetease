import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/tables/transactions_table.dart'; // For TransactionType enum
import '../../../data/database/daos/transactions_dao.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/budget_provider.dart';
import '../onboarding/calibration_screen.dart';
import '../../../services/analytics_service.dart';

/// Écran des transactions
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  TransactionType? _filterType;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).screen('Transactions');
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(calibrationDataProvider).currency;
    final transactionsAsync = ref.watch(transactionsProviderProvider);
    final categoriesAsync = ref.watch(categoriesProviderProvider);
    final accountsAsync = ref.watch(accountsProviderProvider);

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
                    'Transactions',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                      // Track search when user types something meaningful
                      if (value.length == 3 || value.isEmpty) {
                        ref.read(analyticsServiceProvider).capture(
                          'transaction_search_used',
                          properties: {
                            'query_length': value.length,
                            'has_query': value.isNotEmpty,
                          },
                        );
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Tout'),
                          selected: _filterType == null,
                          onSelected: (selected) {
                            setState(() {
                              _filterType = null;
                            });
                            ref.read(analyticsServiceProvider).capture(
                              'transaction_filter_changed',
                              properties: {'filter_type': 'all'},
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Dépenses'),
                          avatar: const Icon(Icons.remove_circle_outline, size: 18),
                          selected: _filterType == TransactionType.expense,
                          onSelected: (selected) {
                            setState(() {
                              _filterType = selected ? TransactionType.expense : null;
                            });
                            ref.read(analyticsServiceProvider).capture(
                              'transaction_filter_changed',
                              properties: {'filter_type': selected ? 'expense' : 'all'},
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Revenus'),
                          avatar: const Icon(Icons.add_circle_outline, size: 18),
                          selected: _filterType == TransactionType.income,
                          onSelected: (selected) {
                            setState(() {
                              _filterType = selected ? TransactionType.income : null;
                            });
                            ref.read(analyticsServiceProvider).capture(
                              'transaction_filter_changed',
                              properties: {'filter_type': selected ? 'income' : 'all'},
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Virements'),
                          avatar: const Icon(Icons.swap_horiz, size: 18),
                          selected: _filterType == TransactionType.transfer,
                          onSelected: (selected) {
                            setState(() {
                              _filterType = selected ? TransactionType.transfer : null;
                            });
                            ref.read(analyticsServiceProvider).capture(
                              'transaction_filter_changed',
                              properties: {'filter_type': selected ? 'transfer' : 'all'},
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Transactions List
            Expanded(
              child: transactionsAsync.when(
                data: (transactions) {
                  return categoriesAsync.when(
                    data: (categories) {
                      return accountsAsync.when(
                        data: (accounts) {
                          // Filter transactions
                          var filteredTransactions = transactions.where((t) {
                            // Type filter
                            if (_filterType != null && t.type != _filterType) {
                              return false;
                            }
                            
                            // Search filter
                            if (_searchQuery.isNotEmpty) {
                              final category = categories.firstWhere(
                                (c) => c.id == t.categoryId,
                                orElse: () => categories.first,
                              );
                              final account = accounts.firstWhere(
                                (a) => a.id == t.accountId,
                                orElse: () => accounts.first,
                              );
                              
                              final searchableText = '${category.name} ${account.name} ${t.description ?? ''}'.toLowerCase();
                              if (!searchableText.contains(_searchQuery)) {
                                return false;
                              }
                            }
                            
                            return true;
                          }).toList();

                          if (filteredTransactions.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 64,
                                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isNotEmpty || _filterType != null
                                        ? 'Aucune transaction trouvée'
                                        : 'Aucune transaction',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Group by date
                          final groupedTransactions = <String, List<Transaction>>{};
                          for (var transaction in filteredTransactions) {
                            final dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);
                            groupedTransactions.putIfAbsent(dateKey, () => []);
                            groupedTransactions[dateKey]!.add(transaction);
                          }

                          // Sort dates descending
                          final sortedDates = groupedTransactions.keys.toList()
                            ..sort((a, b) => b.compareTo(a));

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: sortedDates.length,
                            itemBuilder: (context, index) {
                              final dateKey = sortedDates[index];
                              final dayTransactions = groupedTransactions[dateKey]!;
                              final date = DateTime.parse(dateKey);
                              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date Header
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Text(
                                      _formatDateHeader(date),
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ),
                                  
                                  // Transactions for this date
                                  ...dayTransactions.map((transaction) {
                                    final category = categories.firstWhere(
                                      (c) => c.id == transaction.categoryId,
                                      orElse: () => categories.first,
                                    );
                                    final account = accounts.firstWhere(
                                      (a) => a.id == transaction.accountId,
                                      orElse: () => accounts.first,
                                    );
                                    
                                    return _buildTransactionCard(
                                      transaction,
                                      category,
                                      account,
                                      currency,
                                      context,
                                      ref,
                                    );
                                  }),
                                ],
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, s) => const Center(child: Text('Erreur de chargement des comptes')),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => const Center(child: Text('Erreur de chargement des catégories')),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const Center(child: Text('Erreur de chargement des transactions')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    Transaction transaction,
    Category category,
    Account account,
    String currency,
    BuildContext context,
    WidgetRef ref,
  ) {
    Color amountColor;
    String amountPrefix;
    
    switch (transaction.type) {
      case TransactionType.expense:
        amountColor = AppColors.errorColor;
        amountPrefix = '-';
        break;
      case TransactionType.income:
        amountColor = AppColors.accentColor;
        amountPrefix = '+';
        break;
      case TransactionType.transfer:
        amountColor = AppColors.primaryColor;
        amountPrefix = '';
        break;
    }

    return InkWell(
      onTap: () => _showTransactionOptions(context, ref, transaction, category, account, currency),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: UIHelpers.getCategoryColor(category.type).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                UIHelpers.getIconForCategory(category.icon, category.type),
                color: UIHelpers.getCategoryColor(category.type),
                size: 24,
              ),
            ),
          ),
          title: Text(
            category.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Row(
            children: [
              Icon(
                UIHelpers.getAccountIcon(account.type),
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                account.name,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (transaction.description != null && transaction.description!.isNotEmpty) ...[
                const Text(' • '),
                Flexible(
                  child: Text(
                    transaction.description!,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountPrefix${transaction.amount.toStringAsFixed(0)} $currency',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (transaction.feeAmount != null && transaction.feeAmount! > 0)
                Text(
                  'Frais: ${transaction.feeAmount!.toStringAsFixed(0)} $currency',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionOptions(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
    Category category,
    Account account,
    String currency,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primaryColor),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Modification de transaction à venir'),
                    backgroundColor: AppColors.accentColor,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.errorColor),
              title: const Text('Supprimer'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, ref, transaction);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Annuler'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la transaction ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteTransaction(context, ref, transaction);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.errorColor),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) async {
    try {
      final database = AppDatabase();
      final dao = TransactionsDao(database);
      
      // Delete transaction
      await dao.deleteTransaction(transaction.id);
      
      // Analytics
      ref.read(analyticsServiceProvider).capture(
        'transaction_deleted',
        properties: {
          'transaction_id': transaction.id,
          'type': transaction.type.name,
          'amount': transaction.amount,
        },
      );
      
      // Refresh providers
      ref.invalidate(transactionsProviderProvider);
      ref.invalidate(accountsProviderProvider);
      ref.invalidate(budgetProviderProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction supprimée'),
            backgroundColor: AppColors.accentColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return "Aujourd'hui";
    } else if (dateOnly == yesterday) {
      return 'Hier';
    } else if (dateOnly.isAfter(today.subtract(const Duration(days: 7)))) {
      return DateFormat('EEEE d MMMM', 'fr_FR').format(date);
    } else {
      return DateFormat('d MMMM yyyy', 'fr_FR').format(date);
    }
  }
}
