# Zolt — Design System v3.0
> *Monochrome premium. Cabinet Grotesk. Ivoire & noir profond.*

**Philosophie v3** : Le monochrome est l'identité. La couleur est un signal.  
L'ivoire remplace le blanc. Cabinet Grotesk remplace Inter. Les ombres ont une âme.  
Chaque écran doit donner l'impression d'une app qui coûte cher à faire.

---

## Ce qui change vs v2

| Élément | v2 | v3 |
|---|---|---|
| Police | Inter | **Cabinet Grotesk** + **Zodiak** (montants) |
| Fond clair | `#F7F7F5` | **`#FAFAF7`** ivoire pur |
| Fond sombre | `#0A0A0A` | **`#080807`** noir organique chaud |
| Ombres | Flat (élévation 0) | Douces monochromes + **glow sémantique** |
| Cards | Flat uniforme | **3 profils visuels distincts** (Hero / Standard / Ghost) |
| Disposition Home | Carrousel horizontal | **Layout asymétrique Bento** avec hiérarchie forte |
| Textures | Grain sur hero uniquement | **Grain ivoire global subtil** (noise 2%) |
| Bordures | `rgba` uniform | **Bordures à gradient** sur cartes premium |

---

## 1. Palette

### 1.1 Fonds & Surfaces — Mode Clair

| Token | Hex | Usage |
|---|---|---|
| `bg` | `#FAFAF7` | Scaffold principal — ivoire pur |
| `bg_deep` | `#F3F1EC` | Zones enfoncées, drawer, sidebar |
| `surface_0` | `#FAFAF7` | Même que bg (flush) |
| `surface_1` | `#FFFFFF` | Cards standard — blanc pur sur ivoire = contraste parfait |
| `surface_2` | `#F5F3EE` | Cards secondaires, chips, inputs |
| `surface_3` | `#EDEAE3` | Cards imbriquées, dividers actifs |
| `surface_inverse` | `#0D0D0B` | Hero card inversée (noir organique) |
| `surface_glass` | `rgba(255,255,255,0.72)` | Overlay glassmorphism (modals flottants) |

### 1.2 Fonds & Surfaces — Mode Sombre

| Token | Hex | Usage |
|---|---|---|
| `bg` | `#080807` | Scaffold principal — noir chaud, pas pur |
| `bg_deep` | `#050504` | Zones plus profondes |
| `surface_1` | `#131311` | Cards standard |
| `surface_2` | `#1A1A18` | Cards secondaires |
| `surface_3` | `#222220` | Cards surélevées, bottom sheets |
| `surface_4` | `#2A2A27` | Hover, chips actives |
| `surface_inverse` | `#FAFAF7` | Hero card inversée (ivoire) |
| `surface_glass` | `rgba(20,20,18,0.78)` | Overlay glassmorphism sombre |

### 1.3 Texte

| Token | Clair | Sombre |
|---|---|---|
| `text_primary` | `#0D0D0B` | `#F5F3EE` |
| `text_secondary` | `rgba(13,13,11,0.58)` | `rgba(245,243,238,0.58)` |
| `text_tertiary` | `rgba(13,13,11,0.35)` | `rgba(245,243,238,0.35)` |
| `text_disabled` | `rgba(13,13,11,0.20)` | `rgba(245,243,238,0.20)` |
| `text_inverse` | `#F5F3EE` | `#0D0D0B` |

> **Ivoire dans le texte** : `text_primary` en clair n'est pas `#000000` mais `#0D0D0B` — légèrement chaud, cohérent avec le fond ivoire. L'ensemble respire.

### 1.4 Couleurs sémantiques

> Règle absolue : ces couleurs n'apparaissent QUE pour signaler un état.  
> Jamais décoratives. Jamais dans les titres. Jamais sur les dépenses normales.

