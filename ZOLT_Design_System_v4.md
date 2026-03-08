# Zolt — Design System v4.0
> *Terre & café. Chaleur organique. West African warmth.*

**Philosophie v4** : Fini le monochrome froid. Zolt vit dans des tons chauds — beige, café, marron, terre de Sienne. Une app qui ressemble à l'environnement physique de ses utilisateurs : les marchés, les tissus, la chaleur de l'Afrique de l'Ouest. En sombre, la chaleur persiste : ambre profond, acajou, brun fumé. Jamais de noir pur ni de blanc froid.

---

## Ce qui change vs v3

| Élément | v3 | v4 |
|---|---|---|
| Fond clair | `#FAFAF7` ivoire froid | **`#F5EFE6`** beige sable chaud |
| Fond sombre | `#080807` noir presque pur | **`#1C1410`** brun nuit profond |
| Surfaces claires | Blanc + gris froids | **Crème, cappuccino, latte** |
| Surfaces sombres | Gris charbons | **Acajou, brun fumé, café torréfié** |
| Accent principal | Noir + or | **Café foncé `#3D1F0D` + terracotta** |
| Conseil IA | Card gris neutre | **Card warm muted — fond café clair, texte naturel** |
| Icônes | Lucide, couleur text | **Lucide avec couleur thématique selon contexte** |
| Bottom nav | FAB cercle coupé | **Tab étendu ou FAB intégré flush** |
| Tutoriel | Absent | **Visite guidée interactive 8 étapes** |
| Paramètres | Multi-sections | **3 groupes max** |

---

## 1. Palette

### 1.1 Fonds & Surfaces — Mode Clair

| Token | Hex | Nom | Usage |
|---|---|---|---|
| `bg` | `#F5EFE6` | Sable | Scaffold principal |
| `bg_deep` | `#EDE4D8` | Lin | Zones enfoncées, drawer |
| `surface_0` | `#F5EFE6` | = bg | Flush |
| `surface_1` | `#FBF7F2` | Crème | Cards standard |
| `surface_2` | `#EDE4D8` | Latte | Cards secondaires, chips |
| `surface_3` | `#E2D5C4` | Cappuccino | Cards imbriquées |
| `surface_4` | `#D4C3AD` | Caramel | Hover, accents surface |
| `surface_inverse` | `#2C1810` | Expresso | Hero card inversée |
| `surface_glass` | `rgba(245,239,230,0.80)` | Sable glass | Glassmorphism |

### 1.2 Fonds & Surfaces — Mode Sombre

| Token | Hex | Nom | Usage |
|---|---|---|---|
| `bg` | `#1C1410` | Nuit café | Scaffold principal |
| `bg_deep` | `#140E0A` | Nuit profonde | Zones plus sombres |
| `surface_1` | `#251A13` | Acajou nuit | Cards standard |
| `surface_2` | `#2F2118` | Brun fumé | Cards secondaires |
| `surface_3` | `#3A2A1E` | Chocolat | Cards surélevées |
| `surface_4` | `#4A3628` | Moka | Hover, chips actives |
| `surface_inverse` | `#F5EFE6` | Sable | Hero card inversée |
| `surface_glass` | `rgba(28,20,16,0.82)` | Nuit glass | Glassmorphism |

> **Pourquoi ça fonctionne en sombre ?** Les bruns sombres (`#1C1410`, `#251A13`) ne sont pas froids comme les gris. Ils évoquent le café, la terre, un intérieur chaud. L'écran respire sans agresser.

### 1.3 Texte

| Token | Clair | Sombre |
|---|---|---|
| `text_primary` | `#2C1810` | `#F0E8DC` |
| `text_secondary` | `rgba(44,24,16,0.62)` | `rgba(240,232,220,0.62)` |
| `text_tertiary` | `rgba(44,24,16,0.38)` | `rgba(240,232,220,0.38)` |
| `text_disabled` | `rgba(44,24,16,0.22)` | `rgba(240,232,220,0.22)` |
| `text_inverse` | `#F0E8DC` | `#2C1810` |
| `text_accent` | `#7C3A1E` | `#D4956A` |

