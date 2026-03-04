import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/tables/recurring_charges_table.dart';
import '../../providers/charges_provider.dart';
import '../onboarding/calibration_screen.dart';

class ChargeFormScreen extends ConsumerStatefulWidget {
  final RecurringCharge? charge; // null = création, non-null = édition

  const ChargeFormScreen({super.key, this.charge});

  @override
  ConsumerState<ChargeFormScreen> createState() => _ChargeFormScreenState();
}

class _ChargeFormScreenState extends ConsumerState<ChargeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;

  ChargeType _type = ChargeType.rent;
  ChargeCycle _cycle = ChargeCycle.monthly;
  DateTime? _dueDate;
  bool _loading = false;

  bool get _isEdit => widget.charge != null;

  @override
  void initState() {
    super.initState();
    final c = widget.charge;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _amountCtrl = TextEditingController(
        text: c != null ? c.amount.toStringAsFixed(0) : '');
    if (c != null) {
      _type = c.type;
      _cycle = c.cycle;
      _dueDate = c.dueDate;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      helpText: "Date limite de paiement",
      confirmText: "Confirmer",
      cancelText: "Annuler",
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Choisissez une date limite')),
      );
      return;
    }

    setState(() => _loading = true);
    final amount = double.parse(_amountCtrl.text.replaceAll(' ', ''));

    try {
      final notifier = ref.read(chargesNotifierProvider.notifier);
      if (_isEdit) {
        await notifier.updateCharge(
          id: widget.charge!.id,
          name: _nameCtrl.text.trim(),
          type: _type,
          amount: amount,
          dueDate: _dueDate!,
          cycle: _cycle,
        );
      } else {
        await notifier.addCharge(
          name: _nameCtrl.text.trim(),
          type: _type,
          amount: amount,
          dueDate: _dueDate!,
          cycle: _cycle,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(calibrationDataProvider).currency;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier la charge' : 'Nouvelle charge'),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            SizedBox(height: 12),

            // ── Nom ──
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nom de la charge',
                hintText: 'Ex: Loyer, Électricité Senelec...',
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
            ),

            SizedBox(height: 20),

            // ── Type ──
            Text('Catégorie', style: tt.labelLarge),
            SizedBox(height: 10),
            _TypeSelector(
              selected: _type,
              onChanged: (t) => setState(() => _type = t),
            ),

            SizedBox(height: 20),

            // ── Montant ──
            TextFormField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Montant',
                suffixText: currency,
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Champ requis';
                final n = double.tryParse(v.replaceAll(' ', ''));
                if (n == null || n <= 0) return 'Montant invalide';
                return null;
              },
            ),

            SizedBox(height: 20),

            // ── Date limite ──
            Text('Date limite de paiement', style: tt.labelLarge),
            SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outline),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, color: cs.onSurface.withValues(alpha: 0.6)),
                    SizedBox(width: 12),
                    Text(
                      _dueDate == null
                          ? 'Choisir une date...'
                          : '${_dueDate!.day.toString().padLeft(2, '0')}/'
                              '${_dueDate!.month.toString().padLeft(2, '0')}/'
                              '${_dueDate!.year}',
                      style: _dueDate == null
                          ? tt.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.4))
                          : tt.bodyLarge,
                    ),
                    const Spacer(),
                    if (_dueDate != null)
                      _DaysLeftChip(dueDate: _dueDate!),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // ── Cycle ──
            Text('Fréquence', style: tt.labelLarge),
            SizedBox(height: 10),
            _CycleSelector(
              selected: _cycle,
              onChanged: (c) => setState(() => _cycle = c),
            ),

            SizedBox(height: 32),

            // ── Impact budget ──
            if (_dueDate != null && _amountCtrl.text.isNotEmpty)
              _BudgetImpactBanner(
                amount: double.tryParse(_amountCtrl.text.replaceAll(' ', '')) ?? 0,
                dueDate: _dueDate!,
                currency: currency,
              ),

            SizedBox(height: 16),

            // ── Submit ──
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_isEdit ? 'Enregistrer' : 'Ajouter la charge'),
            ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Sélecteur de type avec grille d'icônes
// ─────────────────────────────────────────────────────────
class _TypeSelector extends StatelessWidget {
  final ChargeType selected;
  final ValueChanged<ChargeType> onChanged;

  const _TypeSelector({required this.selected, required this.onChanged});

  static const _types = [
    (ChargeType.rent,        Icons.home_outlined,           'Loyer'),
    (ChargeType.electricity, Icons.bolt,                    'Électricité'),
    (ChargeType.water,       Icons.water_drop_outlined,     'Eau'),
    (ChargeType.internet,    Icons.wifi_outlined,           'Internet'),
    (ChargeType.school,      Icons.school_outlined,         'Scolarité'),
    (ChargeType.transport,   Icons.directions_bus_outlined, 'Transport'),
    (ChargeType.other,       Icons.receipt_outlined,        'Autre'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _types.map((t) {
        final (type, icon, label) = t;
        final isSelected = type == selected;
        return GestureDetector(
          onTap: () => onChanged(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? cs.primary : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? cs.primary : cs.outline,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    size: 18,
                    color: isSelected ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.6)),
                SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? cs.onPrimary : cs.onSurface)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Sélecteur de cycle (mensuel / hebdo / unique)
// ─────────────────────────────────────────────────────────
class _CycleSelector extends StatelessWidget {
  final ChargeCycle selected;
  final ValueChanged<ChargeCycle> onChanged;

  const _CycleSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final options = [
      (ChargeCycle.monthly, 'Mensuelle'),
      (ChargeCycle.weekly,  'Hebdomadaire'),
      (ChargeCycle.daily,   'Unique'),
    ];

    return Row(
      children: options.map((o) {
        final (cycle, label) = o;
        final isSelected = cycle == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(cycle),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSelected ? cs.primary : cs.outline),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? cs.onPrimary : cs.onSurface,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Chip "J-X"
// ─────────────────────────────────────────────────────────
class _DaysLeftChip extends StatelessWidget {
  final DateTime dueDate;
  const _DaysLeftChip({required this.dueDate});

  @override
  Widget build(BuildContext context) {
    final days = dueDate.difference(DateTime.now()).inDays;
    final color = days <= 3
        ? const Color(0xFFEF4444)
        : days <= 7
            ? const Color(0xFFF59E0B)
            : const Color(0xFF22C55E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        days < 0 ? 'En retard' : 'J-$days',
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Banner — impact sur le budget journalier
// ─────────────────────────────────────────────────────────
class _BudgetImpactBanner extends StatelessWidget {
  final double amount;
  final DateTime dueDate;
  final String currency;

  const _BudgetImpactBanner({
    required this.amount,
    required this.dueDate,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final days = dueDate.difference(DateTime.now()).inDays;
    final safeDays = days > 0 ? days : 1;
    final dailyReserve = amount / safeDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.calculate_outlined,
              color: Color(0xFF22C55E), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Impact sur votre budget',
                    style: Theme.of(context).textTheme.labelLarge),
                SizedBox(height: 4),
                Text(
                  'À mettre de côté chaque jour : ${dailyReserve.toStringAsFixed(0)} $currency/j',
                  style:
                      const TextStyle(color: Color(0xFF22C55E), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