| Token | Hex | Muted (bg) | Glow (ombre) |
|---|---|---|---|
| `positive` | `#16A34A` | `rgba(22,163,74,0.10)` | `rgba(22,163,74,0.25)` |
| `warning` | `#D97706` | `rgba(217,119,6,0.10)` | `rgba(217,119,6,0.22)` |
| `critical` | `#DC2626` | `rgba(220,38,38,0.10)` | `rgba(220,38,38,0.22)` |
| `info` | `#4B6E9E` | `rgba(75,110,158,0.10)` | `rgba(75,110,158,0.20)` |

### 1.5 Premium

| Token | Hex | Usage |
|---|---|---|
| `gold` | `#C9973A` | Badge, icônes, CTA paywall |
| `gold_light` | `#E8B96A` | Highlights, shimmer |
| `gold_muted` | `rgba(201,151,58,0.14)` | Background badges |
| `gold_glow` | `rgba(201,151,58,0.30)` | Ombre bouton Premium |

### 1.6 Bordures

| Token | Clair | Sombre |
|---|---|---|
| `border_faint` | `rgba(13,13,11,0.05)` | `rgba(245,243,238,0.05)` |
| `border_subtle` | `rgba(13,13,11,0.08)` | `rgba(245,243,238,0.08)` |
| `border_default` | `rgba(13,13,11,0.12)` | `rgba(245,243,238,0.10)` |
| `border_strong` | `rgba(13,13,11,0.22)` | `rgba(245,243,238,0.18)` |

**Bordure gradient** (cards hero et Premium) :
```dart
// Effet premium : bordure qui passe de plus clair à plus sombre
gradient: LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Colors.white.withOpacity(0.20),
    Colors.white.withOpacity(0.04),
  ],
)
```

---

## 2. Typographie

### 2.1 Familles de polices

| Famille | Usage | Source |
|---|---|---|
| **Cabinet Grotesk** | Tous les textes UI, titres, corps, boutons | Fontshare (gratuit) |
| **Zodiak** | Montants FCFA uniquement | Fontshare (gratuit) |

**Pourquoi Cabinet Grotesk ?**  
Humaniste moderne, lettres légèrement plus larges que Inter, excellente lisibilité en petite taille sur Android. Le `G` majuscule a une personnalité forte. En français, les accents sont parfaitement dessinés. Utilisé par des apps fintech premium (Revolut redesign, Mansa).

**Pourquoi Zodiak pour les montants ?**  
Police à chiffres fixes (oldstyle + tabular). Les chiffres ont plus de caractère et de poids visuel qu'Inter. `150 000` en Zodiak Medium ressemble à un montant sur une carte bancaire physique.

### 2.2 Chargement Flutter

```dart
// pubspec.yaml
flutter:
  fonts:
    - family: CabinetGrotesk
      fonts:
        - asset: assets/fonts/CabinetGrotesk-Regular.otf
          weight: 400
        - asset: assets/fonts/CabinetGrotesk-Medium.otf
          weight: 500
        - asset: assets/fonts/CabinetGrotesk-Semibold.otf
          weight: 600
        - asset: assets/fonts/CabinetGrotesk-Bold.otf
          weight: 700
        - asset: assets/fonts/CabinetGrotesk-Extrabold.otf
          weight: 800
    - family: Zodiak
      fonts:
        - asset: assets/fonts/Zodiak-Regular.otf
          weight: 400
        - asset: assets/fonts/Zodiak-Medium.otf
          weight: 500
        - asset: assets/fonts/Zodiak-Bold.otf
          weight: 700
```

### 2.3 Échelle typographique

