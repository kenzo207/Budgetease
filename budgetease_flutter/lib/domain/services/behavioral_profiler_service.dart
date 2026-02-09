import 'dart:convert';
import 'package:drift/drift.dart';
import '../../data/database/app_database.dart';
import '../../data/database/tables/transactions_table.dart';

/// Service pour analyser le comportement de dépense de l'utilisateur
class BehavioralProfilerService {
  final AppDatabase _database;

  BehavioralProfilerService({required AppDatabase database}) : _database = database;

  /// Construire le profil comportemental (30 derniers jours)
  Future<BehavioralProfile> buildProfile() async {
    final last30Days = DateTime.now().subtract(const Duration(days: 30));

    final recentTransactions = await (_database.select(_database.transactions)
          ..where((t) => t.date.isBiggerThanValue(last30Days)))
        .get();

    // Fréquence de dépenses (transactions par jour)
    final frequency = recentTransactions.length / 30.0;

    // Pattern horaire
    final hourlyPattern = <int, int>{};
    for (var t in recentTransactions) {
      final hour = t.date.hour;
      hourlyPattern[hour] = (hourlyPattern[hour] ?? 0) + 1;
    }

    // Analyse dépassements (simplifié pour l'instant)
    // TODO: Intégrer avec BudgetCalculatorService pour Daily Cap
    final overrunCount = 0;
    final averageOverrun = 0.0;

    // Déterminer niveau de conseil
    final advisoryLevel = _determineAdvisoryLevel(frequency, overrunCount);

    return BehavioralProfile(
      spendingFrequency: frequency,
      hourlyPattern: hourlyPattern,
      overrunCount: overrunCount,
      averageOverrun: averageOverrun,
      advisoryLevel: advisoryLevel,
      lastUpdated: DateTime.now(),
    );
  }

  /// Récupérer ou créer profil
  Future<BehavioralProfile> getOrCreateProfile() async {
    final existing = await _database.select(_database.behavioralProfiles).getSingleOrNull();

    if (existing == null) {
      // Créer nouveau profil
      final profile = await buildProfile();
      await _saveProfile(profile);
      return profile;
    }

    // Mettre à jour si > 24h
    if (DateTime.now().difference(existing.lastUpdated).inHours > 24) {
      final updated = await buildProfile();
      await _updateProfile(existing.id, updated);
      return updated;
    }

    return BehavioralProfile.fromDb(existing);
  }

  /// Sauvegarder profil
  Future<void> _saveProfile(BehavioralProfile profile) async {
    await _database.into(_database.behavioralProfiles).insert(
      BehavioralProfilesCompanion.insert(
        spendingFrequency: profile.spendingFrequency,
        hourlyPattern: jsonEncode(profile.hourlyPattern),
        overrunCount: profile.overrunCount,
        averageOverrun: profile.averageOverrun,
        advisoryLevel: profile.advisoryLevel,
        lastUpdated: profile.lastUpdated,
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Mettre à jour profil
  Future<void> _updateProfile(int id, BehavioralProfile profile) async {
    await (_database.update(_database.behavioralProfiles)
          ..where((p) => p.id.equals(id)))
        .write(
      BehavioralProfilesCompanion(
        spendingFrequency: Value(profile.spendingFrequency),
        hourlyPattern: Value(jsonEncode(profile.hourlyPattern)),
        overrunCount: Value(profile.overrunCount),
        averageOverrun: Value(profile.averageOverrun),
        advisoryLevel: Value(profile.advisoryLevel),
        lastUpdated: Value(profile.lastUpdated),
      ),
    );
  }

  /// Déterminer niveau de conseil
  String _determineAdvisoryLevel(double frequency, int overruns) {
    if (frequency < 1.0 && overruns < 3) return 'minimal';
    if (frequency > 5.0 || overruns > 10) return 'frequent';
    return 'standard';
  }

  /// Vérifier si dépensier du soir (18h-22h)
  Future<bool> isEveningSpender() async {
    final profile = await getOrCreateProfile();
    
    final eveningTx = (profile.hourlyPattern[18] ?? 0) +
        (profile.hourlyPattern[19] ?? 0) +
        (profile.hourlyPattern[20] ?? 0) +
        (profile.hourlyPattern[21] ?? 0);
    
    final totalTx = profile.hourlyPattern.values.fold(0, (a, b) => a + b);
    
    return totalTx > 0 && (eveningTx / totalTx) > 0.4;
  }

  /// Obtenir heure de dépense préférée
  Future<int?> getPreferredSpendingHour() async {
    final profile = await getOrCreateProfile();
    
    if (profile.hourlyPattern.isEmpty) return null;

    int maxHour = 0;
    int maxCount = 0;

    profile.hourlyPattern.forEach((hour, count) {
      if (count > maxCount) {
        maxCount = count;
        maxHour = hour;
      }
    });

    return maxHour;
  }
}

/// Modèle Behavioral Profile
class BehavioralProfile {
  final double spendingFrequency;
  final Map<int, int> hourlyPattern;
  final int overrunCount;
  final double averageOverrun;
  final String advisoryLevel;
  final DateTime lastUpdated;

  BehavioralProfile({
    required this.spendingFrequency,
    required this.hourlyPattern,
    required this.overrunCount,
    required this.averageOverrun,
    required this.advisoryLevel,
    required this.lastUpdated,
  });

  factory BehavioralProfile.fromDb(BehavioralProfile dbProfile) {
    return BehavioralProfile(
      spendingFrequency: dbProfile.spendingFrequency,
      hourlyPattern: Map<int, int>.from(
        jsonDecode(dbProfile.hourlyPattern.toString()) as Map
      ),
      overrunCount: dbProfile.overrunCount,
      averageOverrun: dbProfile.averageOverrun,
      advisoryLevel: dbProfile.advisoryLevel,
      lastUpdated: dbProfile.lastUpdated,
    );
  }

  /// Niveau de conseil en texte lisible
  String get advisoryLevelText {
    switch (advisoryLevel) {
      case 'minimal':
        return 'Minimal';
      case 'frequent':
        return 'Fréquent';
      default:
        return 'Standard';
    }
  }

  /// Description du comportement
  String get behaviorDescription {
    if (spendingFrequency < 1.0) {
      return 'Vous dépensez peu fréquemment';
    } else if (spendingFrequency < 3.0) {
      return 'Vous avez une fréquence de dépense modérée';
    } else {
      return 'Vous dépensez très fréquemment';
    }
  }
}