### 1.4 Accent & Brand

| Token | Hex | Usage |
|---|---|---|
| `brand` | `#7C3A1E` | Terracotta foncé — CTA principal, accent fort |
| `brand_light` | `#A85C35` | Hover, gradient |
| `brand_muted` | `rgba(124,58,30,0.12)` | Background badges brand |
| `brand_glow` | `rgba(124,58,30,0.28)` | Glow cards actives |
| `earth` | `#9C6B3C` | Ocre/caramel — accent secondaire |
| `earth_muted` | `rgba(156,107,60,0.12)` | Background earth |

### 1.5 Couleurs sémantiques

> Règle absolue : uniquement pour signaler un état. Jamais décoratives.

| Token | Hex | Muted | Glow |
|---|---|---|---|
| `positive` | `#2D7A4F` | `rgba(45,122,79,0.12)` | `rgba(45,122,79,0.28)` |
| `warning` | `#B8650A` | `rgba(184,101,10,0.12)` | `rgba(184,101,10,0.24)` |
| `critical` | `#B53B2A` | `rgba(181,59,42,0.12)` | `rgba(181,59,42,0.24)` |
| `info` | `#4A6E8A` | `rgba(74,110,138,0.12)` | `rgba(74,110,138,0.20)` |

> Les sémantiques sont légèrement désaturées par rapport à v3 pour s'harmoniser avec la palette chaude. Le vert est plus forêt, le rouge plus brique, le orange plus miel — tous cohérents avec les tons earth.

### 1.6 Premium

| Token | Hex | Usage |
|---|---|---|
| `gold` | `#B8892A` | Or légèrement plus chaud (harmonisé avec le beige) |
| `gold_light` | `#D4AE5C` | Highlights |
| `gold_muted` | `rgba(184,137,42,0.14)` | Background badges |
| `gold_glow` | `rgba(184,137,42,0.30)` | Ombre glow premium |

### 1.7 Bordures

| Token | Clair | Sombre |
|---|---|---|
| `border_faint` | `rgba(44,24,16,0.05)` | `rgba(240,232,220,0.05)` |
| `border_subtle` | `rgba(44,24,16,0.08)` | `rgba(240,232,220,0.08)` |
| `border_default` | `rgba(44,24,16,0.13)` | `rgba(240,232,220,0.11)` |
| `border_strong` | `rgba(44,24,16,0.22)` | `rgba(240,232,220,0.18)` |
| `border_brand` | `rgba(124,58,30,0.35)` | `rgba(212,149,106,0.35)` |

---

## 2. Icônes

### 2.1 Bibliothèque

**Lucide Icons** — stroke uniquement, stroke-width 1.5dp. Taille standard 22dp.  
Jamais d'emoji dans l'UI. Jamais.

### 2.2 Couleurs d'icônes selon contexte

Les icônes ne sont **pas** toujours `text_tertiary`. Elles ont une couleur thématique qui renforce la lisibilité du contexte.

| Contexte | Couleur icône | Justification |
|---|---|---|
| Navigation inactive | `text_tertiary` 38% | Discret, non prioritaire |
| Navigation active | `brand` `#7C3A1E` | Marquage fort de position |
| Revenu / Entrée | `positive` `#2D7A4F` | Vert = argent qui entre |
| Dépense / Sortie | `text_secondary` 62% | Neutre — les dépenses sont normales |
| Alerte / Critique | `critical` `#B53B2A` | Rouge = attention |
| Avertissement | `warning` `#B8650A` | Ambre = vigilance |
| Action principale | `text_inverse` sur fond brand | Contraste maximal |
| Premium / Lock | `gold` `#B8892A` | Identité premium |
| Catégorie Transport | `#4A6E8A` info | Identité propre |
| Catégorie Nourriture | `earth` `#9C6B3C` | Couleur naturelle |
| Catégorie Santé | `positive` | Vert médical |
| Catégorie Loisirs | `#7C3A1E` brand muted | Ton chaud sans urgence |
| Charge impayée | `warning` | À régler |
| Charge payée | `positive` | Réglé = tranquille |
| Info / Aide | `info` | Neutre informatif |
| Fraude détectée | `critical` pulsé | Danger |

