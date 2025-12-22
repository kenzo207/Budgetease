# BudgetEase

Application de gestion budgétaire simple et locale, adaptée au contexte africain.

## Fonctionnalités

- ✅ Enregistrement rapide des dépenses et revenus
- ✅ Visualisation par période (jour/semaine/mois)
- ✅ Graphiques de répartition par catégorie
- ✅ Budgets mensuels avec alertes
- ✅ Support multi-devises (FCFA, NGN, GHS, USD, EUR)
- ✅ Export CSV
- ✅ Données 100% locales (IndexedDB)
- ✅ PWA - Fonctionne hors-ligne
- ✅ Rappels quotidiens (selon support navigateur)

## Installation

### Prérequis

- Node.js 18+ et npm

### Étapes

```bash
# Installer les dépendances
npm install

# Lancer en développement
npm run dev

# Build pour production
npm run build

# Prévisualiser le build
npm run preview
```

## Déploiement

### Vercel (recommandé)

```bash
# Installer Vercel CLI
npm i -g vercel

# Déployer
vercel
```

### Netlify

```bash
# Build
npm run build

# Le dossier dist/ contient les fichiers à déployer
```

## Structure du Projet

```
src/
├── components/       # Composants réutilisables
│   ├── ui/          # Composants de base (Button, Card, etc.)
│   ├── layout/      # Layout (Header, BottomNav, FAB)
│   ├── dashboard/   # Composants dashboard
│   ├── transactions/# Composants transactions
│   └── budgets/     # Composants budgets
├── screens/         # Écrans principaux
├── lib/             # Logique métier
│   ├── db.ts        # Configuration Dexie
│   ├── calculations.ts
│   ├── currency.ts
│   ├── export.ts
│   ├── notifications.ts
│   └── recurring.ts
└── types/           # Types TypeScript
```

## Technologies

- **React 18** + **TypeScript**
- **Vite** - Build tool
- **Tailwind CSS** - Styling
- **Dexie.js** - IndexedDB wrapper
- **Recharts** - Graphiques
- **date-fns** - Manipulation dates
- **vite-plugin-pwa** - PWA support

## Utilisation

### Premier lancement

1. Sélectionnez votre devise
2. Configurez le rappel quotidien (optionnel)
3. Choisissez 3 catégories favorites

### Ajouter une transaction

1. Cliquez sur le bouton `+` flottant
2. Sélectionnez Dépense ou Revenu
3. Remplissez le montant, catégorie, moyen de paiement
4. Ajoutez une note (optionnel)
5. Enregistrez

### Créer un budget

1. Allez dans l'onglet "Budgets"
2. Cliquez sur "Créer"
3. Sélectionnez une catégorie
4. Définissez le montant mensuel

### Exporter les données

1. Allez dans "Paramètres"
2. Cliquez sur "Exporter en CSV"
3. Le fichier sera téléchargé automatiquement

## Limitations & Fallbacks

### Notifications (iOS Safari)

Les notifications push ne sont pas supportées sur iOS Safari. Un fallback in-app est implémenté :
- Banner de rappel visible dans l'application
- Badge sur l'icône Paramètres

### Synchronisation

Le MVP ne supporte pas la synchronisation multi-appareils. Les données sont stockées localement uniquement.

**Recommandation** : Exportez régulièrement vos données en CSV.

### Offline

L'application fonctionne entièrement hors-ligne après la première visite. Les assets sont mis en cache automatiquement.

## Support Navigateurs

- ✅ Chrome/Edge (Desktop & Android)
- ✅ Firefox (Desktop & Android)
- ✅ Safari (Desktop & iOS) - notifications limitées
- ✅ Samsung Internet

## Développement

### Ajouter une catégorie par défaut

Modifiez `src/lib/db.ts` dans la fonction `initializeDefaultData()`.

### Ajouter une devise

1. Ajoutez la devise dans `src/types/index.ts`
2. Configurez le formatage dans `src/lib/currency.ts`

### Tests

```bash
# Tests unitaires (à implémenter)
npm run test
```

## Licence

MIT

## Contact

Pour toute question ou suggestion, ouvrez une issue sur GitHub.
