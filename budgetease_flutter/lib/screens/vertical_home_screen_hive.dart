import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Vertical Home Screen MVP avec Hive
/// Simplifié pour démo sans Isar
class VerticalHomeScreenHive extends StatefulWidget {
  const VerticalHomeScreenHive({super.key});

  @override
  State<VerticalHomeScreenHive> createState() => _VerticalHomeScreenHiveState();
}

class _VerticalHomeScreenHiveState extends State<VerticalHomeScreenHive> {
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
            children: [
              // Page 0: Shield (Future)
              _buildShieldPageMVP(),

              // Page 1: Flow (Present) - Default
              _buildFlowPageMVP(),

              // Page 2: History (Past)
              _buildHistoryPageMVP(),
            ],
          ),

          // Position indicator (right side)
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIndicatorDot(0, '🛡️'),
                  const SizedBox(height: 24),
                  _buildIndicatorDot(1, '🎯'),
                  const SizedBox(height: 24),
                  _buildIndicatorDot(2, '📜'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorDot(int page, String emoji) {
    final isActive = _currentPage == page;

    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        width: isActive ? 56 : 40,
        height: isActive ? 56 : 40,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6C63FF) : const Color(0xFF2A2A2A),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? const Color(0xFF6C63FF) : Colors.grey[700]!,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(fontSize: isActive ? 24 : 18),
          ),
        ),
      ),
    );
  }

  void _triggerHapticForPage(int page) {
    if (page == 1) {
      HapticFeedback.mediumImpact(); // Flow (center)
    } else {
      HapticFeedback.lightImpact(); // Shield or History
    }
  }

  // MVP Pages (simplified)
  Widget _buildShieldPageMVP() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield, size: 80, color: Color(0xFF6C63FF)),
          const SizedBox(height: 24),
          const Text(
            '🛡️ The Shield',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'MVP - Fonctionnalité à venir',
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _pageController.animateToPage(1,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut),
            icon: const Icon(Icons.arrow_downward),
            label: const Text('Aller au Flow'),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowPageMVP() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Liquid Gauge simplified
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6C63FF).withOpacity(0.8),
                  const Color(0xFF03DAC6).withOpacity(0.6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '💰',
                    style: TextStyle(fontSize: 48),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '0 FCFA',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Daily Cap',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            '🎯 Flow MVP',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'UI complète - Data à venir',
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.remove_circle),
                label: const Text('Dépense'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_circle),
                label: const Text('Revenu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPageMVP() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 80, color: Color(0xFF6C63FF)),
          const SizedBox(height: 24),
          const Text(
            '📜 History',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'MVP - Aucune transaction',
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _pageController.animateToPage(1,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut),
            icon: const Icon(Icons.arrow_upward),
            label: const Text('Retour au Flow'),
          ),
        ],
      ),
    );
  }
}