| Token | Police | Taille | Poids | Interligne | Usage |
|---|---|---|---|---|---|
| `display_xl` | Cabinet Grotesk | 40sp | 800 | 46 | Écrans onboarding hero |
| `display` | Cabinet Grotesk | 32sp | 700 | 38 | Budget journalier hero |
| `headline_lg` | Cabinet Grotesk | 24sp | 700 | 30 | Titres d'écran |
| `headline_md` | Cabinet Grotesk | 20sp | 600 | 26 | Titres de section |
| `headline_sm` | Cabinet Grotesk | 17sp | 600 | 22 | Titres de carte |
| `body_lg` | Cabinet Grotesk | 15sp | 400 | 22 | Corps principal |
| `body_md` | Cabinet Grotesk | 14sp | 400 | 20 | Corps secondaire (58% opacity) |
| `body_sm` | Cabinet Grotesk | 13sp | 400 | 18 | Labels, chips |
| `caption` | Cabinet Grotesk | 11sp | 500 | 16 | Dates, métadonnées |
| `button` | Cabinet Grotesk | 15sp | 600 | — | Labels boutons |
| `overline` | Cabinet Grotesk | 10sp | 600 | 14 | Section labels uppercase |
| `amount_hero` | Zodiak | 44sp | 700 | 48 | Montant hero principal |
| `amount_xl` | Zodiak | 32sp | 700 | 36 | Montant hero card |
| `amount_lg` | Zodiak | 24sp | 600 | 28 | Montants cartes |
| `amount_md` | Zodiak | 18sp | 500 | 22 | Montants listes |
| `amount_sm` | Zodiak | 14sp | 500 | 18 | Petits montants |
| `amount_xs` | Zodiak | 12sp | 400 | 16 | Métadonnées montants |

### 2.4 Règles typographiques

- **Montants** : toujours Zodiak, jamais Cabinet Grotesk
- **Devise "FCFA"** : Cabinet Grotesk 400, 70% opacity, après le montant Zodiak — les deux polices cohabitent dans le même `RichText`
- **Section labels** : `overline` uppercase, letter-spacing 1.2dp, `text_tertiary`
- **Messages Zolt** : Cabinet Grotesk 400, 85% opacity, pas d'italique
- **Séparateur milliers** : espace fine `\u202F` — `150 000` pas `150000` ni `150,000`

---

## 3. Ombres — Le système en 3 couches

### 3.1 Ombres de base (toutes les cards)

Deux couches superposées pour un effet naturel :

```dart
// Ombre douce — couche 1 (ambient)
BoxShadow(
  color: Color(0x0A0D0D0B),  // noir 4% en clair / ajusté sombre
  blurRadius: 4,
  offset: Offset(0, 1),
)
// Ombre directionnelle — couche 2 (key)
BoxShadow(
  color: Color(0x120D0D0B),  // noir 7%
  blurRadius: 16,
  offset: Offset(0, 4),
  spreadRadius: -2,
)
```

En mode **sombre** : les ombres n'ont aucun effet (fond déjà sombre).  
À la place : bordure gradient subtile + légère élévation de surface.

### 3.2 Ombres hero (carte Budget)

```dart
// Ombre profonde sur la hero card
BoxShadow(
  color: Color(0x1A0D0D0B),  // noir 10%
  blurRadius: 32,
  offset: Offset(0, 8),
  spreadRadius: -4,
)
BoxShadow(
  color: Color(0x0A0D0D0B),
  blurRadius: 8,
  offset: Offset(0, 2),
)
```

### 3.3 Glow sémantique (états actifs uniquement)

> Apparaît uniquement quand une card est dans un état sémantique actif.  
> Subtil — perceptible mais jamais agressif.

```dart
// Glow positif (budget respecté, revenu, épargne)
BoxShadow(
  color: Color(0x4016A34A),  // vert 25%
  blurRadius: 20,
  offset: Offset(0, 4),
  spreadRadius: -4,
)

// Glow warning (budget à 80%+)
BoxShadow(
  color: Color(0x38D97706),  // ambre 22%
  blurRadius: 20,
  offset: Offset(0, 4),
  spreadRadius: -4,
)

// Glow critique (dépassement, retard)
BoxShadow(
  color: Color(0x38DC2626),  // rouge 22%
  blurRadius: 20,
  offset: Offset(0, 4),
  spreadRadius: -4,
)

// Glow premium (card paywall, badge or)
BoxShadow(
  color: Color(0x4DC9973A),  // or 30%
  blurRadius: 24,
  offset: Offset(0, 6),
  spreadRadius: -4,
)
```

---

## 4. Cards — 4 profils visuels

### Profil A — Hero Card (Budget Journalier)

La pièce maîtresse. Inversée, texturée, avec ombre profonde.

