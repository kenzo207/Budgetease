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

/// Bridge FFI vers la bibliothèque Rust `libzolt_engine.so`.
/// 
/// Usage :
/// ```dart
/// final result = ZoltEngine.run(input: {...}, history: [...]);
/// final budget = result['deterministic']['daily_budget'];
/// ```
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
}

/// Exception spécifique au moteur Zolt.
class ZoltEngineException implements Exception {
  final String message;
  const ZoltEngineException(this.message);

  @override
  String toString() => 'ZoltEngineException: $message';
}
