import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/database/app_database.dart';
import 'database_provider.dart';

part 'settings_provider.g.dart';

/// Provider des paramètres utilisateur
@riverpod
class SettingsProvider extends _$SettingsProvider {
  @override
  Future<UserSettings?> build() async {
    final database = ref.watch(databaseProvider);
    final settings = await database.select(database.settings).getSingleOrNull();
    return settings;
  }

  /// Mettre à jour le mode discret
  Future<void> toggleDiscreteMode() async {
    final current = await future;
    if (current == null) return;

    final database = ref.read(databaseProvider);
    await (database.update(database.settings)
          ..where((s) => s.id.equals(current.id)))
        .write(
      SettingsCompanion(
        discreteModeEnabled: Value(!current.discreteModeEnabled),
        updatedAt: Value(DateTime.now()),
      ),
    );

    ref.invalidateSelf();
  }
}
