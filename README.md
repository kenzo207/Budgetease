# 💰 BudgetEase - Flow & Shield Budget App

**Version actuelle** : v3.1 (UX Améliorée)  
**Plateforme** : Flutter (Android)  
**Database** : Drift (SQLite)

---

## 🚀 Quick Start

### Installation
```bash
# Télécharger la dernière version
# APK: budgetease-latest.apk (48MB)

# Installer sur Android
adb install -r budgetease-latest.apk

# Ou transfert manuel vers téléphone
```

### Build depuis source
```bash
cd budgetease_flutter
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build apk --release --no-shrink
```

---

## 📱 Features

### ✅ Implémentées
- **Navigation verticale** : Swipe entre Shield / Flow / History
- **LiquidGauge animé** : Visualisation daily cap en temps réel
- **Multi-wallet** : Cash, MTN MoMo, Orange Money, Bank
- **Shield System** : Fixed charges, debts, SOS fund
- **Daily Cap Calculator** : Flow & Shield budget logic
- **Transaction History** : Historique complet
- **Dark Theme Premium** : Interface moderne

### 🚧 En Développement
- Formulaires ajout transactions
- Shield items management complet
- Charts & statistics
- Export data
- Settings screen

---

## 🏗️ Architecture

### Tech Stack
- **Framework** : Flutter 3.38.9
- **Database** : Drift 2.31.0 (SQLite)
- **State Management** : Provider
- **UI** : Material Design 3
- **Platform** : Android (API 21+)

### Structure
```
budgetease_flutter/
├── lib/
│   ├── database/          # Drift tables & DB
│   ├── services/          # Business logic
│   ├── screens/           # UI screens
│   ├── widgets/           # Reusable widgets
│   ├── providers/         # State management
│   └── utils/             # Helpers
├── android/               # Android config
└── assets/                # Images, fonts

docs/                      # Documentation
builds/                    # APK versions
scripts/                   # Utility scripts
```

---

## 📚 Documentation

- **[User Flow](user_flow.md)** : Diagramme UX complet
- **[Build History](docs/build-history/)** : Historique builds & migrations
- **[Installation Guide](docs/INSTALLATION_GUIDE.md)** : Guide installation détaillé

---

## 🎨 Concept - Flow & Shield

**Flow** : Argent disponible quotidiennement après Shield  
**Shield** : Budget protégé (charges fixes, dettes, urgences)

**Formule** :
```
Daily Cap = (Total Balance - Shield Allocation) / Jours Restants
```

---

## 🔧 Development

### Requirements
- Flutter SDK 3.38.9+
- Android SDK (Platform 35)
- Dart 3.x

### Commands
```bash
# Get dependencies
flutter pub get

# Generate Drift code
dart run build_runner build

# Run debug
flutter run

# Build APK
flutter build apk --release

# Install via ADB
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

---

## 📦 Versions

### v3.1 (Current) - UX Améliorée
- Retrait emojis
- Icônes Material Design
- Navigation améliorée
- Design professionnel

### v3.0 - UI Premium
- Navigation verticale
- LiquidGauge animé
- 3 screens complets

### v2.0 - Migration Drift
- Migration complète Isar → Drift
- Résolution problèmes Android SDK

### v1.0 - MVP
- Proof of concept avec Hive
- UI basique

---

## 🤝 Contributing

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit (`git commit -m 'Add AmazingFeature'`)
4. Push (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

---

## 📄 License

MIT License - Voir LICENSE pour détails

---

## 👤 Author

**Kenzo O'Bryan**  
Project: BudgetEase - Personal Finance Manager

---

**Fait avec ❤️ et Flutter**
