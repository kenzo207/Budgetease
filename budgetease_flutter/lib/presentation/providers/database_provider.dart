import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';

/// Provider singleton de la base de données.
/// Toute l'application partage la MÊME instance d'AppDatabase.
/// Cela évite les fuites de connexions SQLite et garantit
/// la cohérence des données entre les providers.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  // Fermer proprement la DB quand le provider est détruit (ex: tests)
  ref.onDispose(() => db.close());
  return db;
});