```
Background   : surface_inverse (#0D0D0B en clair / #FAFAF7 en sombre)
Border radius: 24dp
Bordure      : gradient 1dp (blanc 18% → blanc 4%) en haut-gauche → bas-droite
Ombre        : ombre hero (§3.2) + glow sémantique selon état budget
Texture      : noise SVG 3%, opacity 35% en overlay — grain de café
Padding      : 22dp
Largeur      : 220dp dans le carrousel

Contenu :
  ├── [overline] "BUDGET DU JOUR" — text_inverse 40%
  ├── [amount_xl] Montant Zodiak — text_inverse
  ├──  "FCFA" Cabinet Grotesk 500 text_inverse 55%
  ├── Barre progress 3dp (ombre glow selon état)
  └── [body_sm] "Il te reste X FCFA" — text_inverse 65%
```

### Profil B — Card Standard

Propre, lumineuse, légèrement élevée grâce aux ombres douces.

```
Background   : surface_1 (#FFFFFF en clair / #131311 en sombre)
Border radius: 18dp
Bordure      : 1dp border_subtle
Ombre        : ombre base 2 couches (§3.1)
Padding      : 18dp ou 20dp
```

### Profil C — Card Ghost / Secondaire

Pour les éléments de second plan. Presque invisible, structure pure.

```
Background   : transparent
Border radius: 16dp
Bordure      : 1dp border_faint
Ombre        : aucune
Padding      : 16dp
```

### Profil D — Card Sémantique (Messages Zolt, alertes)

```
Background   : muted color (10% opacity) sur surface_1
Border radius: 14dp
Border left  : 3.5dp pleine hauteur, couleur sémantique
Bordure      : 1dp border_faint
Ombre        : glow sémantique (§3.3) — intensité 60% du glow normal
Padding      : 14dp 16dp

Critical : bg #DC2626/10 + border #DC2626 + glow rouge
Warning  : bg #D97706/10 + border #D97706 + glow ambre
Positive : bg #16A34A/10 + border #16A34A + glow vert
Info     : bg surface_2 + border border_default, sans glow
```

---

## 5. Layout Home — Bento Asymétrique

### 5.1 Principe

Abandonner le carrousel horizontal uniforme. Adopter un **layout Bento** :  
les cards ont des tailles différentes et créent une grille visuelle avec une hiérarchie immédiate.

```
┌─────────────────────────────────┐
│  HEADER                         │  Fond bg, padding 20dp
│  "Bonjour Kofi 👋"  [🔕] [👁]   │
└─────────────────────────────────┘

┌──────────────────┐ ┌───────────┐
│                  │ │  SOLDE    │  Row 1 — gap 12dp
│  BUDGET DU JOUR  │ │  TOTAL    │
│  [HERO INVERSÉE] │ │ ──────────│  Hero : 2/3 largeur
│  44sp Zodiak     │ │  SANTÉ    │  Right col : 1/3
│  220dp hauteur   │ │  74/100   │
└──────────────────┘ └───────────┘

┌─────────────────────────────────┐
│  MES COMPTES                    │  Row 2 — full width
│  MTN •••• 150 000  Orange ••••  │  Card Standard Profil B
└─────────────────────────────────┘

  [PRÉDICTION FIN DE CYCLE]         Si premium + confiance ≥ 30%
  Bannière collapsible

  MESSAGES ZOLT                     Cards sémantiques empilées
  ────────────────────────────────

  EN ATTENTE DE TRIAGE (n)          Si SMS en attente
  Cards swipables

  TRANSACTIONS RÉCENTES             Section finale
```

### 5.2 Dimensions exactes

