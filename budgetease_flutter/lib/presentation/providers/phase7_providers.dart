import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart'; // Insight type
import '../../domain/services/income_predictor_service.dart';
import '../../domain/services/insights_service.dart';
import '../../domain/services/behavioral_profiler_service.dart';
import '../../domain/services/advisory_service.dart';
import 'database_provider.dart';

// ========== Database Provider ==========
// Le provider singleton est défini dans database_provider.dart
// Il est réexporté ici pour compatibilité avec les imports existants.
export 'database_provider.dart' show databaseProvider;

// ========== Service Providers ==========

final incomePredictorServiceProvider = Provider<IncomePredictorService>((ref) {
  return IncomePredictorService(ref: ref);
});

final insightsServiceProvider = Provider<InsightsService>((ref) {
  final database = ref.watch(databaseProvider);
  return InsightsService(database: database, ref: ref);
});

final behavioralProfilerServiceProvider = Provider<BehavioralProfilerService>((ref) {
  return BehavioralProfilerService(ref: ref);
});

final advisoryServiceProvider = Provider<AdvisoryService>((ref) {
  return AdvisoryService(ref: ref);
});

// ========== Income Predictor Providers ==========

/// Prédiction du prochain revenu (Rust)
final incomePredictionProvider = FutureProvider<IncomePrediction?>((ref) async {
  final service = ref.watch(incomePredictorServiceProvider);
  return await service.predictNextIncome();
});

/// Revenu estimé (réel ou prédit)
final estimatedMonthlyIncomeProvider = FutureProvider<double>((ref) async {
  final service = ref.watch(incomePredictorServiceProvider);
  return await service.getEstimatedMonthlyIncome();
});

/// Prochaine date de revenu prédite
final nextIncomeDateProvider = FutureProvider<DateTime?>((ref) async {
  final service = ref.watch(incomePredictorServiceProvider);
  final pred = await service.predictNextIncome();
  return pred?.predictedDate;
});

/// Jours jusqu'au prochain revenu
final daysUntilNextIncomeProvider = FutureProvider<int?>((ref) async {
  final service = ref.watch(incomePredictorServiceProvider);
  final pred = await service.predictNextIncome();
  return pred?.daysUntilNext;
});

// ========== Insights Providers ==========

/// Insight Ghost Money actif
final ghostMoneyInsightProvider = FutureProvider<Insight?>((ref) async {
  final service = ref.watch(insightsServiceProvider);
  return await service.getOrCreateGhostMoneyInsight();
});

/// Tous les insights actifs
final activeInsightsProvider = FutureProvider<List<Insight>>((ref) async {
  final service = ref.watch(insightsServiceProvider);
  return await service.getActiveInsights();
});

// ========== Behavioral Profile Providers ==========

/// Profil comportemental
final behavioralProfileProvider = FutureProvider<BehavioralReport>((ref) async {
  final service = ref.watch(behavioralProfilerServiceProvider);
  return await service.getOrCreateProfile();
});

/// Est dépensier du soir
final isEveningSpenderProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(behavioralProfilerServiceProvider);
  return await service.isEveningSpender();
});

/// Heure de dépense préférée
final preferredSpendingHourProvider = FutureProvider<int?>((ref) async {
  final service = ref.watch(behavioralProfilerServiceProvider);
  return await service.getPreferredSpendingHour();
});

// ========== Advisory Providers ==========

/// Tous les conseils actifs
final activeAdvisoriesProvider = FutureProvider<List<Advisory>>((ref) async {
  final service = ref.watch(advisoryServiceProvider);
  return await service.getAdvice();
});

/// Daily Cap recommandé (= dailyBudget Rust)
final recommendedDailyCapProvider = FutureProvider<double>((ref) async {
  final service = ref.watch(advisoryServiceProvider);
  return await service.getRecommendedDailyCap();
});
