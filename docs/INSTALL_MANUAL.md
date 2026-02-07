# 📂 Installation Manuelle APK (Sans ADB)

## 🎯 Méthode Simple - Transfert Manuel

**ADB ne fonctionne pas** → Pas de problème ! Méthode manuelle garantie.

---

## 📱 ÉTAPES SIMPLES

### 1️⃣ Préparer le téléphone
**Sur ton téléphone Android** :
1. Connecte le câble USB au PC
2. Tire la **barre de notification** (swipe du haut)
3. Tu verras **"USB pour..."** ou **"Charge via USB"**
4. **Clique dessus**
5. Sélectionne **"Transfert de fichiers"** (ou "MTP")
   - PAS "Charge seulement"
   - PAS "Transfert de photos" (PTP)

### 2️⃣ Ouvrir l'explorateur de fichiers
**Sur ton PC Linux** :
1. Ouvre ton **Gestionnaire de fichiers** (Nautilus/Dolphin/Thunar)
2. Dans la barre latérale gauche, tu devrais voir :
   - **Ton téléphone** (ex: "Galaxy A52" ou "SM-A525F")
3. **Double-clique** sur ton téléphone

### 3️⃣ Copier l'APK
**Dans l'explorateur** :
1. Navigue vers le dossier **Download** de ton téléphone
   - Ou **Téléchargements**
   - Ou directement la **racine** (Stockage interne)
   
2. **Ouvre un deuxième onglet/fenêtre** :
   - Va vers `/home/kenzoobryan/eep/Budgetease/`
   - Trouve `BudgetEase-MVP-v1.0.apk` (44 MB)

3. **Glisse-dépose** ou **Copie-Colle** l'APK vers ton téléphone

### 4️⃣ Installer sur le téléphone
**Sur ton téléphone** :
1. Déconnecte le câble USB
2. Ouvre **Mes Fichiers** / **Gestionnaire de fichiers**
3. Va dans **Download** / **Téléchargements**
4. Tu verras `BudgetEase-MVP-v1.0.apk`
5. **Clique dessus**
6. Si popup "Sources inconnues" :
   - ✅ Autoriser cette source
7. **Installer**
8. **Ouvrir** → L'app se lance ! 🚀

---

## 💡 Alternative : Via Terminal

Si l'explorateur ne marche pas :

```bash
# Trouver où le téléphone est monté
gio mount -l | grep mtp

# Copier l'APK (remplace DEVICE_PATH)
cp BudgetEase-MVP-v1.0.apk "/run/user/$(id -u)/gvfs/mtp:host=*/Download/"
```

---

## ✅ C'est Parti !

**L'APK est prêt** : `/home/kenzoobryan/eep/Budgetease/BudgetEase-MVP-v1.0.apk`

Une fois copié sur ton téléphone et installé, tu pourras :
- 🎯 Tester la navigation verticale
- 🛡️ Voir l'écran Shield
- 📜 Voir l'écran History
- 💰 Tester l'UI du Flow

**Bonne installation !** 📱✨
