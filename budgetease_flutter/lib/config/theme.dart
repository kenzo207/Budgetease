import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════
// ZOLT THEME SYSTEM - PURE B&W
// ═══════════════════════════════════════════════════════

class AppTheme {
  // ── Tokens dark (Fond Noir) ─────────────────────────
  static const _darkBg       = Color(0xFF000000); // Scaffold
  static const _darkSurface  = Color(0xFFFFFFFF); // Cartes
  static const _darkTextOnBg = Color(0xFFFFFFFF); // Texte sur scaffold
  static const _darkTextOnSurface = Color(0xFF000000); // Texte sur cartes
  static const _darkBorderOnBg = Color(0xFFFFFFFF); // Bordures sur scaffold
  static const _darkBorderOnSurface = Color(0xFF000000); // Bordures sur cartes

  // ── Tokens light (Fond Blanc) ──────────────────────
  static const _lightBg       = Color(0xFFFFFFFF); // Scaffold
  static const _lightSurface  = Color(0xFF000000); // Cartes
  static const _lightTextOnBg = Color(0xFF000000); // Texte sur scaffold
  static const _lightTextOnSurface = Color(0xFFFFFFFF); // Texte sur cartes
  static const _lightBorderOnBg = Color(0xFF000000); // Bordures sur scaffold
  static const _lightBorderOnSurface = Color(0xFFFFFFFF); // Bordures sur cartes

  // ════════════════════════════════════════════════════
  // DARK THEME
  // ════════════════════════════════════════════════════
  static ThemeData get darkTheme {
    final base = ThemeData.dark();

    return base.copyWith(
      scaffoldBackgroundColor: _darkBg,

      colorScheme: const ColorScheme.dark(
        primary:         _darkSurface, // White
        onPrimary:       _darkBg, // Black
        secondary:       _darkSurface, // White
        onSecondary:     _darkBg, // Black
        surface:         _darkSurface, // White
        onSurface:       _darkTextOnSurface, // Black
        error:           _darkSurface, // White
        onError:         _darkBg, // Black
        outline:         _darkBorderOnSurface, // Black
        outlineVariant:  _darkBorderOnSurface, // Black
        surfaceContainerHighest: _darkSurface, // White
      ),

      textTheme: _buildTextTheme(textColor: _darkTextOnBg),

      cardTheme: const CardThemeData(
        color: _darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          side: BorderSide(color: _darkBorderOnSurface, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkSurface, // White
          foregroundColor: _darkTextOnSurface, // Black
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkTextOnBg, // White
          side: const BorderSide(color: _darkBorderOnBg, width: 1.5), // White
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 15),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkTextOnBg, // White
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkBg, // Black
        hintStyle: const TextStyle(color: _darkTextOnBg, fontSize: 14), // White
        labelStyle: const TextStyle(color: _darkTextOnBg), // White
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkBorderOnBg, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkBorderOnBg, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkSurface, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkBorderOnBg, width: 1),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: _darkBg,
        selectedColor: _darkSurface,
        labelStyle: GoogleFonts.inter(fontSize: 13, color: _darkTextOnBg),
        secondaryLabelStyle: GoogleFonts.inter(fontSize: 13, color: _darkTextOnSurface),
        side: const BorderSide(color: _darkBorderOnBg, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),

      dividerTheme: const DividerThemeData(
        color: _darkBorderOnBg,
        thickness: 1,
        space: 1,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkBg,
        selectedItemColor: _darkTextOnBg, // White
        unselectedItemColor: _darkTextOnBg, // White
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: _darkBg,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: _darkTextOnBg),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: _darkTextOnBg,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _darkSurface,
        foregroundColor: _darkTextOnSurface,
        elevation: 0,
        shape: CircleBorder(),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? _darkTextOnSurface : _darkTextOnBg,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? _darkSurface : _darkBg,
        ),
        trackOutlineColor: WidgetStateProperty.all(_darkBorderOnBg),
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        // Suppression de iconColor et textColor pour qu'ils héritent automatiquement du contexte 
      ),
    );
  }

  // ════════════════════════════════════════════════════
  // LIGHT THEME
  // ════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    final base = ThemeData.light();

    return base.copyWith(
      scaffoldBackgroundColor: _lightBg,

      colorScheme: const ColorScheme.light(
        primary:         _lightSurface, // Black
        onPrimary:       _lightBg, // White
        secondary:       _lightSurface, // Black
        onSecondary:     _lightBg, // White
        surface:         _lightSurface, // Black
        onSurface:       _lightTextOnSurface, // White
        error:           _lightSurface, // Black
        onError:         _lightBg, // White
        outline:         _lightBorderOnSurface, // White
        outlineVariant:  _lightBorderOnSurface, // White
        surfaceContainerHighest: _lightSurface, // Black
      ),

      textTheme: _buildTextTheme(textColor: _lightTextOnBg),

      cardTheme: const CardThemeData(
        color: _lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          side: BorderSide(color: _lightBorderOnSurface, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightSurface, // Black
          foregroundColor: _lightTextOnSurface, // White
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightTextOnBg, // Black
          side: const BorderSide(color: _lightBorderOnBg, width: 1.5), // Black
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 15),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _lightTextOnBg, // Black
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightBg, // White
        hintStyle: const TextStyle(color: _lightTextOnBg, fontSize: 14), // Black
        labelStyle: const TextStyle(color: _lightTextOnBg), // Black
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightBorderOnBg, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightBorderOnBg, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightSurface, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightBorderOnBg, width: 1),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: _lightBg,
        selectedColor: _lightSurface,
        labelStyle: GoogleFonts.inter(fontSize: 13, color: _lightTextOnBg),
        secondaryLabelStyle: GoogleFonts.inter(fontSize: 13, color: _lightTextOnSurface),
        side: const BorderSide(color: _lightBorderOnBg, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),

      dividerTheme: const DividerThemeData(
        color: _lightBorderOnBg,
        thickness: 1,
        space: 1,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _lightBg,
        selectedItemColor: _lightTextOnBg, // Black
        unselectedItemColor: _lightTextOnBg, // Black
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: _lightBg,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: _lightTextOnBg),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: _lightTextOnBg,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _lightSurface,
        foregroundColor: _lightTextOnSurface,
        elevation: 0,
        shape: CircleBorder(),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? _lightTextOnSurface : _lightTextOnBg,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? _lightSurface : _lightBg,
        ),
        trackOutlineColor: WidgetStateProperty.all(_lightBorderOnBg),
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        // Suppression de iconColor et textColor pour qu'ils héritent automatiquement du contexte
      ),
    );
  }

  // ════════════════════════════════════════════════════
  // TYPOGRAPHIE INTER 
  // ════════════════════════════════════════════════════
  static TextTheme _buildTextTheme({required Color textColor}) {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.w800, color: textColor, height: 1.15),
      displayMedium: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: textColor, height: 1.2),
      displaySmall:  GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: textColor, height: 1.25),
      headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textColor),
      titleLarge:  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: textColor),
      titleMedium: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
      titleSmall:  GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
      bodyLarge:  GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: textColor),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textColor),
      bodySmall:  GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textColor),
      labelLarge:  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textColor),
      labelSmall:  GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: textColor),
    );
  }
}
