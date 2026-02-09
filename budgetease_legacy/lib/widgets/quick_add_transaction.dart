import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:budgetease_flutter/database/app_database.dart';
import 'package:budgetease_flutter/database/transactions_table.dart';
import 'package:budgetease_flutter/services/wallet_service.dart';
import 'package:budgetease_flutter/utils/money.dart';

/// Quick add transaction bottom sheet
class QuickAddTransaction extends StatefulWidget {
  final AppDatabase database;
  final TransactionType type;

  const QuickAddTransaction({
    super.key,
    required this.database,
    required this.type,
  });

  @override
  State<QuickAddTransaction> createState() => _QuickAddTransactionState();
}

class _QuickAddTransactionState extends State<QuickAddTransaction> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedCategory;
  WalletType _selectedWallet = WalletType.cash;
  bool _isLoading = false;

  // Categories
  final List<String> _expenseCategories = [
    'Alimentation',
    'Transport',
    'Logement',
    'Santé',
    'Loisirs',
    'Shopping',
    'Autre',
  ];

  final List<String> _incomeCategories = [
    'Salaire',
    'Freelance',
    'Business',
    'Cadeau',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.type == TransactionType.expense
        ? _expenseCategories.first
        : _incomeCategories.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = widget.type == TransactionType.expense;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                isExpense ? Icons.remove_circle : Icons.add_circle,
                color: isExpense ? Colors.red : Colors.green,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                isExpense ? 'Nouvelle Dépense' : 'Nouveau Revenu',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Amount input
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: '0',
              suffix: const Text('FCFA', style: TextStyle(fontSize: 16)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isExpense ? Colors.red : Colors.green,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isExpense ? Colors.red : Colors.green,
                  width: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Category selector
          Text(
            'Catégorie',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (isExpense ? _expenseCategories : _incomeCategories)
                .map((category) => _buildCategoryChip(category))
                .toList(),
          ),

          const SizedBox(height: 20),

          // Wallet selector
          Text(
            'Portefeuille',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          _buildWalletSelector(),

          const SizedBox(height: 20),

          // Note (optional)
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: 'Note (optionnel)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.note),
            ),
            maxLines: 2,
          ),

          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: isExpense ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Enregistrer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;

    return ChoiceChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedCategory = category);
          HapticFeedback.selectionClick();
        }
      },
      selectedColor: widget.type == TransactionType.expense
          ? Colors.red.withOpacity(0.3)
          : Colors.green.withOpacity(0.3),
      backgroundColor: const Color(0xFF2A2A2A),
    );
  }

  Widget _buildWalletSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: DropdownButton<WalletType>(
        value: _selectedWallet,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: const Color(0xFF2A2A2A),
        items: [
          _buildWalletMenuItem(WalletType.cash, '💵 Cash'),
          _buildWalletMenuItem(WalletType.momoMtn, '📱 MTN MoMo'),
          _buildWalletMenuItem(WalletType.momoOrange, '🍊 Orange Money'),
          _buildWalletMenuItem(WalletType.momoMoov, '🔵 Moov Money'),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedWallet = value);
            HapticFeedback.selectionClick();
          }
        },
      ),
    );
  }

  DropdownMenuItem<WalletType> _buildWalletMenuItem(
    WalletType type,
    String label,
  ) {
    return DropdownMenuItem(
      value: type,
      child: Text(label),
    );
  }

  Future<void> _saveTransaction() async {
    // Validate amount
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showError('Veuillez entrer un montant');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError('Montant invalide');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create transaction
      await widget.database.into(widget.database.transactions).insert(
        TransactionsCompanion.insert(
          type: widget.type,
          date: DateTime.now(),
          amount: amount,
          category: _selectedCategory!,
          sourceWallet: _selectedWallet,
          note: Value(_noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim()),
          isShieldRelated: const Value(false),
          createdAt: DateTime.now(),
        ),
      );

      // Update wallet balance
      final walletService = WalletService(widget.database);
      final wallet = await walletService.getWalletByType(_selectedWallet);

      if (wallet != null) {
        final newBalance = widget.type == TransactionType.expense
            ? wallet.balance - amount
            : wallet.balance + amount;

        await walletService.updateBalance(wallet.id, newBalance);
      }

      // Success feedback
      HapticFeedback.heavyImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.type == TransactionType.expense
                  ? '✅ Dépense enregistrée'
                  : '✅ Revenu enregistré',
            ),
            backgroundColor: widget.type == TransactionType.expense
                ? Colors.red
                : Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.pop(context, true); // Return true to refresh parent
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Erreur: $e');
    }
  }

  void _showError(String message) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
