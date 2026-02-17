# 🚀 Guide de Release - Zolt/BudgetEase

Ce document explique comment fonctionne le processus de release automatique pour l'application Zolt (BudgetEase).

## 📋 Processus Automatique

### Déclenchement

Le workflow de build se déclenche automatiquement :
- ✅ À chaque push sur la branche `main`
- ✅ Manuellement via l'interface GitHub Actions

### Étapes du Workflow

1. **Checkout du code** - Récupération du code source
2. **Setup Java 17** - Installation de l'environnement Java
3. **Setup Flutter 3.10.4** - Installation de Flutter (version du projet)
4. **Installation des dépendances** - `flutter pub get`
5. **Build de l'APK** - `flutter build apk --release`
6. **Extraction de la version** - Lecture depuis `pubspec.yaml`
7. **Création de la Release GitHub** - Avec tag automatique
8. **Upload de l'APK** - Attachement à la release

## 📦 Format de Release

### Nom du Tag
```
v{version}-build.{build_number}
```

**Exemple** : `v4.0.0-build.42`

### Nom de l'APK
```
budgetease-v{version}.apk
```

**Exemple** : `budgetease-v4.0.0.apk`

## 🔄 Comment Créer une Nouvelle Version

### Option 1 : Push sur Main (Automatique)

```bash
# 1. Mettre à jour la version dans pubspec.yaml
# Modifier la ligne : version: 4.1.0+2

# 2. Commit et push
git add budgetease_flutter/pubspec.yaml
git commit -m "chore: bump version to 4.1.0"
git push origin main

# 3. Le workflow se déclenche automatiquement
# Vérifier sur : https://github.com/kenzo207/Budgetease/actions
```

### Option 2 : Déclenchement Manuel

1. Aller sur https://github.com/kenzo207/Budgetease/actions
2. Sélectionner "Build and Release APK"
3. Cliquer sur "Run workflow"
4. Sélectionner la branche `main`
5. Cliquer sur "Run workflow"

## 📥 Téléchargement

### Lien Direct (Dernière Version)
```
https://github.com/kenzo207/Budgetease/releases/latest
```

### Lien Direct APK (Dernière Version)
```
https://github.com/kenzo207/Budgetease/releases/latest/download/budgetease-v{version}.apk
```

### Landing Page
La landing page pointe automatiquement vers la dernière release :
- https://budgetease.vercel.app (ou votre domaine)

## 🔒 Signature de l'APK

### État Actuel : Debug Signing

⚠️ **Important** : Actuellement, l'APK est signé avec les clés de **debug** (développement uniquement).

Configuration dans `android/app/build.gradle.kts` :
```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")
        // ...
    }
}
```

### Migration vers Production Signing (Future)

Pour une release en production, vous devrez :

1. **Créer un Keystore**
   ```bash
   keytool -genkey -v -keystore budgetease-release.keystore \
     -alias budgetease -keyalg RSA -keysize 2048 -validity 10000
   ```

2. **Configurer les Secrets GitHub**
   - `KEYSTORE_FILE` : Fichier keystore encodé en base64
   - `KEYSTORE_PASSWORD` : Mot de passe du keystore
   - `KEY_ALIAS` : Alias de la clé
   - `KEY_PASSWORD` : Mot de passe de la clé

3. **Modifier le Workflow**
   Ajouter une étape de signature avant le build :
   ```yaml
   - name: Decode Keystore
     run: |
       echo "${{ secrets.KEYSTORE_FILE }}" | base64 -d > android/app/release.keystore
   ```

4. **Mettre à jour build.gradle.kts**
   ```kotlin
   signingConfigs {
       create("release") {
           storeFile = file("release.keystore")
           storePassword = System.getenv("KEYSTORE_PASSWORD")
           keyAlias = System.getenv("KEY_ALIAS")
           keyPassword = System.getenv("KEY_PASSWORD")
       }
   }
   
   buildTypes {
       release {
           signingConfig = signingConfigs.getByName("release")
       }
   }
   ```

## 📊 Monitoring

### Vérifier le Build
1. Aller sur https://github.com/kenzo207/Budgetease/actions
2. Vérifier le statut du dernier workflow
3. Consulter les logs en cas d'erreur

### Vérifier la Release
1. Aller sur https://github.com/kenzo207/Budgetease/releases
2. Vérifier que la release est créée
3. Vérifier que l'APK est attaché

## 🐛 Troubleshooting

### Le workflow échoue au build
- Vérifier les logs dans GitHub Actions
- Vérifier que `pubspec.yaml` est valide
- Vérifier que toutes les dépendances sont disponibles

### L'APK n'est pas uploadé
- Vérifier que le build s'est terminé avec succès
- Vérifier les permissions du `GITHUB_TOKEN`
- Vérifier que le fichier APK existe dans le bon chemin

### La landing page ne télécharge pas l'APK
- Vérifier que la release existe sur GitHub
- Vérifier que l'APK est bien attaché à la release
- Vérifier le lien dans `landing/index.html`

## 📝 Notes

- **Limite de taille** : GitHub Releases supporte jusqu'à 2 GB par fichier
- **Rétention** : Les artifacts sont conservés 30 jours
- **Releases** : Les releases sont conservées indéfiniment
- **Versioning** : Suivre le format SemVer (Semantic Versioning)
