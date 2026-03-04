import 'package:flutter/material.dart';
import '../../data/database/tables/accounts_table.dart';
import '../../data/database/tables/categories_table.dart';
import '../constants/app_constants.dart';

class UIHelpers {
  // --- Accounts ---

  static IconData getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.wallet;
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

  // --- Mapping d'icônes par nom ---
  static const Map<String, IconData> iconMap = {
    // Dépenses
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'phone_iphone': Icons.phone_iphone,
    'home': Icons.home_rounded,
    'local_hospital': Icons.local_hospital,
    'sports_esports': Icons.sports_esports,
    'checkroom': Icons.checkroom,
    'school': Icons.school,
    'lightbulb': Icons.lightbulb_outline,
    'category': Icons.category,
    'shopping_cart': Icons.shopping_cart,
    'local_grocery_store': Icons.local_grocery_store,
    'bolt': Icons.bolt,
    'water_drop': Icons.water_drop,
    'wifi': Icons.wifi,
    'directions_bus': Icons.directions_bus,
    'receipt': Icons.receipt_long,
    'pets': Icons.pets,
    'fitness_center': Icons.fitness_center,
    'local_gas_station': Icons.local_gas_station,
    'local_laundry_service': Icons.local_laundry_service,
    'child_care': Icons.child_care,
    'flight': Icons.flight_takeoff,
    'movie': Icons.movie_outlined,
    'music_note': Icons.music_note,
    'coffee': Icons.coffee,
    'spa': Icons.spa,
    'build': Icons.build,
    'local_parking': Icons.local_parking,
    'local_pharmacy': Icons.local_pharmacy,

    // Revenus
    'account_balance_wallet': Icons.account_balance_wallet,
    'work': Icons.work_outline,
    'laptop_mac': Icons.laptop_mac,
    'storefront': Icons.storefront,
    'card_giftcard': Icons.card_giftcard,
    'trending_up': Icons.trending_up,
    'attach_money': Icons.attach_money,
    'real_estate_agent': Icons.real_estate_agent,
    'handshake': Icons.handshake,
    'volunteer_activism': Icons.volunteer_activism,
    'monetization_on': Icons.monetization_on,
    'savings': Icons.savings,
    'payments': Icons.payments,
    'store': Icons.store,

    // Legacy fallbacks
    'money': Icons.money,
    'credit_card': Icons.credit_card,
  };

  // --- Categories ---

  static IconData getCategoryIcon(CategoryType type) {
    switch (type) {
      case CategoryType.expense:
        return Icons.shopping_cart;
      case CategoryType.income:
        return Icons.account_balance_wallet;
    }
  }

  static IconData getIconForCategory(String? iconName, CategoryType type) {
    if (iconName == null || iconName.isEmpty) {
      return getCategoryIcon(type);
    }
    return iconMap[iconName] ?? getCategoryIcon(type);
  }

  /// Liste des icônes disponibles pour le picker de catégories
  static List<MapEntry<String, IconData>> get availableIcons => iconMap.entries.toList();

  static Color getCategoryColor(CategoryType type) {
    switch (type) {
      case CategoryType.expense:
        return AppColors.errorColor;
      case CategoryType.income:
        return AppColors.accentColor;
    }
  }

  // --- Theme Wrapper pour les surfaces ---
  static Widget withSurfaceTheme(BuildContext context, Widget child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          // Invert primary/onPrimary inside surfaces
          primary: Theme.of(context).colorScheme.onSurface,
          onPrimary: Theme.of(context).colorScheme.surface,
        ),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Theme.of(context).colorScheme.onSurface,
          displayColor: Theme.of(context).colorScheme.onSurface,
        ),
        iconTheme: Theme.of(context).iconTheme.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.onSurface,
            foregroundColor: Theme.of(context).colorScheme.surface,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            side: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
              width: 1.5
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      child: child,
    );
  }
}
