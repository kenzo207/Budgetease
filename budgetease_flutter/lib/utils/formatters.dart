import 'package:intl/intl.dart';

class CurrencyFormatter {
  static const Map<String, Map<String, dynamic>> currencies = {
    'FCFA': {'symbol': 'FCFA', 'decimals': 0},
    'NGN': {'symbol': '₦', 'decimals': 2},
    'GHS': {'symbol': 'GH₵', 'decimals': 2},
    'USD': {'symbol': '\$', 'decimals': 2},
    'EUR': {'symbol': '€', 'decimals': 2},
  };

  static String format(double amount, String currency) {
    final currencyInfo = currencies[currency] ?? currencies['FCFA']!;
    final decimals = currencyInfo['decimals'] as int;
    final symbol = currencyInfo['symbol'] as String;

    if (currency == 'FCFA') {
      return '${amount.toStringAsFixed(decimals)} $symbol';
    }

    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimals,
    );
    return formatter.format(amount);
  }
}

class DateFormatter {
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return "Aujourd'hui";
    } else if (dateOnly == yesterday) {
      return 'Hier';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  static String formatMonth(String monthStr) {
    final parts = monthStr.split('-');
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    return DateFormat('MMMM yyyy', 'fr_FR').format(date);
  }
}
