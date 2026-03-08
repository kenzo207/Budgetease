import 'package:flutter/material.dart';
import '../../core/utils/zolt_animations.dart';

enum ZoltToastType { success, error, info }

class ZoltToast {
  static OverlayEntry? _currentEntry;
  static AnimationController? _currentController;

  /// Affiche un toast premium qui respecte les guidelines V3 de Zolt.
  static void show({
    required BuildContext context,
    required String message,
    ZoltToastType type = ZoltToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Retirer le précédent toast s'il y en a un
    _currentController?.reverse().then((_) {
      _currentEntry?.remove();
      _currentEntry = null;
    });

    final overlay = Overlay.of(context);
    
    // Setup animation controller for this specific toast
    final controller = AnimationController(
        vsync: overlay,
        duration: ZoltAnimations.durationMedium,
        reverseDuration: ZoltAnimations.durationShort);

    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 24, // un peu au-dessus du bas de l'écran
          left: 24,
          right: 24,
          child: Material(
            color: Colors.transparent,
            child: _ToastWidget(
              message: message,
              type: type,
              controller: controller,
            ),
          ),
        );
      },
    );

    _currentEntry = entry;
    _currentController = controller;

    overlay.insert(entry);
    controller.forward();

    // Auto dismiss
    Future.delayed(duration, () {
      if (_currentEntry == entry) {
        controller.reverse().then((_) {
          if (_currentEntry == entry) {
            entry.remove();
            _currentEntry = null;
          }
        });
      }
    });
  }
}

class _ToastWidget extends StatelessWidget {
  final String message;
  final ZoltToastType type;
  final AnimationController controller;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color iconColor;
    IconData icon;

    switch (type) {
      case ZoltToastType.success:
        bgColor = isDark ? const Color(0xFF131311) : const Color(0xFFFFFFFF);
        iconColor = const Color(0xFF16A34A);
        icon = Icons.check_circle_rounded;
        break;
      case ZoltToastType.error:
        bgColor = isDark ? const Color(0xFF1A1A18) : const Color(0xFFF5F3EE);
        iconColor = const Color(0xFFDC2626);
        icon = Icons.error_rounded;
        break;
      case ZoltToastType.info:
        bgColor = isDark ? const Color(0xFF2A2A27) : const Color(0xFF0D0D0B);
        iconColor = isDark ? const Color(0xFFF5F3EE) : const Color(0xFFFAFAF7);
        icon = Icons.info_outline_rounded;
        break;
    }

    // Entrée : Slide up + fade (easeOut)
    // Sortie : Fade + scale 0.95 (easeIn)
    
    final slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: controller, curve: ZoltAnimations.curveEntrance),
    );

    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    final scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              ],
              border: Border.all(
                color: isDark ? const Color(0x1AF5F3EE) : const Color(0x1E0D0D0B),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontFamily: 'CabinetGrotesk',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: type == ZoltToastType.info 
                          ? (isDark ? const Color(0xFFF5F3EE) : const Color(0xFFFAFAF7))
                          : (isDark ? const Color(0xFFF5F3EE) : const Color(0xFF0D0D0B)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
