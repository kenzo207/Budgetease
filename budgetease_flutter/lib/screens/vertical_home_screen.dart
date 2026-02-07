import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:budgetease_flutter/database/app_database.dart';
import 'package:budgetease_flutter/screens/flow_screen.dart';
import 'package:budgetease_flutter/screens/shield_screen.dart';
import 'package:budgetease_flutter/screens/history_screen.dart';

/// Main home screen with vertical navigation
/// Swipe UP → Shield (Future)
/// Center → Flow (Present)
/// Swipe DOWN → History (Past)
class VerticalHomeScreen extends StatefulWidget {
  const VerticalHomeScreen({super.key});

  @override
  State<VerticalHomeScreen> createState() => _VerticalHomeScreenState();
}

class _VerticalHomeScreenState extends State<VerticalHomeScreen> {
  late PageController _pageController;
  int _currentPage = 1; // Start at Flow (center)

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // Vertical PageView
          PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
              _triggerHapticForPage(page);
            },
            children: const [
              // Page 0: Shield (Future)
              ShieldScreen(),

              // Page 1: Flow (Present) - Default
              FlowScreen(),

              // Page 2: History (Past)
              HistoryScreen(),
            ],
          ),

          // Vertical position indicator
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildVerticalIndicator(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIndicatorDot(
            index: 0,
            icon: Icons.shield_outlined,
            label: 'Shield',
            isActive: _currentPage == 0,
          ),
          const SizedBox(height: 20),
          _buildIndicatorDot(
            index: 1,
            icon: Icons.water_drop_outlined,
            label: 'Flow',
            isActive: _currentPage == 1,
          ),
          const SizedBox(height: 20),
          _buildIndicatorDot(
            index: 2,
            icon: Icons.history,
            label: 'History',
            isActive: _currentPage == 2,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorDot({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: isActive ? 56 : 48,
        height: isActive ? 56 : 48,
        decoration: BoxDecoration(
          color: isActive 
              ? const Color(0xFF6C63FF) 
              : const Color(0xFF2A2A2A),
          shape: BoxShape.circle,
          boxShadow: isActive ? [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ] : [],
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey[600],
          size: isActive ? 28 : 24,
        ),
      ),
    );
  }

  void _triggerHapticForPage(int page) {
    switch (page) {
      case 0: // Shield
        HapticFeedback.mediumImpact();
        break;
      case 1: // Flow
        HapticFeedback.lightImpact();
        break;
      case 2: // History
        HapticFeedback.heavyImpact();
        break;
    }
  }
}
