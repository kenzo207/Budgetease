import '../../data/database/tables/settings_table.dart';
import 'dart:math' as math;

/// Service de gestion des cycles financiers
class CycleManagerService {
  final FinancialCycle cycle;

  CycleManagerService({required this.cycle});

  /// Calculer le nombre de jours restants dans le cycle actuel
  /// (inclut le jour actuel)
  int getDaysRemainingInCycle() {
    final now = DateTime.now();
    
    switch (cycle) {
      case FinancialCycle.monthly:
        // Jours restants jusqu'à la fin du mois (inclut aujourd'hui)
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
        return math.max(1, lastDayOfMonth.day - now.day + 1);
        
      case FinancialCycle.weekly:
        // Jours restants jusqu'au dimanche (inclut aujourd'hui)
        // Lundi=1 ... Dimanche=7
        // Dimanche : 7 - 7 + 1 = 1 (correct: seul aujourd'hui reste)
        // Lundi : 7 - 1 + 1 = 7 (correct: semaine entière)
        return math.max(1, DateTime.sunday - now.weekday + 1);
        
      case FinancialCycle.daily:
        return 1;
        
      case FinancialCycle.irregular:
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
        return math.max(1, lastDayOfMonth.day - now.day + 1);
    }
  }

  /// Obtenir la date de début du cycle actuel
  DateTime getStartOfCycle() {
    final now = DateTime.now();
    
    switch (cycle) {
      case FinancialCycle.monthly:
        return DateTime(now.year, now.month, 1);
        
      case FinancialCycle.weekly:
        // Lundi de la semaine actuelle
        final daysFromMonday = now.weekday - DateTime.monday;
        return DateTime(now.year, now.month, now.day).subtract(Duration(days: daysFromMonday));
        
      case FinancialCycle.daily:
        return DateTime(now.year, now.month, now.day);
        
      case FinancialCycle.irregular:
        return DateTime(now.year, now.month, 1);
    }
  }

  /// Obtenir la date de fin du cycle actuel
  DateTime getEndOfCycle() {
    final now = DateTime.now();
    
    switch (cycle) {
      case FinancialCycle.monthly:
        return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        
      case FinancialCycle.weekly:
        // Dimanche de la semaine actuelle (pas la semaine prochaine !)
        // weekday: Lundi=1 ... Dimanche=7
        final daysUntilSunday = DateTime.sunday - now.weekday; // 0 si dimanche
        final sunday = DateTime(now.year, now.month, now.day).add(Duration(days: daysUntilSunday));
        return DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59);
        
      case FinancialCycle.daily:
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
        
      case FinancialCycle.irregular:
        return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    }
  }

  /// Calculer le nombre total de jours dans le cycle
  int getTotalDaysInCycle() {
    final start = getStartOfCycle();
    final end = getEndOfCycle();
    return end.difference(start).inDays + 1;
  }
}
