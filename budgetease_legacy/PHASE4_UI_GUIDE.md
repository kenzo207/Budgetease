# Phase 4: Liquid UI Implementation Guide

> **Objectif** : Transformer BudgetEase en un organisme financier vivant avec une UI liquide, gestures naturels et navigation verticale.

## 🎯 Vision

L'interface ne doit plus ressembler à une app bancaire froide, mais à un **organisme vivant** qui respire avec vos finances.

## 📋 Composants à créer

### 1. Liquid Gauge (Bulle centrale)
**Fichier** : `lib/widgets/liquid_gauge.dart`

**Caractéristiques** :
- Bulle liquide animée représentant le Daily Cap
- Couleurs dynamiques selon l'état :
  - 🟢 **Vert calme** : > 70% restant
  - 🟠 **Orange agité** : 30-70% restant
  - 🔴 **Rouge bouillant** : < 30% restant
- Animations Rive pour le liquide
- Tap → affiche breakdown détaillé
- Long press → mode privacy

**Données affichées** :
```dart
- Daily Cap restant (gros chiffre central)
- % utilisé (petit texte)
- Jours restants (en bas)
```

### 2. Gesture Input System
**Fichier** : `lib/widgets/gesture_transaction_input.dart`

**Concept** :
- Icônes flottantes des wallets (💵 Cash, 📱 MoMo, etc.)
- **Drag & Drop** vers la bulle centrale = ajouter dépense
- **Swipe up** = ajouter revenu
- Dialog contextuel pendant le drag
- Haptic feedback à chaque étape

**Flow** :
1. User drag icône wallet → bulle devient réceptive (pulsation)
2. Release sur bulle → modal rapide montant + catégorie
3. Validation → animation liquide (bulle baisse)
4. Toast confirmation

### 3. Vertical Navigation
**Fichier** : `lib/screens/vertical_home_screen.dart`

**Structure** :
```
┌─────────────────┐
│   SHIELD (Up)   │  ← Scroll vers haut
│  Charges fixes  │
│  Dettes, SOS    │
├─────────────────┤
│  FLOW (Center)  │  ← Position initiale
│  Liquid Gauge   │
│  Daily Cap      │
├─────────────────┤
│ HISTORY (Down)  │  ← Scroll vers bas
│  Transactions   │
│  Statistiques   │
└─────────────────┘
```

**Implémentation** :
- `PageView` vertical avec 3 pages
- Snap automatique
- Indicateur visuel de position
- Gestes fluides

### 4. Wallets Screen
**Fichier** : `lib/screens/wallets_screen.dart`

**Design** :
- Cartes colorées par wallet
- Balance en gros
- Icône + nom
- Tap → détails + historique
- FAB → dialog transfer

**Exemple carte** :
```
┌───────────────────────┐
│ 💵 Cash               │
│                       │
│ 25,000 FCFA          │
│ ━━━━━━━━━━━━━ 45%   │ (% du total)
└───────────────────────┘
```

### 5. Shield Screen
**Fichier** : `lib/screens/shield_screen.dart`

**Sections** :
1. **Header** : Total Shield ce mois
2. **Charges fixes** : Liste avec dates d'échéance
3. **Dettes** : Progress bars
4. **SOS Reserve** : Carte spéciale

**Alertes** :
- Badge rouge si échéance < 7 jours
- Notification dettes presque remboursées

## 🎨 Design System

### Couleurs
```dart
// Flow states
static const flowHealthy = Color(0xFF4CAF50);    // Vert
static const flowWarning = Color(0xFFFF9800);    // Orange
static const flowDanger = Color(0xFFF44336);     // Rouge

// Shield
static const shieldBlue = Color(0xFF2196F3);
static const shieldDark = Color(0xFF1565C0);

// Backgrounds
static const bgDark = Color(0xFF121212);
static const bgCard = Color(0xFF1E1E1E);
```

### Animations
- **Liquid** : Rive file `assets/rive/liquid_gauge.riv`
- **Transitions** : 300ms ease-in-out
- **Haptics** : medium impact pour feedback

## 📦 Packages nécessaires

Déjà installés :
- ✅ `provider` (state management)
- ✅ `isar` (database)

À ajouter :
- `rive` pour animations liquides
- `flutter_animate` pour micro-animations
- Optionnel : `lottie` pour animations alternatives

## 🚀 Ordre d'implémentation

### Week 8 : Liquid Gauge
1. Installer Rive
2. Créer animation liquide dans Rive
3. Widget `LiquidGauge` basique
4. Intégrer données Daily Cap
5. États couleurs dynamiques

### Week 9 : Gestures
1. Widget `GestureTransactionInput`
2. Drag & drop wallet → bulle
3. Haptic feedback
4. Modal quick add
5. Tests UX

### Week 10 : Vertical Nav
1. `VerticalHomeScreen` avec PageView
2. Shield section (haut)
3. Flow section (centre)
4. History section (bas)
5. Smooth scroll + snap

### Week 11 : Polish
1. Micro-animations
2. Loading states
3. Error handling
4. Empty states
5. Accessibility

## 💡 Notes importantes

### Performance
- Limiter frame rate Rive à 30fps sur low-end devices
- Lazy load historique (pagination)
- Cache images/animations

### UX
- Toujours donner feedback immédiat
- Animations < 300ms
- Gestures doivent être intuitifs sans tutorial

### Tests
- Tester sur vrai device (gestures)
- Vérifier performance Android budget phones
- Tests accessibility (TalkBack, VoiceOver)

## 📚 Ressources

- [Rive Documentation](https://rive.app/community/doc/flutter/docWXSsRqwBx)
- [Flutter Gestures Guide](https://docs.flutter.dev/development/ui/advanced/gestures)
- [Material Design - Motion](https://m3.material.io/styles/motion/overview)
