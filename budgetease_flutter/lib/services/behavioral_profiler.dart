import 'dart:math';
import '../models/transaction.dart';
import '../models/behavioral_profile.dart';
import 'database_service.dart';
import 'advisor_service.dart';

class BehavioralProfiler {
  /// Construit le profil comportemental basé sur les 30 derniers jours
  static BehavioralProfile buildProfile() {
    final last30Days = DateTime.now().subtract(const Duration(days: 30));
    final recentTransactions = DatabaseService.transactions.values
        .where((t) => t.date.isAfter(last30Days))
        .toList();

    // Calcul de la fréquence de dépenses
    final frequency = recentTransactions.length / 30;

    // Construction du pattern horaire
    final hourlyPattern = <int, int>{};
    for (var t in recentTransactions) {
      final hour = t.date.hour;
      hourlyPattern[hour] = (hourlyPattern[hour] ?? 0) + 1;
    }

    // Analyse des dépassements
    int overruns = 0;
    double totalOverrun = 0;

    for (int i = 0; i < 30; i++) {
      final day = DateTime.now().subtract(Duration(days: i));
      final dailyCap = AdvisorService.getRecommendedDailyCap();
      final spent = _getDailySpent(day);

      if (spent > dailyCap && dailyCap > 0) {
        overruns++;
        totalOverrun += (spent - dailyCap);
      }
    }

    return BehavioralProfile(
      spendingFrequency: frequency,
      hourlyPattern: hourlyPattern,
      overrunCount: overruns,
      averageOverrun: overruns > 0 ? totalOverrun / overruns : 0,
      lastUpdated: DateTime.now(),
    );
  }

  /// Récupère ou crée le profil stocké
  static BehavioralProfile getOrCreateProfile() {
    final box = DatabaseService.behavioralProfiles;
    
    if (box.isEmpty) {
      final profile = buildProfile();
      box.add(profile);
      return profile;
    }

    final profile = box.values.first;
    
    // Mettre à jour si plus de 24h
    if (DateTime.now().difference(profile.lastUpdated).inHours > 24) {
      final updated = buildProfile();
      profile.spendingFrequency = updated.spendingFrequency;
      profile.hourlyPattern = updated.hourlyPattern;
      profile.overrunCount = updated.overrunCount;
      profile.averageOverrun = updated.averageOverrun;
      profile.lastUpdated = updated.lastUpdated;
      profile.save();
    }

    return profile;
  }

  /// Calcule les dépenses d'une journée spécifique
  static double _getDailySpent(DateTime day) {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return DatabaseService.transactions.values
        .where((t) =>
            t.type == 'expense' &&
            t.date.isAfter(startOfDay) &&
            t.date.isBefore(endOfDay))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Détermine si l'utilisateur a tendance à dépenser le soir
  static bool isEveningSpender() {
    final profile = getOrCreateProfile();
    final eveningTransactions = (profile.hourlyPattern[18] ?? 0) +
        (profile.hourlyPattern[19] ?? 0) +
        (profile.hourlyPattern[20] ?? 0) +
        (profile.hourlyPattern[21] ?? 0);
    
    final totalTransactions = profile.hourlyPattern.values.fold(0, (a, b) => a + b);
    
    return totalTransactions > 0 && (eveningTransactions / totalTransactions) > 0.4;
  }
}
