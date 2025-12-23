import 'package:uuid/uuid.dart';
import '../models/fixed_charge.dart';
import 'database_service.dart';

class FixedChargeService {
  static List<FixedCharge> getAllCharges() {
    return DatabaseService.fixedCharges.values.toList();
  }

  static List<FixedCharge> getActiveCharges() {
    return DatabaseService.fixedCharges.values.where((c) => c.isActive).toList();
  }

  static double getMonthlyFixedChargesAmount() {
    double total = 0;
    final charges = getActiveCharges();

    for (var charge in charges) {
      switch (charge.frequency) {
        case 'daily':
          total += charge.amount * 30;
          break;
        case 'weekly':
          total += charge.amount * 4.33; // Avg weeks in month
          break;
        case 'monthly':
          total += charge.amount;
          break;
        case 'yearly':
          total += charge.amount / 12;
          break;
      }
    }
    return total;
  }

  static Future<void> addCharge({
    required String title,
    required double amount,
    required String frequency,
    required DateTime nextDueDate,
    String? categoryId,
  }) async {
    final charge = FixedCharge(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      frequency: frequency,
      nextDueDate: nextDueDate,
      categoryId: categoryId,
    );
    await DatabaseService.fixedCharges.add(charge);
  }

  static Future<void> updateCharge(FixedCharge charge) async {
    await charge.save();
  }

  static Future<void> deleteCharge(FixedCharge charge) async {
    await charge.delete();
  }

  static Future<void> toggleActive(FixedCharge charge) async {
    charge.isActive = !charge.isActive;
    await charge.save();
  }

  /// Calcule le montant des charges fixes dues pour le reste du mois courant
  static double getRemainingFixedChargesForMonth() {
    double total = 0;
    final now = DateTime.now();
    final charges = getActiveCharges();

    for (var charge in charges) {
      if (charge.nextDueDate.month == now.month && 
          charge.nextDueDate.year == now.year &&
          charge.nextDueDate.isAfter(now)) {
            total += charge.amount;
      }
      // Note: Pour daily/weekly, c'est plus complexe, ici on simplifie pour le MVP
      // On pourrait affiner en comptant le nombre d'occurrences restantes
    }
    return total;
  }
}
