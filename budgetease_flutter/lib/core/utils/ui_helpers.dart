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

  static IconData getIconForCategory(String? iconName, CategoryType type) {
    if (iconName == null || iconName.isEmpty) {
      return getCategoryIcon(type);
    }

    switch (iconName) {
      // Expense
      case 'restaurant': return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'phone_iphone': return Icons.phone_iphone;
      case 'home': return Icons.home;
      case 'local_hospital': return Icons.local_hospital;
      case 'sports_esports': return Icons.sports_esports;
      case 'checkroom': return Icons.checkroom;
      case 'school': return Icons.school;
      case 'lightbulb': return Icons.lightbulb;
      case 'category': return Icons.category;
      
      // Income
      case 'payments': return Icons.payments;
      case 'work': return Icons.work;
      case 'store': return Icons.store;
      case 'card_giftcard': return Icons.card_giftcard;
      case 'trending_up': return Icons.trending_up;
      case 'attach_money': return Icons.attach_money;
      
      // Fallback/Legacy (if emoji)
      default: return getCategoryIcon(type);
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