### 2.3 Règles d'usage

- **stroke-width** : toujours 1.5dp (jamais 2dp qui fait trop lourd, jamais 1dp trop fin)
- **Taille** : 22dp standard, 18dp compact (listes), 28dp hero, 16dp badges
- **Jamais** de fond coloré sur une icône seule (sauf badge statut)
- **Icône + label** : gap 6dp, icône alignée verticalement avec la baseline du texte
- En mode sombre : les icônes colorées gardent leur couleur sémantique — elles ne deviennent jamais blanches

### 2.4 Icônes par section de l'app

```
Home          : home (brand actif) / home (tertiary inactif)
Transactions  : list (tertiary/brand)
Comptes       : wallet / credit-card
Ajouter       : plus → intégré (voir §Bottom Nav)
Paramètres    : settings (tertiary/brand)

Revenu        : arrow-down-circle (positive)
Dépense       : arrow-up-circle (text_secondary)
Transfert     : arrow-left-right (info)
MoMo          : smartphone (earth)
Epargne       : piggy-bank (positive)
Objectif      : target (brand)
Budget        : bar-chart-2 (brand)
Score santé   : activity (sémantique selon score)
Score crédit  : trending-up (positive / warning / critical)
Fraude        : shield-alert (critical)
Alerte        : alert-triangle (warning)
Succès        : check-circle (positive)
Verrou/Premium: lock (gold)
Déverrou      : unlock (gold)
Notifications : bell / bell-off (tertiary)
Aide/Tour     : compass (brand)
Paramètres    : settings-2 (tertiary)
Profil        : user-circle (tertiary)
Calendrier    : calendar (earth)
Triage        : inbox (warning si badge)
SMS parser    : message-square (info)
Export        : download (tertiary)
Partager      : share-2 (tertiary)
Fermer        : x (tertiary)
Retour        : arrow-left (tertiary)
```

---

## 3. Bottom Navigation — refonte

### 3.1 Concept : Tab bar pill intégrée

Abandon du FAB circulaire coupé dans la barre. Deux options selon le contexte :

**Option A — Tab bar avec action inline (recommandée)**
Le bouton d'ajout est un élément *à l'intérieur* de la barre, visuellement intégré, stylisé différemment des tabs mais sans casser la forme de la barre.

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  [🏠]    [📋]    [＋ Ajouter]    [💼]    [⚙️]      │
│  Home  Histor.  ─────────────  Comptes  Params     │
│         (pill brand centré, texte + icône)          │
└─────────────────────────────────────────────────────┘
```

Le tab central "Ajouter" :
- Background : `brand` `#7C3A1E` — pill arrondie `radius_full` dans la barre
- Texte : "Ajouter" en Cabinet Grotesk 12sp 600 `text_inverse`
- Icône : `plus` 18dp `text_inverse` à gauche du texte
- Taille : hauteur 38dp, padding H 16dp
- La barre garde sa hauteur uniforme — aucun débordement

**Option B — Speed dial (alternative pour accès rapide)**
Tap sur [+] ouvre un speed dial en overlay depuis la barre :

```
                      [SMS / MoMo]    icône: message-square
                   [Dépense manuelle]  icône: minus-circle
                   [Revenu manuel]     icône: plus-circle
                   ─────────────────
[ Home ]  [ Liste ]  [  ×  ]  [ Compte ]  [ Params ]
```
Les options montent avec stagger 60ms, fond scrim `surface_glass blur 16dp`.

### 3.2 Specs complètes de la barre

