# Zolt

Application de gestion financiere personnelle, concue pour le marche africain francophone.  
100% local, donnees chiffrees, aucune connexion serveur.

**Plateforme** : Android  
**Version** : 4.0.0  
**Stack** : Flutter / Drift / SQLCipher / Riverpod

---

## Installation

La derniere version est disponible dans les [Releases](https://github.com/kenzo207/Budgetease/releases/latest).  
Telechargez `zolt.apk` et installez-le sur votre appareil Android.

### Build depuis les sources

```bash
cd budgetease_flutter
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build apk --release
```

L'APK genere se trouve dans `build/app/outputs/flutter-apk/app-release.apk`.

### Pre-requis

- Flutter SDK 3.38+
- Android SDK (API 24+)
- Dart 3.10+

---

## Fonctionnalites

### Gestion financiere
- Budget quotidien calcule selon le cycle financier (mensuel, hebdomadaire, journalier)
- Transactions : depenses, revenus, virements inter-comptes
- Frais de transaction pris en compte dans les calculs
- Comptes multiples (cash, MTN MoMo, Orange Money, carte bancaire)
- Categories personnalisables

### Detection SMS Mobile Money
- Lecture automatique des SMS operateurs (MTN MoMo, Wave, Orange, Moov)
- Extraction du montant, frais, contrepartie, reference, solde
- Ecran de validation avant ajout au budget
- Prevention des doublons

### Analyse
- Vue mensuelle des revenus, depenses et solde
- Repartition par categorie
- Navigation entre les mois

### Notifications
- Alertes budget (depassement, depense importante)
- Rappel quotidien
- Detection de nouvelles transactions SMS

### Securite
- Base de donnees chiffree (AES-256 via SQLCipher)
- Cle stockee dans Android Keystore
- Code PIN et authentification biometrique
- Mode discret (masquage des montants)
- Aucune donnee envoyee a l'exterieur

### Parametres
- Devises : FCFA, EUR, USD, GBP, CAD
- Theme : clair, sombre, systeme
- Export et restauration des donnees

---

## Architecture

```
budgetease_flutter/
  lib/
    config/           Configuration et theme
    core/             Constantes, utilitaires, formatters
    data/             Base de donnees Drift, DAOs, tables, migrations
    domain/           Services metier (budget, cycles, SMS, notifications)
    presentation/     Ecrans, providers Riverpod, widgets
    services/         Analytics
  android/            Configuration Android
  assets/             Images et icones
```

### Base de donnees

6 tables : settings, accounts, categories, transactions, recurring_charges, pending_transactions.  
Schema version 6 avec migrations chainees (v1 a v6).

### Calcul du budget

```
Budget quotidien = (Solde total - Charges fixes - Epargne - Transport) / Jours restants du cycle
```

---

## Dependances principales

| Dependance | Usage |
|---|---|
| drift | Base de donnees SQLite |
| sqlcipher_flutter_libs | Chiffrement |
| flutter_riverpod | Gestion d'etat |
| flutter_local_notifications | Notifications |
| flutter_sms_inbox | Lecture SMS |
| posthog_flutter | Analytics |
| local_auth | Biometrie |
| fl_chart | Graphiques |

---

## Licence

MIT

---

Kenzo O'Bryan
