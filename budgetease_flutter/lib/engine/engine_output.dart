/// Sortie complète du moteur Zolt (désérialisée depuis JSON Rust).
class ZoltEngineOutput {
  final DeterministicResult deterministic;
  final BehavioralProfile profile;
  final EndOfCyclePrediction? prediction;
  final List<ConversationalMessage> messages;
  final List<Map<String, dynamic>> suggestions;
  final List<Map<String, dynamic>> anomalies;

  const ZoltEngineOutput({
    required this.deterministic,
    required this.profile,
    this.prediction,
    required this.messages,
    required this.suggestions,
    required this.anomalies,
  });

  factory ZoltEngineOutput.fromJson(Map<String, dynamic> j) {
    return ZoltEngineOutput(
      deterministic: DeterministicResult.fromJson(
          j['deterministic'] as Map<String, dynamic>),
      profile: BehavioralProfile.fromJson(
          j['profile'] as Map<String, dynamic>),
      prediction: j['prediction'] != null
          ? EndOfCyclePrediction.fromJson(
              j['prediction'] as Map<String, dynamic>)
          : null,
      messages: (j['messages'] as List? ?? [])
          .map((m) => ConversationalMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
      suggestions: (j['suggestions'] as List? ?? [])
          .map((s) => s as Map<String, dynamic>)
          .toList(),
      anomalies: (j['anomalies'] as List? ?? [])
          .map((a) => a as Map<String, dynamic>)
          .toList(),
    );
  }
}

/// Résultat du moteur déterministe (Couche 1).
class DeterministicResult {
  final double totalBalance;
  final double committedMass;   // épargne + transport + charges
  final double freeMass;        // ce qui est libre
  final int daysRemaining;
  final double dailyBudget;     // B_j
  final double spentToday;
  final double remainingToday;  // B_j - dépenses du jour
  final double transportReserve;
  final double chargesReserve;

  const DeterministicResult({
    required this.totalBalance,
    required this.committedMass,
    required this.freeMass,
    required this.daysRemaining,
    required this.dailyBudget,
    required this.spentToday,
    required this.remainingToday,
    required this.transportReserve,
    required this.chargesReserve,
  });

  factory DeterministicResult.fromJson(Map<String, dynamic> j) {
    return DeterministicResult(
      totalBalance:     (j['total_balance']     as num).toDouble(),
      committedMass:    (j['committed_mass']    as num).toDouble(),
      freeMass:         (j['free_mass']         as num).toDouble(),
      daysRemaining:    (j['days_remaining']    as num).toInt(),
      dailyBudget:      (j['daily_budget']      as num).toDouble(),
      spentToday:       (j['spent_today']       as num).toDouble(),
      remainingToday:   (j['remaining_today']   as num).toDouble(),
      transportReserve: (j['transport_reserve'] as num).toDouble(),
      chargesReserve:   (j['charges_reserve']   as num).toDouble(),
    );
  }
}

/// Profil comportemental (Module A).
class BehavioralProfile {
  final String rhythm;            // Linear | Frontal | Terminal | Erratic
  final double volatilityScore;   // 0.0 → 1.0
  final double savingsAchievement;// ratio moyen atteinte épargne
  final int cyclesObserved;
  final double hiddenChargesTotal;

  const BehavioralProfile({
    required this.rhythm,
    required this.volatilityScore,
    required this.savingsAchievement,
    required this.cyclesObserved,
    required this.hiddenChargesTotal,
  });

  factory BehavioralProfile.fromJson(Map<String, dynamic> j) {
    return BehavioralProfile(
      rhythm:               j['rhythm'] as String? ?? 'Linear',
      volatilityScore:      (j['volatility_score']    as num?)?.toDouble() ?? 0.0,
      savingsAchievement:   (j['savings_achievement'] as num?)?.toDouble() ?? 1.0,
      cyclesObserved:       (j['cycles_observed']     as num?)?.toInt()    ?? 0,
      hiddenChargesTotal:   (j['hidden_charges_total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Libellé du rythme en français
  String get rhythmLabel {
    switch (rhythm) {
      case 'Frontal':  return 'Dépensier en début de mois';
      case 'Terminal': return 'Dépensier en fin de mois';
      case 'Erratic':  return 'Irrégulier';
      default:         return 'Régulier';
    }
  }
}

/// Prédiction de fin de cycle (Module B).
class EndOfCyclePrediction {
  final double projectedFinalBalance;
  final double projectedDeficit;     // 0 si pas de déficit
  final double confidence;           // 0.0..1.0
  final String alertLevel;           // Info | Warning | Critical | Positive

  const EndOfCyclePrediction({
    required this.projectedFinalBalance,
    required this.projectedDeficit,
    required this.confidence,
    required this.alertLevel,
  });

  factory EndOfCyclePrediction.fromJson(Map<String, dynamic> j) {
    return EndOfCyclePrediction(
      projectedFinalBalance: (j['projected_final_balance'] as num).toDouble(),
      projectedDeficit:      (j['projected_deficit']       as num).toDouble(),
      confidence:            (j['confidence']              as num).toDouble(),
      alertLevel:            j['alert_level'] as String? ?? 'Info',
    );
  }

  bool get isDeficit => projectedDeficit > 0;
  bool get isReliable => confidence >= 0.30;
}

/// Message conversationnel (Couche 3).
class ConversationalMessage {
  final String level;    // Info | Warning | Critical | Positive
  final String title;
  final String body;
  final int? ttlDays;

  const ConversationalMessage({
    required this.level,
    required this.title,
    required this.body,
    this.ttlDays,
  });

  factory ConversationalMessage.fromJson(Map<String, dynamic> j) {
    return ConversationalMessage(
      level:   j['level'] as String? ?? 'Info',
      title:   j['title'] as String? ?? '',
      body:    j['body']  as String? ?? '',
      ttlDays: j['ttl_days'] as int?,
    );
  }
}