```
Background   : surface_glass (blur 20dp, saturation 1.15)
Bordure top  : 1dp border_subtle
Border radius: 0 (flush) — ou 20dp top-left/top-right si floating
Hauteur      : 64dp + safe area iOS/Android

Tab inactif :
  Icône    : 22dp, text_tertiary
  Label    : Cabinet Grotesk 10sp 500, text_tertiary
  Gap      : 4dp icône → label

Tab actif :
  Icône    : 22dp, brand (#7C3A1E clair / #D4956A sombre)
  Label    : Cabinet Grotesk 10sp 700, brand
  Indicateur: pill 3dp height, largeur = label + 16dp, brand 15% opacity, centré sous le label

Tab Ajouter (central) :
  Pill     : brand, height 38dp, radius_full, padding H 16dp
  Icône    : plus 18dp text_inverse
  Texte    : "Ajouter" 12sp 600 text_inverse
  Ombre    : 0 2dp 8dp brand_glow + 0 1dp 2dp rgba(0,0,0,0.10)
```

---

## 4. Conseil IA — nouvelle présentation

### 4.1 Problème v3

La card "conseil IA" avec fond gris neutre + texte long + icône générique = évidence que c'est du texte machine. Ça casse la confiance.

### 4.2 Solution v4 : Le message Zolt comme conversation naturelle

**Principe** : Pas de card qui crie "IA". Le message de Zolt est présenté comme un message de conversation discret — comme un SMS d'un ami qui connaît tes finances.

```
Design de la card message Zolt :

Background   : surface_1 (crème) en clair / surface_2 en sombre
Border-left  : 3dp brand (#7C3A1E) — seul marqueur d'identité Zolt
Border radius: 0 à gauche, 14dp droite+bas
Padding      : 14dp 16dp 14dp 18dp
Ombre        : aucune (flat, discret)

En-tête :
  Icône contextuelle (22dp, couleur sémantique) — PAS le logo IA
  Texte court en bold (le fait brut) — text_primary
  Gap 8dp

Corps :
  Texte explicatif (1-2 lignes max) — text_secondary 62%
  Aucun bullet point, aucune liste, phrase naturelle

Pied :
  Action CTA ghost très petite : "Voir le détail →" brand, 13sp
  Aligné à droite

Exemples de titres sans saveur IA :
  ❌ "Analyse de vos habitudes financières"
  ✅ "Tu dépenses 23% de plus le vendredi"

  ❌ "Recommandation budgétaire basée sur l'IA"
  ✅ "À ce rythme, il te reste 8 700 FCFA à fin de cycle"

  ❌ "Insight comportemental détecté"
  ✅ "Mois difficile — mode serré activé"
```

### 4.3 Icônes contextuelles pour chaque type de message

```
Budget dépassé       → alert-triangle (warning)
Fin de mois serrée   → trending-down (critical)
Bonne progression    → trending-up (positive)
Anomalie dépense     → search (info)
Prédiction           → calendar-clock (info brand)
Score santé          → activity (sémantique)
Fraude               → shield-alert (critical)
Épargne atteinte     → check-circle (positive)
Charge impayée       → clock (warning)
Conseil économie     → lightbulb (earth)
```

---

## 5. Tutoriel — Visite guidée interactive

### 5.1 Déclenchement

- **Première ouverture** : automatique après onboarding
- **Depuis Paramètres** : "Revoir la visite guidée" (section Aide)
- **Depuis Home** : bouton discret compass `22dp` `brand` en haut droite, 7 premiers jours seulement

### 5.2 Système de tooltip highlight

```
Overlay      : scrim #1C1410 72% sur tout l'écran
Découpe      : région transparente + border brand 2dp + radius matching le composant
Tooltip card :
  Background : surface_inverse
  Radius     : 14dp
  Padding    : 16dp
  Ombre      : 0 8dp 24dp rgba(0,0,0,0.24)
  Position   : above / below / trailing selon l'espace disponible
  Flèche     : 8dp triangle solid surface_inverse, centrée

Navigation :
  Bouton "Suivant" : brand pill — "Suivant (N/8)"
  Bouton "Passer"  : ghost text_tertiary, aligné gauche
  Progress dots    : 8 dots, actif = brand 8dp, inactif = border_default 6dp
```

