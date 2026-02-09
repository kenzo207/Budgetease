import 'package:flutter/material.dart';
import '../../models/fixed_charge.dart';
import '../../services/fixed_charge_service.dart';
import '../../services/database_service.dart';
import '../../utils/colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/custom_widgets.dart';
import 'fixed_charge_form_screen.dart';

class FixedChargesScreen extends StatefulWidget {
  const FixedChargesScreen({super.key});

  @override
  State<FixedChargesScreen> createState() => _FixedChargesScreenState();
}

class _FixedChargesScreenState extends State<FixedChargesScreen> {
  List<FixedCharge> _charges = [];

  @override
  void initState() {
    super.initState();
    _loadCharges();
  }

  void _loadCharges() {
    setState(() {
      _charges = FixedChargeService.getAllCharges();
    });
  }

  Future<void> _openForm([FixedCharge? charge]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FixedChargeFormScreen(charge: charge),
      ),
    );

    if (result == true) {
      _loadCharges();
    }
  }

  Future<void> _toggleActive(FixedCharge charge) async {
    await FixedChargeService.toggleActive(charge);
    _loadCharges();
  }

  @override
  Widget build(BuildContext context) {
    final settings = DatabaseService.settings.values.firstOrNull;
    final currency = settings?.currency ?? 'FCFA';
    final totalMonthly = FixedChargeService.getMonthlyFixedChargesAmount();

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Charges Fixes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: Column(
        children: [
          // KPI Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomCard(
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_clock, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total mensuel bloqué',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.gray600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(totalMonthly, currency),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // List
          Expanded(
            child: _charges.isEmpty
                ? EmptyState(
                    icon: Icons.calendar_today,
                    title: 'Aucune charge fixe',
                    subtitle: 'Ajoutez vos loyers, abonnements et factures récurrentes.',
                    actionText: 'Ajouter une charge',
                    onAction: () => _openForm(),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _charges.length,
                    itemBuilder: (context, index) {
                      final charge = _charges[index];
                      return _buildChargeItem(charge, currency);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _charges.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _openForm(),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildChargeItem(FixedCharge charge, String currency) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.gray200),
      ),
      color: charge.isActive ? Colors.white : AppColors.gray50,
      child: ListTile(
        onTap: () => _openForm(charge),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: charge.isActive ? AppColors.gray100 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.receipt_long,
            color: charge.isActive ? AppColors.gray900 : AppColors.gray400,
          ),
        ),
        title: Text(
          charge.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: charge.isActive ? AppColors.gray900 : AppColors.gray500,
            decoration: charge.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(
          _getFrequencyLabel(charge.frequency),
          style: TextStyle(
            color: AppColors.gray500,
            fontSize: 13,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CurrencyFormatter.format(charge.amount, currency),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: charge.isActive ? AppColors.gray900 : AppColors.gray400,
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: charge.isActive,
              onChanged: (value) => _toggleActive(charge),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  String _getFrequencyLabel(String frequency) {
    switch (frequency) {
      case 'daily': return 'Chaque jour';
      case 'weekly': return 'Chaque semaine';
      case 'monthly': return 'Chaque mois';
      case 'yearly': return 'Chaque année';
      default: return frequency;
    }
  }
}
