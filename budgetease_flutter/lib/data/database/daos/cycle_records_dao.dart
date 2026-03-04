import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/cycle_records_table.dart';

part 'cycle_records_dao.g.dart';

/// DAO pour les snapshots de cycles financiers terminés.
/// Utilisé par l'engine_provider pour alimenter le moteur Zolt avec
/// l'historique des cycles passés.
@DriftAccessor(tables: [CycleRecords])
class CycleRecordsDao extends DatabaseAccessor<AppDatabase>
    with _$CycleRecordsDaoMixin {
  CycleRecordsDao(super.db);

  /// Insérer un nouveau snapshot de cycle
  Future<int> insertRecord(CycleRecordsCompanion record) =>
      into(cycleRecords).insert(record);

  /// Récupérer les N derniers cycles (ordre anti-chron)
  Future<List<CycleRecord>> getLastN(int n) {
    return (select(cycleRecords)
          ..orderBy([(r) => OrderingTerm.desc(r.cycleStart)])
          ..limit(n))
        .get();
  }

  /// Récupérer tous les cycles
  Future<List<CycleRecord>> getAll() =>
      (select(cycleRecords)
            ..orderBy([(r) => OrderingTerm.desc(r.cycleStart)]))
          .get();

  /// Vérifier si un snapshot existe déjà pour une période donnée
  Future<bool> hasRecordForCycle(DateTime start, DateTime end) async {
    final result = await (select(cycleRecords)
          ..where((r) =>
              r.cycleStart.equals(start) & r.cycleEnd.equals(end)))
        .getSingleOrNull();
    return result != null;
  }

  /// Supprimer les snapshots trop anciens (garder les N derniers)
  Future<void> pruneOldRecords({int keepLast = 24}) async {
    final all = await getAll();
    if (all.length <= keepLast) return;
    final toDelete = all.skip(keepLast).map((r) => r.id).toList();
    await (delete(cycleRecords)
          ..where((r) => r.id.isIn(toDelete)))
        .go();
  }
}
