import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/constants/app_constants.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/tables/recurring_incomes_table.dart';
import '../../providers/incomes_provider.dart';

class IncomeFormScreen extends ConsumerStatefulWidget {
  final RecurringIncome? income;

  const IncomeFormScreen({super.key, this.income});

  @override
  ConsumerState<IncomeFormScreen> createState() => _IncomeFormScreenState();
}

class _IncomeFormScreenState extends ConsumerState<IncomeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _amountCtrl;
  
  IncomeCategory _selectedType = IncomeCategory.salary;
  IncomeFrequency _selectedFrequency = IncomeFrequency.monthly;
  int _daysPerWeek = 5;
  DateTime _nextDepositDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.income?.name ?? '');
    _amountCtrl = TextEditingController(
      text: widget.income != null ? widget.income!.amount.toString() : '',
    );
    if (widget.income != null) {
      _selectedType = widget.income!.type;
      _selectedFrequency = widget.income!.frequency;
      _daysPerWeek = widget.income!.daysPerWeek ?? 1;
      _nextDepositDate = widget.income!.nextDepositDate;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountCtrl.text) ?? 0.0;
    
    // Si ce n'est pas daily_x_times, on nettoie daysPerWeek
    final days = _selectedFrequency == IncomeFrequency.daily_x_times ? _daysPerWeek : null;

    if (widget.income == null) {
      final companion = RecurringIncomesCompanion(
        name: drift.Value(_nameCtrl.text),
        amount: drift.Value(amount),
        type: drift.Value(_selectedType),
        frequency: drift.Value(_selectedFrequency),
        daysPerWeek: drift.Value(days),
        nextDepositDate: drift.Value(_nextDepositDate),
        createdAt: drift.Value(DateTime.now()),
      );
      ref.read(incomesNotifierProvider.notifier).addIncome(companion);
    } else {
      final updated = widget.income!.copyWith(
        name: _nameCtrl.text,
        amount: amount,
        type: _selectedType,
        frequency: _selectedFrequency,
        daysPerWeek: drift.Value(days),
        nextDepositDate: _nextDepositDate,
      );
      ref.read(incomesNotifierProvider.notifier).updateIncome(updated);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.income == null ? 'Nouveau revenu' : 'Modifier revenu'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Nom ──
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nom (ex: Argent de poche)',
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (v) => v!.isEmpty ? 'Requis' : null,
            ),
            SizedBox(height: 20),

            // ── Montant ──
            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Montant (à chaque versement)',
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (v) {
                if (v!.isEmpty) return 'Requis';
                if (double.tryParse(v) == null) return 'Nombre invalide';
                return null;
              },
            ),
            SizedBox(height: 24),

            // ── Catégorie ──
            DropdownButtonFormField<IncomeCategory>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Catégorie de revenu',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: IncomeCategory.values.map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text(_translateCategory(t)),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
            ),
            SizedBox(height: 24),

            // ── Fréquence ──
            Text('Fréquence de versement', style: Theme.of(context).textTheme.titleSmall),
            SizedBox(height: 8),
            SegmentedButton<IncomeFrequency>(
              segments: const [
                ButtonSegment(value: IncomeFrequency.monthly, label: Text('Mois')),
                ButtonSegment(value: IncomeFrequency.weekly, label: Text('Semaine')),
                ButtonSegment(value: IncomeFrequency.daily_x_times, label: Text('Jour')),
              ],
              selected: {_selectedFrequency},
              onSelectionChanged: (Set<IncomeFrequency> newSelection) {
                setState(() => _selectedFrequency = newSelection.first);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Theme.of(context).colorScheme.primary.withValues(alpha: 0.2);
                  }
                  return Colors.transparent;
                }),
              ),
            ),
            SizedBox(height: 20),

            // ── Jours par semaine (si Journalier) ──
            if (_selectedFrequency == IncomeFrequency.daily_x_times) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Combien de fois par semaine ?', style: Theme.of(context).textTheme.bodyMedium),
                    Slider(
                      value: _daysPerWeek.toDouble(),
                      min: 1,
                      max: 7,
                      divisions: 6,
                      activeColor: Theme.of(context).colorScheme.primary,
                      label: '$_daysPerWeek jours',
                      onChanged: (v) => setState(() => _daysPerWeek = v.round()),
                    ),
                    Text('Je reçois $_amountCtrl.text, $_daysPerWeek fois par semaine.', 
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              SizedBox(height: 24),
            ],

            // ── Date de prochaine rentrée ──
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.event_available, color: Theme.of(context).colorScheme.primary),
              title: Text('Date du prochain versement'),
              subtitle: Text(
                '${_nextDepositDate.day}/${_nextDepositDate.month}/${_nextDepositDate.year}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _nextDepositDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (date != null) setState(() => _nextDepositDate = date);
              },
            ),

            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Enregistrer le revenu'),
            ),
          ],
        ),
      ),
    );
  }

  String _translateCategory(IncomeCategory t) {
    switch (t) {
      case IncomeCategory.pocket_money: return 'Argent de poche';
      case IncomeCategory.salary:       return 'Salaire (Mensuel)';
      case IncomeCategory.freelance:    return 'Mission / Freelance';
      case IncomeCategory.business:     return 'Recette (Commerce)';
      case IncomeCategory.allowance:    return 'Pension / Allocation';
      case IncomeCategory.other:        return 'Autre';
    }
  }
}
