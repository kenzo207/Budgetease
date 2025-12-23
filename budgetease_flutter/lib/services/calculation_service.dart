import '../models/transaction.dart';

class CalculationService {
  static Map<String, double> getPeriodTotals(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    double income = 0;
    double expenses = 0;

    for (var transaction in transactions) {
      if (transaction.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(endDate.add(const Duration(days: 1)))) {
        if (transaction.type == 'income') {
          income += transaction.amount;
        } else {
          expenses += transaction.amount;
        }
      }
    }

    return {
      'income': income,
      'expenses': expenses,
      'balance': income - expenses,
    };
  }

  static Map<String, double> getRealAvailableBudget(
    double totalIncome,
    double totalFixedCharges,
    double totalExpenses,
    double savingsGoal,
  ) {
    // Reste pour Dépenses Variables (RDV)
    final rdv = totalIncome - totalFixedCharges - savingsGoal;
    
    // Argent Réellement Disponible (ARD)
    final ard = rdv - totalExpenses;

    return {
      'rdv': rdv,
      'ard': ard,
      'fixed': totalFixedCharges,
      'saved': savingsGoal,
    };
  }

  static List<Map<String, dynamic>> getTopCategories(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate, {
    int limit = 3,
  }) {
    final categoryTotals = <String, double>{};

    for (var transaction in transactions) {
      if (transaction.type == 'expense' &&
          transaction.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(endDate.add(const Duration(days: 1)))) {
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }

    final totalExpenses = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);

    final categories = categoryTotals.entries.map((entry) {
      return {
        'category': entry.key,
        'amount': entry.value,
        'percentage': totalExpenses > 0 ? (entry.value / totalExpenses) * 100 : 0,
      };
    }).toList();

    categories.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

    return categories.take(limit).toList();
  }

  static Map<String, dynamic> getBudgetProgress(
    String category,
    double budgetAmount,
    List<Transaction> transactions,
    String month,
  ) {
    final monthParts = month.split('-');
    final year = int.parse(monthParts[0]);
    final monthNum = int.parse(monthParts[1]);

    final startDate = DateTime(year, monthNum, 1);
    final endDate = DateTime(year, monthNum + 1, 0);

    double spent = 0;
    for (var transaction in transactions) {
      if (transaction.type == 'expense' &&
          transaction.category == category &&
          transaction.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(endDate.add(const Duration(days: 1)))) {
        spent += transaction.amount;
      }
    }

    final percentage = budgetAmount > 0 ? (spent / budgetAmount) * 100 : 0;
    final remaining = budgetAmount - spent;

    String status;
    if (percentage >= 100) {
      status = 'exceeded';
    } else if (percentage >= 80) {
      status = 'warning';
    } else {
      status = 'safe';
    }

    return {
      'spent': spent,
      'percentage': percentage,
      'remaining': remaining,
      'status': status,
    };
  }
}
