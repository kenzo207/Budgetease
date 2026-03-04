import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';
import 'database_provider.dart';

/// Provider pour la couleur des bordures
final borderColorProvider = FutureProvider<Color>((ref) async {
  final database = ref.watch(databaseProvider);
  final settings = await database.select(database.settings).getSingleOrNull();

  if (settings?.borderColor != null) {
    try {
      final colorHex = settings!.borderColor!;
      final colorInt = int.parse(colorHex.substring(1), radix: 16);
      return Color(colorInt + 0xFF000000);
    } catch (e) {
      // Fallback to default green
      return const Color(0xFF4CAF50);
    }
  }

  // Default green color
  return const Color(0xFF4CAF50);
});

/// Provider pour obtenir la bordure avec opacité
final cardBorderProvider = FutureProvider<BorderSide>((ref) async {
  final color = await ref.watch(borderColorProvider.future);
  return BorderSide(
    color: color.withValues(alpha: 0.3),
    width: 1.5,
  );
});
