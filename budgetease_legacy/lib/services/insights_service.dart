import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/ghost_money_insight.dart';
import 'database_service.dart';
import 'calculation_service.dart';

class InsightsService {
  /// Seuil pour considérer une dépense comme "micro"
  static const double microExpenseThreshold = 500.0;
  
  /// Nombre minimum de transactions pour déclencher l'insight
  static const int minTransactionCount = 5;
  
  /// Impact minimum (en %) pour déclencher l'insight
  static const double minImpactPercentage = 5.0;

  /// Détecte les patterns de micro-dépenses répétées (Argent Fantôme)
  static GhostMoneyInsight? detectGhostMoney() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final transactions = DatabaseService.transactions.values.toList();

    // Filtrer les micro-dépenses de la dernière semaine
    final microExpenses = transactions
        .where((t) =>
            t.type == 'expense' &&
            t.amount <= microExpenseThreshold &&
            t.date.isAfter(weekAgo))
        .toList();

    // Seuil de déclenchement : au moins 5 transactions
    if (microExpenses.length < minTransactionCount) return null;

    final total = microExpenses.fold(0.0, (sum, t) => sum + t.amount);
    final categories = microExpenses.map((t) => t.category).toSet().toList();

    // Calculer l'impact relatif par rapport à l'argent disponible
    final ard = _getRealAvailableBudget();
    
    // Si pas d'argent disponible, pas d'insight pertinent
    if (ard <= 0) return null;
    
    final impact = (total / ard) * 100;

    // Ne déclencher que si impact > seuil minimum
    if (impact < minImpactPercentage) return null;

    return GhostMoneyInsight(
      id: const Uuid().v4(),
      detectedAt: now,
      totalAmount: total,
      transactionCount: microExpenses.length,
      categoryNames: categories,
      percentageOfAvailable: impact,
    );
  }

  /// Récupère ou crée l'insight actuel
  static GhostMoneyInsight? getOrCreateInsight() {
    final box = DatabaseService.ghostMoneyInsights;

    // Nettoyer les anciens insights (> 7 jours)
    final toDelete = box.values.where((i) => !i.isRelevant).toList();
    for (var insight in toDelete) {
      insight.delete();
    }

    // Vérifier s'il existe déjà un insight récent
    final existing = box.values.where((i) => i.isRelevant).toList();
    if (existing.isNotEmpty) {
      return existing.first;
    }

    // Sinon, détecter un nouveau pattern
    final newInsight = detectGhostMoney();
    if (newInsight != null) {
      box.add(newInsight);
    }

    return newInsight;
  }

  /// Calcule l'argent réellement disponible
  static double _getRealAvailableBudget() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final transactions = DatabaseService.transactions.values.toList();
    
    final totals = CalculationService.getPeriodTotals(transactions, startOfMonth, now);
    final balance = totals['balance'] ?? 0;
    
    return balance;
  }

  /// Obtient tous les insights actifs
  static List<GhostMoneyInsight> getActiveInsights() {
    final box = DatabaseService.ghostMoneyInsights;
    return box.values.where((i) => i.isRelevant).toList();
  }

  /// Supprime un insight spécifique
  static Future<void> dismissInsight(GhostMoneyInsight insight) async {
    await insight.delete();
  }
}
