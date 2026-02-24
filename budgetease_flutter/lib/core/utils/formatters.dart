import 'package:intl/intl.dart';

/// Formateur de montants monétaires
class MoneyFormatter {
  /// Formater un montant avec la devise
  static String format(double amount, String currency) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '${formatter.format(amount.round())} $currency';
  }

  /// Formater un montant sans décimales
  static String formatCompact(double amount, String currency) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '${formatter.format(amount.round())} $currency';
  }

  /// Formater un montant en mode compact (K, M, B)
  static String formatShort(double amount, String currency) {
    final abs = amount.abs();
    final sign = amount < 0 ? '-' : '';
    if (abs >= 1000000000) {
      return '$sign${(abs / 1000000000).toStringAsFixed(1)}B $currency';
    } else if (abs >= 1000000) {
      return '$sign${(abs / 1000000).toStringAsFixed(1)}M $currency';
    } else if (abs >= 1000) {
      return '$sign${(abs / 1000).toStringAsFixed(1)}K $currency';
    }
    return formatCompact(amount, currency);
  }

  /// Parser un montant depuis une chaîne
  /// Supporte: "1 000", "1,000", "1.000", "1.000.000", "1 000,50"
  static double? parse(String text) {
    String cleaned = text.trim();
    // Retirer symboles monétaires
    cleaned = cleaned.replaceAll(RegExp(r'[^\d\s.,\-]'), '');
    cleaned = cleaned.trim();
    if (cleaned.isEmpty) return null;
    
    // Compter les points et virgules
    final dots = '.'.allMatches(cleaned).length;
    final commas = ','.allMatches(cleaned).length;
    
    if (dots > 1) {
      // Multiple dots = thousands separators (1.000.000)
      cleaned = cleaned.replaceAll('.', '');
    } else if (commas > 1) {
      // Multiple commas = thousands separators (1,000,000)
      cleaned = cleaned.replaceAll(',', '');
    } else if (dots == 1 && commas == 1) {
      // One of each: determine order (1.000,50 vs 1,000.50)
      final dotPos = cleaned.indexOf('.');
      final commaPos = cleaned.indexOf(',');
      if (dotPos < commaPos) {
        // 1.000,50 — dot=thousands, comma=decimal
        cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // 1,000.50 — comma=thousands, dot=decimal
        cleaned = cleaned.replaceAll(',', '');
      }
    } else if (commas == 1) {
      // Single comma: could be decimal or thousands
      final afterComma = cleaned.split(',').last;
      if (afterComma.length == 3 && !afterComma.contains(' ')) {
        // 1,000 — thousands separator
        cleaned = cleaned.replaceAll(',', '');
      } else {
        // 1,50 — decimal separator
        cleaned = cleaned.replaceAll(',', '.');
      }
    } else if (dots == 1) {
      // Single dot: could be decimal or thousands
      final afterDot = cleaned.split('.').last;
      if (afterDot.length == 3 && !afterDot.contains(' ')) {
        // Ambiguous: 1.000 could be 1000 or 1.0
        // For FCFA (no decimals), treat as thousands
        cleaned = cleaned.replaceAll('.', '');
      }
      // else: keep as-is (decimal point)
    }
    // Remove spaces
    cleaned = cleaned.replaceAll(' ', '');
    return double.tryParse(cleaned);
  }
}

/// Formateur de dates
class DateFormatter {
  /// Formater une date au format court (dd/MM/yyyy)
  static String formatShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formater une date au format long (dd MMMM yyyy)
  static String formatLong(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'fr_FR').format(date);
  }

  /// Formater une date avec l'heure
  static String formatWithTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Formater une date relative (Aujourd'hui, Hier, etc.)
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Aujourd\'hui';
    } else if (dateOnly == yesterday) {
      return 'Hier';
    } else if (dateOnly.isAfter(today.subtract(const Duration(days: 7)))) {
      return DateFormat('EEEE', 'fr_FR').format(date);
    } else {
      return formatShort(date);
    }
  }
}