### 5.3 Les 8 étapes de la visite

**Étape 1 — Budget du jour**
- Highlight : Hero card Budget du jour
- Titre : "Ton budget de la journée"
- Texte : "Zolt calcule chaque matin combien tu peux dépenser. La barre te dit où tu en es."

**Étape 2 — Solde & Santé**
- Highlight : Colonne droite (Solde + Score santé)
- Titre : "Ton solde et ta santé financière"
- Texte : "Le score 0-100 résume l'état de tes finances ce cycle. Vert = bien, ambre = surveiller."

**Étape 3 — Transactions & triage**
- Highlight : Zone triage en bas de Home
- Titre : "Tes transactions MoMo arrivent ici"
- Texte : "Chaque SMS MoMo est lu automatiquement. Glisse à droite pour confirmer, à gauche pour ignorer."

**Étape 4 — Ajouter une transaction**
- Highlight : Tab Ajouter dans la barre
- Titre : "Ajouter manuellement"
- Texte : "Pour une dépense en espèces ou un revenu non-MoMo, appuie ici."

**Étape 5 — Comptes**
- Highlight : Tab Comptes
- Titre : "Tes comptes Mobile Money"
- Texte : "Gère MTN, Moov, Orange, Wave dans un seul endroit. Zolt lit les soldes depuis tes SMS."

**Étape 6 — Messages Zolt**
- Highlight : Section messages sur Home
- Titre : "Zolt t'observe et te prévient"
- Texte : "Ces messages viennent de l'analyse de tes habitudes. Pas de notification inutile — uniquement quand c'est utile."

**Étape 7 — Mode fin de mois serré** *(Premium)*
- Highlight : Bannière tight mode (si active) ou simulation
- Titre : "Mode fin de mois serré"
- Texte : "Quand Zolt détecte un risque de déficit, le budget est ajusté automatiquement et un calendrier des jours critiques est généré."

**Étape 8 — Score de crédit** *(Premium)*
- Highlight : Card Score Zolt dans Comptes ou Home
- Titre : "Ton Score Zolt"
- Texte : "Un score de crédit basé sur ton vrai comportement financier — pas une banque, mais un point de départ pour accéder à des microprêts."

**Fin de visite**
```
Card plein écran (bottom sheet) :
  Icône compass 48dp brand, centré
  Titre : "Tu connais Zolt." (28sp 800)
  Sous-titre : "Reviens ici depuis les paramètres si tu as besoin d'un rappel."
  CTA : "C'est parti →" brand, pleine largeur
```

---

## 6. Paramètres — 3 groupes maximum

### 6.1 Principe

Fini les 6-8 sections avec des titres compliqués. Les paramètres de Zolt tiennent en **3 groupes** sans sous-menus inutiles.

### 6.2 Structure

```
╔══════════════════════════════════════╗
║  ← Paramètres                        ║
╠══════════════════════════════════════╣
║                                      ║
║  [avatar initiale] Kofi Mensah        ║
║  Compte gratuit / Premium jusqu'au…  ║
║  [Gérer mon abonnement]  →            ║
║                                      ║
╠══ MON COMPTE ════════════════════════╣
║  Prénom et préférences    →          ║
║  Mes comptes MoMo          →          ║
║  Charges et revenus récurrents →     ║
║  Données & Export          →          ║
║                                      ║
╠══ APPARENCE & APP ═══════════════════╣
║  Thème      [Clair / Sombre / Auto]  ║
║  Langue     [Français / English]     ║
║  Notifications [toggle]              ║
║  Widget écran d'accueil  →           ║
║                                      ║
╠══ AIDE ══════════════════════════════╣
║  Revoir la visite guidée   →         ║
║  Comment fonctionne Zolt ? →         ║
║  Nous contacter            →         ║
║                                      ║
║  Version 1.5.0 · Zolt                ║
║  [Supprimer mon compte]  ← rouge     ║
╚══════════════════════════════════════╝
```