```
Padding horizontal global : 16dp
Gap entre cards Bento     : 12dp
Gap entre sections        : 24dp

Row 1 :
  Hero card (gauche)  : flex 2 — ~220dp de large
  Colonne droite      : flex 1 — ~108dp de large
    Card Solde Total  : hauteur 100dp
    Card Santé        : hauteur 100dp (gap 12dp entre les deux)
  Hauteur Row 1       : 212dp

Row 2 (Comptes) :
  Full width — hauteur 88dp
  3 comptes max en ligne, séparés par divider vertical
  Chaque compte : icône opérateur 28dp + nom + solde amount_sm

Bannière Prédiction :
  Full width — hauteur 64dp
  Collapsible (tap pour expand)
  État flouté si gratuit

Messages Zolt :
  Full width — hauteur variable selon contenu
  Max 3 messages visibles, "Voir plus" ghost button

Triage Zone :
  Full width — hauteur 96dp par card
  Swipe right : bg positive_muted + check icon
  Swipe left  : bg critical_muted + x icon
```

---

## 6. Typographie — Composants spéciaux

### 6.1 RichText Montant + Devise

```dart
RichText(
  text: TextSpan(children: [
    TextSpan(
      text: "150\u202F000",  // espace fine insécable
      style: TextStyle(
        fontFamily: 'Zodiak',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
    ),
    TextSpan(
      text: " FCFA",
      style: TextStyle(
        fontFamily: 'CabinetGrotesk',
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: textPrimary.withOpacity(0.55),
      ),
    ),
  ]),
)
```

### 6.2 Section Label

```dart
Text(
  "TRANSACTIONS RÉCENTES",
  style: TextStyle(
    fontFamily: 'CabinetGrotesk',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
    color: textTertiary,
  ),
)
```

---

## 7. Boutons

### Primaire

```
Background   : text_primary (#0D0D0B clair / #F5F3EE sombre)
Texte        : text_inverse, Cabinet Grotesk 600 15sp
Border radius: 14dp
Hauteur      : 54dp
Padding H    : 24dp
Ombre        : 0 2dp 8dp rgba(0,0,0,0.12) + 0 1dp 2dp rgba(0,0,0,0.08)
Pressed      : scale 0.97 + opacity 88%
```

### Secondaire

```
Background   : transparent
Bordure      : 1.5dp border_strong
Texte        : text_primary, Cabinet Grotesk 600 15sp
Border radius: 14dp
Hauteur      : 54dp
```

### Ghost / Tertiaire

```
Background   : transparent
Texte        : text_secondary, Cabinet Grotesk 500 14sp
Hauteur      : 44dp
Underline    : optionnel
```

### Premium CTA

```
Background   : gradient 135° #C9973A → #A67B28
Texte        : #0D0D0B, Cabinet Grotesk 700 16sp
Border radius: 14dp
Hauteur      : 58dp
Bordure      : 1dp gradient (gold_light 40% → gold 10%)
Ombre        : glow premium (§3.3) + 0 4dp 12dp rgba(0,0,0,0.15)
Pressed      : scale 0.96 + brightness 0.95
```

### Destructif

```
Background   : critical_muted (#DC2626 10%)
Texte        : #DC2626, Cabinet Grotesk 600 15sp
Border radius: 14dp
Hauteur      : 54dp
```

---

## 8. Composants additionnels

### 8.1 Barre de progression

```
Track        : border_subtle, radius_full
Épaisseur    : 5dp (standard) / 3dp (hero card)
Fill         :
  0–79%      → positive — ombre glow positive 15%
  80–99%     → warning  — ombre glow warning 15%
  100%+      → critical — ombre glow critical 15%
Animation    : 700ms easeOutCubic
```

### 8.2 Badge de statut

```
Hauteur      : 26dp
Padding H    : 10dp
Border radius: radius_full
Cabinet Grotesk 11sp 600 uppercase

Positif   : bg positive_muted, texte positive, glow positif 20%
Warning   : bg warning_muted, texte warning
Critique  : bg critical_muted, texte critical, glow critique 20%
Premium   : bg gold_muted, texte gold, glow premium 20%
Neutre    : bg surface_2/surface_3, texte text_secondary
```

### 8.3 Inputs

```
Background   : surface_2 (clair) / surface_2 (sombre)
Bordure repos: 1dp border_subtle
Bordure focus: 1.5dp text_primary + glow 0 0 0 3dp rgba(text_primary, 0.08)
Border radius: 14dp
Hauteur      : 54dp
Padding H    : 16dp
Label float  : Cabinet Grotesk 11sp 500, monte à y=-10dp au focus
```

