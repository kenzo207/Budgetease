// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engine_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$engineDailyBudgetHash() => r'f0ef88949f66b8bf454ea00bcd6b08a3bf5b2510';

/// Budget journalier (accès rapide)
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
String _$engineMessagesHash() => r'8efdc7d61f18dd1f2e70fc9e717e46bb1ac7aa7a';

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
String _$enginePredictionHash() => r'9c53e6a61e3b35bbca10bd6a9309cc2a1591a50a';

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
String _$zoltEngineProviderHash() =>
    r'239b4d31874ba988dbbaaefba8216568f36c9e26';

/// Provider principal du moteur Zolt.
///
/// Retourne [ZoltEngineOutput] (depuis le moteur Rust si disponible,
/// sinon calcul Dart en fallback exact).
///
/// Copied from [ZoltEngineProvider].
@ProviderFor(ZoltEngineProvider)
final zoltEngineProviderProvider = AutoDisposeAsyncNotifierProvider<
    ZoltEngineProvider, eng.ZoltEngineOutput>.internal(
  ZoltEngineProvider.new,
  name: r'zoltEngineProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$zoltEngineProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ZoltEngineProvider = AutoDisposeAsyncNotifier<eng.ZoltEngineOutput>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
