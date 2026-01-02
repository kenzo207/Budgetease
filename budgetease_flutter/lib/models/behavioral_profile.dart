import 'package:hive/hive.dart';

part 'behavioral_profile.g.dart';

@HiveType(typeId: 5)
class BehavioralProfile extends HiveObject {
  @HiveField(0)
  String userId; // Toujours "local" pour MVP

  @HiveField(1)
  double spendingFrequency; // Transactions/jour

  @HiveField(2)
  Map<int, int> hourlyPattern; // Heure → Nombre de transactions

  @HiveField(3)
  int overrunCount; // Dépassements sur 30 jours

  @HiveField(4)
  double averageOverrun; // Montant moyen de dépassement

  @HiveField(5)
  DateTime lastUpdated;

  BehavioralProfile({
    this.userId = "local",
    required this.spendingFrequency,
    required this.hourlyPattern,
    required this.overrunCount,
    required this.averageOverrun,
    required this.lastUpdated,
  });

  /// Score interne (jamais affiché à l'utilisateur)
  /// 0 = discipliné, 1 = à risque
  double get riskScore {
    final frequencyScore = spendingFrequency > 5 ? 0.3 : 0;
    final overrunScore = overrunCount > 10 ? 0.4 : (overrunCount / 25);
    final eveningScore = (hourlyPattern[20] ?? 0) > 3 ? 0.3 : 0;
    
    return (frequencyScore + overrunScore + eveningScore).clamp(0.0, 1.0);
  }

  /// Niveau de conseil adapté au profil
  String get adviceLevel {
    if (riskScore > 0.6) return 'frequent'; // Conseils fréquents et directs
    if (riskScore < 0.3) return 'minimal'; // Conseils rares et encourageants
    return 'standard'; // Conseils standards
  }
}