### 8.4 Bottom Navigation

```
Background   : surface_glass (glassmorphism)
Blur         : backdropFilter blur 20dp saturation 1.2
Bordure top  : 1dp border_faint
Icônes inact : text_tertiary, stroke 1.5dp, taille 22dp
Icônes actif : text_primary, stroke 1.5dp
Label actif  : Cabinet Grotesk 10sp 600
FAB central  :
  Background : text_primary
  Icône      : text_inverse, 24dp
  Border rad : 18dp
  Ombre      : 0 4dp 16dp rgba(0,0,0,0.18) + 0 2dp 4dp rgba(0,0,0,0.10)
```

### 8.5 Card Premium verrouillée

```
Background   : surface_1
Contenu      : ImageFilter.blur(sigma: 10)
Overlay      : bg 25% opacity sur le flou
Badge cadenas:
  Icône lock : #C9973A, 22dp, centré sur le contenu
  Label      : "★ PREMIUM" — Cabinet Grotesk 10sp 600 #C9973A
  Fond badge : gold_muted, radius_full, padding 6dp 10dp
Ombre        : glow premium 40%
```

### 8.6 Skeleton Loading

```
Base         : surface_3
Shimmer      : gradient surface_4 → surface_2 → surface_4
Direction    : -30° (diagonal, plus premium qu'horizontal)
Durée        : 1600ms linear loop
Delay        : +100ms par card pour effet cascade
```

### 8.7 Toast / Snackbar

```
Background   : surface_inverse (contraste maximal)
Texte        : text_inverse, Cabinet Grotesk 14sp 500
Border radius: 14dp
Padding      : 14dp 18dp
Ombre        : profonde — 0 8dp 24dp rgba(0,0,0,0.20)
Icône gauche : sémantique selon type
Position     : bottom 24dp, margin H 16dp
Animation    : slide up + fade in 280ms easeOut
Auto-dismiss : 3500ms
```

---

## 9. Écrans spécifiques

### 9.1 Paywall Premium

```
Fond         : bg (#080807) — écran le plus sombre de l'app
Padding H    : 24dp

Section 1 — Hero (paddingTop 48dp)
  Logo Zolt centré — text_primary, 32dp hauteur
  Badge "★ PREMIUM" — Cabinet Grotesk 11sp 600 #C9973A
  Gap 32dp

Section 2 — Pitch
  "Ton argent mérite mieux."
  Cabinet Grotesk 32sp 800 text_primary — max 2 lignes
  Sous-titre 15sp 400 text_secondary
  Gap 32dp

Section 3 — Avantages (liste)
  Icône ✓ #C9973A 16dp + texte Cabinet Grotesk 15sp 400 text_primary
  Gap 14dp entre items — 7 avantages max visibles

Section 4 — Toggle Plans (surface_2, radius_full)
  Mensuel : "790 FCFA / mois"
  Annuel  : "5 900 FCFA / an" + badge "-38%" gold
  Zodiak pour les montants, Cabinet Grotesk pour "/mois"

Section 5 — CTA
  Bouton Premium pleine largeur (§7)
  "Commencer — 7 jours offerts"
  Gap 12dp
  "Sans engagement · Données conservées" — caption text_tertiary centré
```

### 9.2 Score de santé (Health Score Card)

```
Card Standard Profil B — 108dp de large dans le Bento
Padding : 14dp

  [overline] "SANTÉ"
  [amount_lg Zodiak] Score (ex: "74")
    + "/100" Cabinet Grotesk 11sp text_tertiary
  Arc SVG animé 0→score (900ms easeOutCubic)
    Couleur arc : sémantique selon score
    ≥80 : positive + glow vert
    60–79 : warning + glow ambre
    <60  : critical + glow rouge
  [body_sm] Grade : "Bien" / "Excellent" / "Attention"
    Couleur sémantique
```

### 9.3 Onboarding

