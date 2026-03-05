// ─────────────────────────────────────────────────────────────
// ANALYTICS RESULT (zolt_analytics)
// ─────────────────────────────────────────────────────────────

/// Statistique d'une catégorie de dépenses retournée par zolt_analytics.
class CategoryStat {
  final String category;
  final double total;
  final double pctOfBudget;   // % du total dépenses
  final int txCount;
  final double avgPerTx;
  final double? vsHistoryPct; // delta vs moyenne cycles précédents

  const CategoryStat({
    required this.category,
    required this.total,
    required this.pctOfBudget,
    required this.txCount,
    required this.avgPerTx,
    this.vsHistoryPct,
  });

  factory CategoryStat.fromJson(Map<String, dynamic> j) {
    return CategoryStat(
      category:     j['category']       as String? ?? '',
      total:        (j['total']         as num?)?.toDouble() ?? 0,
      pctOfBudget:  (j['pct_of_budget'] as num?)?.toDouble() ?? 0,
      txCount:      (j['tx_count']      as num?)?.toInt()    ?? 0,
      avgPerTx:     (j['avg_per_tx']    as num?)?.toDouble() ?? 0,
      vsHistoryPct: (j['vs_history_pct'] as num?)?.toDouble(),
    );
  }
}

/// Résultat complet de zolt_analytics.
class AnalyticsResult {
  final double totalExpenses;
  final double totalIncome;
  final double net;               // totalIncome - totalExpenses
  final List<CategoryStat> byCategory;
  final double dailyAverage;
  final Map<String, int>? peakDay; // {year, month, day}
  final double peakDayAmount;
  final double savingsRate;       // (income - expenses) / income, clamped -1..1
  final double? prevExpenses;     // comparaison période précédente
  final double? prevIncome;
  final double? deltaPct;

  const AnalyticsResult({
    required this.totalExpenses,
    required this.totalIncome,
    required this.net,
    required this.byCategory,
    required this.dailyAverage,
    this.peakDay,
    required this.peakDayAmount,
    required this.savingsRate,
    this.prevExpenses,
    this.prevIncome,
    this.deltaPct,
  });

  factory AnalyticsResult.fromJson(Map<String, dynamic> j) {
    Map<String, int>? peak;
    if (j['peak_day'] != null) {
      final d = j['peak_day'] as Map<String, dynamic>;
      peak = {'year': (d['year'] as num).toInt(), 'month': (d['month'] as num).toInt(), 'day': (d['day'] as num).toInt()};
    }
    final comp = j['comparison'] as Map<String, dynamic>?;
    return AnalyticsResult(
      totalExpenses: (j['total_expenses'] as num?)?.toDouble() ?? 0,
      totalIncome:   (j['total_income']   as num?)?.toDouble() ?? 0,
      net:           (j['net']            as num?)?.toDouble() ?? 0,
      byCategory:    (j['by_category'] as List? ?? [])
          .map((c) => CategoryStat.fromJson(c as Map<String, dynamic>))
          .toList(),
      dailyAverage:  (j['daily_average']    as num?)?.toDouble() ?? 0,
      peakDay:       peak,
      peakDayAmount: (j['peak_day_amount']  as num?)?.toDouble() ?? 0,
      savingsRate:   (j['savings_rate']     as num?)?.toDouble() ?? 0,
      prevExpenses:  (comp?['previous_expenses'] as num?)?.toDouble(),
      prevIncome:    (comp?['previous_income']   as num?)?.toDouble(),
      deltaPct:      (comp?['delta_pct']         as num?)?.toDouble(),
    );
  }
}

// ─────────────────────────────────────────────────────────────

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

/// Sortie moteur V2 — ajoute income_prediction + notifications (Rust v1.2+).
class ZoltEngineOutputV2 extends ZoltEngineOutput {
  final IncomePredictionResult? incomePrediction;
  final List<NotificationTrigger> notifications;

  const ZoltEngineOutputV2({
    required super.deterministic,
    required super.profile,
    super.prediction,
    required super.messages,
    required super.suggestions,
    required super.anomalies,
    this.incomePrediction,
    this.notifications = const [],
  });

