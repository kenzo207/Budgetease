import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/database/app_database.dart';
import '../../data/database/tables/settings_table.dart';
import 'package:drift/drift.dart' as drift;

part 'theme_provider.g.dart';

@riverpod
class ThemeProvider extends _$ThemeProvider {
  @override
  Future<ThemeMode> build() async {
    final database = AppDatabase();
    // Load settings from DB
    try {
      final settings = await database.select(database.settings).getSingleOrNull();
      if (settings != null) {
        return _preferenceToMode(settings.themeMode);
      }
    } catch (e) {
      print('Error loading theme: $e');
    }
    return ThemeMode.system; // Default
  }

  /// Update theme mode in DB and state
  Future<void> setThemeMode(ThemeMode mode) async {
    final database = AppDatabase();
    state = AsyncData(mode); // Optimistic update

    try {
      final settings = await database.select(database.settings).getSingleOrNull();
      if (settings != null) {
        await (database.update(database.settings)
              ..where((t) => t.id.equals(settings.id)))
            .write(SettingsCompanion(
              themeMode: drift.Value(_modeToPreference(mode)),
              updatedAt: drift.Value(DateTime.now()),
            ));
      }
    } catch (e) {
      print('Error saving theme: $e');
      // Revert on error?
      ref.invalidateSelf();
    }
  }

  ThemeMode _preferenceToMode(ThemeModePreference pref) {
    switch (pref) {
      case ThemeModePreference.light:
        return ThemeMode.light;
      case ThemeModePreference.dark:
        return ThemeMode.dark;
      case ThemeModePreference.system:
        return ThemeMode.system;
    }
  }

  ThemeModePreference _modeToPreference(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return ThemeModePreference.light;
      case ThemeMode.dark:
        return ThemeModePreference.dark;
      case ThemeMode.system:
        return ThemeModePreference.system;
    }
  }
}