```
Fond         : bg ivoire
Progress bar : 3dp, text_primary fill sur border_subtle, radius_full
Indicateur   : étape N/7 — caption text_tertiary

Chaque étape :
  Illustration : simple, noir sur fond ivoire (SVG inline)
  Headline     : Cabinet Grotesk 28sp 800 text_primary
  Sous-titre   : Cabinet Grotesk 15sp 400 text_secondary
  Input(s)     : style §8.3
  Bouton       : Primaire pleine largeur + Ghost "Passer" en dessous

Ton conversationnel :
  "Quel est ton prénom ?" > "Nom"
  "Où gardes-tu ton argent ?" > "Type de compte"
  "Combien veux-tu épargner ce mois ?" > "Objectif d'épargne"
```

---

## 10. Animations & Motion

| Élément | Animation | Durée | Courbe |
|---|---|---|---|
| Ouverture bottom sheet | Slide up + fade | 340ms | easeOutCubic |
| Fermeture | Slide down + fade | 240ms | easeInCubic |
| Transition écran | Fade cross | 200ms | easeInOut |
| Tap card | Scale 0.97 | 110ms | easeOut |
| Montant budget (count-up) | 0 → valeur | 750ms | easeOutExpo |
| Barre progression (fill) | 0 → valeur | 700ms | easeOutCubic |
| Arc santé (draw) | 0 → score | 900ms | easeOutCubic |
| Glow sémantique (apparition) | Fade in | 400ms | easeOut |
| Shimmer skeleton | Diagonal loop | 1600ms | linear |
| Toast (entrée) | Slide up + fade | 280ms | easeOut |
| Toast (sortie) | Fade + scale 0.95 | 200ms | easeIn |
| FAB (press) | Scale 0.92 | 120ms | easeOut |
| Swipe triage | Slide natif | — | — |
| Paywall (scroll reveal) | Fade + translateY 20dp | 350ms | easeOut |

**Règle stricte** : jamais de `Curves.bounceOut` ni de spring exagéré.  
Zolt est un compagnon premium. Chaque animation doit sembler intentionnelle et sobre.

---

## 11. Tokens Flutter complets

