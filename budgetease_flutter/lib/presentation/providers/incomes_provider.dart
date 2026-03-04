import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/recurring_incomes_dao.dart';
import '../../data/database/tables/recurring_incomes_table.dart';
import 'database_provider.dart';

part 'incomes_provider.g.dart';

/// Provider pour accéder au DAO des revenus réguliers
@riverpod
RecurringIncomesDao incomesDao(IncomesDaoRef ref) {
  final db = ref.watch(databaseProvider);
  return RecurringIncomesDao(db);
}

/// Notifier pour gérer l'état de la liste des revenus réguliers (CRUD)
@riverpod
class IncomesNotifier extends _$IncomesNotifier {
  @override
  Future<List<RecurringIncome>> build() async {
    return _loadIncomes();
  }

  Future<List<RecurringIncome>> _loadIncomes() async {
    final dao = ref.watch(incomesDaoProvider);
    return dao.getActiveIncomes();
  }

  /// Ajouter un nouveau revenu régulier
  Future<void> addIncome(RecurringIncomesCompanion income) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dao = ref.watch(incomesDaoProvider);
      await dao.insertIncome(income);
      return _loadIncomes();
    });
  }

  /// Mettre à jour un revenu existant
  Future<void> updateIncome(RecurringIncome income) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dao = ref.watch(incomesDaoProvider);
      await dao.updateIncome(income);
      return _loadIncomes();
    });
  }

  /// Supprimer (désactiver) un revenu
  Future<void> deleteIncome(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dao = ref.watch(incomesDaoProvider);
      await dao.deactivateIncome(id);
      return _loadIncomes();
    });
  }
}

/// Provider dérivé pour récupérer uniquement le prochain revenu en attente (urgent)
@riverpod
Future<RecurringIncome?> nextPendingIncome(NextPendingIncomeRef ref) async {
  final dao = ref.watch(incomesDaoProvider);
  final now = DateTime.now();
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
  
  // Récupère les revenus dont la date prévue est passée ou c'est pour aujourd'hui
  final pending = await dao.getPendingIncomes(endOfDay);
  
  if (pending.isEmpty) return null;
  return pending.first;
}
