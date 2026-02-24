# 📱 Zolt V4 - Fonctionnalités

**Version**: 4.0.0 | **Plateforme**: Android | **Type**: Gestion Financière Local-First

---

## 🎯 Vue d'Ensemble

Application de gestion financière personnelle avec chiffrement des données, conçue pour le marché africain francophone.

---

## ✅ Fonctionnalités Principales

### 🚀 Onboarding
- Parcours d'accueil en 8 écrans
- Configuration initiale (nom, devise, budget)
- Création du premier compte bancaire
- Demande de permissions (SMS, notifications)

### 🏠 Dashboard
- Résumé financier mensuel (revenus, dépenses, solde)
- Carrousel de cartes interactives (Budget quotidien, Solde total, Comptes)
- Graphiques de répartition par catégorie
- Mode discret (masquage des montants)
- Bouton d'action rapide pour créer une transaction

### 💸 Transactions
- Création de transactions (Dépense, Revenu, Virement)
- Liste groupée par date avec formatage français
- Filtres par type et recherche
- Suppression avec confirmation
- Affichage détaillé (montant, catégorie, compte, note, frais)

### 📊 Analyse
- Vue mensuelle avec navigation
- Cartes récapitulatives (revenus, dépenses, solde)
- Répartition détaillée par catégorie
- Graphiques en secteurs et barres
- Comparaison avec mois précédent

### 🏦 Gestion
- Comptes bancaires multiples avec soldes en temps réel
- Virements inter-comptes
- Catégories personnalisées (création, modification, suppression)
- Catégories par défaut pré-configurées
- Protection contre suppression de catégories utilisées

### ⚙️ Paramètres
- **Profil**: Nom, devise (FCFA, EUR, USD, GBP, CAD)
- **Apparence**: Thème Noir & Blanc (Clair/Sombre/Système), Bordures colorées (8 couleurs)
- **Notifications**: Alertes budget, Check-in quotidien
- **SMS**: Détection automatique Mobile Money (Wave, Orange, MTN, Moov)
- **Données**: Sauvegarde, Restauration, Réinitialisation
- **Sécurité**: Chiffrement SQLCipher, Mode discret

### 🔔 Notifications
- Alertes budget avec jauge visuelle
- Rappels quotidiens à 20h
- Notifications personnalisées style "Zolt"

### 📲 SMS Mobile Money
- Parsing automatique des SMS
- Détection de 4 opérateurs (Wave, Orange, MTN, Moov)
- Écran de validation des transactions détectées
- Prévention des doublons

### 📈 Analytics
- Intégration PostHog
- Tracking des événements (onboarding, transactions, navigation)
- Respect de la vie privée

### 🛡️ Sécurité
- Base de données chiffrée (SQLCipher)
- Stockage sécurisé des clés
- 100% Local-First (aucune connexion serveur)
- Contrôle total des données

---

## 🚀 Fonctionnalités Avancées (Phase 7)

- **Prédiction de revenus**: Analyse des patterns et prédiction du prochain revenu
- **Ghost Money**: Détection des micro-dépenses et calcul de l'impact
- **Profil comportemental**: Analyse de la fréquence et des patterns horaires
- **Conseils personnalisés**: Recommandations basées sur le comportement

---

## 📊 Chiffres Clés

- **15+ écrans** fonctionnels
- **9 tables** en base de données
- **15+ providers** Riverpod
- **7 services** métier
- **30+ dépendances**
- **5 devises** supportées
- **4 opérateurs** Mobile Money détectés

---

## ⚠️ En Développement

- Modification de transactions
- Export/Import JSON/CSV
- Authentification biométrique
- Code PIN
- Gestion des charges récurrentes

---

## 🏆 Points Forts

✅ 100% Local-First  
✅ Chiffrement SQLCipher  
✅ Interface Noir & Blanc moderne  
✅ Personnalisation complète  
✅ SMS Auto-detect  
✅ Notifications intelligentes  
✅ Multi-comptes illimité  
✅ Français natif  

---

**Dernière mise à jour**: Février 2026  
**Statut**: ✅ Production Ready
