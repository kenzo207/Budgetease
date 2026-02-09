import '../models/transaction.dart';
import '../models/fixed_charge.dart';
import 'calculation_service.dart';
import 'database_service.dart';
import 'fixed_charge_service.dart';
import 'income_analyzer.dart';
import 'behavioral_profiler.dart';
import 'period_calculator.dart';

class AdvisoryRule {
  final String id;
  final String message;
  final String type; // 'danger', 'warning', 'info', 'success'
  final double? amount;

  AdvisoryRule({
    required this.id,
    required this.message,
    required this.type,
    this.amount,
  });
}

class AdvisorService {
  static List<AdvisoryRule> getAdvice() {
    final rules = <AdvisoryRule>[];
    final now = DateTime.now();
    
    // Data Loading
    final transactions = DatabaseService.transactions.values.toList();
    final fixedCharges = FixedChargeService.getActiveCharges();
    final settings = DatabaseService.settings.values.firstOrNull;
    final currency = settings?.currency ?? 'FCFA';

    // Get behavioral profile for adaptive advice
    final profile = BehavioralProfiler.getOrCreateProfile();
    final adviceLevel = profile.adviceLevel;

    // 1. Check Fixed Charges approaching
    for (var charge in fixedCharges) {
      final daysUntil = charge.nextDueDate.difference(now).inDays;
      
      // Adapt threshold based on profile
      final threshold = adviceLevel == 'frequent' ? 7 : 5;
      
      if (daysUntil >= 0 && daysUntil <= threshold) {
        rules.add(AdvisoryRule(
          id: 'charge_${charge.id}',
          message: 'Votre échéance "${charge.title}" arrive dans ${daysUntil == 0 ? "aujourd'hui" : "$daysUntil jours"}. Assurez-vous d\'avoir ${_formatMoney(charge.amount, currency)}.',
          type: 'warning',
          amount: charge.amount,
        ));
      }
    }

    // 2. Spending Velocity Check (only for standard and frequent profiles)
    if (adviceLevel != 'minimal') {
      final startOfMonth = DateTime(now.year, now.month, 1);
      final daysPassed = now.day;
      
      if (daysPassed > 1) {
        final thisMonthExpenses = CalculationService.getPeriodTotals(
          transactions, 
          startOfMonth, 
          now
        )['expenses'] ?? 0;

        final avgDaily = thisMonthExpenses / daysPassed;
        
        // Calculate today's spending
        final todayExpenses = CalculationService.getPeriodTotals(
          transactions,
          DateTime(now.year, now.month, now.day),
          now
        )['expenses'] ?? 0;

        // Adapt threshold based on profile
        final multiplier = adviceLevel == 'frequent' ? 1.5 : 2.0;
        final minAmount = adviceLevel == 'frequent' ? 500.0 : 1000.0;

        if (todayExpenses > (avgDaily * multiplier) && todayExpenses > minAmount) {
          final tone = adviceLevel == 'frequent' 
            ? 'Vos dépenses du jour dépassent votre moyenne. Ralentissez pour finir le mois sereinement.'
            : 'Vos dépenses du jour sont 2x supérieures à votre moyenne. Essayez de ralentir demain.';
          
          rules.add(AdvisoryRule(
            id: 'velocity_high',
            message: tone,
            type: 'info',
          ));
        }
      }
    }

    // 3. End of Month Savings Opportunity (for all profiles)
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = daysInMonth - now.day;
    
    if (daysLeft <= 3) {
      final startOfMonth = DateTime(now.year, now.month, 1);
      final totals = CalculationService.getPeriodTotals(transactions, startOfMonth, now);
      final balance = totals['balance'] ?? 0;
      
      if (balance > 0) {
        rules.add(AdvisoryRule(
          id: 'save_opportunity',
          message: 'Fin de mois en positif ! Vous pourriez épargner une partie de ces ${_formatMoney(balance, currency)}.',
          type: 'success',
          amount: balance,
        ));
      }
    }

    return rules;
  }

