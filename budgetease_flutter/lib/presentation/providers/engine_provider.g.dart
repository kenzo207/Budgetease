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
String _$engineAnalyticsHash() => r'2ccb31bf84210783bbad6d10a88cce5c562d9982';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Analytics d'un mois donné via zolt_analytics.
/// [month] = DateTime(year, month, 1) — seuls year et month comptent.
/// Retourne null si le moteur n'est pas disponible.
///
/// Copied from [engineAnalytics].
@ProviderFor(engineAnalytics)
const engineAnalyticsProvider = EngineAnalyticsFamily();

/// Analytics d'un mois donné via zolt_analytics.
/// [month] = DateTime(year, month, 1) — seuls year et month comptent.
/// Retourne null si le moteur n'est pas disponible.
///
/// Copied from [engineAnalytics].
class EngineAnalyticsFamily extends Family<AsyncValue<eng.AnalyticsResult?>> {
  /// Analytics d'un mois donné via zolt_analytics.
  /// [month] = DateTime(year, month, 1) — seuls year et month comptent.
  /// Retourne null si le moteur n'est pas disponible.
  ///
  /// Copied from [engineAnalytics].
  const EngineAnalyticsFamily();

  /// Analytics d'un mois donné via zolt_analytics.
  /// [month] = DateTime(year, month, 1) — seuls year et month comptent.
  /// Retourne null si le moteur n'est pas disponible.
  ///
  /// Copied from [engineAnalytics].
  EngineAnalyticsProvider call(
    DateTime month,
  ) {
    return EngineAnalyticsProvider(
      month,
    );
  }

  @override
  EngineAnalyticsProvider getProviderOverride(
    covariant EngineAnalyticsProvider provider,
  ) {
    return call(
      provider.month,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'engineAnalyticsProvider';
}

/// Analytics d'un mois donné via zolt_analytics.
/// [month] = DateTime(year, month, 1) — seuls year et month comptent.
/// Retourne null si le moteur n'est pas disponible.
///
/// Copied from [engineAnalytics].
class EngineAnalyticsProvider
    extends AutoDisposeFutureProvider<eng.AnalyticsResult?> {
  /// Analytics d'un mois donné via zolt_analytics.
  /// [month] = DateTime(year, month, 1) — seuls year et month comptent.
  /// Retourne null si le moteur n'est pas disponible.
  ///
  /// Copied from [engineAnalytics].
  EngineAnalyticsProvider(
    DateTime month,
  ) : this._internal(
          (ref) => engineAnalytics(
            ref as EngineAnalyticsRef,
            month,
          ),
          from: engineAnalyticsProvider,
          name: r'engineAnalyticsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$engineAnalyticsHash,
          dependencies: EngineAnalyticsFamily._dependencies,
          allTransitiveDependencies:
              EngineAnalyticsFamily._allTransitiveDependencies,
          month: month,
        );

  EngineAnalyticsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.month,
  }) : super.internal();

  final DateTime month;

  @override
  Override overrideWith(
    FutureOr<eng.AnalyticsResult?> Function(EngineAnalyticsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EngineAnalyticsProvider._internal(
        (ref) => create(ref as EngineAnalyticsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<eng.AnalyticsResult?> createElement() {
    return _EngineAnalyticsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EngineAnalyticsProvider && other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EngineAnalyticsRef on AutoDisposeFutureProviderRef<eng.AnalyticsResult?> {
  /// The parameter `month` of this provider.
  DateTime get month;
}

class _EngineAnalyticsProviderElement
    extends AutoDisposeFutureProviderElement<eng.AnalyticsResult?>
    with EngineAnalyticsRef {
  _EngineAnalyticsProviderElement(super.provider);

  @override
  DateTime get month => (origin as EngineAnalyticsProvider).month;
}

String _$engineRawInputHash() => r'69a3c4d219ccfb018acde3249443cd44f7a28215';

/// Expose les inputs bruts du moteur pour les fonctionnalités avancées (Simulateur, Credit Score)
///
/// Copied from [engineRawInput].
@ProviderFor(engineRawInput)
final engineRawInputProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
  engineRawInput,
  name: r'engineRawInputProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$engineRawInputHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EngineRawInputRef = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
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
