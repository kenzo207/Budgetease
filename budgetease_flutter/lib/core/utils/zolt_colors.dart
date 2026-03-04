import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

// ═══════════════════════════════════════════════════════
// ZOLT ADAPTIVE COLORS — Extension on BuildContext
// ═══════════════════════════════════════════════════════
//
// Utilisation :
//   context.zolt.bg          → fond principal du mode courant
//   context.zolt.surface     → fond de carte / input
//   context.zolt.surface2    → fond secondaire (hover, section)
//   context.zolt.border      → bordure fine
//   context.zolt.textPrimary → texte principal
//   context.zolt.text2       → texte secondaire
//   context.zolt.text3       → texte tertiaire / placeholder
//   context.zolt.primary     → couleur d'accent primaire (blanc dark / charcoal light)
//   context.zolt.onPrimary   → texte sur primary
//
// Couleurs fonctionnelles (inchangées peu importe le mode) :
//   Theme.of(context).colorScheme.primary    → vert revenus #22C55E
//   Theme.of(context).colorScheme.primary     → rouge dépenses #EF4444
//   Theme.of(context).colorScheme.primary   → ambre alertes #F59E0B
// ═══════════════════════════════════════════════════════

extension ZoltContext on BuildContext {
  ZoltColors get zolt => ZoltColors.of(this);
}

class ZoltColors {
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color border;
  final Color primary;
  final Color onPrimary;
  final Color textPrimary;
  final Color text2;
  final Color text3;
  final bool isDark;

  const ZoltColors._({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.primary,
    required this.onPrimary,
    required this.textPrimary,
    required this.text2,
    required this.text3,
    required this.isDark,
  });

  factory ZoltColors.of(BuildContext context) {
    final bright = Theme.of(context).brightness;
    final dark = bright == Brightness.dark;

    return dark
        ? const ZoltColors._(
            bg:          Color(0xFF0D0D0D),
            surface:     Color(0xFF1A1A1A),
            surface2:    Color(0xFF242424),
            border:      Color(0xFF2E2E2E),
            primary:     Color(0xFFFFFFFF),
            onPrimary:   Color(0xFF0D0D0D),
            textPrimary: Color(0xFFFFFFFF),
            text2:       Color(0xFFB0B0B0),
            text3:       Color(0xFF6B6B6B),
            isDark:      true,
          )
        : const ZoltColors._(
            bg:          Color(0xFFF7F5F2),
            surface:     Color(0xFFFFFFFF),
            surface2:    Color(0xFFF0EEE9),
            border:      Color(0xFFE5E2DC),
            primary:     Color(0xFF1A1A1A),
            onPrimary:   Color(0xFFFFFFFF),
            textPrimary: Color(0xFF1A1A1A),
            text2:       Color(0xFF6B6B6B),
            text3:       Color(0xFFB0B0B0),
            isDark:      false,
          );
  }

  // ── Couleurs fonctionnelles (même dans les deux modes) ──
  Color get income => primary;
  Color get expense => primary;
  Color get alert => primary;
}
