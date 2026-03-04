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
import '../../providers/engine_provider.dart';
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
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Removed to use theme
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
                  SizedBox(height: 16),
                  
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
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
                  
                  SizedBox(height: 16),
                  
                  // Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: Text('Tout'),
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
                        SizedBox(width: 8),
                        FilterChip(
                          label: Text('Dépenses'),
                          avatar: Icon(Icons.remove_circle_outline, size: 18),
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
                        SizedBox(width: 8),
                        FilterChip(
                          label: Text('Revenus'),
                          avatar: Icon(Icons.add_circle_outline, size: 18),
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
                        SizedBox(width: 8),
                        FilterChip(
                          label: Text('Virements'),
                          avatar: Icon(Icons.swap_horiz, size: 18),
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
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6).withValues(alpha: 0.5),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isNotEmpty || _filterType != null
                                        ? 'Aucune transaction trouvée'
                                        : 'Aucune transaction',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                        loading: () => Center(child: CircularProgressIndicator()),
                        error: (e, s) => _buildErrorRetry(
                          message: 'Erreur de chargement des comptes',
                          onRetry: () => ref.invalidate(accountsProviderProvider),
                        ),
                      );
                    },
                    loading: () => Center(child: CircularProgressIndicator()),
                    error: (e, s) => _buildErrorRetry(
                      message: 'Erreur de chargement des catégories',
                      onRetry: () => ref.invalidate(categoriesProviderProvider),
                    ),
                  );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, s) => _buildErrorRetry(
                  message: 'Erreur de chargement des transactions',
                  onRetry: () => ref.invalidate(transactionsProviderProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorRetry({required String message, required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
            SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
            SizedBox(height: 16),
            TextButton.icon(
              icon: Icon(Icons.refresh, size: 18),
              label: Text('Réessayer'),
              onPressed: onRetry,
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
        amountColor = Theme.of(context).colorScheme.primary;
        amountPrefix = '-';
        break;
      case TransactionType.income:
        amountColor = Theme.of(context).colorScheme.primary;
        amountPrefix = '+';
        break;
      case TransactionType.transfer:
        amountColor = Theme.of(context).colorScheme.primary;
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
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              SizedBox(width: 4),
              Text(
                account.name,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (transaction.description != null && transaction.description!.isNotEmpty) ...[
                Text(' • '),
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
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
              leading: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.primary),
              title: Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Modification de transaction à venir'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.primary),
              title: Text('Supprimer'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, ref, transaction, category, account, currency);
              },
            ),
            ListTile(
              leading: Icon(Icons.close),
              title: Text('Annuler'),
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
    Category category,
    Account account,
    String currency,
  ) {
    final sign = transaction.type == TransactionType.expense ? '-' : '+';
    final amountStr = '$sign${transaction.amount.toStringAsFixed(0)} $currency';
    final color = transaction.type == TransactionType.expense
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer cette transaction ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Récap de ce qu'on va supprimer
              UIHelpers.withSurfaceTheme(context, Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                        ),
                        Text(
                          account.name,
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    amountStr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                ],
              ),
              )),
            SizedBox(height: 14),
            Text(
              'Cette action est irréversible.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteTransaction(context, ref, transaction);
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
            child: Text('Supprimer'),
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
      ref.invalidate(zoltEngineProviderProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction supprimée'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Theme.of(context).colorScheme.primary,
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
