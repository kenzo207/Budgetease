import 'package:flutter/material.dart';
import '../../data/database/tables/accounts_table.dart';
import '../../data/database/tables/categories_table.dart';
import '../constants/app_constants.dart';

class UIHelpers {
  // --- Accounts ---

  static IconData getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.money; // Ou Icons.wallet
      case AccountType.mobileMoney:
        return Icons.phone_android;
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.savings:
        return Icons.savings;
    }
  }

  static Color getAccountColor(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return const Color(0xFF00E676); // Green
      case AccountType.mobileMoney:
        return const Color(0xFF1E88E5); // Blue
      case AccountType.bank:
        return const Color(0xFFFF6B6B); // Red
      case AccountType.savings:
        return const Color(0xFFFFD93D); // Yellow
    }
  }

  // --- Categories ---

  static IconData getCategoryIcon(CategoryType type) {
    switch (type) {
      case CategoryType.expense:
        return Icons.shopping_cart;
      case CategoryType.income:
        return Icons.attach_money;
    }
  }

  static Color getCategoryColor(CategoryType type) {
    switch (type) {
      case CategoryType.expense:
        return AppColors.errorColor;
      case CategoryType.income:
        return AppColors.accentColor;
    }
  }
}
