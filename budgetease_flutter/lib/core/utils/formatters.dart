import 'package:intl/intl.dart';

/// Formateur de montants monétaires
class MoneyFormatter {
  /// Formater un montant avec la devise
  static String format(double amount, String currency) {
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return '${formatter.format(amount)} $currency';
  }

  /// Formater un montant sans décimales
  static String formatCompact(double amount, String currency) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '${formatter.format(amount)} $currency';
  }

  /// Formater un montant en mode compact (K, M, B)
  static String formatShort(double amount, String currency) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B $currency';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M $currency';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K $currency';
    }
    return formatCompact(amount, currency);
  }

  /// Parser un montant depuis une chaîne
  static double? parse(String text) {
    // Retirer les espaces et remplacer la virgule par un point
    final cleaned = text.replaceAll(' ', '').replaceAll(',', '.');
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
