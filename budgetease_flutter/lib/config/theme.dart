import 'package:flutter/material.dart';
import '../core/utils/zolt_colors.dart';

/// Configuration du thème de l'application Zolt v4
class AppTheme {
  // --- Dark Theme ---
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: ZoltTokens.darkInverse,
      scaffoldBackgroundColor: ZoltTokens.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: ZoltTokens.darkInverse,
        onPrimary: ZoltTokens.darkBgDeep,
        secondary: ZoltTokens.darkTextSecondary,
        surface: ZoltTokens.darkSurface1,
        error: ZoltTokens.critical,
      ),
      
      // Typographie
      textTheme: _buildTextTheme(Brightness.dark),
      
      // Cards Profil B (Standard)
      cardTheme: const CardThemeData(
        color: ZoltTokens.darkSurface1,
        elevation: 0, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: Color(0x1FF0E8DC), width: 1), // border_default dark
        ),
      ),
      
      // Boutons primaires
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ZoltTokens.darkTextPrimary,
          foregroundColor: ZoltTokens.darkBg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          minimumSize: const Size(0, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'CabinetGrotesk',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Boutons secondaires / outline
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ZoltTokens.darkTextPrimary,
          side: const BorderSide(color: Color(0x38F0E8DC), width: 1.5), // border_strong dark
          padding: const EdgeInsets.symmetric(horizontal: 24),
          minimumSize: const Size(0, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'CabinetGrotesk',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Buttons (Ghost)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ZoltTokens.darkTextSecondary,
          minimumSize: const Size(0, 44),
          textStyle: const TextStyle(
            fontFamily: 'CabinetGrotesk',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ZoltTokens.darkSurface2,
        hintStyle: const TextStyle(
          color: ZoltTokens.darkTextTertiary,
          fontFamily: 'CabinetGrotesk',
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x14F0E8DC)), // border_subtle
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x14F0E8DC)), // border_subtle
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ZoltTokens.darkTextPrimary, width: 1.5),
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent, // Sera géré par le widget avec glassmorphism
        selectedItemColor: ZoltTokens.darkTextPrimary,
        unselectedItemColor: ZoltTokens.darkTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: 'CabinetGrotesk',
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'CabinetGrotesk',
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: ZoltTokens.darkBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: ZoltTokens.darkTextPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'CabinetGrotesk',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ZoltTokens.darkTextPrimary,
        ),
      ),
    );
  }

  // --- Light Theme ---
  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      primaryColor: ZoltTokens.lightInverse,
      scaffoldBackgroundColor: ZoltTokens.lightBg,
      colorScheme: const ColorScheme.light(
        primary: ZoltTokens.lightInverse,
        onPrimary: ZoltTokens.lightBgDeep,
        secondary: ZoltTokens.lightTextSecondary,
        surface: ZoltTokens.lightSurface1,
        error: ZoltTokens.critical,
      ),
      
      // Typographie
      textTheme: _buildTextTheme(Brightness.light),
      
      // Cards Profil B (Standard)
      cardTheme: const CardThemeData(
        color: ZoltTokens.lightSurface1,
        elevation: 0, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: Color(0x1F2C1810), width: 1), // border_default light
        ),
      ),
      
      // Boutons primaires
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ZoltTokens.lightTextPrimary,
          foregroundColor: ZoltTokens.lightBg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          minimumSize: const Size(0, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'CabinetGrotesk',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Boutons secondaires / outline
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ZoltTokens.lightTextPrimary,
          side: const BorderSide(color: Color(0x382C1810), width: 1.5), // border_strong light
          padding: const EdgeInsets.symmetric(horizontal: 24),
          minimumSize: const Size(0, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'CabinetGrotesk',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Buttons (Ghost)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ZoltTokens.lightTextSecondary,
          minimumSize: const Size(0, 44),
          textStyle: const TextStyle(
            fontFamily: 'CabinetGrotesk',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ZoltTokens.lightSurface2,
        hintStyle: const TextStyle(
          color: ZoltTokens.lightTextTertiary,
          fontFamily: 'CabinetGrotesk',
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x142C1810)), // border_subtle light
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x142C1810)), 
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ZoltTokens.lightTextPrimary, width: 1.5),
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: ZoltTokens.lightTextPrimary,
        unselectedItemColor: ZoltTokens.lightTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: 'CabinetGrotesk',
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'CabinetGrotesk',
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: ZoltTokens.lightBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: ZoltTokens.lightTextPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'CabinetGrotesk',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ZoltTokens.lightTextPrimary,
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final primary = isDark ? ZoltTokens.darkTextPrimary : ZoltTokens.lightTextPrimary;
    final secondary = isDark ? ZoltTokens.darkTextSecondary : ZoltTokens.lightTextSecondary;

    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'CabinetGrotesk',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      displayMedium: TextStyle(
        fontFamily: 'CabinetGrotesk',
        fontSize: 24,
        fontWeight: FontWeight.w700, // headline_lg
        color: primary,
      ),
      titleLarge: TextStyle(
        fontFamily: 'CabinetGrotesk',
        fontSize: 20,
        fontWeight: FontWeight.w600, // headline_md
        color: primary,
      ),
      titleMedium: TextStyle(
        fontFamily: 'CabinetGrotesk',
        fontSize: 17,
        fontWeight: FontWeight.w600, // headline_sm
        color: primary,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'CabinetGrotesk',
        fontSize: 15,
        fontWeight: FontWeight.w400, // body_lg
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'CabinetGrotesk',
        fontSize: 14,
        fontWeight: FontWeight.w400, // body_md
        color: secondary,
      ),
      bodySmall: TextStyle(
        fontFamily: 'CabinetGrotesk',
        fontSize: 13,
        fontWeight: FontWeight.w400, // body_sm
        color: secondary,
      ),
      labelSmall: TextStyle( // caption
        fontFamily: 'CabinetGrotesk',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
    );
  }
}
