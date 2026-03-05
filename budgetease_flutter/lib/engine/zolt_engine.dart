import 'dart:ffi';
import 'dart:convert';
import 'dart:io';
import 'package:ffi/ffi.dart';

// ─── Signatures C ──────────────────────────────────────────────
typedef _ZoltRunC    = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);
typedef _ZoltRunDart = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);
typedef _ZoltFreeC    = Void Function(Pointer<Utf8>);
typedef _ZoltFreeDart = void Function(Pointer<Utf8>);
typedef _ZoltVersionC    = Pointer<Utf8> Function();
typedef _ZoltVersionDart = Pointer<Utf8> Function();
// Single-arg FFI (classify, session, analytics, close_cycle, validate, integrity, onboarding)
typedef _ZoltSingleC    = Pointer<Utf8> Function(Pointer<Utf8>);
typedef _ZoltSingleDart = Pointer<Utf8> Function(Pointer<Utf8>);
// Alias pour la lisibilité
typedef _ZoltClassifyC    = Pointer<Utf8> Function(Pointer<Utf8>);
typedef _ZoltClassifyDart = Pointer<Utf8> Function(Pointer<Utf8>);

/// Bridge FFI vers la bibliothèque Rust `libzolt_engine.so`.
///
/// v1.2/v1.3 — 11 fonctions FFI exposées :
///   run, free, version, classify, predict_income,
///   session, analytics, close_cycle, validate, integrity, onboarding
class ZoltEngine {
  static DynamicLibrary? _lib;
  static _ZoltRunDart? _run;
  static _ZoltFreeDart? _free;
  static _ZoltVersionDart? _version;

  /// Initialise le moteur — à appeler une seule fois au démarrage.
  static bool initialize() {
    try {
      if (_lib != null) return true; // déjà initialisé

      if (Platform.isAndroid) {
        _lib = DynamicLibrary.open('libzolt_engine.so');
      } else if (Platform.isIOS) {
        _lib = DynamicLibrary.process();
      } else {
        // Desktop / test : essaie le chemin de debug
        _lib = DynamicLibrary.open('libzolt_engine.so');
      }

      _run = _lib!.lookupFunction<_ZoltRunC, _ZoltRunDart>('zolt_run');
      _free = _lib!.lookupFunction<_ZoltFreeC, _ZoltFreeDart>('zolt_free');
      _version = _lib!.lookupFunction<_ZoltVersionC, _ZoltVersionDart>('zolt_version');

      return true;
    } catch (e) {
      // Le moteur n'est pas disponible — on tombera en mode fallback Flutter
      return false;
    }
  }

  /// Retourne la version du moteur, ou null si non disponible.
  static String? get engineVersion {
    if (_version == null) return null;
    try {
      final ptr = _version!();
      final v = ptr.toDartString();
      _free!(ptr);
      return v;
    } catch (_) {
      return null;
    }
  }

  /// Vrai si le moteur Rust est chargé et opérationnel.
  static bool get isAvailable => _run != null;

  /// Exécute le moteur complet.
  /// 
  /// [input]   → EngineInput (comptes, charges, transactions, cycle)
  /// [history] → List de CycleRecord des cycles passés
  /// 
  /// Retourne ZoltEngineOutput ou lève une [ZoltEngineException].
  static Map<String, dynamic> run({
    required Map<String, dynamic> input,
    List<Map<String, dynamic>> history = const [],
  }) {
    if (!isAvailable) {
      throw const ZoltEngineException('Moteur non initialisé');
    }

    final inputPtr   = jsonEncode(input).toNativeUtf8();
    final historyPtr = jsonEncode(history).toNativeUtf8();

    Pointer<Utf8>? resultPtr;
    try {
      resultPtr = _run!(inputPtr, historyPtr);

        // Guard against null pointer returned by Rust on internal error
        if (resultPtr.address == 0) {
          throw const ZoltEngineException('Moteur Rust a retourné un pointeur nul');
        }

        final json = resultPtr.toDartString();
        final result = jsonDecode(json) as Map<String, dynamic>;      if (result.containsKey('error')) {
        throw ZoltEngineException(result['error'] as String);
      }

      return result;
    } finally {
      malloc.free(inputPtr);
      malloc.free(historyPtr);
      if (resultPtr != null) _free!(resultPtr);
    }
  }

  // ─── Lazy loaders pour toutes les FFI single-arg ─────────────
  static _ZoltSingleDart? _loadFn(String name) {
    if (_lib == null) return null;
    try {
      return _lib!.lookupFunction<_ZoltSingleC, _ZoltSingleDart>(name);
    } catch (_) {
      return null;
    }
  }

  static late final _ZoltClassifyDart?   _classify       = _loadFn('zolt_classify');
  static late final _ZoltSingleDart?     _predictIncomeFn = _loadFn('zolt_predict_income');
  static late final _ZoltSingleDart?     _sessionFn      = _loadFn('zolt_session');
  static late final _ZoltSingleDart?     _analyticsFn    = _loadFn('zolt_analytics');
  static late final _ZoltSingleDart?     _closeCycleFn   = _loadFn('zolt_close_cycle');
  static late final _ZoltSingleDart?     _validateFn     = _loadFn('zolt_validate');
  static late final _ZoltSingleDart?     _integrityFn    = _loadFn('zolt_integrity');
  static late final _ZoltSingleDart?     _onboardingFn   = _loadFn('zolt_onboarding');