  factory ZoltEngineOutputV2.fromJson(Map<String, dynamic> j) {
    final base = ZoltEngineOutput.fromJson(j);
    return ZoltEngineOutputV2(
      deterministic:     base.deterministic,
      profile:           base.profile,
      prediction:        base.prediction,
      messages:          base.messages,
      suggestions:       base.suggestions,
      anomalies:         base.anomalies,
      incomePrediction:  j['income_prediction'] != null
          ? IncomePredictionResult.fromJson(j['income_prediction'] as Map<String, dynamic>)
          : null,
      notifications: (j['notifications'] as List? ?? [])
          .map((n) => NotificationTrigger.fromJson(n as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SESSION STATE (zolt_session) — v1.3
// ─────────────────────────────────────────────────────────────

/// Résultat complet de zolt_session : engine + health + cycle + charges + triage + integrity.
class SessionState {
  final ZoltEngineOutputV2 engine;
  final HealthScore health;
  final CycleDetectionResult cycle;
  final List<ChargeTrackingResult> chargeTracking;
  final List<TriageResult> triage;
  final IntegrityReport integrity;
  final int computedAtEpoch;

  const SessionState({
    required this.engine,
    required this.health,
    required this.cycle,
    required this.chargeTracking,
    required this.triage,
    required this.integrity,
    required this.computedAtEpoch,
  });

  factory SessionState.fromJson(Map<String, dynamic> j) {
    return SessionState(
      engine:          ZoltEngineOutputV2.fromJson(j['engine'] as Map<String, dynamic>),
      health:          HealthScore.fromJson(j['health'] as Map<String, dynamic>),
      cycle:           CycleDetectionResult.fromJson(j['cycle'] as Map<String, dynamic>),
      chargeTracking:  (j['charge_tracking'] as List? ?? [])
          .map((c) => ChargeTrackingResult.fromJson(c as Map<String, dynamic>))
          .toList(),
      triage:          (j['triage'] as List? ?? [])
          .map((t) => TriageResult.fromJson(t as Map<String, dynamic>))
          .toList(),
      integrity:       IntegrityReport.fromJson(j['integrity'] as Map<String, dynamic>),
      computedAtEpoch: (j['computed_at_epoch'] as num?)?.toInt() ?? 0,
    );
  }

  /// Accès rapide au budget journalier
  double get dailyBudget => engine.deterministic.dailyBudget;

  /// Accès rapide aux messages conversationnels
  List<ConversationalMessage> get messages => engine.messages;

  /// Accès rapide à la prédiction de fin de cycle
  EndOfCyclePrediction? get prediction => engine.prediction;
}

// ─────────────────────────────────────────────────────────────
// HEALTH SCORE
// ─────────────────────────────────────────────────────────────

/// Score de santé financière 0-100 avec 4 dimensions.
class HealthScore {
  final int score;        // 0-100 global
  final String grade;     // Excellent | Good | Fair | Poor | Critical
  final int budget;       // dimension respect budget journalier
  final int savings;      // dimension progression épargne
  final int stability;    // dimension régularité dépenses
  final int prediction;   // dimension trajectoire fin de cycle
  final int trend;        // delta vs cycle précédent (-100..+100)
  final String message;

  const HealthScore({
    required this.score,
    required this.grade,
    required this.budget,
    required this.savings,
    required this.stability,
    required this.prediction,
    required this.trend,
    required this.message,
  });

  factory HealthScore.fromJson(Map<String, dynamic> j) {
    return HealthScore(
      score:      (j['score']      as num?)?.toInt() ?? 0,
      grade:      j['grade']       as String? ?? 'Poor',
      budget:     (j['budget']     as num?)?.toInt() ?? 0,
      savings:    (j['savings']    as num?)?.toInt() ?? 0,
      stability:  (j['stability']  as num?)?.toInt() ?? 0,
      prediction: (j['prediction'] as num?)?.toInt() ?? 0,
      trend:      (j['trend']      as num?)?.toInt() ?? 0,
      message:    j['message']     as String? ?? '',
    );
  }

  /// Vrai si la santé est bonne (Good ou Excellent)
  bool get isGood => grade == 'Excellent' || grade == 'Good';

  /// Couleur associée au grade (code hex)
  String get gradeColor {
    switch (grade) {
      case 'Excellent': return '#69F0AE';
      case 'Good':      return '#40C4FF';
      case 'Fair':      return '#FFAB40';
      case 'Poor':      return '#FF5252';
      case 'Critical':  return '#D50000';
      default:          return '#FFAB40';
    }
  }

  /// Emoji associé au grade
  String get gradeEmoji {
    switch (grade) {
      case 'Excellent': return '🌟';
      case 'Good':      return '✅';
      case 'Fair':      return '⚠️';
      case 'Poor':      return '🔴';
      case 'Critical':  return '🚨';
      default:          return '❓';
    }
  }
}

// ─────────────────────────────────────────────────────────────
// CYCLE DETECTION
// ─────────────────────────────────────────────────────────────

/// État du cycle courant détecté par le moteur.
class CycleDetectionResult {
  final String status;      // Active | EndingSoon | ShouldClose | ShouldInit
  final int currentDay;
  final int totalDays;
  final double pctElapsed;  // 0.0..1.0
  final Map<String, dynamic>? nextInputTemplate;

  const CycleDetectionResult({
    required this.status,
    required this.currentDay,
    required this.totalDays,
    required this.pctElapsed,
    this.nextInputTemplate,
  });

  factory CycleDetectionResult.fromJson(Map<String, dynamic> j) {
    // Le status peut être un objet {"EndingSoon":{"days":2}} ou une string "Active"
    String statusStr = 'Active';
    final rawStatus = j['status'];
    if (rawStatus is String) {
      statusStr = rawStatus;
    } else if (rawStatus is Map) {
      statusStr = rawStatus.keys.first;
    }
    return CycleDetectionResult(
      status:            statusStr,
      currentDay:        (j['current_day']  as num?)?.toInt() ?? 1,
      totalDays:         (j['total_days']   as num?)?.toInt() ?? 30,
      pctElapsed:        (j['pct_elapsed']  as num?)?.toDouble() ?? 0.0,
      nextInputTemplate: j['next_input_template'] as Map<String, dynamic>?,
    );
  }

  bool get isEndingSoon  => status == 'EndingSoon';
  bool get shouldClose   => status == 'ShouldClose';
  bool get shouldInit    => status == 'ShouldInit';

  int get daysRemaining => (totalDays - currentDay).clamp(0, totalDays);
}

// ─────────────────────────────────────────────────────────────
// CHARGE TRACKING
// ─────────────────────────────────────────────────────────────

/// Suivi d'une charge récurrente avec alertes contextuelles.
class ChargeTrackingResult {
  final String chargeId;
  final String chargeName;
  final double totalAmount;
  final double paidAmount;
  final double remaining;
  final bool isFullyPaid;
  final bool isOverdue;
  final int daysUntilDue;          // négatif = en retard
  final double dailyReserveNeeded;
  final ConversationalMessage? alert;

  const ChargeTrackingResult({
    required this.chargeId,
    required this.chargeName,
    required this.totalAmount,
    required this.paidAmount,
    required this.remaining,
    required this.isFullyPaid,
    required this.isOverdue,
    required this.daysUntilDue,
    required this.dailyReserveNeeded,
    this.alert,
  });

  factory ChargeTrackingResult.fromJson(Map<String, dynamic> j) {
    return ChargeTrackingResult(
      chargeId:           j['charge_id']             as String? ?? '',
      chargeName:         j['charge_name']            as String? ?? '',
      totalAmount:        (j['total_amount']          as num?)?.toDouble() ?? 0,
      paidAmount:         (j['paid_amount']           as num?)?.toDouble() ?? 0,
      remaining:          (j['remaining']             as num?)?.toDouble() ?? 0,
      isFullyPaid:        j['is_fully_paid']          as bool? ?? false,
      isOverdue:          j['is_overdue']             as bool? ?? false,
      daysUntilDue:       (j['days_until_due']        as num?)?.toInt()    ?? 0,
      dailyReserveNeeded: (j['daily_reserve_needed']  as num?)?.toDouble() ?? 0,
      alert: j['alert'] != null
          ? ConversationalMessage.fromJson(j['alert'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TRIAGE RESULT
// ─────────────────────────────────────────────────────────────

/// Résultat d'enrichissement d'une transaction SMS en attente.
class TriageResult {
  final String id;
  final Map<String, dynamic> classification;  // tx_type, category, confidence, reason
  final bool suggestIgnore;
  final String? ignoreReason;
  final Map<String, dynamic>? budgetImpact;   // pct_daily_budget, remaining_after, would_exceed

  const TriageResult({
    required this.id,
    required this.classification,
    required this.suggestIgnore,
    this.ignoreReason,
    this.budgetImpact,
  });

  factory TriageResult.fromJson(Map<String, dynamic> j) {
    return TriageResult(
      id:             j['id']             as String? ?? '',
      classification: j['classification'] as Map<String, dynamic>? ?? {},
      suggestIgnore:  j['suggest_ignore'] as bool? ?? false,
      ignoreReason:   j['ignore_reason']  as String?,
      budgetImpact:   j['budget_impact']  as Map<String, dynamic>?,
    );
  }

  String get category => classification['category'] as String? ?? 'autre';
  double get confidence => (classification['confidence'] as num?)?.toDouble() ?? 0.0;
  bool get wouldExceedBudget => budgetImpact?['would_exceed'] as bool? ?? false;
}

// ─────────────────────────────────────────────────────────────
// INTEGRITY REPORT
// ─────────────────────────────────────────────────────────────

class IntegrityReport {
  final bool isValid;
  final List<Map<String, dynamic>> errors;   // {code, message, fatal}
  final List<String> warnings;
  final List<String> autoFixed;
  final int dataConfidence;  // 0-100

  const IntegrityReport({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.autoFixed,
    required this.dataConfidence,
  });

  factory IntegrityReport.fromJson(Map<String, dynamic> j) {
    return IntegrityReport(
      isValid:        j['is_valid']        as bool? ?? true,
      errors:         (j['errors']         as List? ?? []).cast<Map<String, dynamic>>(),
      warnings:       (j['warnings']       as List? ?? []).cast<String>(),
      autoFixed:      (j['auto_fixed']     as List? ?? []).cast<String>(),
      dataConfidence: (j['data_confidence'] as num?)?.toInt() ?? 100,
    );
  }

  bool get hasFatalError => errors.any((e) => e['fatal'] as bool? ?? false);
}

// ─────────────────────────────────────────────────────────────
// NOTIFICATION TRIGGER
// ─────────────────────────────────────────────────────────────

/// Notification décidée par le moteur Rust. Flutter se contente d'exécuter.
class NotificationTrigger {
  final String channel;    // BudgetAlerts | Reminders | SmsParsing | RecurringCharges
  final String priority;   // High | Normal | Low
  final String title;
  final String body;
  final int delaySecs;
  final String dedupKey;

  const NotificationTrigger({
    required this.channel,
    required this.priority,
    required this.title,
    required this.body,
    required this.delaySecs,
    required this.dedupKey,
  });

  factory NotificationTrigger.fromJson(Map<String, dynamic> j) {
    return NotificationTrigger(
      channel:   j['channel']    as String? ?? 'Reminders',
      priority:  j['priority']   as String? ?? 'Normal',
      title:     j['title']      as String? ?? '',
      body:      j['body']       as String? ?? '',
      delaySecs: (j['delay_secs'] as num?)?.toInt() ?? 0,
      dedupKey:  j['dedup_key']  as String? ?? '',
    );
  }

  bool get isHigh => priority == 'High';
}

// ─────────────────────────────────────────────────────────────
// INCOME PREDICTION RESULT
// ─────────────────────────────────────────────────────────────

class IncomePredictionResult {
  final double predictedAmount;
  final DateTime? predictedDate;
  final double confidence;
  final String patternDescription;
  final int basedOnCycles;

  const IncomePredictionResult({
    required this.predictedAmount,
    required this.predictedDate,
    required this.confidence,
    required this.patternDescription,
    required this.basedOnCycles,
  });

  factory IncomePredictionResult.fromJson(Map<String, dynamic> j) {
    DateTime? date;
    if (j['predicted_date'] != null) {
      final d = j['predicted_date'] as Map<String, dynamic>;
      date = DateTime(d['year'] as int, d['month'] as int, d['day'] as int);
    }
    return IncomePredictionResult(
      predictedAmount:     (j['predicted_amount']     as num).toDouble(),
      predictedDate:       date,
      confidence:          (j['confidence']           as num).toDouble(),
      patternDescription:  j['pattern_description']   as String? ?? '',
      basedOnCycles:       (j['based_on_cycles']      as num).toInt(),
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