### 6.3 Design de chaque item

```
Hauteur item    : 54dp
Padding H       : 20dp
Icône gauche    : 20dp, text_tertiary (couleur thématique si applicable)
Label           : body_md text_primary
Valeur actuelle : body_sm text_tertiary alignée droite
Chevron         : chevron-right 16dp text_tertiary (items navigables)
Toggle          : Switch Flutter natif, track brand

Groupes :
  Label section  : overline 10sp 600, letter-spacing 1.4, text_tertiary
  Padding top    : 24dp, padding bottom : 4dp
  Dividers       : 1dp border_faint entre items, PAS avant/après la section

Item destructif (Supprimer mon compte) :
  Texte          : critical #B53B2A
  Icône          : trash-2, critical
  Pas de chevron — tap → confirmation bottom sheet
```

---

## 7. Tokens Flutter v4 complets

### 7.1 Couleurs

```dart
// lib/core/theme/zolt_colors.dart

class ZoltColors {
  // ── Fonds Clair ──────────────────────────────────────────
  static const lightBg         = Color(0xFFF5EFE6); // Sable
  static const lightBgDeep     = Color(0xFFEDE4D8); // Lin
  static const lightSurface1   = Color(0xFFFBF7F2); // Crème
  static const lightSurface2   = Color(0xFFEDE4D8); // Latte
  static const lightSurface3   = Color(0xFFE2D5C4); // Cappuccino
  static const lightSurface4   = Color(0xFFD4C3AD); // Caramel
  static const lightInverse    = Color(0xFF2C1810); // Expresso
  static const lightGlass      = Color(0xCCF5EFE6); // Sable glass

  // ── Fonds Sombre ──────────────────────────────────────────
  static const darkBg          = Color(0xFF1C1410); // Nuit café
  static const darkBgDeep      = Color(0xFF140E0A); // Nuit profonde
  static const darkSurface1    = Color(0xFF251A13); // Acajou nuit
  static const darkSurface2    = Color(0xFF2F2118); // Brun fumé
  static const darkSurface3    = Color(0xFF3A2A1E); // Chocolat
  static const darkSurface4    = Color(0xFF4A3628); // Moka
  static const darkInverse     = Color(0xFFF5EFE6); // Sable
  static const darkGlass       = Color(0xD11C1410); // Nuit glass

  // ── Texte Clair ───────────────────────────────────────────
  static const lightText1      = Color(0xFF2C1810); // Expresso
  static const lightText2      = Color(0x9E2C1810); // 62%
  static const lightText3      = Color(0x612C1810); // 38%
  static const lightText4      = Color(0x382C1810); // 22%
  static const lightTextInv    = Color(0xFFF0E8DC);

  // ── Texte Sombre ──────────────────────────────────────────
  static const darkText1       = Color(0xFFF0E8DC);
  static const darkText2       = Color(0x9EF0E8DC); // 62%
  static const darkText3       = Color(0x61F0E8DC); // 38%
  static const darkText4       = Color(0x38F0E8DC); // 22%
  static const darkTextInv     = Color(0xFF2C1810);

  // ── Brand / Accent ────────────────────────────────────────
  static const brand           = Color(0xFF7C3A1E); // Terracotta
  static const brandLight      = Color(0xFFA85C35);
  static const brandMuted      = Color(0x1F7C3A1E);
  static const brandGlow       = Color(0x477C3A1E);
  static const brandDark       = Color(0xFFD4956A); // Terracotta clair (sombre)

  static const earth           = Color(0xFF9C6B3C); // Ocre
  static const earthMuted      = Color(0x1F9C6B3C);

  // ── Sémantiques ───────────────────────────────────────────
  static const positive        = Color(0xFF2D7A4F);
  static const positiveMuted   = Color(0x1F2D7A4F);
  static const positiveGlow    = Color(0x472D7A4F);

  static const warning         = Color(0xFFB8650A);
  static const warningMuted    = Color(0x1FB8650A);
  static const warningGlow     = Color(0x3DB8650A);

  static const critical        = Color(0xFFB53B2A);
  static const criticalMuted   = Color(0x1FB53B2A);
  static const criticalGlow    = Color(0x3DB53B2A);

  static const info            = Color(0xFF4A6E8A);
  static const infoMuted       = Color(0x1F4A6E8A);

  // ── Premium ───────────────────────────────────────────────
  static const gold            = Color(0xFFB8892A);
  static const goldLight       = Color(0xFFD4AE5C);
  static const goldMuted       = Color(0x24B8892A);
  static const goldGlow        = Color(0x4DB8892A);

  // ── Bordures ──────────────────────────────────────────────
  // Clair
  static const lBorderFaint    = Color(0x0D2C1810);
  static const lBorderSubtle   = Color(0x142C1810);
  static const lBorderDefault  = Color(0x212C1810);
  static const lBorderStrong   = Color(0x382C1810);
  // Sombre
  static const dBorderFaint    = Color(0x0DF0E8DC);
  static const dBorderSubtle   = Color(0x14F0E8DC);
  static const dBorderDefault  = Color(0x1CF0E8DC);
  static const dBorderStrong   = Color(0x2EF0E8DC);
}
```

