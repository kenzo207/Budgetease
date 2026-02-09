import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/database/tables/recurring_charges_table.dart';
import '../onboarding/onboarding_screen.dart';
import 'calibration_screen.dart';

/// Modèle pour une charge fixe à créer
class ChargeToCreate {
  final String name;
  final ChargeType type;
  final double amount;
  final DateTime? dueDate;

  ChargeToCreate({
    required this.name,
    required this.type,
    required this.amount,
    this.dueDate,
  });
}

/// Provider pour les charges fixes à créer
final chargesToCreateProvider = StateProvider<List<ChargeToCreate>>((ref) => []);

/// Écran 5 : Charges Fixes
class FixedChargesScreen extends ConsumerStatefulWidget {
  const FixedChargesScreen({super.key});

  @override
  ConsumerState<FixedChargesScreen> createState() => _FixedChargesScreenState();
}

class _FixedChargesScreenState extends ConsumerState<FixedChargesScreen> {
  final List<ChargeToCreate> _charges = [];

  void _addCharge() {
    showDialog(
      context: context,
      builder: (context) => _AddChargeDialog(
        onAdd: (charge) {
          setState(() {
            _charges.add(charge);
          });
        },
      ),
    );
  }

  void _removeCharge(int index) {
    setState(() {
      _charges.removeAt(index);
    });
  }

  void _onContinue() {
    ref.read(chargesToCreateProvider.notifier).state = _charges;
    ref.read(onboardingControllerProvider.notifier).nextStep();
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(calibrationDataProvider).currency;
    final totalCharges = _charges.fold<double>(
      0.0,
      (sum, charge) => sum + charge.amount,
    );

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              ref.read(onboardingControllerProvider.notifier).previousStep();
            },
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Vos dépenses obligatoires récurrentes',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Loyer, factures, abonnements...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          
          const SizedBox(height: 24),
          
          if (_charges.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune charge fixe ajoutée',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _charges.length,
                itemBuilder: (context, index) {
                  final charge = _charges[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(_getChargeIcon(charge.type)),
                      title: Text(charge.name),
                      subtitle: Text(_getChargeTypeName(charge.type)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${charge.amount.toStringAsFixed(0)} $currency',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _removeCharge(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          
          if (_charges.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total mensuel',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${totalCharges.toStringAsFixed(0)} $currency',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.warningColor,
                        ),
                  ),
                ],
              ),
            ),
          
          OutlinedButton.icon(
            onPressed: _addCharge,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une charge'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onContinue,
              child: Text(_charges.isEmpty ? 'Passer' : 'Continuer'),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getChargeIcon(ChargeType type) {
    switch (type) {
      case ChargeType.rent:
        return Icons.home;
      case ChargeType.electricity:
        return Icons.bolt;
      case ChargeType.water:
        return Icons.water_drop;
      case ChargeType.internet:
        return Icons.wifi;
      case ChargeType.school:
        return Icons.school;
      case ChargeType.transport:
        return Icons.directions_bus;
      case ChargeType.other:
        return Icons.receipt;
    }
  }

  String _getChargeTypeName(ChargeType type) {
    switch (type) {
      case ChargeType.rent:
        return 'Loyer';
      case ChargeType.electricity:
        return 'Électricité';
      case ChargeType.water:
        return 'Eau';
      case ChargeType.internet:
        return 'Internet';
      case ChargeType.school:
        return 'Scolarité';
      case ChargeType.transport:
        return 'Transport';
      case ChargeType.other:
        return 'Autre';
    }
  }
}

class _AddChargeDialog extends ConsumerStatefulWidget {
  final Function(ChargeToCreate) onAdd;

  const _AddChargeDialog({required this.onAdd});

  @override
  ConsumerState<_AddChargeDialog> createState() => _AddChargeDialogState();
}

class _AddChargeDialogState extends ConsumerState<_AddChargeDialog> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  ChargeType _selectedType = ChargeType.rent;
  DateTime? _dueDate;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  bool get _canAdd =>
      _nameController.text.isNotEmpty && _amountController.text.isNotEmpty;

  void _onAdd() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    widget.onAdd(ChargeToCreate(
      name: _nameController.text,
      type: _selectedType,
      amount: amount,
      dueDate: _dueDate,
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter une charge fixe'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                hintText: 'Ex: Loyer',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ChargeType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: ChargeType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getTypeName(type)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Montant',
                suffixText: ref.watch(calibrationDataProvider).currency,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _canAdd ? _onAdd : null,
          child: const Text('Ajouter'),
        ),
      ],
    );
  }

  String _getTypeName(ChargeType type) {
    switch (type) {
      case ChargeType.rent:
        return 'Loyer';
      case ChargeType.electricity:
        return 'Électricité';
      case ChargeType.water:
        return 'Eau';
      case ChargeType.internet:
        return 'Internet';
      case ChargeType.school:
        return 'Scolarité';
      case ChargeType.transport:
        return 'Transport';
      case ChargeType.other:
        return 'Autre';
    }
  }
}