  // ─── Helper interne : 1 arg → JSON ───────────────────────────
  static Map<String, dynamic> _call1(
    _ZoltSingleDart? fn,
    String fnName,
    Map<String, dynamic> payload,
  ) {
    if (fn == null) throw ZoltEngineException('$fnName non disponible');
    final inputPtr = jsonEncode(payload).toNativeUtf8();
    Pointer<Utf8>? resultPtr;
    try {
      resultPtr = fn(inputPtr);
      if (resultPtr.address == 0) throw ZoltEngineException('$fnName a retourné null');
      final json = resultPtr.toDartString();
      final result = jsonDecode(json) as Map<String, dynamic>;
      if (result.containsKey('error')) throw ZoltEngineException(result['error'] as String);
      return result;
    } finally {
      malloc.free(inputPtr);
      if (resultPtr != null) _free!(resultPtr);
    }
  }

  // ─── zolt_classify ───────────────────────────────────────────
  /// Classifie une transaction (SMS ou saisie manuelle) via l'IA Rust.
  /// Retourne une map avec `tx_type`, `category`, `confidence`, `reason`.
  static Map<String, dynamic> classify({
    required double amount,
    String? description,
    String? counterpart,
    String? smsText,
  }) => _call1(_classify, 'zolt_classify', {
    'amount': amount,
    'description': description,
    'counterpart': counterpart,
    'sms_text': smsText,
  });

  // ─── zolt_predict_income ─────────────────────────────────────
  /// Prédit le prochain revenu basé sur l'historique des cycles.
  /// Retourne null si l'historique est insuffisant.
  static Map<String, dynamic>? predictIncome({
    required List<Map<String, dynamic>> history,
  }) {
    if (_predictIncomeFn == null) throw const ZoltEngineException('zolt_predict_income non disponible');
    final now = DateTime.now();
    final inputPtr = jsonEncode({
      'history': history,
      'today': {'year': now.year, 'month': now.month, 'day': now.day},
    }).toNativeUtf8();
    Pointer<Utf8>? resultPtr;
    try {
      resultPtr = _predictIncomeFn!(inputPtr);
      if (resultPtr.address == 0) return null;
      final json = resultPtr.toDartString();
      if (json == 'null') return null;
      final result = jsonDecode(json);
      if (result == null) return null;
      final map = result as Map<String, dynamic>;
      if (map.containsKey('error')) throw ZoltEngineException(map['error'] as String);
      return map;
    } finally {
      malloc.free(inputPtr);
      if (resultPtr != null) _free!(resultPtr);
    }
  }

  // ─── zolt_session ────────────────────────────────────────────
  /// Pipeline tout-en-un : engine + health + cycle + charges + triage + integrity.
  ///
  /// [engineInput]  → EngineInput sérialisé
  /// [history]      → List<CycleRecord> des cycles passés
  /// [pendingSms]   → List<PendingTransactionInput> (SMS en attente)
  ///
  /// Retourne [SessionState] complet.
  static Map<String, dynamic> session({
    required Map<String, dynamic> engineInput,
    List<Map<String, dynamic>> history = const [],
    List<Map<String, dynamic>> pendingSms = const [],
  }) => _call1(_sessionFn, 'zolt_session', {
    'engine_input': engineInput,
    'history':      history,
    'pending_sms':  pendingSms,
  });

  // ─── zolt_analytics ──────────────────────────────────────────
  /// Stats avancées du cycle avec comparaison historique.
  /// Retourne [AnalyticsResult] : by_category, peak_day, savings_rate, etc.
  static Map<String, dynamic> analytics({
    required Map<String, dynamic> analyticsInput,
  }) => _call1(_analyticsFn, 'zolt_analytics', analyticsInput);

  // ─── zolt_close_cycle ────────────────────────────────────────
  /// Clôture le cycle courant et retourne un résumé [CycleCloseResult].
  static Map<String, dynamic> closeCycle({
    required Map<String, dynamic> input,
  }) => _call1(_closeCycleFn, 'zolt_close_cycle', input);

  // ─── zolt_validate ───────────────────────────────────────────
  /// Valide un [EngineInput] côté Rust. Retourne `{"valid":true}` ou `{"valid":false,"error":"..."}`.
  static Map<String, dynamic> validate({
    required Map<String, dynamic> engineInput,
  }) => _call1(_validateFn, 'zolt_validate', engineInput);

  // ─── zolt_integrity ──────────────────────────────────────────
  /// Vérifie l'intégrité des données. Retourne [IntegrityReport].
  static Map<String, dynamic> integrity({
    required Map<String, dynamic> engineInput,
    List<Map<String, dynamic>> history = const [],
  }) => _call1(_integrityFn, 'zolt_integrity', {
    'engine_input': engineInput,
    'history':      history,
  });

  // ─── zolt_onboarding ─────────────────────────────────────────
  /// Valide et construit un [EngineInput] depuis les données d'onboarding.
  /// Retourne [OnboardingResult] avec `is_ready` et `validation_errors`.
  static Map<String, dynamic> onboarding({
    required Map<String, dynamic> onboardingInput,
  }) => _call1(_onboardingFn, 'zolt_onboarding', onboardingInput);
}

/// Exception spécifique au moteur Zolt.
class ZoltEngineException implements Exception {
  final String message;
  const ZoltEngineException(this.message);

  @override
  String toString() => 'ZoltEngineException: $message';
}