### 7.2 Ombres

```dart
// lib/core/theme/zolt_shadows.dart

class ZoltShadows {
  // Ombres de base — warm tinted (légèrement teintées brun vs noir pur)
  static List<BoxShadow> card() => [
    BoxShadow(color: Color(0x0A2C1810), blurRadius: 4, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x142C1810), blurRadius: 16, offset: Offset(0, 4), spreadRadius: -2),
  ];

  static List<BoxShadow> hero() => [
    BoxShadow(color: Color(0x0A2C1810), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x1E2C1810), blurRadius: 32, offset: Offset(0, 8), spreadRadius: -4),
  ];

  static List<BoxShadow> glowBrand() => [
    ...card(),
    BoxShadow(color: Color(0x477C3A1E), blurRadius: 20, offset: Offset(0, 4), spreadRadius: -4),
  ];

  static List<BoxShadow> glowPositive() => [
    ...card(),
    BoxShadow(color: Color(0x472D7A4F), blurRadius: 20, offset: Offset(0, 4), spreadRadius: -4),
  ];

  static List<BoxShadow> glowWarning() => [
    ...card(),
    BoxShadow(color: Color(0x3DB8650A), blurRadius: 20, offset: Offset(0, 4), spreadRadius: -4),
  ];

  static List<BoxShadow> glowCritical() => [
    ...card(),
    BoxShadow(color: Color(0x3DB53B2A), blurRadius: 20, offset: Offset(0, 4), spreadRadius: -4),
  ];

  static List<BoxShadow> glowPremium() => [
    BoxShadow(color: Color(0x4DB8892A), blurRadius: 24, offset: Offset(0, 6), spreadRadius: -4),
  ];

  static List<BoxShadow> bottomNav() => [
    BoxShadow(color: Color(0x142C1810), blurRadius: 20, offset: Offset(0, -4)),
  ];
}
```

### 7.3 Thème Flutter complet

```dart
// lib/core/theme/zolt_theme.dart

ThemeData zoltLightTheme() => ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: ZoltColors.lightBg,
  colorScheme: ColorScheme.light(
    primary:   ZoltColors.brand,
    secondary: ZoltColors.earth,
    surface:   ZoltColors.lightSurface1,
    error:     ZoltColors.critical,
    onPrimary: ZoltColors.lightTextInv,
    onSurface: ZoltColors.lightText1,
  ),
  fontFamily: 'CabinetGrotesk',
  dividerColor: ZoltColors.lBorderSubtle,
  cardColor: ZoltColors.lightSurface1,
);

ThemeData zoltDarkTheme() => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: ZoltColors.darkBg,
  colorScheme: ColorScheme.dark(
    primary:   ZoltColors.brandDark,
    secondary: ZoltColors.earth,
    surface:   ZoltColors.darkSurface1,
    error:     ZoltColors.critical,
    onPrimary: ZoltColors.darkTextInv,
    onSurface: ZoltColors.darkText1,
  ),
  fontFamily: 'CabinetGrotesk',
  dividerColor: ZoltColors.dBorderSubtle,
  cardColor: ZoltColors.darkSurface1,
);
```

