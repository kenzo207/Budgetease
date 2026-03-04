# Zolt Engine — Guide d'intégration Flutter

## Architecture

```
zolt_engine/          ← ce projet Rust
flutter_app/
  ├── lib/
  │   └── engine/
  │       ├── zolt_engine.dart     ← wrapper FFI
  │       ├── engine_input.dart    ← modèles Dart
  │       └── engine_output.dart   ← modèles Dart
  └── android/app/src/main/jniLibs/  ← .so compilés
```

---

## Étape 1 — Compiler la lib Rust

### Android (arm64 — la cible principale Afrique de l'Ouest)
```bash
# Installer la cible
rustup target add aarch64-linux-android

# Compiler
cargo build --release --target aarch64-linux-android

# Copier dans Flutter
cp target/aarch64-linux-android/release/libzolt_engine.so \
   ../flutter_app/android/app/src/main/jniLibs/arm64-v8a/
```

### iOS
```bash
rustup target add aarch64-apple-ios
cargo build --release --target aarch64-apple-ios
# Intégrer le .a dans Xcode via build phases
```

---

## Étape 2 — Wrapper Dart (zolt_engine.dart)

```dart
import 'dart:ffi';
import 'dart:convert';
import 'package:ffi/ffi.dart';

// Signatures C
typedef ZoltRunC = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);
typedef ZoltRunDart = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);
typedef ZoltFreeC = Void Function(Pointer<Utf8>);
typedef ZoltFreeDart = void Function(Pointer<Utf8>);

class ZoltEngine {
  static final DynamicLibrary _lib = DynamicLibrary.open('libzolt_engine.so');

  static final _run  = _lib.lookupFunction<ZoltRunC,  ZoltRunDart>('zolt_run');
  static final _free = _lib.lookupFunction<ZoltFreeC, ZoltFreeDart>('zolt_free');

  /// Exécute le moteur complet.
  /// [input]   → EngineInput sérialisé en JSON
  /// [history] → List<CycleRecord> sérialisée en JSON
  static Map<String, dynamic> run({
    required Map<String, dynamic> input,
    required List<Map<String, dynamic>> history,
  }) {
    final inputPtr   = jsonEncode(input).toNativeUtf8();
    final historyPtr = jsonEncode(history).toNativeUtf8();

    final resultPtr = _run(inputPtr, historyPtr);

    // Libère les strings d'entrée
    malloc.free(inputPtr);
    malloc.free(historyPtr);

    // Lit le résultat
    final resultJson = resultPtr.toDartString();
    _free(resultPtr); // libère la mémoire Rust

    final result = jsonDecode(resultJson) as Map<String, dynamic>;
    if (result.containsKey('error')) {
      throw Exception('ZoltEngine error: ${result['error']}');
    }
    return result;
  }
}
```

---

## Étape 3 — Utilisation dans Flutter

```dart
// Dans votre BLoC / Provider / ViewModel
final output = ZoltEngine.run(
  input: {
    'today': {'year': 2026, 'month': 3, 'day': 15},
    'accounts': [
      {
        'id': 'momo_1',
        'name': 'MTN MoMo',
        'account_type': 'MobileMoney',
        'balance': 250000.0,
        'is_active': true,
      }
    ],
    'charges': [
      {
        'id': 'loyer',
        'name': 'Loyer',
        'amount': 150000.0,
        'due_day': 31,
        'status': 'Pending',
        'amount_paid': 0.0,
        'is_active': true,
      }
    ],
    'transactions': [], // transactions du cycle courant
    'cycle': {
      'cycle_type': 'Monthly',
      'savings_goal': 30000.0,
      'transport': {
        'Daily': {              // ou 'Subscription' ou 'None'
          'cost_per_day': 500.0,
          'work_days': [1, 2, 3, 4, 5], // lun-ven
        }
      },
    },
  },
  history: [], // List<CycleRecord> des cycles passés depuis SQLite
);

// Accès aux résultats
final dailyBudget   = output['deterministic']['daily_budget'] as double;
final messages      = output['messages'] as List;
final suggestions   = output['suggestions'] as List;
final prediction    = output['prediction'];  // peut être null
```

---

## Format JSON des cycles passés (CycleRecord)

```json
[
  {
    "cycle_start":      {"year": 2026, "month": 2, "day": 1},
    "cycle_end":        {"year": 2026, "month": 2, "day": 28},
    "opening_balance":  300000.0,
    "closing_balance":  45000.0,
    "total_income":     300000.0,
    "total_expenses":   225000.0,
    "savings_goal":     30000.0,
    "savings_achieved": 30000.0,
    "daily_expenses":   [8000, 5000, 12000, ...],
    "category_totals":  [["transport", 15000], ["nourriture", 45000]],
    "transactions":     [...]
  }
]
```

---

## Format JSON de sortie (ZoltEngineOutput)

```json
{
  "deterministic": {
    "total_balance":     250000.0,
    "committed_mass":    187500.0,
    "free_mass":          62500.0,
    "days_remaining":        17,
    "daily_budget":        3676.47,
    "spent_today":            0.0,
    "remaining_today":     3676.47,
    "transport_reserve":   7500.0,
    "charges_reserve":   150000.0
  },
  "profile": {
    "rhythm":               "Linear",
    "volatility_score":       0.15,
    "savings_achievement":    0.92,
    "cycles_observed":           3,
    "hidden_charges_total":      0.0
  },
  "prediction": {
    "projected_final_balance": 12000.0,
    "projected_deficit":           0.0,
    "confidence":               0.65,
    "alert_level":             "Info"
  },
  "anomalies": [],
  "messages": [
    {
      "level":    "Info",
      "title":    "Bonne trajectoire 👍",
      "body":     "Tu devrais finir le mois avec environ 12 000 FCFA de marge.",
      "ttl_days": 7
    }
  ],
  "suggestions": []
}
```

---

## Quand appeler le moteur ?

| Événement                      | Action                        |
|-------------------------------|-------------------------------|
| Ouverture de l'app             | `zolt_run()` complet          |
| Nouvelle transaction validée   | `zolt_run()` complet          |
| SMS Mobile Money reçu          | Parser SMS → transaction → `zolt_run()` |
| Changement de paramètre        | `zolt_run()` complet          |
| Fin de cycle                   | Archiver CycleRecord → `zolt_run()` nouveau cycle |

Le moteur est stateless — il recalcule tout à chaque appel.
Le coût est négligeable (< 1ms sur ARM64 pour 30 jours d'historique).
