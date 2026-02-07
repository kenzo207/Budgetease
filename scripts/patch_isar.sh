#!/bin/bash

# Script pour patcher Isar et corriger le problème de namespace Android

echo "🔧 Patch Isar Flutter Libs pour compatibilité Android Gradle..."

# Trouver le fichier build.gradle d'Isar
ISAR_BUILD_FILE="$HOME/.pub-cache/hosted/pub.dev/isar_flutter_libs-3.1.0+1/android/build.gradle"

if [ ! -f "$ISAR_BUILD_FILE" ]; then
    echo "❌ Fichier Isar build.gradle non trouvé"
    exit 1
fi

# Vérifier si le namespace est déjà ajouté
if grep -q "namespace" "$ISAR_BUILD_FILE"; then
    echo "✅ Namespace déjà présent dans Isar build.gradle"
    exit 0
fi

# Backup original
cp "$ISAR_BUILD_FILE" "${ISAR_BUILD_FILE}.backup"

# Ajouter le namespace après la ligne "android {"
sed -i '/android {/a\    namespace "dev.isar.isar_flutter_libs"' "$ISAR_BUILD_FILE"

echo "✅ Patch appliqué avec succès!"
echo "📄 Backup créé: ${ISAR_BUILD_FILE}.backup"
echo ""
echo "Vous pouvez maintenant relancer: flutter build apk --release"