  static double getRecommendedDailyCap() {
    final bounds = PeriodCalculator.getCurrentPeriodBounds();
    final daysRemaining = PeriodCalculator.getDaysRemainingInPeriod();

    // Get income transactions for current period
    final incomeTransactions = DatabaseService.transactions.values
        .where((t) => 
          t.type == 'income' &&
          t.date.isAfter(bounds['start']!.subtract(const Duration(days: 1))) &&
          t.date.isBefore(bounds['end']!.add(const Duration(days: 1)))
        )
        .toList();

    // Calculate total period income (normalized to user's period)
    double totalPeriodIncome = 0;
    for (var t in incomeTransactions) {
      totalPeriodIncome += PeriodCalculator.normalizeToUserPeriod(
        t.amount,
        t.incomeFrequency,
      );
    }

    // If no income this period, use pattern analysis from IncomeAnalyzer
    if (totalPeriodIncome == 0) {
      final pattern = IncomeAnalyzer.getOrCreatePattern();
      final weeklyIncome = pattern.estimatedWeeklyIncome;
      
      if (weeklyIncome > 0) {
        // Convert estimated weekly income to user period
        totalPeriodIncome = PeriodCalculator.normalizeToUserPeriod(
          weeklyIncome,
          'weekly',
        );
      } else {
        // Fallback to current balance logic if no income pattern
        final now = DateTime.now();
        final transactions = DatabaseService.transactions.values.toList();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final totals = CalculationService.getPeriodTotals(transactions, startOfMonth, now);
        
        final currentBalance = totals['balance'] ?? 0;
        final fixedChargesRemaining = FixedChargeService.getRemainingFixedChargesForMonth();
        
        // Adjust fixed charges for period
        final periodFixedChargesRemaining = PeriodCalculator.convertMonthlyToPeriod(fixedChargesRemaining);
        
        final realAvailable = currentBalance - periodFixedChargesRemaining;
        
        if (realAvailable <= 0) return 0;
        return realAvailable / daysRemaining;
      }
    }

    // Get fixed charges for user's period
    final monthlyFixedCharges = FixedChargeService.getMonthlyFixedChargesAmount();
    final fixedCharges = PeriodCalculator.convertMonthlyToPeriod(monthlyFixedCharges);
    
    // Get settings for SOS amount
    final settings = DatabaseService.settings.values.firstOrNull;
    final sosAmount = settings?.sosAmount ?? 0.0;
    
    // Convert SOS amount to period equivalent (if period is small, SOS impact is huge, 
    // so we distribute SOS deduction over the remaining days of the month/period)
    // Simplified strategy: Subtract full SOS amount from available funds immediately
    
    // Get expenses for current period
    final transactions = DatabaseService.transactions.values.toList();
    final totals = CalculationService.getPeriodTotals(
      transactions,
      bounds['start']!,
      DateTime.now(),
    );
    final spent = totals['expenses'] ?? 0;

    // Calculate available money
    final disposable = totalPeriodIncome - fixedCharges;
    var remaining = disposable - spent;
    
    // Apply SOS Logic (Friction Protocol)
    if (sosAmount > 0) {
      remaining -= sosAmount;
    }

    if (remaining <= 0) return 0;

    return remaining / daysRemaining;
  }

  static Future<void> activateSOS(double amount) async {
    final settings = DatabaseService.settings.values.firstOrNull;
    if (settings != null) {
      settings.sosAmount = amount;
      await settings.save();
    }
  }

  static Future<void> deactivateSOS() async {
    final settings = DatabaseService.settings.values.firstOrNull;
    if (settings != null) {
      settings.sosAmount = 0.0;
      await settings.save();
    }
  }

  static String _formatMoney(double amount, String currency) {
    return '${amount.toStringAsFixed(0)} $currency';
  }
}
