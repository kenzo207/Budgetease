import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../domain/services/income_predictor_service.dart';
import '../../domain/services/insights_service.dart';
import '../../domain/services/behavioral_profiler_service.dart';
import '../../domain/services/advisory_service.dart';

// ========== Database Provider ==========

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// ========== Service Providers ==========

final incomePredictorServiceProvider = Provider<IncomePredictorService>((ref) {
  final database = ref.watch(databaseProvider);
  return IncomePredictorService(database: database);
});

final insightsServiceProvider = Provider<InsightsService>((ref) {
  final database = ref.watch(databaseProvider);
  return InsightsService(database: database);
});

final behavioralProfilerServiceProvider = Provider<BehavioralProfilerService>((ref) {
  final database = ref.watch(databaseProvider);
  return BehavioralProfilerService(database: database);
});

final advisoryServiceProvider = Provider<AdvisoryService>((ref) {
  final database = ref.watch(databaseProvider);
  final profiler = ref.watch(behavioralProfilerServiceProvider);
  final incomePredictor = ref.watch(incomePredictorServiceProvider);
  
  return AdvisoryService(
    database: database,
    profiler: profiler,
    incomePredictor: incomePredictor,
  );
});

// ========== Income Predictor Providers ==========

/// Pattern d'analyse des revenus
final incomePatternProvider = FutureProvider<IncomeAnalysis>((ref) async {
  final service = ref.watch(incomePredictorServiceProvider);
  return await service.analyzeIncomePattern();
});

/// Prédiction mensuelle
final monthlyIncomePredictionProvider = FutureProvider<double>((ref) async {
  final service = ref.watch(incomePredictorServiceProvider);
  return await service.predictMonthlyIncome();
});

/// Revenu estimé (réel ou prédit)
final estimatedMonthlyIncomeProvider = FutureProvider<double>((ref) async {
  final service = ref.watch(incomePredictorServiceProvider);
  return await service.getEstimatedMonthlyIncome();
});

/// Prochaine date de revenu
final nextIncomeDateProvider = FutureProvider<DateTime?>((ref) async {
  final service = ref.watch(incomePredictorServiceProvider);
  return await service.predictNextIncomeDate();
});

/// Jours jusqu'au prochain revenu
final daysUntilNextIncomeProvider = FutureProvider<int?>((ref) async {
  final service = ref.watch(incomePredictorServiceProvider);
  return await service.getDaysUntilNextIncome();
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

/// Daily Cap recommandé
final recommendedDailyCapProvider = FutureProvider<double>((ref) async {
  final service = ref.watch(advisoryServiceProvider);
  return await service.getRecommendedDailyCap();
});
