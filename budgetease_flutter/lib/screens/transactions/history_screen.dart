import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../../services/database_service.dart';
import '../../utils/colors.dart';
import '../../utils/formatters.dart';
import '../transactions/transaction_form_screen.dart';
import '../../widgets/common/custom_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedPeriod = 'month';
  String? _selectedCategory;
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    final box = DatabaseService.transactions;
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'day':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'month':
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    var transactions = box.values.where((t) {
      final isInPeriod = t.date.isAfter(startDate.subtract(const Duration(days: 1)));
      final matchesCategory = _selectedCategory == null || t.category == _selectedCategory;
      return isInPeriod && matchesCategory;
    }).toList();

    transactions.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      _transactions = transactions;
    });
  }

  Future<void> _editTransaction(Transaction transaction) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionFormScreen(transaction: transaction),
      ),
    );

    if (result == true) {
      _loadTransactions();
    }
  }

  Map<String, List<Transaction>> _groupByDate() {
    final grouped = <String, List<Transaction>>{};

    for (var transaction in _transactions) {
      final dateKey = DateFormatter.formatDate(transaction.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final settings = DatabaseService.settings.values.firstOrNull;
    final currency = settings?.currency ?? 'FCFA';
    final groupedTransactions = _groupByDate();

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Historique'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: _transactions.isEmpty
          ? EmptyState(
              icon: Icons.history,
              title: 'Aucune transaction',
              subtitle: 'Vos transactions apparaîtront ici',
            )
          : RefreshIndicator(
              onRefresh: () async => _loadTransactions(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groupedTransactions.length,
                itemBuilder: (context, index) {
                  final dateKey = groupedTransactions.keys.elementAt(index);
                  final transactions = groupedTransactions[dateKey]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          dateKey,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray600,
                          ),
                        ),
                      ),
                      ...transactions.map((transaction) =>
                          _buildTransactionItem(transaction, currency)),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const TransactionFormScreen(),
            ),
          );
          if (result == true) {
            _loadTransactions();
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Transaction', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction, String currency) {
    final category = DatabaseService.categories.values.firstWhere(
      (c) => c.name == transaction.category,
      orElse: () => DatabaseService.categories.values.last,
    );

    final isExpense = transaction.type == 'expense';
    final color = isExpense ? AppColors.danger : AppColors.success;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            category.icon,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(
          transaction.category,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.paymentMethod),
            if (transaction.note != null && transaction.note!.isNotEmpty)
              Text(
                transaction.note!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.gray600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Text(
          '${isExpense ? '-' : '+'} ${CurrencyFormatter.format(transaction.amount, currency)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        onTap: () => _editTransaction(transaction),
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtres',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Période',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip('Jour', 'day', setModalState),
                  _buildFilterChip('Semaine', 'week', setModalState),
                  _buildFilterChip('Mois', 'month', setModalState),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Catégorie',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Toutes')),
                  ...DatabaseService.categories.values.map((cat) => DropdownMenuItem(
                        value: cat.name,
                        child: Row(
                          children: [
                            Text(cat.icon),
                            const SizedBox(width: 8),
                            Text(cat.name),
                          ],
                        ),
                      )),
                ],
                onChanged: (value) {
                  setModalState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Réinitialiser',
                      isOutlined: true,
                      onPressed: () {
                        setState(() {
                          _selectedPeriod = 'month';
                          _selectedCategory = null;
                        });
                        _loadTransactions();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Appliquer',
                      onPressed: () {
                        _loadTransactions();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, StateSetter setModalState) {
    final isSelected = _selectedPeriod == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setModalState(() => _selectedPeriod = value);
        setState(() => _selectedPeriod = value);
      },
      selectedColor: AppColors.primaryLight,
      checkmarkColor: AppColors.primary,
    );
  }
}
