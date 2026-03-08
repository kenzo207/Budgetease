import 'package:flutter/material.dart';

class ZoltTokens {
  // ── Fonds Clair ──
  static const lightBg        = Color(0xFFF5EFE6);
  static const lightBgDeep    = Color(0xFFEDE4D8);
  static const lightSurface1  = Color(0xFFFBF7F2);
  static const lightSurface2  = Color(0xFFEDE4D8);
  static const lightSurface3  = Color(0xFFE2D5C4);
  static const lightSurface4  = Color(0xFFD4C3AD);
  static const lightInverse   = Color(0xFF2C1810);
  static const lightGlass     = Color(0xCCF5EFE6);

  // ── Fonds Sombre ──
  static const darkBg         = Color(0xFF1C1410);
  static const darkBgDeep     = Color(0xFF140E0A);
  static const darkSurface1   = Color(0xFF251A13);
  static const darkSurface2   = Color(0xFF2F2118);
  static const darkSurface3   = Color(0xFF3A2A1E);
  static const darkSurface4   = Color(0xFF4A3628);
  static const darkInverse    = Color(0xFFF5EFE6);
  static const darkGlass      = Color(0xD11C1410);

  // ── Texte Clair ──
  static const lightTextPrimary   = Color(0xFF2C1810);
  static const lightTextSecondary = Color(0x9E2C1810);  // 62%
  static const lightTextTertiary  = Color(0x612C1810);  // 38%
  static const lightTextDisabled  = Color(0x382C1810);  // 22%

  // ── Texte Sombre ──
  static const darkTextPrimary    = Color(0xFFF0E8DC);
  static const darkTextSecondary  = Color(0x9EF0E8DC);  // 62%
  static const darkTextTertiary   = Color(0x61F0E8DC);  // 38%
  static const darkTextDisabled   = Color(0x38F0E8DC);  // 22%

  // ── Brand & Earth ──
  static const brand          = Color(0xFF7C3A1E);
  static const brandLight     = Color(0xFFA85C35);
  static const earth          = Color(0xFF9C6B3C);

  // ── Sémantiques ──
  static const positive       = Color(0xFF2D7A4F);
  static const positiveMuted  = Color(0x1E2D7A4F);
  static const positiveGlow   = Color(0x472D7A4F);

  static const warning        = Color(0xFFB8650A);
  static const warningMuted   = Color(0x1EB8650A);
  static const warningGlow    = Color(0x3DB8650A);

  static const critical       = Color(0xFFB53B2A);
  static const criticalMuted  = Color(0x1EB53B2A);
  static const criticalGlow   = Color(0x3DB53B2A);

  static const info           = Color(0xFF4A6E8A);
  static const infoMuted      = Color(0x1E4A6E8A);

  // ── Premium ──
  static const gold           = Color(0xFFB8892A);
  static const goldLight      = Color(0xFFD4AE5C);
  static const goldMuted      = Color(0x24B8892A);
  static const goldGlow       = Color(0x4DB8892A);
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
