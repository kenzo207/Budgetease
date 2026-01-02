import 'package:hive/hive.dart';

part 'ghost_money_insight.g.dart';

@HiveType(typeId: 7)
class GhostMoneyInsight extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime detectedAt;

  @HiveField(2)
  double totalAmount;

  @HiveField(3)
  int transactionCount;

  @HiveField(4)
  List<String> categoryNames;

  @HiveField(5)
  int periodDays; // 7 par défaut

  @HiveField(6)
  double percentageOfAvailable; // Impact relatif

  GhostMoneyInsight({
    required this.id,
    required this.detectedAt,
    required this.totalAmount,
    required this.transactionCount,
    required this.categoryNames,
    this.periodDays = 7,
    required this.percentageOfAvailable,
  });

  /// Indique si l'insight est encore pertinent (moins de 7 jours)
  bool get isRelevant {
    final now = DateTime.now();
    return now.difference(detectedAt).inDays < 7;
  }

  /// Niveau de sévérité basé sur l'impact
  String get severity {
    if (percentageOfAvailable > 15) return 'high';
    if (percentageOfAvailable > 8) return 'medium';
    return 'low';
  }
}
