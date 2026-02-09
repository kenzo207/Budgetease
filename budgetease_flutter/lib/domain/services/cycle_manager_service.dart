import '../../data/database/tables/settings_table.dart';

/// Service de gestion des cycles financiers
class CycleManagerService {
  final FinancialCycle cycle;

  CycleManagerService({required this.cycle});

  /// Calculer le nombre de jours restants dans le cycle actuel
  int getDaysRemainingInCycle() {
    final now = DateTime.now();
    
    switch (cycle) {
      case FinancialCycle.monthly:
        // Jours restants jusqu'à la fin du mois
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
        return lastDayOfMonth.day - now.day + 1;
        
      case FinancialCycle.weekly:
        // Jours restants jusqu'au dimanche
        final daysUntilSunday = DateTime.sunday - now.weekday;
        return daysUntilSunday == 0 ? 7 : daysUntilSunday;
        
      case FinancialCycle.daily:
        // Toujours 1 jour (aujourd'hui)
        return 1;
        
      case FinancialCycle.irregular:
        // Pas de cycle défini, utiliser le mois par défaut
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
        return lastDayOfMonth.day - now.day + 1;
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
        return now.subtract(Duration(days: daysFromMonday));
        
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
        // Dimanche de la semaine actuelle
        final daysUntilSunday = DateTime.sunday - now.weekday;
        final sunday = now.add(Duration(days: daysUntilSunday == 0 ? 7 : daysUntilSunday));
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
