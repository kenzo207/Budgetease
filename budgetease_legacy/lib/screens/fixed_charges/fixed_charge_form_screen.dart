import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/fixed_charge.dart';
import '../../services/fixed_charge_service.dart';
import '../../utils/colors.dart';
import '../../widgets/common/custom_widgets.dart';

class FixedChargeFormScreen extends StatefulWidget {
  final FixedCharge? charge;

  const FixedChargeFormScreen({super.key, this.charge});

  @override
  State<FixedChargeFormScreen> createState() => _FixedChargeFormScreenState();
}

class _FixedChargeFormScreenState extends State<FixedChargeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String _frequency = 'monthly';
  DateTime _nextDueDate = DateTime.now();
  bool _isLoading = false;

  final Map<String, String> _frequencyLabels = {
    'daily': 'Tous les jours',
    'weekly': 'Toutes les semaines',
    'monthly': 'Tous les mois',
    'yearly': 'Tous les ans',
  };

  @override
  void initState() {
    super.initState();
    if (widget.charge != null) {
      _titleController.text = widget.charge!.title;
      _amountController.text = widget.charge!.amount.toString();
      _frequency = widget.charge!.frequency;
      _nextDueDate = widget.charge!.nextDueDate;
    }
  }

  Future<void> _saveCharge() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);

      if (widget.charge != null) {
        widget.charge!.title = _titleController.text;
        widget.charge!.amount = amount;
        widget.charge!.frequency = _frequency;
        widget.charge!.nextDueDate = _nextDueDate;
        await FixedChargeService.updateCharge(widget.charge!);
      } else {
        await FixedChargeService.addCharge(
          title: _titleController.text,
          amount: amount,
          frequency: _frequency,
          nextDueDate: _nextDueDate,
        );
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
        title: Text(widget.charge != null ? 'Modifier charge fixe' : 'Nouvelle charge fixe'),
        actions: [
          if (widget.charge != null)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.danger),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmer'),
                    content: const Text('Supprimer cette charge fixe ?'),
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
                  await FixedChargeService.deleteCharge(widget.charge!);
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
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la charge',
                  hintText: 'Ex: Loyer, Abonnement Internet...',
                  prefixIcon: Icon(Icons.label_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

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
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Frequency
              DropdownButtonFormField<String>(
                value: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Fréquence',
                  prefixIcon: Icon(Icons.repeat),
                  border: OutlineInputBorder(),
                ),
                items: _frequencyLabels.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _frequency = value!),
              ),
              const SizedBox(height: 16),

              // Date
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _nextDueDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _nextDueDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Prochaine échéance',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${_nextDueDate.day.toString().padLeft(2, '0')}/${_nextDueDate.month.toString().padLeft(2, '0')}/${_nextDueDate.year}',
                  ),
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
                      onPressed: _saveCharge,
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

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
