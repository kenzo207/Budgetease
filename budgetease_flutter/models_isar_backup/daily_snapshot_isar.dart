import 'package:isar/isar.dart';

part 'daily_snapshot_isar.g.dart';

@collection
class DailySnapshotIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late DateTime date; // Date du jour (midnight)

  late double dailyCapAllocated; // Cap alloué ce jour

  late double spent; // Dépensé ce jour

  late double carriedOver; // Reporté du jour précédent

  String? carryOverChoice; // "boost_tomorrow", "reinforce_shield", null

  late DateTime createdAt;

  DailySnapshotIsar({
    this.id = Isar.autoIncrement,
    required this.date,
    required this.dailyCapAllocated,
    this.spent = 0.0,
    this.carriedOver = 0.0,
    this.carryOverChoice,
    required this.createdAt,
  });

  // Helpers
  double get remaining => dailyCapAllocated - spent;
  double get saved => remaining > 0 ? remaining : 0;
  bool get hasCarryOver => carriedOver > 0;
}
