# 🔌 ADB USB - Autorisation Téléphone

## ✅ État Actuel

**ADB détecté** : ✅ Fonctionnel  
**Téléphone connecté** : ✅ Device `R5CY72G00ZZ` détecté  
**Statut** : ⚠️ **UNAUTHORIZED** (non autorisé)

---

## 📱 ACTION REQUISE SUR TON TÉLÉPHONE

### Popup à autoriser

Sur ton téléphone Android, tu dois voir une **popup** :

```
┌─────────────────────────────────────┐
│  Autoriser le débogage USB ?        │
│                                      │
│  L'empreinte RSA de cet            │
│  ordinateur est :                   │
│  XX:XX:XX:...                       │
│                                      │
│  [ ] Toujours autoriser depuis     │
│      cet ordinateur                 │
│                                      │
│  [Annuler]           [OK]          │
└─────────────────────────────────────┘
```

### Étapes :
1. ✅ **Coche** la case "Toujours autoriser depuis cet ordinateur"
2. ✅ **Appuie sur OK**

---

## 🔧 Si tu ne vois pas la popup

### Vérifications :
1. **Débogage USB activé ?**
   - Paramètres → Options développeur → Débogage USB ✅

2. **Mode de connexion USB correct ?**
   - Notification USB → Sélectionne **"Transfert de fichiers"** (MTP)

3. **Réveiller le téléphone**
   - Appuie sur le bouton power
   - Déverrouille l'écran
   - La popup devrait apparaître

### Forcer une nouvelle demande :
```bash
# Redémarrer ADB server
~/Android/Sdk/platform-tools/adb kill-server
~/Android/Sdk/platform-tools/adb start-server
~/Android/Sdk/platform-tools/adb devices
```

---

## ⏭️ Prochaine Étape

Une fois autorisé, je lancerai :
```bash
~/Android/Sdk/platform-tools/adb install -r BudgetEase-MVP-v1.0.apk
```

L'app s'installera automatiquement sur ton téléphone ! 🚀

---

**Dis-moi quand tu as autorisé la connexion USB** ✅
