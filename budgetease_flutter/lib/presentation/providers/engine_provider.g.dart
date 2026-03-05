// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engine_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$engineDailyBudgetHash() => r'f8a5bc6764b587d3cd544de2f858f4c35ec7570f';

/// Budget journalier
///
/// Copied from [engineDailyBudget].
@ProviderFor(engineDailyBudget)
final engineDailyBudgetProvider = AutoDisposeFutureProvider<double>.internal(
  engineDailyBudget,
  name: r'engineDailyBudgetProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$engineDailyBudgetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EngineDailyBudgetRef = AutoDisposeFutureProviderRef<double>;
String _$engineMessagesHash() => r'a2b9e8e9b749dba6e4705fab3e23d50d9ff0bfb0';

/// Messages conversationnels du moteur
///
/// Copied from [engineMessages].
@ProviderFor(engineMessages)
final engineMessagesProvider =
    AutoDisposeFutureProvider<List<eng.ConversationalMessage>>.internal(
  engineMessages,
  name: r'engineMessagesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$engineMessagesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EngineMessagesRef
    = AutoDisposeFutureProviderRef<List<eng.ConversationalMessage>>;
String _$enginePredictionHash() => r'8127f23fd26181dc798bdadc7bdb08c9f5bcd0ed';

/// Prédiction de fin de cycle
///
/// Copied from [enginePrediction].
@ProviderFor(enginePrediction)
final enginePredictionProvider =
    AutoDisposeFutureProvider<eng.EndOfCyclePrediction?>.internal(
  enginePrediction,
  name: r'enginePredictionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$enginePredictionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EnginePredictionRef
    = AutoDisposeFutureProviderRef<eng.EndOfCyclePrediction?>;
String _$engineHealthScoreHash() => r'4324433d71e3559bdbf763a27314072f33496015';

/// Score de santé financière
///
/// Copied from [engineHealthScore].
@ProviderFor(engineHealthScore)
final engineHealthScoreProvider =
    AutoDisposeFutureProvider<eng.HealthScore>.internal(
  engineHealthScore,
  name: r'engineHealthScoreProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$engineHealthScoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EngineHealthScoreRef = AutoDisposeFutureProviderRef<eng.HealthScore>;
String _$engineCycleStatusHash() => r'824fc9e2e270a5f72a5e1f972a83d296443d6b66';

/// État du cycle courant
///
/// Copied from [engineCycleStatus].
@ProviderFor(engineCycleStatus)
final engineCycleStatusProvider =
    AutoDisposeFutureProvider<eng.CycleDetectionResult>.internal(
  engineCycleStatus,
  name: r'engineCycleStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$engineCycleStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EngineCycleStatusRef
    = AutoDisposeFutureProviderRef<eng.CycleDetectionResult>;
String _$engineChargeTrackingHash() =>
    r'08ecf165d011c039eec77e5704251758fb7d0627';

/// Suivi des charges récurrentes
///
/// Copied from [engineChargeTracking].
@ProviderFor(engineChargeTracking)
final engineChargeTrackingProvider =
    AutoDisposeFutureProvider<List<eng.ChargeTrackingResult>>.internal(
  engineChargeTracking,
  name: r'engineChargeTrackingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$engineChargeTrackingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EngineChargeTrackingRef
    = AutoDisposeFutureProviderRef<List<eng.ChargeTrackingResult>>;
String _$engineIntegrityHash() => r'8631e4a624de40f2865839696954e54d678485be';

/// Rapport d'intégrité des données
///
/// Copied from [engineIntegrity].
@ProviderFor(engineIntegrity)
final engineIntegrityProvider =
    AutoDisposeFutureProvider<eng.IntegrityReport>.internal(
  engineIntegrity,
  name: r'engineIntegrityProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$engineIntegrityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EngineIntegrityRef = AutoDisposeFutureProviderRef<eng.IntegrityReport>;
String _$zoltEngineProviderHash() =>
    r'746a81832cccb152d7b1c928453590473a5ee8cd';

/// Provider principal du moteur Zolt.
///
/// Utilise [ZoltEngine.session] (v1.3) si disponible → retourne [SessionState].
/// Sinon replie sur [ZoltEngine.run] (V2) → wrappé en [SessionState] minimal.
/// En dernier recours, calcul Dart pur.
///
/// Copied from [ZoltEngineProvider].
@ProviderFor(ZoltEngineProvider)
final zoltEngineProviderProvider = AutoDisposeAsyncNotifierProvider<
    ZoltEngineProvider, eng.SessionState>.internal(
  ZoltEngineProvider.new,
  name: r'zoltEngineProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$zoltEngineProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ZoltEngineProvider = AutoDisposeAsyncNotifier<eng.SessionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
