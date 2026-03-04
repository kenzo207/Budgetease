import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════
// ZOLT BRAND PALETTE
// ═══════════════════════════════════════════════════════
//
// Logo Zolt = monochrome charcoal + blanc + cauri comme "O"
// Mode sombre  → fond quasi-noir, surfaces gris anthracite, accents blancs
// Mode clair   → fond blanc cassé chaud, surfaces blanches, accents charcoal
//
// Couleurs fonctionnelles (revenus / dépenses / alertes) :
//   Vert émeraude #22C55E — Income (positive)
//   Rouge chaleureux #EF4444 — Expense (negative)
//   Ambre #F59E0B — Warning / attention
// ═══════════════════════════════════════════════════════

/// Couleurs statiques de référence (design strictement Noir et Blanc)
class AppColors {
  // ── Noir et Blanc pur ───────────────────────────────
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // ── Sémantique & Fonctionnel (Désactivé pour design B&W) ──
  // On remplace les anciennes couleurs par du pur noir par défaut, 
  // les widgets devront idéalement utiliser le Theme.of(context)
  static const Color accentColor  = pureBlack;
  static const Color errorColor   = pureBlack;
  static const Color warningColor = pureBlack;

  static const Color success = pureBlack;
  static const Color danger  = pureBlack;
  static const Color warning = pureBlack;

  // ── Primaire (Zolt) ──────────────────────────────────
  static const Color primaryColor = pureBlack;

  // ── Anciens Tokens (à déprécier) ───────────────────────
  static const Color backgroundColor = pureBlack;
  static const Color surfaceColor    = pureBlack;
  static const Color cardColor       = pureBlack;

  static const Color textPrimary   = pureWhite;
  static const Color textSecondary = pureWhite;
  static const Color textTertiary  = pureWhite;
}

/// Constantes de l'application
class AppConstants {
  static const String appName    = 'Zolt';
  static const String appVersion = '4.0.0';

  static const List<String> supportedCurrencies = [
    'FCFA', 'EUR', 'USD', 'GHS', 'NGN',
  ];

  static const List<String> mobileMoneyOperators = [
    'MTN MoMo', 'Moov Money', 'Orange Money', 'Wave',
  ];

  static const double maxTransactionAmount = 1000000000;
  static const double minTransactionAmount = 0.01;

  static const int inactivityLockDuration = 60;
  static const int pinLength = 4;
  static const int smsRetentionDays = 7;
}
