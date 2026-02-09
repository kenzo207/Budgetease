import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../providers/categories_provider.dart';
import '../providers/accounts_provider.dart';
import '../providers/transactions_provider.dart';
import '../screens/onboarding/calibration_screen.dart';
import '../../data/database/tables/transactions_table.dart';
import '../../data/database/tables/categories_table.dart';
import '../../core/utils/ui_helpers.dart';
import '../../data/database/tables/accounts_table.dart';

/// Bottom Sheet d'actions (FAB)
class ActionBottomSheet extends ConsumerStatefulWidget {
  const ActionBottomSheet({super.key});

  @override
  ConsumerState<ActionBottomSheet> createState() => _ActionBottomSheetState();
}

class _ActionBottomSheetState extends ConsumerState<ActionBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primaryColor,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: 'Dépense', icon: Icon(Icons.remove_circle_outline)),
              Tab(text: 'Revenu', icon: Icon(Icons.add_circle_outline)),
              Tab(text: 'Virement', icon: Icon(Icons.swap_horiz)),
            ],
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                ExpenseTab(),
                IncomeTab(),
                TransferTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Onglet Dépense
class ExpenseTab extends ConsumerStatefulWidget {
  const ExpenseTab({super.key});

  @override
  ConsumerState<ExpenseTab> createState() => _ExpenseTabState();
}

class _ExpenseTabState extends ConsumerState<ExpenseTab> {
  final _amountController = TextEditingController();
  int? _selectedCategoryId;
  int? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();
  bool _isException = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _amountController.text.isNotEmpty &&
      _selectedCategoryId != null &&
      _selectedAccountId != null;

