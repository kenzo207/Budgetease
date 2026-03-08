import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../engine/engine_output.dart';
import '../../presentation/providers/engine_provider.dart';

/// Service de conseils adaptatifs — lit uniquement les données du moteur Rust.
///
/// Toutes les valeurs (charges, vitesse, épargne, prédiction) proviennent du
/// [SessionState] retourné par [zoltEngineProviderProvider].
/// Aucun calcul n'est effectué côté Dart.
class AdvisoryService {
  final Ref _ref;

  AdvisoryService({required Ref ref}) : _ref = ref;

  /// Obtenir tous les conseils actifs depuis le SessionState Rust.
  Future<List<Advisory>> getAdvice() async {
    final session = await _ref.read(zoltEngineProviderProvider.future);
    final advices = <Advisory>[];

    // ── 1. Charges imminentes (ChargeTracker Rust) ───────────────
    final urgentCharges = session.chargeTracking
        .where((c) => !c.isFullyPaid && c.daysUntilDue <= 7)
        .toList();

    if (urgentCharges.isNotEmpty) {
      final totalAmount = urgentCharges.fold<double>(0, (s, c) => s + c.remaining);
      advices.add(Advisory(
        type: 'shield_reminder',
        title: 'Échéances Approchantes',
        message: 'Vous avez ${urgentCharges.length} charge(s) à payer bientôt '
            '(${totalAmount.toStringAsFixed(0)} FCFA).',
        priority: 'high',
        actionLabel: 'Voir les charges',
      ));
    }

    // ── 2. Alertes des charges en retard ─────────────────────────
    final overdueCharges = session.chargeTracking.where((c) => c.isOverdue).toList();
    if (overdueCharges.isNotEmpty) {
      advices.add(Advisory(
        type: 'overdue_charge',
        title: 'Charges en Retard',
        message: '${overdueCharges.length} charge(s) dépassée(s). Réglez-les dès que possible.',
        priority: 'high',
        actionLabel: 'Voir les charges',
      ));
    }

    // ── 3. Messages d'alerte du moteur (niveau Warning/Critical) ──
    for (final msg in session.messages) {
      if (msg.level == 'Warning' || msg.level == 'Critical') {
        advices.add(Advisory(
          type: 'engine_alert',
          title: msg.title,
          message: msg.body,
          priority: msg.level == 'Critical' ? 'high' : 'medium',
          actionLabel: null,
        ));
      }
    }

    // ── 4. Prédiction fin de cycle ────────────────────────────────
    final prediction = session.prediction;
    if (prediction != null && prediction.isDeficit && prediction.isReliable) {
      advices.add(Advisory(
        type: 'end_of_cycle_risk',
        title: 'Risque de Déficit',
        message: 'Projection : déficit de ${prediction.projectedDeficit.toStringAsFixed(0)} FCFA '
            'en fin de cycle.',
        priority: 'medium',
        actionLabel: 'Voir analyse',
      ));
    }

    // ── 5. Opportunité d'épargne (freeMass élevée) ────────────────
    final freeMass = session.engine.deterministic.freeMass;
    if (freeMass > 1000) {
      advices.add(Advisory(
        type: 'savings_opportunity',
        title: "Opportunité d'Épargne",
        message: 'Vous avez ${freeMass.toStringAsFixed(0)} FCFA de marge libre ce cycle.',
        priority: 'low',
        actionLabel: 'Épargner',
      ));
    }

    // ── 6. Prédiction de revenu peu fiable ───────────────────────
    final incomePred = session.engine.incomePrediction;
    if (incomePred != null && incomePred.confidence < 0.30) {
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

  /// Daily Cap recommandé = budget journalier calculé par le moteur Rust.
  Future<double> getRecommendedDailyCap() async {
    final session = await _ref.read(zoltEngineProviderProvider.future);
    return session.dailyBudget;
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
        return 0xFFFF5252;
      case 'medium':
        return 0xFFFFAB00;
      default:
        return 0xFF1E88E5;
    }
  }

  /// Icône selon type
  IconData get icon {
    switch (type) {
      case 'shield_reminder':
        return Icons.verified_user_outlined;
      case 'overdue_charge':
        return Icons.warning_amber_rounded;
      case 'velocity_alert':
      case 'engine_alert':
        return Icons.report_problem_outlined;
      case 'end_of_cycle_risk':
        return Icons.trending_down;
      case 'savings_opportunity':
        return Icons.savings_outlined;
      case 'income_prediction':
        return Icons.analytics_outlined;
      default:
        return Icons.info_outline;
    }
  }
}
