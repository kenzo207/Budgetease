import 'package:flutter/material.dart';

class ZoltTokens {
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark
        ? const ZoltColors._(
            bg: ZoltTokens.darkBg,
            surface: ZoltTokens.darkSurface1,
            surface2: ZoltTokens.darkSurface2,
            border: Color(0x1AF5F3EE), // border_default dark
            primary: ZoltTokens.darkInverse,
            onPrimary: ZoltTokens.darkBg,
            textPrimary: ZoltTokens.darkTextPrimary,
            text2: ZoltTokens.darkTextSecondary,
            text3: ZoltTokens.darkTextTertiary,
            isDark: true,
          )
        : const ZoltColors._(
            bg: ZoltTokens.lightBg,
            surface: ZoltTokens.lightSurface1,
            surface2: ZoltTokens.lightSurface2,
            border: Color(0x1E0D0D0B), // border_default light
            primary: ZoltTokens.lightInverse,
            onPrimary: ZoltTokens.lightBg,
            textPrimary: ZoltTokens.lightTextPrimary,
            text2: ZoltTokens.lightTextSecondary,
            text3: ZoltTokens.lightTextTertiary,
            isDark: false,
          );
  }

  // Couleurs fonctionnelles
  Color get income => ZoltTokens.positive;
  Color get expense => primary;
  Color get alert => ZoltTokens.warning;
}