```dart
// lib/core/theme/zolt_colors.dart

class ZoltColors {
  // ── Fonds Clair ──
  static const lightBg        = Color(0xFFFAFAF7);
  static const lightBgDeep    = Color(0xFFF3F1EC);
  static const lightSurface1  = Color(0xFFFFFFFF);
  static const lightSurface2  = Color(0xFFF5F3EE);
  static const lightSurface3  = Color(0xFFEDEAE3);
  static const lightInverse   = Color(0xFF0D0D0B);
  static const lightGlass     = Color(0xB8FFFFFF);

  // ── Fonds Sombre ──
  static const darkBg         = Color(0xFF080807);
  static const darkBgDeep     = Color(0xFF050504);
  static const darkSurface1   = Color(0xFF131311);
  static const darkSurface2   = Color(0xFF1A1A18);
  static const darkSurface3   = Color(0xFF222220);
  static const darkSurface4   = Color(0xFF2A2A27);
  static const darkInverse    = Color(0xFFFAFAF7);
  static const darkGlass      = Color(0xC7141412);

  // ── Texte Clair ──
  static const lightTextPrimary   = Color(0xFF0D0D0B);
  static const lightTextSecondary = Color(0x940D0D0B);  // 58%
  static const lightTextTertiary  = Color(0x590D0D0B);  // 35%
  static const lightTextDisabled  = Color(0x330D0D0B);  // 20%

  // ── Texte Sombre ──
  static const darkTextPrimary    = Color(0xFFF5F3EE);
  static const darkTextSecondary  = Color(0x94F5F3EE);
  static const darkTextTertiary   = Color(0x59F5F3EE);
  static const darkTextDisabled   = Color(0x33F5F3EE);

  // ── Sémantiques ──
  static const positive       = Color(0xFF16A34A);
  static const positiveMuted  = Color(0x1A16A34A);
  static const positiveGlow   = Color(0x4016A34A);

  static const warning        = Color(0xFFD97706);
  static const warningMuted   = Color(0x1AD97706);
  static const warningGlow    = Color(0x38D97706);

  static const critical       = Color(0xFFDC2626);
  static const criticalMuted  = Color(0x1ADC2626);
  static const criticalGlow   = Color(0x38DC2626);

  static const info           = Color(0xFF4B6E9E);
  static const infoMuted      = Color(0x1A4B6E9E);

  // ── Premium ──
  static const gold           = Color(0xFFC9973A);
  static const goldLight      = Color(0xFFE8B96A);
  static const goldMuted      = Color(0x24C9973A);
  static const goldGlow       = Color(0x4DC9973A);
}

// lib/core/theme/zolt_shadows.dart

class ZoltShadows {
  static List<BoxShadow> card() => [
    BoxShadow(color: Color(0x0A0D0D0B), blurRadius: 4, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x120D0D0B), blurRadius: 16, offset: Offset(0, 4), spreadRadius: -2),
  ];

  static List<BoxShadow> hero() => [
    BoxShadow(color: Color(0x0A0D0D0B), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x1A0D0D0B), blurRadius: 32, offset: Offset(0, 8), spreadRadius: -4),
  ];

  static List<BoxShadow> glowPositive() => [
    ...card(),
    BoxShadow(color: Color(0x4016A34A), blurRadius: 20, offset: Offset(0, 4), spreadRadius: -4),
  ];

  static List<BoxShadow> glowWarning() => [
    ...card(),
    BoxShadow(color: Color(0x38D97706), blurRadius: 20, offset: Offset(0, 4), spreadRadius: -4),
  ];

  static List<BoxShadow> glowCritical() => [
    ...card(),
    BoxShadow(color: Color(0x38DC2626), blurRadius: 20, offset: Offset(0, 4), spreadRadius: -4),
  ];

  static List<BoxShadow> glowPremium() => [
    BoxShadow(color: Color(0x4DC9973A), blurRadius: 24, offset: Offset(0, 6), spreadRadius: -4),
  ];

  static List<BoxShadow> button() => [
    BoxShadow(color: Color(0x1F0D0D0B), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x140D0D0B), blurRadius: 2, offset: Offset(0, 1)),
  ];
}
```

---

## 12. Do & Don't v3

### ✅ Do

- Utiliser **Zodiak** pour tous les montants FCFA sans exception
- Utiliser `#FAFAF7` ivoire (jamais `#FFFFFF` pur) comme fond clair
- Superposer 2 couches d'ombre (ambient + key) pour un effet naturel
- Ajouter le glow sémantique uniquement sur les cards en état actif
- Appliquer la texture grain sur la hero card inversée
- Utiliser le layout Bento asymétrique pour l'écran d'accueil
- Séparer visuellement "Montant" (Zodiak) et "Devise" (Cabinet Grotesk) dans un `RichText`
- Utiliser `\u202F` comme séparateur milliers

### ❌ Don't

- Utiliser Cabinet Grotesk pour les montants (réservé Zodiak)
- Mettre `#000000` ou `#FFFFFF` pur comme fond (toujours `#080807` / `#FAFAF7`)
- Ajouter le glow sémantique sur des éléments décoratifs
- Utiliser plus de 2 couleurs sémantiques sur un même écran
- Animer avec bounce, spring ou elastic
- Afficher un spinner plein écran (skeleton uniquement)
- Mettre du rouge sur chaque ligne de dépense (réservé aux dépassements et retards)
- Utiliser le glassmorphism en dehors du Bottom Nav et des modals flottants

---

## 13. Ressources & Téléchargements

| Ressource | Source | Gratuit |
|---|---|---|
| Cabinet Grotesk | fontshare.com/fonts/cabinet-grotesk | ✅ |
| Zodiak | fontshare.com/fonts/zodiak | ✅ |
| Lucide Icons | lucide.dev | ✅ |
| Texture noise SVG | (générer avec noise.app ou grainy-gradient) | ✅ |

---

*Zolt Design System v3.0 — Mars 2026*  
*Cabinet Grotesk + Zodiak + Ivoire + Glow sémantique*  
*Compatible Flutter 3.x — Null safety — Dark & Light mode*
