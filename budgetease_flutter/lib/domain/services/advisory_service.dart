import 'package:drift/drift.dart';
import '../../data/database/app_database.dart';
import '../../data/database/tables/transactions_table.dart';
import '../../data/database/tables/recurring_charges_table.dart';
import 'behavioral_profiler_service.dart';
import 'income_predictor_service.dart';

/// Service pour fournir des conseils intelligents adaptatifs
class AdvisoryService {
  final AppDatabase _database;
  final BehavioralProfilerService _profiler;
  final IncomePredictorService _incomePredictor;

  AdvisoryService({
    required AppDatabase database,
    required BehavioralProfilerService profiler,
    required IncomePredictorService incomePredictor,
  })  : _database = database,
        _profiler = profiler,
        _incomePredictor = incomePredictor;

  /// Obtenir tous les conseils actifs
  Future<List<Advisory>> getAdvice() async {
    final profile = await _profiler.getOrCreateProfile();
    final advices = <Advisory>[];

    // 1. Charges fixes approchantes (7 jours)
    final upcomingCharges = await _getUpcomingCharges();
    if (upcomingCharges.isNotEmpty) {
      final totalAmount = upcomingCharges.fold<double>(
        0.0,
        (sum, charge) => sum + charge.amount
      );
      
      advices.add(Advisory(
        type: 'shield_reminder',
        title: 'Échéances Approchantes',
        message: 'Vous avez ${upcomingCharges.length} charge(s) à payer bientôt '
            '(${totalAmount.toStringAsFixed(0)} FCFA).',
        priority: 'high',
        actionLabel: 'Voir les charges',
      ));
    }

    // 2. Vitesse de dépenses élevée
    if (await _isSpendingFast()) {
      advices.add(Advisory(
        type: 'velocity_alert',
        title: 'Dépenses Rapides Aujourd\'hui',
        message: 'Vos dépenses du jour sont 2x supérieures à votre moyenne quotidienne.',
        priority: 'medium',
        actionLabel: 'Voir détails',
      ));
    }

    // 3. Opportunité d'épargne
    final savings = await _calculatePotentialSavings();
    if (savings > 1000) {
      advices.add(Advisory(
        type: 'savings_opportunity',
        title: 'Opportunité d\'Épargne',
        message: 'Vous pourriez épargner ${savings.toStringAsFixed(0)} FCFA ce mois. '
            'Félicitations pour votre gestion !',
        priority: 'low',
        actionLabel: 'Épargner',
      ));
    }

    // 4. Prédiction de revenu
    final pattern = await _incomePredictor.analyzeIncomePattern();
    if (pattern.confidence < 0.5 && pattern.transactionCount > 0) {
      advices.add(Advisory(
        type: 'income_prediction',
        title: 'Revenus Irréguliers Détectés',
        message: 'Vos revenus sont irréguliers. Enregistrez plus de transactions '
            'pour des prédictions plus précises.',
        priority: 'low',
        actionLabel: null,
      ));
    }

    return advices;
  }

  /// Charges approchantes (7 jours)
  Future<List<RecurringCharge>> _getUpcomingCharges() async {
    final now = DateTime.now();
    final sevenDaysLater = now.add(const Duration(days: 7));

    return await (_database.select(_database.recurringCharges)
          ..where((c) =>
              c.isActive.equals(true) &
              c.isPaid.equals(false) &
              c.dueDate.isBiggerThanValue(now) &
              c.dueDate.isSmallerOrEqualValue(sevenDaysLater)))
        .get();
  }

  /// Vérifier vitesse de dépenses
  Future<bool> _isSpendingFast() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    // Dépenses du jour
    final todayExpenses = await (_database.select(_database.transactions)
          ..where((t) =>
              t.type.equals(TransactionType.expense.index) &
              t.date.isBiggerThanValue(startOfDay)))
        .get();

    final todayTotal = todayExpenses.fold<double>(0.0, (sum, t) => sum + t.amount);

    // Moyenne quotidienne (30 derniers jours)
    final last30Days = today.subtract(const Duration(days: 30));
    final recentExpenses = await (_database.select(_database.transactions)
          ..where((t) =>
              t.type.equals(TransactionType.expense.index) &
              t.date.isBiggerThanValue(last30Days)))
        .get();

    if (recentExpenses.isEmpty) return false;

    final avgDaily = recentExpenses.fold<double>(0.0, (sum, t) => sum + t.amount) / 30;

    return todayTotal > (avgDaily * 2) && todayTotal > 1000;
  }

  /// Calculer épargne potentielle
  Future<double> _calculatePotentialSavings() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    // Revenus - Dépenses - Shield
    final incomes = await (_database.select(_database.transactions)
          ..where((t) =>
              t.type.equals(TransactionType.income.index) &
              t.date.isBiggerThanValue(monthStart)))
        .get();

    final expenses = await (_database.select(_database.transactions)
          ..where((t) =>
              t.type.equals(TransactionType.expense.index) &
              t.date.isBiggerThanValue(monthStart)))
        .get();

    // Shield total (charges fixes non payées)
    final unpaidCharges = await (_database.select(_database.recurringCharges)
          ..where((c) => c.isActive.equals(true) & c.isPaid.equals(false)))
        .get();

    final totalIncome = incomes.fold<double>(0.0, (sum, t) => sum + t.amount);
    final totalExpenses = expenses.fold<double>(0.0, (sum, t) => sum + t.amount);
    final shieldTotal = unpaidCharges.fold<double>(0.0, (sum, c) => sum + c.amount);

    final potential = totalIncome - totalExpenses - shieldTotal;
    return potential > 0 ? potential : 0;
  }

  /// Obtenir Daily Cap recommandé
  Future<double> getRecommendedDailyCap() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - now.day + 1;

    // Revenus estimés
    final estimatedIncome = await _incomePredictor.getEstimatedMonthlyIncome();

    // Dépenses actuelles
    final expenses = await (_database.select(_database.transactions)
          ..where((t) =>
              t.type.equals(TransactionType.expense.index) &
              t.date.isBiggerThanValue(monthStart)))
        .get();

    final totalExpenses = expenses.fold<double>(0.0, (sum, t) => sum + t.amount);

    // Shield
    final unpaidCharges = await (_database.select(_database.recurringCharges)
          ..where((c) => c.isActive.equals(true) & c.isPaid.equals(false)))
        .get();

    final shieldTotal = unpaidCharges.fold<double>(0.0, (sum, c) => sum + c.amount);

    // Calcul Daily Cap
    final available = estimatedIncome - totalExpenses - shieldTotal;
    final dailyCap = available / daysRemaining;

    return dailyCap > 0 ? dailyCap : 0;
  }
}

/// Modèle Advisory (Conseil)
class Advisory {
  final String type;
  final String title;
  final String message;
  final String priority; // low, medium, high
  final String? actionLabel;

  Advisory({
    required this.type,
    required this.title,
    required this.message,
    required this.priority,
    this.actionLabel,
  });

  /// Couleur selon priorité
  int get priorityColor {
    switch (priority) {
      case 'high':
        return 0xFFFF5252; // Rouge
      case 'medium':
        return 0xFFFFAB00; // Orange
      default:
        return 0xFF1E88E5; // Bleu
    }
  }

  /// Icône selon type
  String get icon {
    switch (type) {
      case 'shield_reminder':
        return '🛡️';
      case 'velocity_alert':
        return '⚠️';
      case 'savings_opportunity':
        return '💰';
      case 'income_prediction':
        return '📊';
      default:
        return 'ℹ️';
    }
  }
}
