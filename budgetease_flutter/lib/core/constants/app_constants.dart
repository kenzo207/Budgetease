import 'package:flutter/material.dart';

/// Couleurs principales de l'application (Dark Theme Bancaire)
class AppColors {
  // Couleurs principales
  static const Color primaryColor = Color(0xFF1E88E5); // Bleu bancaire
  static const Color backgroundColor = Color(0xFF0A0E21); // Noir profond
  static const Color surfaceColor = Color(0xFF1D1E33); // Gris foncé
  static const Color cardColor = Color(0xFF262A41); // Gris moyen
  static const Color accentColor = Color(0xFF00E676); // Vert (positif)
  static const Color errorColor = Color(0xFFFF5252); // Rouge (négatif)
  static const Color warningColor = Color(0xFFFFAB00); // Orange (attention)
  
  // Couleurs de texte
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textTertiary = Colors.white60;
  
  // Couleurs de statut
  static const Color success = Color(0xFF00E676);
  static const Color danger = Color(0xFFFF5252);
  static const Color info = Color(0xFF1E88E5);
  static const Color warning = Color(0xFFFFAB00);
}

/// Constantes de l'application
class AppConstants {
  // Nom de l'application
  static const String appName = 'BudgetEase';
  static const String appVersion = '4.0.0';
  
  // Devises supportées
  static const List<String> supportedCurrencies = [
    'FCFA',
    'EUR',
    'USD',
    'GHS',
    'NGN',
  ];
  
  // Opérateurs Mobile Money
  static const List<String> mobileMoneyOperators = [
    'MTN',
    'Moov',
    'Orange',
    'Wave',
  ];
  
  // Limites de montants
  static const double maxTransactionAmount = 1000000000; // 1 milliard
  static const double minTransactionAmount = 0.01;
  
  // Durées
  static const int inactivityLockDuration = 60; // secondes
  static const int pinLength = 4;
  
  // Parsing SMS
  static const int smsRetentionDays = 7;
}
