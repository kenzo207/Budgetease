import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/engine_provider.dart';

part 'budget_provider.g.dart';

/// Provider du budget quotidien.
///
/// Délègue à [engineDailyBudgetProvider] (qui utilise zolt_session ou fallback Dart).
/// Plus de double-call : le moteur est calculé une seule fois via engine_provider.
@riverpod
Future<double> budgetProvider(BudgetProviderRef ref) async {
  return ref.watch(engineDailyBudgetProvider.future);
}