  Future<void> _save() async {
    if (!_canSave) return;

    setState(() {
      _isSaving = true;
    });

    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    try {
      await ref.read(transactionsProviderProvider.notifier).createTransaction(
            amount: amount,
            type: TransactionType.expense,
            categoryId: _selectedCategoryId!,
            accountId: _selectedAccountId!,
            date: _selectedDate,
            isException: _isException,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dépense enregistrée'),
            backgroundColor: AppColors.accentColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(calibrationDataProvider).currency;
    final categoriesAsync = ref.watch(categoriesProviderProvider);
    final accountsAsync = ref.watch(accountsProviderProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Montant
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: Theme.of(context).textTheme.displayMedium,
            decoration: InputDecoration(
              labelText: 'Montant',
              suffixText: currency,
              prefixIcon: const Icon(Icons.attach_money),
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 24),

          // Catégorie
          Text(
            'Catégorie',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          categoriesAsync.when(
            data: (categories) {
              final expenseCategories = categories
                  .where((c) => c.type == CategoryType.expense)
                  .toList();

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: expenseCategories.map((category) {
                  final isSelected = _selectedCategoryId == category.id;
                  return FilterChip(
                    label: Text(category.name),
                    avatar: Text(category.icon),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryId = selected ? category.id : null;
                      });
                    },
                  );
                }).toList(),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Erreur'),
          ),

          const SizedBox(height: 24),

          // Compte débité
          Text(
            'Compte débité',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          accountsAsync.when(
            data: (accounts) {
              return DropdownButtonFormField<int>(
                value: _selectedAccountId,
                decoration: const InputDecoration(
                  labelText: 'Sélectionner un compte',
                ),
                items: accounts.map((account) {
                  return DropdownMenuItem(
                    value: account.id,
                    child: Row(
                      children: [
                        Icon(
                          UIHelpers.getAccountIcon(account.type),
                          color: UIHelpers.getAccountColor(account.type),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(account.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAccountId = value;
                  });
                },
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Erreur'),
          ),

          const SizedBox(height: 24),

          // Date
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date'),
            subtitle: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
          ),

          const SizedBox(height: 16),

          // Exceptionnel
          SwitchListTile(
            title: const Text('Dépense exceptionnelle'),
            subtitle: const Text('Exclue du calcul du budget quotidien'),
            value: _isException,
            onChanged: (value) {
              setState(() {
                _isException = value;
              });
            },
          ),

          const SizedBox(height: 24),

          // Bouton Enregistrer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSave && !_isSaving ? _save : null,
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Enregistrer'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Onglet Revenu
class IncomeTab extends ConsumerStatefulWidget {
  const IncomeTab({super.key});

  @override
  ConsumerState<IncomeTab> createState() => _IncomeTabState();
}

class _IncomeTabState extends ConsumerState<IncomeTab> {
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController();
  int? _selectedCategoryId;
  int? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();
  String _scopeType = 'global';
  int? _scopeDuration;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _amountController.text.isNotEmpty &&
      _selectedCategoryId != null &&
      _selectedAccountId != null;

  Future<void> _save() async {
    if (!_canSave) return;

    setState(() {
      _isSaving = true;
    });

    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    try {
      await ref.read(transactionsProviderProvider.notifier).createTransaction(
            amount: amount,
            type: TransactionType.income,
            categoryId: _selectedCategoryId!,
            accountId: _selectedAccountId!,
            date: _selectedDate,
            scopeType: _scopeType,
            scopeDuration: _scopeDuration,
            description: _sourceController.text.isEmpty ? null : _sourceController.text,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Revenu enregistré'),
            backgroundColor: AppColors.accentColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(calibrationDataProvider).currency;
    final categoriesAsync = ref.watch(categoriesProviderProvider);
    final accountsAsync = ref.watch(accountsProviderProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Montant
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: Theme.of(context).textTheme.displayMedium,
            decoration: InputDecoration(
              labelText: 'Montant',
              suffixText: currency,
              prefixIcon: const Icon(Icons.attach_money),
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 16),

          // Source
          TextField(
            controller: _sourceController,
            decoration: const InputDecoration(
              labelText: 'Source (optionnel)',
              prefixIcon: Icon(Icons.business),
            ),
          ),

          const SizedBox(height: 24),

          // Catégorie
          Text(
            'Catégorie',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          categoriesAsync.when(
            data: (categories) {
              final incomeCategories = categories
                  .where((c) => c.type == CategoryType.income)
                  .toList();

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: incomeCategories.map((category) {
                  final isSelected = _selectedCategoryId == category.id;
                  return FilterChip(
                    label: Text(category.name),
                    avatar: Text(category.icon),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryId = selected ? category.id : null;
                      });
                    },
                  );
                }).toList(),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Erreur'),
          ),

          const SizedBox(height: 24),

          // Compte crédité
          Text(
            'Compte crédité',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          accountsAsync.when(
            data: (accounts) {
              return DropdownButtonFormField<int>(
                value: _selectedAccountId,
                decoration: const InputDecoration(
                  labelText: 'Sélectionner un compte',
                ),
                items: accounts.map((account) {
                  return DropdownMenuItem(
                    value: account.id,
                    child: Row(
                      children: [
                        Icon(
                          UIHelpers.getAccountIcon(account.type),
                          color: UIHelpers.getAccountColor(account.type),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(account.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAccountId = value;
                  });
                },
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Erreur'),
          ),

          const SizedBox(height: 24),

          // Portée (Scope)
          Text(
            'Portée du revenu',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          RadioListTile<String>(
            title: const Text('Augmenter mon niveau de vie'),
            subtitle: const Text('Lissé sur tout le cycle'),
            value: 'global',
            groupValue: _scopeType,
            onChanged: (value) {
              setState(() {
                _scopeType = value!;
                _scopeDuration = null;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Couvrir une période spécifique'),
            subtitle: const Text('Budget temporaire'),
            value: 'temporary',
            groupValue: _scopeType,
            onChanged: (value) {
              setState(() {
                _scopeType = value!;
              });
            },
          ),
          if (_scopeType == 'temporary')
            Padding(
              padding: const EdgeInsets.only(left: 56, top: 8),
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nombre de jours',
                  suffixText: 'jours',
                ),
                onChanged: (value) {
                  setState(() {
                    _scopeDuration = int.tryParse(value);
                  });
                },
              ),
            ),
          RadioListTile<String>(
            title: const Text('Épargne pure'),
            subtitle: const Text('N\'affecte pas le budget'),
            value: 'savings',
            groupValue: _scopeType,
            onChanged: (value) {
              setState(() {
                _scopeType = value!;
                _scopeDuration = null;
              });
            },
          ),

          const SizedBox(height: 24),

          // Bouton Enregistrer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSave && !_isSaving ? _save : null,
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Enregistrer'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Onglet Virement
class TransferTab extends ConsumerStatefulWidget {
  const TransferTab({super.key});

  @override
  ConsumerState<TransferTab> createState() => _TransferTabState();
}

class _TransferTabState extends ConsumerState<TransferTab> {
  final _amountController = TextEditingController();
  final _feeController = TextEditingController();
  int? _sourceAccountId;
  int? _destAccountId;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _amountController.text.isNotEmpty &&
      _sourceAccountId != null &&
      _destAccountId != null &&
      _sourceAccountId != _destAccountId;

  Future<void> _save() async {
    if (!_canSave) return;

    setState(() {
      _isSaving = true;
    });

    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    final fee = double.tryParse(_feeController.text);

    try {
      await ref.read(transactionsProviderProvider.notifier).createTransaction(
            amount: amount,
            type: TransactionType.transfer,
            categoryId: 1, // Catégorie par défaut pour les virements
            accountId: _sourceAccountId!,
            toAccountId: _destAccountId,
            date: _selectedDate,
            feeAmount: fee,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Virement enregistré'),
            backgroundColor: AppColors.accentColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(calibrationDataProvider).currency;
    final accountsAsync = ref.watch(accountsProviderProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Montant
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: Theme.of(context).textTheme.displayMedium,
            decoration: InputDecoration(
              labelText: 'Montant',
              suffixText: currency,
              prefixIcon: const Icon(Icons.attach_money),
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 24),

          // Compte source
          Text(
            'De',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          accountsAsync.when(
            data: (accounts) {
              return DropdownButtonFormField<int>(
                value: _sourceAccountId,
                decoration: const InputDecoration(
                  labelText: 'Compte source',
                ),
                items: accounts.map((account) {
                  return DropdownMenuItem(
                    value: account.id,
                    child: Row(
                      children: [
                        Icon(
                          UIHelpers.getAccountIcon(account.type),
                          color: UIHelpers.getAccountColor(account.type),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(account.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _sourceAccountId = value;
                  });
                },
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Erreur'),
          ),

          const SizedBox(height: 24),

          // Compte destination
          Text(
            'Vers',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          accountsAsync.when(
            data: (accounts) {
              return DropdownButtonFormField<int>(
                value: _destAccountId,
                decoration: const InputDecoration(
                  labelText: 'Compte destination',
                ),
                items: accounts.map((account) {
                  return DropdownMenuItem(
                    value: account.id,
                    child: Row(
                      children: [
                        Icon(
                          UIHelpers.getAccountIcon(account.type),
                          color: UIHelpers.getAccountColor(account.type),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(account.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _destAccountId = value;
                  });
                },
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Erreur'),
          ),

          const SizedBox(height: 24),

          // Frais
          TextField(
            controller: _feeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Frais (optionnel)',
              suffixText: currency,
              prefixIcon: const Icon(Icons.money_off),
            ),
          ),

          const SizedBox(height: 24),

          // Date
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date'),
            subtitle: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
          ),

          const SizedBox(height: 24),

          // Bouton Enregistrer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSave && !_isSaving ? _save : null,
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Enregistrer'),
            ),
          ),
        ],
      ),
    );
  }
}