---

## 8. Mise à jour du Home — Layout Bento avec v4

### 8.1 Hero card inversée v4

En mode clair :
```
Background : #2C1810 (Expresso)
Grain overlay : noise SVG 3%, opacity 40%
Teinte grain : légèrement ambre (pas monochrome noir)
```

En mode sombre :
```
Background : #FBF7F2 (Crème)
Grain overlay : noise SVG 3%, opacity 30%
```

La hero card inversée en v4 a une chaleur que la v3 n'avait pas — fond expresso vs fond noir pur.

### 8.2 Messages Zolt v4

La section "Messages" ne s'appelle plus "Conseils IA" ni "Insights".  
Elle s'appelle simplement **"Zolt dit"** (ou rien — juste les cards directement).

Chaque message :
- Icône contextuelle (voir §4.3) — jamais une ampoule générique seule
- Titre = fait chiffré ou court, direct
- Maximum 2 lignes de texte
- CTA "Voir →" uniquement si une action est disponible

---

## 9. Do & Don't v4

### ✅ Do

- Utiliser les tons chauds `#F5EFE6`, `#FBF7F2`, `#2C1810` comme base systématique
- Icônes Lucide stroke 1.5dp, couleur thématique selon contexte (pas toujours gris)
- Tab Ajouter intégré dans la barre (pill brand), jamais de FAB qui dépasse
- Messages Zolt : titre factuel court, icône contextuelle, jamais "basé sur l'IA"
- 3 groupes en paramètres : Mon Compte / Apparence & App / Aide
- Tutoriel : 8 étapes avec highlight scrim + tooltip, accessible depuis paramètres
- Ombres teintées brun (`#2C1810`) plutôt que noir pur pour la cohérence

### ❌ Don't

- `#000000` ou `#FFFFFF` pur nulle part dans l'app
- Emoji dans l'UI — icônes Lucide uniquement
- FAB qui coupe le bottom nav ou déborde au-dessus
- Titres de messages contenant les mots "IA", "analyse", "algorithme", "insight"
- Icônes toujours `text_tertiary` peu importe le contexte
- Plus de 3 sections dans les paramètres
- `Curves.bounceOut` ou spring exagéré

---

## 10. Récapitulatif des changements par écran

| Écran | Changement v4 |
|---|---|
| **Home** | Fond sable `#F5EFE6`, hero expresso `#2C1810`, messages renommés "Zolt dit" avec icônes contextuelles |
| **Bottom Nav** | Tab Ajouter pill brand intégré, indicateur actif = pill fond brand 15% |
| **Transactions** | Icône revenu = vert, icône dépense = text_secondary, icône MoMo = earth |
| **Comptes** | Surface cappuccino pour les cards opérateur |
| **Paramètres** | 3 groupes : Mon Compte / Apparence & App / Aide |
| **Tutoriel** | 8 étapes highlight + tooltip, accessible depuis paramètres (Aide) |
| **Score santé** | Icône `activity` sémantique, arc couleur sémantique |
| **Fraude** | Icône `shield-alert` critical, card rouge muted |
| **Mode serré** | Icône `trending-down` critical, bannière ambre |
| **Premium** | Lock icon gold, gradient brand plus chaud |

---

*Zolt Design System v4.0 — Mars 2026*
*Sable · Café · Expresso · Terracotta*
*Cabinet Grotesk + Zodiak — Lucide Icons 1.5dp stroke*
*Compatible Flutter 3.x — Null safety — Dark & Light mode*
