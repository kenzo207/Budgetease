#!/bin/bash

# Script de build et installation pour BudgetEase V3.5
# Assurez-vous que votre téléphone est connecté et le débogage USB activé.

echo "🚀 Préparation du build V3.5 Behavioral..."

cd budgetease_flutter

# 1. Nettoyage
echo "🧹 Nettoyage..."
flutter clean
flutter pub get

# 2. Génération de code (hive adapter)
# Nous l'avons fait manuellement, mais c'est bien de le refaire proprement si possible
echo "🏭 Génération des adaptateurs..."
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Installation
echo "📱 Compilation et Installation sur le device..."
flutter run --release

echo "✅ Terminé !"
