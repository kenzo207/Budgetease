# 🔧 Troubleshooting ADB Unauthorized

## ❌ Problème Actuel
Téléphone toujours **unauthorized** après redémarrage ADB

## 🔍 Checklist Vérification

### 1. Débogage USB Activé ?
**Sur ton téléphone** :
- Paramètres → À propos du téléphone
- Tape 7x sur "Numéro de build" → Mode Dev activé ✅
- Paramètres → Options développeur
- **Débogage USB** → ✅ ACTIVÉ (switch vert)

### 2. Mode Connexion USB
**Dans la barre de notification** :
- Tire la barre du haut
- Tu dois voir "USB pour..."
- Clique dessus
- Sélectionne **"Transfert de fichiers"** (MTP)
- PAS "Charge seulement"

### 3. Popup d'autorisation
**Déverrouille ton téléphone complètement** :
- Pas sur l'écran de verrouillage
- Déverrouille avec PIN/motif
- Va sur l'écran d'accueil
- La popup devrait apparaître

### 4. Révocation anciennes clés
Si tu as eu d'autres connexions ADB avant :
- Paramètres → Options développeur
- **Révoquer les autorisations de débogage USB**
- Redé connecte le câble USB

## 🔌 Alternative : Transfert Manuel

Si ADB ne fonctionne pas, on peut :
1. Ouvrir l'explorateur de fichiers Linux
2. Le téléphone apparaîtra comme périphérique
3. Copier l'APK vers Download/
4. Installer depuis le téléphone

**Veux-tu essayer ça à la place ?**
