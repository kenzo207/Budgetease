import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/border_color_provider.dart';

/// Widget Card avec bordure dynamique
class DynamicCard extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;

  const DynamicCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borderAsync = ref.watch(cardBorderProvider);

    return borderAsync.when(
      data: (border) => Container(
        margin: margin,
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).cardTheme.color,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          border: Border.fromBorderSide(border),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: padding != null
              ? Padding(padding: padding!, child: child)
              : child,
        ),
      ),
      loading: () => Card(
        margin: margin,
        elevation: elevation ?? 0,
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
      error: (e, s) => Card(
        margin: margin,
        elevation: elevation ?? 0,
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}
