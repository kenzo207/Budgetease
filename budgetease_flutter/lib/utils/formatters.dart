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
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  static String formatMonth(String monthStr) {
    try {
      final parts = monthStr.split('-');
      if (parts.length != 2) return monthStr;
      
      final year = parts[0];
      final month = int.parse(parts[1]);
      
      const months = [
        'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
        'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
      ];
      
      if (month < 1 || month > 12) return monthStr;
      
      return '${months[month - 1]} $year';
    } catch (e) {
      return monthStr;
    }
  }
}
