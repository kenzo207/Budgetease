import 'database_service.dart';

class PeriodCalculator {
  /// Get user's preferred budget period
  static String getUserPeriod() {
    final settings = DatabaseService.settings.values.firstOrNull;
    return settings?.budgetPeriod ?? 'monthly';
  }

  /// Get start and end dates for the current period
  static Map<String, DateTime> getCurrentPeriodBounds() {
    final now = DateTime.now();
    final period = getUserPeriod();

    switch (period) {
      case 'daily':
        return {
          'start': DateTime(now.year, now.month, now.day),
          'end': DateTime(now.year, now.month, now.day, 23, 59, 59),
        };
      case 'weekly':
        // Start of week is Monday
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return {
          'start': DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          'end': DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59),
        };
      case 'monthly':
      default:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return {
          'start': startOfMonth,
          'end': endOfMonth,
        };
    }
  }

  /// Get user-friendly label for current period
  static String getPeriodLabel() {
    final period = getUserPeriod();
    switch (period) {
      case 'daily': return 'Aujourd\'hui';
      case 'weekly': return 'Cette Semaine';
      default: return 'Ce Mois';
    }
  }

  /// Normalize an amount from its frequency to the user's period
  static double normalizeToUserPeriod(double amount, String? frequency) {
    if (frequency == null || frequency.isEmpty) return amount;
    
    final userPeriod = getUserPeriod();
    
    // First convert to daily amount
    double dailyAmount;
    switch (frequency) {
      case 'daily': dailyAmount = amount; break;
      case 'weekly': dailyAmount = amount / 7; break;
      default: dailyAmount = amount / 30; // Approximation for monthly
    }

    // Then convert to user's period
    switch (userPeriod) {
      case 'daily': return dailyAmount;
      case 'weekly': return dailyAmount * 7;
      default: return dailyAmount * 30;
    }
  }

  /// Convert a monthly amount (like fixed charges) to user's period
  static double convertMonthlyToPeriod(double monthlyAmount) {
    final period = getUserPeriod();
    switch (period) {
      case 'daily': return monthlyAmount / 30;
      case 'weekly': return monthlyAmount / 4.33;
      default: return monthlyAmount;
    }
  }

  /// Get number of days remaining in current period
  static int getDaysRemainingInPeriod() {
    final now = DateTime.now();
    final period = getUserPeriod();

    switch (period) {
      case 'daily': return 1;
      case 'weekly': 
        return 7 - now.weekday + 1; // Include today
      default:
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        return daysInMonth - now.day + 1;
    }
  }
}
