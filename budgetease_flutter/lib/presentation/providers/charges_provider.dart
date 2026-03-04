import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/recurring_charges_dao.dart';
import '../../data/database/tables/recurring_charges_table.dart';
import 'database_provider.dart';
import 'package:drift/drift.dart' as drift;

part 'charges_provider.g.dart';

/// Provider — liste des charges actives
@riverpod
class ChargesNotifier extends _$ChargesNotifier {
  @override
  Future<List<RecurringCharge>> build() async {
    final db = ref.watch(databaseProvider);
    return RecurringChargesDao(db).getActiveCharges();
  }

  RecurringChargesDao get _dao =>
      RecurringChargesDao(ref.read(databaseProvider));

  /// Ajouter / créer une charge
  Future<void> addCharge({
    required String name,
    required ChargeType type,
    required double amount,
    required DateTime dueDate,
    required ChargeCycle cycle,
  }) async {
    await _dao.insertCharge(RecurringChargesCompanion.insert(
      name: name,
      type: type,
      amount: amount,
      dueDate: dueDate,
      cycle: cycle,
      createdAt: DateTime.now(),
    ));
    ref.invalidateSelf();
  }

  /// Modifier une charge existante
  Future<void> updateCharge({
    required int id,
    required String name,
    required ChargeType type,
    required double amount,
    required DateTime dueDate,
    required ChargeCycle cycle,
  }) async {
    final existing = await _dao.getChargeById(id);
    if (existing == null) return;
    await _dao.updateCharge(existing.copyWith(
      name: name,
      type: type,
      amount: amount,
      dueDate: dueDate,
      cycle: cycle,
    ));
    ref.invalidateSelf();
  }

  /// Marquer comme payée (le solde sera débité via une transaction réelle)
  Future<void> markPaid(int id) async {
    await _dao.markAsPaid(id);
    ref.invalidateSelf();
  }

  /// Supprimer
  Future<void> delete(int id) async {
    await _dao.deleteCharge(id);
    ref.invalidateSelf();
  }
}

/// Provider — charge la plus urgente (pour HomeScreen widget)
@riverpod
Future<RecurringCharge?> mostUrgentCharge(MostUrgentChargeRef ref) async {
  final db = ref.watch(databaseProvider);
  return RecurringChargesDao(db).getMostUrgentCharge();
}

/// Provider — réserve journalière totale des charges
@riverpod
Future<double> dailyChargeReserve(DailyChargeReserveRef ref) async {
  final db = ref.watch(databaseProvider);
  return RecurringChargesDao(db).getDailyReserveTotal();
}
