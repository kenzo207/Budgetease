import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/zolt_colors.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/tables/transactions_table.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/engine_provider.dart';
import '../onboarding/calibration_screen.dart';
import '../../../services/analytics_service.dart';
import '../../widgets/edit_transaction_sheet.dart';

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

  String _formatAmount(double amount, String currency, TransactionType type) {
    String prefix = type == TransactionType.expense ? '- ' : (type == TransactionType.income ? '+ ' : '');
    return '$prefix${NumberFormat('#,###', 'fr_FR').format(amount).replaceAll(',', ' ')} $currency';
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(calibrationDataProvider).currency;
    final transactionsAsync = ref.watch(transactionsProviderProvider);
    final categoriesAsync = ref.watch(categoriesProviderProvider);
    final accountsAsync = ref.watch(accountsProviderProvider);
    final zolt = context.zolt;

    return Scaffold(
      backgroundColor: zolt.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transactions',
                    style: TextStyle(
                      fontFamily: 'CabinetGrotesk',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: zolt.textPrimary,
                    ),
                  ),
                  Icon(LucideIcons.filter, size: 22, color: zolt.text3),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: zolt.surface2,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(LucideIcons.search, size: 18, color: zolt.text3),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Rechercher...',
                          hintStyle: TextStyle(
                            fontFamily: 'CabinetGrotesk',
                            fontSize: 14,
                            color: zolt.text3,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(
                          fontFamily: 'CabinetGrotesk',
                          fontSize: 14,
                          color: zolt.textPrimary,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () => setState(() => _searchQuery = ''),
                        child: Icon(LucideIcons.x, size: 16, color: zolt.text3),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('Tous', null, zolt),
                  const SizedBox(width: 8),
                  _buildFilterChip('Dépenses', TransactionType.expense, zolt),
                  const SizedBox(width: 8),
                  _buildFilterChip('Revenus', TransactionType.income, zolt),
                  const SizedBox(width: 8),
                  _buildFilterChip('Virements', TransactionType.transfer, zolt),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Transactions List
            Expanded(
              child: transactionsAsync.when(
                data: (transactions) {
                  return categoriesAsync.when(
                    data: (categories) {
                      return accountsAsync.when(
                        data: (accounts) {
                          var filteredTransactions = transactions.where((t) {
                            if (_filterType != null && t.type != _filterType) return false;
                            if (_searchQuery.isNotEmpty) {
                              final cat = categories.firstWhere((c) => c.id == t.categoryId, orElse: () => categories.first);
                              final acc = accounts.firstWhere((a) => a.id == t.accountId, orElse: () => accounts.first);
                              final text = '${cat.name} ${acc.name} ${t.description ?? ''}'.toLowerCase();
                              if (!text.contains(_searchQuery)) return false;
                            }
                            return true;
                          }).toList();

                          if (filteredTransactions.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(LucideIcons.inbox, size: 48, color: zolt.text3),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucune transaction trouvée',
                                    style: TextStyle(
                                      fontFamily: 'CabinetGrotesk',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: zolt.text2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 32),
                                    child: Text(
                                      'Ajoute ta première dépense ou attend que Zolt lise tes SMS.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'CabinetGrotesk',
                                        fontSize: 14,
                                        color: zolt.text3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final grouped = <String, List<Transaction>>{};
                          for (var t in filteredTransactions) {
                            final dateKey = DateFormat('yyyy-MM-dd').format(t.date);
                            grouped.putIfAbsent(dateKey, () => []).add(t);
                          }
                          final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: sortedDates.length,
                            itemBuilder: (context, index) {
                              final dateKey = sortedDates[index];
                              final dayTransactions = grouped[dateKey]!;
                              final dateStr = _formatDateHeader(DateTime.parse(dateKey)).toUpperCase();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8, top: 16),
                                    child: Text(
                                      '$dateStr — ${DateFormat('d MMMM yyyy', 'fr_FR').format(DateTime.parse(dateKey))}',
                                      style: TextStyle(
                                        fontFamily: 'CabinetGrotesk',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.4,
                                        color: zolt.text3,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: zolt.bg,
                                    ),
                                    child: Column(
                                      children: dayTransactions.map((t) {
                                        final cat = categories.firstWhere((c) => c.id == t.categoryId, orElse: () => categories.first);
                                        final acc = accounts.firstWhere((a) => a.id == t.accountId, orElse: () => accounts.first);
                                        final isLast = t == dayTransactions.last;
                                        
                                        return Column(
                                          children: [
                                            _buildTransactionItem(t, cat, acc, currency, zolt),
                                            if (!isLast)
                                              Divider(height: 1, thickness: 1, color: zolt.border),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        loading: () => Center(child: CircularProgressIndicator(color: ZoltTokens.brand)),
                        error: (_, __) => _buildError('Erreur de comptes', zolt),
                      );
                    },
                    loading: () => Center(child: CircularProgressIndicator(color: ZoltTokens.brand)),
                    error: (_, __) => _buildError('Erreur catégories', zolt),
                  );
                },
                loading: () => Center(child: CircularProgressIndicator(color: ZoltTokens.brand)),
                error: (_, __) => _buildError('Erreur transactions', zolt),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, TransactionType? type, ZoltColors zolt) {
    final isSelected = _filterType == type;
    return GestureDetector(
      onTap: () {
        setState(() => _filterType = type);
        ref.read(analyticsServiceProvider).capture('transaction_filter_changed');
      },
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? zolt.primary : zolt.surface2,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'CabinetGrotesk',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? zolt.onPrimary : zolt.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction t, Category cat, Account acc, String currency, ZoltColors zolt) {
    Color amountColor;
    if (t.type == TransactionType.expense) {
      amountColor = ZoltTokens.critical;
    } else if (t.type == TransactionType.income) {
      amountColor = ZoltTokens.positive;
    } else {
      amountColor = zolt.textPrimary;
    }

    final timeStr = "${t.date.hour.toString().padLeft(2, '0')}:${t.date.minute.toString().padLeft(2, '0')}";

    return InkWell(
      onTap: () => _showTransactionModal(t, cat, acc, currency, zolt),
      onLongPress: () => _showTransactionModal(t, cat, acc, currency, zolt),
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: zolt.isDark ? ZoltTokens.darkSurface3 : ZoltTokens.lightSurface3,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  UIHelpers.getIconForCategory(cat.icon, cat.type),
                  color: UIHelpers.getCategoryColor(cat.type),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontFamily: 'CabinetGrotesk',
                      fontSize: 13,
                      color: zolt.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${t.description != null && t.description!.isNotEmpty ? t.description! : acc.name} • $timeStr',
                    style: TextStyle(
                      fontFamily: 'CabinetGrotesk',
                      fontSize: 12,
                      color: zolt.text2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatAmount(t.amount, currency, t.type),
              style: TextStyle(
                fontFamily: 'Zodiak',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionModal(Transaction t, Category cat, Account acc, String currency, ZoltColors zolt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: zolt.isDark ? ZoltTokens.darkSurface3 : ZoltTokens.lightSurface3,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: zolt.isDark ? ZoltTokens.darkSurface4 : ZoltTokens.lightSurface4,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 24),
              // Icon & Title
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: zolt.surface2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        UIHelpers.getIconForCategory(cat.icon, cat.type),
                        color: UIHelpers.getCategoryColor(cat.type),
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontFamily: 'CabinetGrotesk',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: zolt.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _formatAmount(t.amount, currency, t.type),
                  style: TextStyle(
                    fontFamily: 'Zodiak',
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: t.type == TransactionType.expense ? ZoltTokens.critical : (t.type == TransactionType.income ? ZoltTokens.positive : zolt.textPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Divider(height: 1, thickness: 1, color: zolt.border),
              const SizedBox(height: 24),
              
              _buildModalRow('Date', '${DateFormat('d MMMM yyyy', 'fr_FR').format(t.date)} · ${t.date.hour.toString().padLeft(2, '0')}:${t.date.minute.toString().padLeft(2, '0')}', zolt),
              _buildModalRow('Compte', acc.name, zolt),
              _buildModalRow('Catégorie', cat.name, zolt),
              if (t.description != null && t.description!.isNotEmpty)
                _buildModalRow('Note', t.description!, zolt),
              _buildModalRow('Source', 'Manuelle', zolt),

              const SizedBox(height: 24),
              Divider(height: 1, thickness: 1, color: zolt.border),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: ZoltTokens.brand,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: zolt.border),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(LucideIcons.edit2, size: 18),
                      label: const Text('Modifier', style: TextStyle(fontFamily: 'CabinetGrotesk', fontWeight: FontWeight.w600)),
                      onPressed: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (ctx) => EditTransactionSheet(transaction: t),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: ZoltTokens.critical,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: zolt.border),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(LucideIcons.trash2, size: 18),
                      label: const Text('Supprimer', style: TextStyle(fontFamily: 'CabinetGrotesk', fontWeight: FontWeight.w600)),
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteTransaction(t);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }

  Widget _buildModalRow(String key, String value, ZoltColors zolt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 13, color: zolt.textPrimary)),
          Text(value, style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 13, color: zolt.text2)),
        ],
      ),
    );
  }

  Future<void> _deleteTransaction(Transaction t) async {
    try {
      await ref.read(transactionsProviderProvider.notifier).deleteTransactionFromProvider(t);
      ref.read(analyticsServiceProvider).capture("transaction_deleted", properties: {"transaction_id": t.id});
      ref.invalidate(zoltEngineProviderProvider);
    } catch (e) {
      debugPrint("Error deleting: $e");
    }
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return "Aujourd'hui";
    if (dateOnly == yesterday) return 'Hier';
    return "CE JOUR";
  }

  Widget _buildError(String msg, ZoltColors zolt) {
    return Center(child: Text(msg, style: TextStyle(color: zolt.text2)));
  }
}
