// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$budgetProviderHash() => r'1ac4c04412b8beaac1002bdca623009f513a769b';

/// Provider du budget quotidien.
///
/// Délègue à [engineDailyBudgetProvider] (qui utilise zolt_session ou fallback Dart).
/// Plus de double-call : le moteur est calculé une seule fois via engine_provider.
///
/// Copied from [budgetProvider].
@ProviderFor(budgetProvider)
final budgetProviderProvider = AutoDisposeFutureProvider<double>.internal(
  budgetProvider,
  name: r'budgetProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BudgetProviderRef = AutoDisposeFutureProviderRef<double>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
