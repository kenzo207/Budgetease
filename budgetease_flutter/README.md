# BudgetEase v4.0

**Version**: 4.0.0 "Professional Banking Edition"  
**Architecture**: Clean Architecture + Riverpod + Drift (SQLCipher)

## 🚀 Démarrage Rapide

### Prérequis
- Flutter SDK 3.10.4+
- Android SDK 34+
- Dart 3.0+

### Installation

```bash
cd budgetease_v4
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Lancer l'application

```bash
flutter run
```

### Build APK

```bash
flutter build apk --release
```

---

## 📁 Structure du Projet

```
budgetease_v4/
├── lib/
│   ├── core/                    # Utilitaires & Constantes
│   ├── data/                    # Base de données & DAOs
│   ├── domain/                  # Services métier
│   ├── presentation/            # UI & Providers
│   └── config/                  # Configuration
├── pubspec.yaml
└── build.yaml
```

---

## ✅ Phases Complétées

### Phase 1: Architecture & Setup ✅
- ✅ Structure Clean Architecture
- ✅ Base de données Drift + SQLCipher (6 tables)
- ✅ Services métier (Budget Calculator, Cycle Manager, Transport Manager)
- ✅ Configuration thème dark bancaire

### Phase 2: Sécurité & Authentification ✅
- ✅ SecurityService (biométrie + PIN)
- ✅ LockScreen avec support biométrie
- ✅ PinScreen avec clavier numérique
- ✅ Providers Riverpod pour la sécurité
- ✅ Gestion des sessions

---

## 🔐 Sécurité

- **Chiffrement DB**: AES-256 via SQLCipher
- **Clé stockée**: Android Keystore (flutter_secure_storage)
- **Authentification**: Biométrie + PIN
- **Verrouillage auto**: 60 secondes d'inactivité

---

## 🧮 Algorithme du Budget Quotidien

```dart
Daily Cap = (Solde Total - Charges Fixes - Épargne - Transport) / Jours Restants
```

---

## 📦 Dépendances Principales

- `flutter_riverpod`: State management
- `drift`: Base de données SQLite
- `sqlcipher_flutter_libs`: Chiffrement
- `local_auth`: Biométrie
- `telephony`: Parsing SMS
- `google_fonts`: Typographie

---

## 🚧 Prochaines Étapes

- [ ] Phase 3: Onboarding (8 écrans)
- [ ] Phase 4: Providers Riverpod
- [ ] Phase 5: Interface Utilisateur
- [ ] Phase 6: Parsing SMS
- [ ] Phase 7: Tests & Build

---

**Développé avec ❤️ pour l'Afrique**
