import 'package:isar/isar.dart';

part 'shield_item_isar.g.dart';

enum ShieldType {
  fixedCharge, // Loyer, abonnements
  debt, // Dettes à rembourser
  sos, // Réserve SOS
}

enum RecurringFrequency {
  daily,
  weekly,
  monthly,
  yearly,
}

@collection
class ShieldItemIsar {
  Id id = Isar.autoIncrement;

  late String title; // "Loyer", "Dette Mensuelle", "SOS Reserve"

  @enumerated
  late ShieldType type;

  late double amount;

  @enumerated
  late RecurringFrequency frequency;

  @Index()
  DateTime? nextDueDate; // For fixed charges and debts

  late bool isActive;

  late DateTime createdAt;

  // Debt specific fields
  double? totalDebtAmount; // Total debt remaining
  int? installmentsRemaining; // Number of payments left

  ShieldItemIsar({
    this.id = Isar.autoIncrement,
    required this.title,
    required this.type,
    required this.amount,
    required this.frequency,
    this.nextDueDate,
    this.isActive = true,
    required this.createdAt,
    this.totalDebtAmount,
    this.installmentsRemaining,
  });

  // Helper to get progress for debts
  double? get debtProgress {
    if (type != ShieldType.debt || totalDebtAmount == null) return null;
    if (totalDebtAmount! <= 0) return 1.0;
    
    final paid = totalDebtAmount! - (amount * (installmentsRemaining ?? 0));
    return (paid / totalDebtAmount!).clamp(0.0, 1.0);
  }
}
