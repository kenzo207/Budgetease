import 'package:budgetease_flutter/database/app_database.dart';
import 'package:budgetease_flutter/database/transactions_table.dart';
import 'package:budgetease_flutter/services/shield_service.dart';
import 'package:budgetease_flutter/services/wallet_service.dart';
import 'package:budgetease_flutter/utils/money.dart';
import 'package:drift/drift.dart';

/// Calculator for Daily Cap using Flow & Shield concept
class DailyCapCalculator {
  final AppDatabase database;
  final ShieldService shieldService;
  final WalletService walletService;

  DailyCapCalculator(this.database, this.shieldService, this.walletService);

  /// Calculate the recommended Daily Cap
  /// Formula: Daily Cap = (Total Balance - Shield) / Days Remaining in Month
  Future<Money> calculateDailyCap(String currency) async {
    final daysInMonth = DateTime.now().day;
    final daysRemaining = _getDaysRemainingInMonth();

    if (daysRemaining <= 0) {
      return Money.zero(currency);
    }

    // Get total balance
    final balance = await walletService.getTotalBalance(currency);

    // Get shield allocation for remaining days
    final dailyShield = await shieldService.calculateDailyShieldAllocation();
    final shieldNeeded = Money(dailyShield * daysRemaining, currency);

    // Flow = Balance - Shield
    final flow = balance - shieldNeeded;

    // Daily Cap = Flow / Days Remaining
    if (flow.isNegative || flow.isZero) {
      return Money.zero(currency);
    }

    return flow / daysRemaining.toDouble();
  }

  /// Get Real Available Budget (RAB)
  Future<Money> getRealAvailableBudget(String currency) async {
    final balance = await walletService.getTotalBalance(currency);
    final shieldTotal = await shieldService.calculateMonthlyShieldTotal();
    
    return balance - Money(shieldTotal, currency);
  }

  /// Get today's spending so far
  Future<Money> getTodaySpending(String currency) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final transactions = await (database.select(database.transactions)
          ..where((t) => 
              t.type.equals(TransactionType.expense.index) &
              t.date.isBiggerOrEqualValue(startOfDay)))
        .get();

    final total = transactions.fold<double>(
      0.0,
      (sum, t) => sum + t.amount,
    );

    return Money(total, currency);
  }

  /// Get this month's spending
  Future<Money> getMonthSpending(String currency) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    final transactions = await (database.select(database.transactions)
          ..where((t) => 
              t.type.equals(TransactionType.expense.index) &
              t.date.isBiggerOrEqualValue(startOfMonth)))
        .get();

    final total = transactions.fold<double>(
      0.0,
      (sum, t) => sum + t.amount,
    );

    return Money(total, currency);
  }

  /// Helper: Get days remaining in current month
  int _getDaysRemainingInMonth() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    return lastDayOfMonth - now.day + 1;
  }

  /// Get budget status
  Future<BudgetStatus> getBudgetStatus(String currency) async {
    final dailyCap = await calculateDailyCap(currency);
    final todaySpent = await getTodaySpending(currency);
    final balance = await walletService.getTotalBalance(currency);
    
    return BudgetStatus(
      dailyCap: dailyCap,
      todaySpent: todaySpent,
      remaining: dailyCap - todaySpent,
      totalBalance: balance,
      daysRemaining: _getDaysRemainingInMonth(),
    );
  }
}

/// Budget status data class
class BudgetStatus {
  final Money dailyCap;
  final Money todaySpent;
  final Money remaining;
  final Money totalBalance;
  final int daysRemaining;

  BudgetStatus({
    required this.dailyCap,
    required this.todaySpent,
    required this.remaining,
    required this.totalBalance,
    required this.daysRemaining,
  });

  double get spentPercentage {
    if (dailyCap.isZero) return 0.0;
    return (todaySpent.amount / dailyCap.amount).clamp(0.0, 1.0);
  }

  bool get isOverBudget => todaySpent > dailyCap;
}
