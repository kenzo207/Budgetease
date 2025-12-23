import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../../services/database_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_widgets.dart';

class TransactionFormScreen extends StatefulWidget {
  final Transaction? transaction;

  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = 'expense';
  String? _selectedCategory;
  String _selectedPaymentMethod = 'MoMo';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _type = widget.transaction!.type;
      _amountController.text = widget.transaction!.amount.toString();
      _selectedCategory = widget.transaction!.category;
      _selectedPaymentMethod = widget.transaction!.paymentMethod;
      _selectedDate = widget.transaction!.date;
      _noteController.text = widget.transaction!.note ?? '';
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une catégorie')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      final box = DatabaseService.transactions;

      if (widget.transaction != null) {
        // Update existing
        widget.transaction!.type = _type;
        widget.transaction!.amount = amount;
        widget.transaction!.category = _selectedCategory!;
        widget.transaction!.paymentMethod = _selectedPaymentMethod;
        widget.transaction!.date = _selectedDate;
        widget.transaction!.note = _noteController.text.isEmpty ? null : _noteController.text;
        await widget.transaction!.save();
      } else {
        // Create new
        final transaction = Transaction(
          id: const Uuid().v4(),
          type: _type,
          amount: amount,
          category: _selectedCategory!,
          paymentMethod: _selectedPaymentMethod,
          date: _selectedDate,
          note: _noteController.text.isEmpty ? null : _noteController.text,
          createdAt: DateTime.now(),
        );
        await box.add(transaction);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction != null ? 'Modifier' : 'Nouvelle transaction'),
        actions: [
          if (widget.transaction != null)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.danger),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmer'),
                    content: const Text('Voulez-vous supprimer cette transaction ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Supprimer', style: TextStyle(color: AppColors.danger)),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  await widget.transaction!.delete();
                  if (mounted) {
                    Navigator.pop(context, true);
                  }
                }
              },
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Type selector
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton('Dépense', 'expense', AppColors.danger),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeButton('Revenu', 'income', AppColors.success),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Montant invalide';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Le montant doit être positif';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: defaultCategories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.name,
                    child: Row(
                      children: [
                        Text(cat.icon, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(cat.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              const SizedBox(height: 16),

              // Payment method
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Moyen de paiement',
                  prefixIcon: Icon(Icons.payment),
                  border: OutlineInputBorder(),
                ),
                items: paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
              ),
              const SizedBox(height: 16),

              // Date
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Note
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Note (optionnel)',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Annuler',
                      isOutlined: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Enregistrer',
                      onPressed: _saveTransaction,
                      isLoading: _isLoading,
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

  Widget _buildTypeButton(String label, String type, Color color) {
    final isSelected = _type == type;
    return InkWell(
      onTap: () => setState(() => _type = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
