import 'package:budgetease_flutter/data/database/app_database.dart';
import 'package:budgetease_flutter/data/database/tables/recurring_charges_table.dart';
import 'package:budgetease_flutter/data/database/tables/settings_table.dart';
import 'package:budgetease_flutter/data/database/tables/transactions_table.dart';
import 'package:budgetease_flutter/data/database/tables/accounts_table.dart';

/// Construit l'objet JSON d'entrée pour le moteur Zolt (EngineInput).
/// Toutes les données viennent de la base SQLite locale.
Map<String, dynamic> buildEngineInput({
  required List<Account> accounts,
  required List<RecurringCharge> charges,
  required List<Transaction> transactions,
  required UserSettings settings,
}) {
  final now = DateTime.now();

  return {
    'today': {
      'year':  now.year,
      'month': now.month,
      'day':   now.day,
    },

    // ── Comptes ──────────────────────────────────────────
    'accounts': accounts
        .where((a) => a.isActive)
        .map((a) => {
              'id':           a.id.toString(),
              'name':         a.name,
              'account_type': _accountType(a.type),
              'balance':      a.currentBalance,
              'is_active':    true,
            })
        .toList(),

    // ── Charges fixes ─────────────────────────────────────
    'charges': charges
        .where((c) => c.isActive)
        .map((c) {
          final daysLeft = c.dueDate.difference(now).inDays;
          return {
            'id':           c.id.toString(),
            'name':         c.name,
            'amount':       c.amount,
            'due_day':      c.dueDate.day,
            'status':       c.isPaid
                ? 'Paid'
                : daysLeft < 0
                    ? 'Overdue'
                    : 'Pending',
            'amount_paid':  c.paidAmount,
            'is_active':    true,
          };
        })
        .toList(),

    // ── Transactions du cycle ──────────────────────────────
    'transactions': transactions.map((t) => {
          'id':          t.id.toString(),
          'date': {
            'year':  t.date.year,
            'month': t.date.month,
            'day':   t.date.day,
          },
          'amount':        t.amount,
          'tx_type':       _txType(t.type),
          'category':      t.categoryId?.toString(),
          'account_id':    t.accountId.toString(),
          'description':   t.description,
          'sms_confidence': null,
        }).toList(),

    // ── Cycle financier ────────────────────────────────────
    'cycle': {
      'cycle_type':   _cycleType(settings.financialCycle),
      'savings_goal': settings.savingsGoal,
      'transport':    _transportJson(settings),
    },
  };
}

// ─── Helpers de conversion ──────────────────────────────────────

String _accountType(AccountType t) {
  switch (t) {
    case AccountType.mobileMoney: return 'MobileMoney';
    case AccountType.cash:        return 'Cash';
    case AccountType.bank:        return 'Bank';
    case AccountType.savings:     return 'Bank'; // mapping par défaut
  }
}

String _txType(TransactionType t) {
  switch (t) {
    case TransactionType.income:    return 'Income';
    case TransactionType.expense:   return 'Expense';
    case TransactionType.transfer:  return 'TransferOut'; // Simplification Zolt
  }
}

String _cycleType(FinancialCycle c) {
  switch (c) {
    case FinancialCycle.monthly:   return 'Monthly';
    case FinancialCycle.weekly:    return 'Weekly';
    case FinancialCycle.daily:     return 'Daily';
    case FinancialCycle.irregular: return 'Monthly'; // fallback
  }
}

dynamic _transportJson(UserSettings s) {
  switch (s.transportMode) {
    case TransportMode.none:
      return 'None';
    case TransportMode.fixed:
      return 'Subscription';
    case TransportMode.daily:
      // Construire work_days depuis daysPerWeek stocké en DB
      // ex: 3 jours → [1, 2, 3] (lun, mar, mer)
      final daysPerWeek = s.transportDaysPerWeek ?? 5;
      final workDays = List<int>.generate(
        daysPerWeek.clamp(1, 7),
        (i) => i + 1,
      );
      return {
        'Daily': {
          'cost_per_day': s.dailyTransportCost ?? 0.0,
          'work_days':    workDays,
        }
      };
  }
}
