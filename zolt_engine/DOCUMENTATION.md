# Zolt Engine — Documentation Technique Complète
**Version 1.0.0 — Mars 2026**

---

## Table des matières

1. [Vue d'ensemble](#1-vue-densemble)
2. [Architecture globale](#2-architecture-globale)
3. [Couche 1 — Moteur déterministe](#3-couche-1--moteur-déterministe)
4. [Couche 2 — Moteur adaptatif](#4-couche-2--moteur-adaptatif)
5. [Couche 3 — Surface conversationnelle](#5-couche-3--surface-conversationnelle)
6. [Bridge Flutter (FFI)](#6-bridge-flutter-ffi)
7. [Types de données](#7-types-de-données)
8. [Cycle de vie d'un calcul](#8-cycle-de-vie-dun-calcul)
9. [Phases d'apprentissage](#9-phases-dapprentissage)
10. [Compiler et intégrer](#10-compiler-et-intégrer)
11. [Questions fréquentes](#11-questions-fréquentes)

---

## 1. Vue d'ensemble

Zolt Engine est le cerveau financier de l'application Zolt. C'est une bibliothèque Rust compilée en natif (`.so` Android, `.dylib`/`.a` iOS) qui tourne **entièrement sur l'appareil de l'utilisateur** — aucune donnée ne quitte le téléphone, aucun serveur n'est nécessaire.

### Ce que le moteur fait

Le moteur répond à une question fondamentale à chaque ouverture de l'application :

> **"Combien puis-je dépenser aujourd'hui sans mettre en danger mes engagements du mois ?"**

Mais contrairement à une simple formule, il va plus loin :

- Il **apprend** les habitudes réelles de l'utilisateur cycle après cycle
- Il **prédit** comment le mois va se terminer avant qu'il soit terminé
- Il **détecte** les comportements anormaux ou dangereux
- Il **communique** ses conclusions en français, de façon claire et actionnable

### Pourquoi Rust ?

Rust a été choisi pour trois raisons :

1. **Performance** : le moteur tourne en moins d'1ms même sur des téléphones bas de gamme
2. **Sécurité mémoire** : pas de bugs de corruption mémoire, critique pour des données financières
3. **FFI propre** : s'intègre parfaitement avec Flutter via `dart:ffi` sans overhead

---

## 2. Architecture globale

Le moteur est organisé en **3 couches indépendantes** qui ne se mélangent jamais.

```
┌─────────────────────────────────────────────────────────────────┐
│  ENTRÉE : EngineInput (JSON depuis Flutter)                      │
│  Contient : soldes, charges, transactions du cycle, paramètres   │
└───────────────────────────┬─────────────────────────────────────┘
                            │
            ┌───────────────▼───────────────┐
            │   COUCHE 1 — DÉTERMINISTE      │
            │   deterministic/mod.rs         │
            │                               │
            │   • Calcule la masse engagée  │
            │   • Calcule la masse libre    │
            │   • Calcule B_j (budget/jour) │
            │   • Toujours exact, jamais    │
            │     approximatif              │
            └───────────────┬───────────────┘
                            │ DeterministicResult
            ┌───────────────▼───────────────┐
            │   COUCHE 2 — ADAPTATIF         │
            │   adaptive/                   │
            │                               │
            │   Module A : Profil           │
            │   Module B : Prédiction       │
            │   Module C : Anomalies        │
            │   Module D : Ajustements      │
            │   Module E : Mémoire          │
            └───────────────┬───────────────┘
                            │ AdaptiveOutput
            ┌───────────────▼───────────────┐
            │   COUCHE 3 — SURFACE           │
            │   surface/mod.rs               │
            │                               │
            │   Traduit tout en messages    │
            │   français hiérarchisés       │
            └───────────────┬───────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│  SORTIE : ZoltEngineOutput (JSON vers Flutter)                   │
│  Contient : budget, profil, prédiction, anomalies, messages      │
└─────────────────────────────────────────────────────────────────┘
```

**Règle d'or** : chaque couche ne peut accéder qu'à la couche du dessus, jamais à celle du dessous. La Couche 3 ne recalcule jamais de budget. La Couche 1 n'affiche jamais de message.

---

## 3. Couche 1 — Moteur déterministe

**Fichier** : `src/deterministic/mod.rs`

### Le principe fondamental : séparation en deux masses

La logique centrale repose sur une idée simple : avant de calculer ce que l'utilisateur peut dépenser, il faut d'abord identifier ce qui est **déjà destiné** à quelque chose.

```
MASSE ENGAGÉE  =  Épargne objectif
               +  Transport total restant du cycle
               +  Σ (toutes les charges non encore payées)

MASSE LIBRE    =  Solde total  −  Masse engagée

BUDGET JOUR    =  Masse libre  ÷  Jours restants du cycle
```

### Pourquoi cette logique est meilleure que l'ancienne formule

L'ancienne formule de Zolt déduisait les réserves de charges **après** la division, ce qui créait une sous-estimation du budget réel. La nouvelle logique réserve d'abord tout l'argent "déjà pris", puis divise ce qui reste.

**Exemple concret** :
- Solde : 300 000 FCFA
- Épargne objectif : 30 000 FCFA
- Loyer à payer (dans 20 jours) : 150 000 FCFA
- Transport restant : 7 500 FCFA
- Jours restants : 17

```
Masse engagée = 30 000 + 150 000 + 7 500 = 187 500 FCFA
Masse libre   = 300 000 − 187 500        = 112 500 FCFA
Budget/jour   = 112 500 ÷ 17             =   6 617 FCFA/j
```

L'utilisateur voit **6 617 FCFA** à dépenser aujourd'hui — un chiffre exact, pas une approximation.

### Gestion du transport

Le transport est traité différemment selon son type :

- **Abonnement mensuel** → c'est une charge fixe comme le loyer. Il rejoint la masse engagée via la liste des charges.
- **Transport journalier** → le moteur compte les jours ouvrables réels restants jusqu'à la fin du cycle (pas une approximation fractionnaire), multiplie par le coût journalier, et ajoute ce total à la masse engagée.

### Gestion des charges

Chaque charge a un état explicite :

| État | Comportement |
|------|-------------|
| `Pending` | Montant total compté dans la masse engagée |
| `PartiallyPaid` | Seulement le montant restant (amount − amount_paid) |
| `Paid` | Exclue entièrement de la masse engagée |
| `Overdue` | Montant total compté en priorité (comme Pending) |

### Cas limites gérés

- **Masse libre négative** : clampée à 0. Budget = 0. Une alerte critique est déclenchée.
- **Dernier jour du cycle** : le budget du jour = masse libre entière (pas de division par 0).
- **Revenu reçu en cours de mois** : le solde est mis à jour et le moteur recalcule immédiatement.

---

## 4. Couche 2 — Moteur adaptatif

**Dossier** : `src/adaptive/`

Le moteur adaptatif contient 5 modules indépendants. Chaque module peut fonctionner même si les autres échouent. Ils partagent tous le même historique de cycles passés (`Vec<CycleRecord>`).

### Phase d'observation (cycles 1 à 2)

Pendant les 3 premiers cycles, le moteur tourne en **mode silencieux** : il collecte des données mais ne génère pas encore de suggestions ni de prédictions. Afficher des prédictions avec trop peu de données créerait plus de confusion que de valeur.

---

### Module A — Profil comportemental
**Fichier** : `src/adaptive/profile.rs`

Le profil est une représentation évolutive des **vraies habitudes** de l'utilisateur, distinctes de ce qu'il a déclaré à l'onboarding.

#### Rythme de dépense

Le moteur divise chaque cycle en 3 tiers et calcule quelle part des dépenses tombe dans chaque tiers, en moyenne sur tous les cycles.

```
Rythme FRONTAL  → > 40% des dépenses en premier tiers (début de mois)
Rythme TERMINAL → > 40% des dépenses en dernier tiers (fin de mois)
Rythme LINEAR   → répartition équilibrée
Rythme ERRATIC  → coefficient de variation élevé, pas de pattern clair
```

Le rythme est utilisé par le Module B pour corriger les projections.

#### Volatilité

La volatilité mesure à quel point les dépenses journalières de l'utilisateur varient. Un utilisateur à volatilité haute a besoin d'une marge de sécurité plus grande.

```
Volatilité = Coefficient de variation des dépenses journalières
           = Écart-type / Moyenne
           
Score 0.0 → très régulier (même montant chaque jour)
Score 1.0 → très erratique (dépenses imprévisibles)
```

#### Taux de réalisation de l'épargne

La médiane (pas la moyenne, pour résister aux valeurs extrêmes) du ratio `épargne réalisée / épargne objectif` sur les cycles passés. Ce chiffre détermine si le Module D doit proposer une révision de l'objectif.

#### Charges informelles détectées

Le moteur scanne les transactions à la recherche de montants similaires (± 10%) qui apparaissent à la même semaine du cycle sur plusieurs cycles consécutifs. Ces patterns sont des charges informelles oubliées (tontine, aide familiale, abonnement informel).

---

### Module B — Prédiction fin de cycle
**Fichier** : `src/adaptive/prediction.rs`

À tout moment du cycle, le moteur peut projeter le solde final.

#### Algorithme de projection

**Étape 1 — Taux de dépense actuel**
```
Taux_actuel = Total_dépensé_depuis_début_cycle ÷ Jours_écoulés
```

**Étape 2 — Correction par le rythme comportemental**

Un utilisateur à rythme frontal dépense 60% de son argent dans les 15 premiers jours. Si on projette son taux actuel (élevé) linéairement sur le reste du mois, on sur-estimera ses dépenses futures. Le facteur de correction corrige ça :

```
Facteur FRONTAL  = 0.5 + 0.5 × (jours_écoulés / jours_total)
→ En début de mois : facteur bas (on anticipe que ça va ralentir)
→ En fin de mois   : facteur ≈ 1.0 (plus de correction nécessaire)

Facteur TERMINAL = 1.5 − 0.5 × (jours_écoulés / jours_total)  
→ En début de mois : facteur haut (on anticipe une accélération)
→ En fin de mois   : facteur ≈ 1.0
```

**Étape 3 — Solde projeté**
```
Dépenses_restantes_projetées = Taux_actuel × Facteur × Jours_restants
Solde_final_estimé = Solde_actuel − Dépenses_projetées − Masse_engagée
```

#### Score de confiance

La prédiction affiche un score de confiance (0.0 à 1.0). Il est faible en début de cycle (peu de signal) et avec peu d'historique (peu de cycles passés). Si la confiance est inférieure à 0.30, la prédiction n't est pas affichée pour éviter de donner une fausse impression de précision.

#### Niveaux d'alerte déclenchés

| Condition | Alerte |
|-----------|--------|
| Déficit > 15% du budget mensuel | `Critical` |
| Déficit > 0 | `Warning` |
| Marge finale > 20% du budget | `Positive` |
| Sinon | `Info` |

---

### Module C — Détection d'anomalies
**Fichier** : `src/adaptive/anomaly.rs`

Trois types d'anomalies sont détectés, avec des fenêtres temporelles différentes.

#### Ghost Money (micro-dépenses répétées)

Amélioration majeure par rapport à la version précédente : le seuil de "micro-dépense" est maintenant **relatif** au budget journalier de l'utilisateur, pas fixe à 500 FCFA.

```
Seuil_micro = clamp(Budget_journalier × 2%, 200 FCFA, 2000 FCFA)
```

Une alerte Ghost Money est déclenchée si :
- Fenêtre : 7 derniers jours
- Au moins 5 transactions ≤ seuil_micro
- Leur total représente ≥ 5% de la masse libre

#### Montant inhabituel (nécessite historique)

Pour chaque catégorie de dépense, le moteur calcule la distribution historique (moyenne + écart-type). Une transaction est "inhabituelle" si son montant dépasse `moyenne + 2 × écart-type`.

Ce n'est pas une alerte automatiquement négative — c'est une question posée à l'utilisateur : "C'est normal ?"

#### Timing inhabituel (nécessite historique)

Si l'utilisateur dépense habituellement dans une catégorie à la semaine 1 du mois, et qu'une dépense de cette catégorie arrive à la semaine 3 → signal. Décalage de ≥ 2 semaines nécessaire pour déclencher.

---

### Module D — Ajustements adaptatifs
**Fichier** : `src/adaptive/adjustment.rs`

**Règle absolue** : ce module ne modifie jamais directement les paramètres. Il génère des **suggestions** que l'utilisateur accepte ou refuse dans l'interface.

#### Suggestion 1 : Révision de l'objectif d'épargne

Déclenchée si l'utilisateur rate son objectif d'épargne (< 90% de l'objectif) sur **3 cycles consécutifs**.

```
Objectif_suggéré = Médiane(épargnes_réalisées_3_derniers_cycles) × 1.05
```

Les 5% supplémentaires représentent une légère aspiration au-dessus de ce qui est réellement atteint.

#### Suggestion 2 : Ajouter une charge cachée

Déclenchée si le Module A détecte un pattern de dépense récurrent non déclaré comme charge fixe. Le moteur propose : "Tu dépenses environ X FCFA chaque [semaine] du mois. Veux-tu l'ajouter comme charge fixe ?"

#### Suggestion 3 : Marge de sécurité comportementale

Pour les utilisateurs avec `volatility_score > 0.3`, le moteur suggère d'ajouter une marge silencieuse dans le calcul :

```
Marge = volatility_score × 10% de la masse libre
        (plafonnée à 10% maximum)
```

Un utilisateur avec volatilité 0.7 se verra proposer une marge de 7% — son budget journalier affiché sera légèrement réduit pour absorber les dépenses imprévues.

---

### Module E — Mémoire épisodique
**Fichier** : `src/adaptive/memory.rs`

La mémoire épisodique enregistre les **événements marquants** de chaque cycle passé et les réutilise pour anticiper.

#### Épisodes enregistrés

| Type | Condition de déclenchement |
|------|---------------------------|
| `CriticalLowBalance` | Solde < 10% du revenu mensuel à un moment quelconque |
| `SavingsGoalReached` | Épargne réalisée ≥ 100% de l'objectif |
| `SavingsGoalMissed` | Épargne réalisée < 80% de l'objectif |
| `ExceptionalExpense` | Dépense journalière > 3× la moyenne du cycle |
| `MonthlyDeficit` | Solde de clôture < 0 |
| `ComfortableEnd` | Solde de clôture > 20% du revenu mensuel |

#### Filtrage des épisodes pertinents

À chaque calcul, le moteur filtre les épisodes selon deux critères :
1. **Même semaine du cycle** (± 1 semaine) : si on est en semaine 4, les épisodes difficiles des semaines 3-5 des cycles passés sont pertinents
2. **Même mois de l'année** : détecte les patterns saisonniers (rentrée scolaire, fêtes, etc.) après 12 mois de données

Si un épisode critique (solde bas, déficit) est trouvé, un message d'avertissement est généré dans la Couche 3.

---

## 5. Couche 3 — Surface conversationnelle

**Fichier** : `src/surface/mod.rs`

La surface traduit tous les signaux des couches 1 et 2 en messages lisibles en français.

### Hiérarchie des messages

Les messages sont **strictement hiérarchisés** pour éviter de noyer l'utilisateur :

| Niveau | Couleur | Max simultanés | Disparaît |
|--------|---------|----------------|-----------|
| `Critical` | Rouge | 1 | Jamais (jusqu'à résolution) |
| `Warning` | Orange | 2 | Après TTL ou action |
| `Info` | Bleu | 3 | Après 7 jours |
| `Positive` | Vert | 1 | Après 3 jours |

Règle : si un message `Critical` existe, aucun `Positive` n'est affiché.

Les messages sont triés par sévérité décroissante avant d'être envoyés à Flutter.

### Sources de messages

| Source | Type de message généré |
|--------|----------------------|
| Masse libre ≤ 0 | Critical — budget insuffisant |
| Prédiction déficit > 15% | Critical — fin de mois difficile |
| Prédiction déficit faible | Warning — attention fin de mois |
| Ghost Money détecté | Warning — argent fantôme |
| Montant inhabituel | Warning — dépense anormale |
| Timing inhabituel | Info — timing inhabituel |
| Épisode critique passé | Warning — rappel du passé |
| Suggestion Module D | Info — actionnable |
| Bonne trajectoire | Positive — encouragement |

### Format des messages

Chaque message contient :
- `level` : Critical / Warning / Info / Positive
- `title` : titre court (max 50 caractères)
- `body` : explication avec chiffres réels de l'utilisateur
- `ttl_days` : durée d'affichage en jours (null = permanent)

---

## 6. Bridge Flutter (FFI)

**Fichier** : `src/ffi/mod.rs`

### Fonctions exportées

```c
// Exécute le moteur complet. Retourne JSON ZoltEngineOutput.
// Libérer le résultat avec zolt_free() après utilisation.
char* zolt_run(const char* input_json, const char* history_json);

// Libère la mémoire allouée par zolt_run().
// OBLIGATOIRE — chaque appel à zolt_run doit être suivi d'un zolt_free.
void zolt_free(char* ptr);

// Retourne la version du moteur. Libérer avec zolt_free().
char* zolt_version();
```

### Protocole d'appel depuis Flutter

```
Flutter                          Rust
  │                               │
  ├─ Sérialise EngineInput → JSON  │
  ├─ Sérialise history → JSON      │
  ├─ Alloue strings natives ──────►│
  │                               ├─ Parse JSON
  │                               ├─ Exécute Couche 1
  │                               ├─ Exécute Couche 2
  │                               ├─ Exécute Couche 3
  │                               ├─ Sérialise ZoltEngineOutput → JSON
  │◄─────────────────── Pointeur ──┤
  ├─ Lit JSON résultat             │
  ├─ Désérialise en Dart           │
  ├─ Appelle zolt_free(ptr) ──────►│ Libère la mémoire
  └─ Met à jour l'UI               │
```

### Gestion des erreurs

Si le moteur rencontre une erreur (JSON invalide, pointeur null, etc.), il retourne un JSON d'erreur au lieu de crasher :

```json
{"error": "description de l'erreur"}
```

Flutter doit toujours vérifier la présence de la clé `"error"` avant d'utiliser le résultat.

---

## 7. Types de données

### EngineInput (entrée)

```json
{
  "today": {"year": 2026, "month": 3, "day": 15},
  "accounts": [
    {
      "id": "string",
      "name": "string",
      "account_type": "MobileMoney" | "Cash" | "Bank",
      "balance": 250000.0,
      "is_active": true
    }
  ],
  "charges": [
    {
      "id": "string",
      "name": "string",
      "amount": 150000.0,
      "due_day": 31,
      "status": "Pending" | "Paid" | "Overdue" | "PartiallyPaid",
      "amount_paid": 0.0,
      "is_active": true
    }
  ],
  "transactions": [
    {
      "id": "string",
      "date": {"year": 2026, "month": 3, "day": 10},
      "amount": 5000.0,
      "tx_type": "Expense" | "Income" | "TransferOut" | "TransferIn" | "Withdrawal" | "Deposit",
      "category": "nourriture",
      "account_id": "string",
      "description": null,
      "sms_confidence": null
    }
  ],
  "cycle": {
    "cycle_type": "Monthly" | "Weekly" | "Daily" | {"Irregular": {"cycle_start": {...}, "cycle_end": {...}}},
    "savings_goal": 30000.0,
    "transport": "None" | "Subscription" | {"Daily": {"cost_per_day": 500.0, "work_days": [1,2,3,4,5]}}
  }
}
```

### ZoltEngineOutput (sortie)

```json
{
  "deterministic": {
    "total_balance": 300000.0,
    "committed_mass": 187500.0,
    "free_mass": 112500.0,
    "days_remaining": 17,
    "daily_budget": 6617.64,
    "spent_today": 2000.0,
    "remaining_today": 4617.64,
    "transport_reserve": 7500.0,
    "charges_reserve": 150000.0
  },
  "profile": {
    "rhythm": "Linear" | "Frontal" | "Terminal" | "Erratic",
    "volatility_score": 0.15,
    "savings_achievement": 0.92,
    "cycles_observed": 3,
    "hidden_charges_total": 0.0
  },
  "prediction": null,
  "anomalies": [],
  "messages": [
    {
      "level": "Info" | "Warning" | "Critical" | "Positive",
      "title": "string",
      "body": "string",
      "ttl_days": 7
    }
  ],
  "suggestions": []
}
```

---

## 8. Cycle de vie d'un calcul

### Quand appeler `zolt_run()` ?

| Événement Flutter | Action |
|-------------------|--------|
| Ouverture de l'app | `zolt_run()` complet |
| Nouvelle transaction validée | `zolt_run()` complet |
| SMS Mobile Money reçu et validé | `zolt_run()` complet |
| Modification d'une charge | `zolt_run()` complet |
| Changement de l'objectif d'épargne | `zolt_run()` complet |
| Fin de cycle (archivage) | Sauvegarder `CycleRecord` → `zolt_run()` nouveau cycle |

Le moteur est **stateless** — il recalcule tout à chaque appel. Ce n'est pas un problème car le calcul prend moins d'1ms.

### Archivage d'un cycle terminé

Quand un cycle se termine, Flutter doit construire un `CycleRecord` à partir des données SQLite et l'ajouter à l'historique :

```dart
final record = CycleRecord(
  cycleStart: ...,
  cycleEnd: ...,
  openingBalance: ...,  // solde au 1er jour du cycle
  closingBalance: ...,  // solde au dernier jour
  totalIncome: ...,     // Σ revenus du cycle
  totalExpenses: ...,   // Σ dépenses du cycle
  savingsGoal: ...,
  savingsAchieved: ..., // épargne réellement mise de côté
  dailyExpenses: [...], // dépenses par jour, index 0 = jour 1
  categoryTotals: [...],
  transactions: [...],  // toutes les transactions du cycle
);
// Sauvegarder dans SQLite, puis inclure dans history[] au prochain appel
```

---

## 9. Phases d'apprentissage

| Phase | Cycles | Modules actifs | Ce que l'utilisateur voit |
|-------|--------|---------------|--------------------------|
| **Observation** | 0-2 | Couche 1 uniquement | Budget journalier exact, aucune prédiction |
| **Apprentissage** | 3-5 | Couches 1+2 (modules A, B, C) | Prédictions, anomalies, premiers insights |
| **Mature** | 6-11 | Couches 1+2+3 complètes | Suggestions adaptatives, messages riches |
| **Saisonnier** | 12+ | Tout + mémoire saisonnière | Anticipation des patterns annuels |

La transition entre phases est automatique — le moteur vérifie `history.len()` à chaque appel.

---

## 10. Compiler et intégrer

### Prérequis

```bash
# Installer Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Installer les cibles mobiles
rustup target add aarch64-linux-android   # Android 64-bit (principal)
rustup target add armv7-linux-androideabi  # Android 32-bit (anciens téléphones)
rustup target add aarch64-apple-ios        # iOS
```

### Compilation Android

```bash
cd zolt_engine

# Release optimisé (LTO activé, symbols strippés)
cargo build --release --target aarch64-linux-android

# Copier dans le projet Flutter
cp target/aarch64-linux-android/release/libzolt_engine.so \
   ../votre_app_flutter/android/app/src/main/jniLibs/arm64-v8a/
```

### Compilation iOS

```bash
cargo build --release --target aarch64-apple-ios
# Intégrer libzolt_engine.a dans Xcode → Build Phases → Link Binary With Libraries
```

### Lancer les tests

```bash
cargo test
# Attendu : 15+ tests passent, 0 échouent
```

### Wrapper Dart minimal

```dart
// pubspec.yaml : ajouter ffi: ^2.0.0

import 'dart:ffi';
import 'dart:convert';
import 'package:ffi/ffi.dart';

class ZoltEngine {
  static final _lib = DynamicLibrary.open('libzolt_engine.so');

  static final _run = _lib.lookupFunction<
    Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>),
    Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>)
  >('zolt_run');

  static final _free = _lib.lookupFunction<
    Void Function(Pointer<Utf8>),
    void Function(Pointer<Utf8>)
  >('zolt_free');

  static Map<String, dynamic> compute({
    required Map<String, dynamic> input,
    required List<dynamic> history,
  }) {
    final inputPtr   = jsonEncode(input).toNativeUtf8();
    final historyPtr = jsonEncode(history).toNativeUtf8();
    final resultPtr  = _run(inputPtr, historyPtr);

    malloc.free(inputPtr);
    malloc.free(historyPtr);

    final json = resultPtr.toDartString();
    _free(resultPtr);

    final result = jsonDecode(json) as Map<String, dynamic>;
    if (result.containsKey('error')) {
      throw Exception('ZoltEngine: ${result['error']}');
    }
    return result;
  }
}
```

---

## 11. Questions fréquentes

**Q : Le moteur peut-il crasher et faire planter l'app ?**
Non. Toutes les erreurs sont capturées et retournées comme JSON d'erreur. Le moteur n'utilise jamais `panic!` en mode release (`panic = "abort"` dans Cargo.toml assure une terminaison propre dans le pire des cas).

**Q : Que se passe-t-il si l'utilisateur n'a qu'un seul cycle d'historique ?**
Les modules B, C et D fonctionnent en mode dégradé ou silencieux. Seul le module A tente d'apprendre ce qu'il peut. Aucun message trompeur n'est affiché.

**Q : Le moteur est-il thread-safe ?**
Oui. Le moteur est entièrement stateless — il ne modifie aucune variable globale. Il peut être appelé depuis n'importe quel thread Flutter.

**Q : Comment gérer les transactions SMS non confirmées ?**
Les transactions avec `sms_confidence < 0.7` ne doivent pas être incluses dans `EngineInput.transactions` tant qu'elles ne sont pas validées par l'utilisateur. Pour les transactions à confiance haute (≥ 0.9), elles peuvent être incluses immédiatement.

**Q : Comment l'utilisateur "accepte" une suggestion du Module D ?**
Flutter affiche la suggestion avec un bouton "Accepter". Si l'utilisateur accepte, Flutter met à jour le paramètre concerné dans SQLite et appelle `zolt_run()` avec les nouveaux paramètres. Le moteur ne gère pas cet état — c'est Flutter qui est responsable de la persistance des préférences.

**Q : La taille du binaire compilé ?**
Environ 300-500 KB pour le `.so` Android release (LTO + strip activés). Négligeable pour une app mobile.

---

*Documentation générée le 04/03/2026 — Zolt Engine v1.0.0*
