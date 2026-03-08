import 'package:flutter/material.dart';
import '../../core/utils/zolt_colors.dart';
import '../../core/utils/zolt_shadows.dart';
import 'zolt_animated_card.dart';

enum ZoltCardProfile {
  hero,
  standard,
  ghost,
  semantic,
}

enum ZoltSemanticLevel {
  positive,
  warning,
  critical,
  info,
}

class ZoltCard extends StatelessWidget {
  final Widget child;
  final ZoltCardProfile profile;
  final ZoltSemanticLevel? semanticLevel;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const ZoltCard({
    super.key,
    required this.child,
    this.profile = ZoltCardProfile.standard,
    this.semanticLevel,
    this.padding,
    this.margin,
    this.onTap,
  }) : assert(
         profile != ZoltCardProfile.semantic || semanticLevel != null,
         'ZoltSemanticLevel is required when profile is ZoltCardProfile.semantic',
       );

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    BoxDecoration decoration;
    EdgeInsetsGeometry defaultPadding;
    Widget content = child;

    switch (profile) {
      case ZoltCardProfile.hero:
        final borderColor = isDark ? const Color(0x2EFFFFFF) : const Color(0x0AFFFFFF); 
        decoration = BoxDecoration(
          color: isDark ? ZoltTokens.darkInverse : ZoltTokens.lightInverse,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: isDark ? null : ZoltShadows.hero(),
        );
        defaultPadding = const EdgeInsets.all(22);
        break;

      case ZoltCardProfile.standard:
        decoration = BoxDecoration(
          color: isDark ? ZoltTokens.darkSurface1 : ZoltTokens.lightSurface1,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? const Color(0x1AF5F3EE) : const Color(0x1E0D0D0B), width: 1),
          boxShadow: isDark ? null : ZoltShadows.card(),
        );
        defaultPadding = const EdgeInsets.all(18);
        break;

      case ZoltCardProfile.ghost:
        decoration = BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0x0DF5F3EE) : const Color(0x0D0D0D0B), width: 1),
        );
        defaultPadding = const EdgeInsets.all(16);
        break;

      case ZoltCardProfile.semantic:
        Color bgColor;
        Color borderLeftColor;
        List<BoxShadow>? glow;

        switch (semanticLevel!) {
          case ZoltSemanticLevel.critical:
            bgColor = ZoltTokens.criticalMuted;
            borderLeftColor = ZoltTokens.critical;
            glow = ZoltShadows.glowCritical();
            break;
          case ZoltSemanticLevel.warning:
            bgColor = ZoltTokens.warningMuted;
            borderLeftColor = ZoltTokens.warning;
            glow = ZoltShadows.glowWarning();
            break;
          case ZoltSemanticLevel.positive:
            bgColor = ZoltTokens.positiveMuted;
            borderLeftColor = ZoltTokens.positive;
            glow = ZoltShadows.glowPositive();
            break;
          case ZoltSemanticLevel.info:
            bgColor = isDark ? ZoltTokens.darkSurface2 : ZoltTokens.lightSurface2;
            borderLeftColor = isDark ? const Color(0x1AF5F3EE) : const Color(0x1E0D0D0B);
            glow = null;
            break;
        }

        final uniformBorderColor = isDark ? const Color(0x0DF5F3EE) : const Color(0x0D0D0D0B);
        
        decoration = BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: uniformBorderColor, width: 1),
          boxShadow: isDark ? null : glow,
        );
        
        content = Stack(
          children: [
            Padding(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: child,
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3.5,
                decoration: BoxDecoration(
                  color: borderLeftColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        );
        defaultPadding = EdgeInsets.zero; // managed by the Stack
        break;
    }

    if (profile != ZoltCardProfile.semantic) {
      content = Padding(
        padding: padding ?? defaultPadding,
        child: child, // Use the original child here, not the already-wrapped content
      );
    }

    if (onTap != null) {
      content = ZoltAnimatedCard(
        onTap: onTap,
        child: content,
      );
    }

    return Container(
      margin: margin,
      decoration: decoration,
      child: content,
    );
  }
}
