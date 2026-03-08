import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_constants.dart';
import '../screens/home/home_screen.dart';
import '../screens/transactions/transactions_screen.dart';
import '../screens/analysis/analysis_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../widgets/action_bottom_sheet.dart';
import '../providers/navigation_provider.dart';
import '../../services/analytics_service.dart';
import '../../core/utils/tutorial_keys.dart';

/// Écran principal avec Bottom Navigation
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {


  final List<Widget> _screens = const [
    HomeScreen(),
    TransactionsScreen(),
    AnalysisScreen(),
    SettingsScreen(),
  ];

  void _showActionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ActionBottomSheet(),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label, int currentIndex, {Key? key}) {
    final isSelected = currentIndex == index;
    final color = isSelected 
        ? Theme.of(context).colorScheme.primary 
        : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor ?? Colors.grey;
        
    return GestureDetector(
      key: key,
      onTap: () {
        ref.read(navigationIndexProvider.notifier).state = index;
        final screenByName = ['Home', 'Transactions', 'Analysis', 'Settings'];
        if (index < screenByName.length) {
          ref.read(analyticsServiceProvider).screen(screenByName[index]);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPill() {
    return GestureDetector(
      onTap: _showActionBottomSheet,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF7C3A1E), // brand #7C3A1E
          borderRadius: BorderRadius.circular(100), // radius_full
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(LucideIcons.plus, color: Color(0xFFF0E8DC), size: 18), // text_inverse
            SizedBox(width: 6),
            Text(
              'Ajouter',
              style: TextStyle(
                color: Color(0xFFF0E8DC), // text_inverse
                fontFamily: 'CabinetGrotesk',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Écouter le provider de navigation
    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        child: SafeArea(
          child: Container(
            height: 65,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, LucideIcons.home, LucideIcons.home, 'Accueil', currentIndex),
                _buildNavItem(1, LucideIcons.receipt, LucideIcons.receipt, 'Histor.', currentIndex),
                _buildAddPill(),
                _buildNavItem(2, LucideIcons.pieChart, LucideIcons.pieChart, 'Analyse', currentIndex),
                _buildNavItem(3, LucideIcons.settings, LucideIcons.settings, 'Params', currentIndex, key: TutorialKeys.settingsTabKey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
