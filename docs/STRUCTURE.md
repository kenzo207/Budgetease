# 📁 Structure du Repository BudgetEase

```
Budgetease/
│
├── 📱 budgetease_flutter/          # Application Flutter principale
│   ├── lib/                        # Code source Dart
│   │   ├── database/              # Tables Drift & DB config
│   │   ├── services/              # Logique métier
│   │   ├── screens/               # Écrans UI
│   │   ├── widgets/               # Composants réutilisables
│   │   ├── providers/             # State management (Provider)
│   │   ├── utils/                 # Helpers & utilities
│   │   └── main.dart              # Entry point
│   │
│   ├── android/                    # Configuration Android
│   ├── assets/                     # Images, fonts
│   ├── test/                       # Tests unitaires
│   └── pubspec.yaml                # Dépendances Flutter
│
├── 📦 builds/                      # APK builds
│   ├── budgetease-latest.apk      # ✅ Version actuelle (v3.1)
│   └── old-versions/              # Archives builds précédents
│       ├── BudgetEase-MVP-v1.0.apk
│       ├── BudgetEase-Drift-v2.0.apk
│       └── BudgetEase-Premium-v3.0.apk
│
├── 📚 docs/                        # Documentation
│   ├── INSTALLATION_GUIDE.md       # Guide installation
│   ├── ADB_AUTHORIZATION.md        # Setup ADB
│   ├── ADB_TROUBLESHOOTING.md      # Debug ADB
│   ├── INSTALL_MANUAL.md           # Installation manuelle
│   ├── FINAL_OPTIONS.md            # Options finales
│   └── build-history/             # Historique de build
│       ├── BUILD_SESSION_SUMMARY.md
│       ├── BUILD_SUCCESS.md
│       └── DEADLOCK_REPORT.md
│
├── 🔧 scripts/                     # Scripts utilitaires
│   ├── build_and_install.sh       # Build + install auto
│   └── patch_isar.sh              # (Obsolète - Isar retiré)
│
├── 📄 README.md                    # Documentation principale
├── 📋 user_flow.md                 # Diagramme UX détaillé
├── 📊 user_flow.mmd                # Mermaid diagram
└── .gitignore                      # Git ignore rules
```

---

## 🗂️ Organisation par Type

### Code Source Principal
- `budgetease_flutter/` → App Flutter complète

### Builds & Releases
- `budgetease-latest.apk` → Version actuelle (racine)
- `builds/old-versions/` → Archives versions précédentes

### Documentation
- `docs/` → Guides & documentation technique
- `docs/build-history/` → Rapports de build

### Développement
- `scripts/` → Automatisations & outils

---

## ✅ Fichiers Importants

| Fichier | Usage |
|---------|-------|
| `budgetease-latest.apk` | **APK à installer** (v3.1) |
| `README.md` | Documentation principale |
| `user_flow.md` | Flow UX complet |
| `budgetease_flutter/pubspec.yaml` | Dépendances projet |
| `budgetease_flutter/lib/main.dart` | Entry point app |

---

## 🧹 Nettoyage Effectué

### ✅ Supprimé
- `node_modules/` (Web - non utilisé)
- `dist/` (Build web - non utilisé)
- `src/` (Code web - non utilisé)
- `public/` (Assets web - non utilisés)
- Fichiers config web (package.json, vite.config, etc.)

### ✅ Organisé
- APKs → `builds/`
- Docs build → `docs/build-history/`
- Docs install → `docs/`
- Scripts → `scripts/`

### ✅ Renommé
- `BudgetEase-UX-v3.1.apk` → `budgetease-latest.apk`

---

## 🎯 Prochaines Étapes

1. **Développement** : Ajouter features dans `budgetease_flutter/`
2. **Build** : Générer APK avec scripts ou manuellement
3. **Release** : Copier APK vers `budgetease-latest.apk`
4. **Archive** : Déplacer ancienne version vers `builds/old-versions/`
5. **Documentation** : Mettre à jour README

---

**Repository propre et organisé !** ✨
