import 'package:drift/drift.dart';

/// Settings table - app configuration
@DataClassName('SettingData')
class Settings extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  /// Currency code (default FCFA)
  TextColumn get currency => text().withDefault(const Constant('FCFA'))();
  
  /// Dark mode enabled?
  BoolColumn get darkMode => boolean().withDefault(const Constant(true))();
  
  /// Privacy mode (blur amounts)?
  BoolColumn get privacyMode => boolean().withDefault(const Constant(false))();
  
  /// Shadow savings rate (0.0 to 1.0)
  RealColumn get shadowSavingsRate => real().withDefault(const Constant(0.1))();
}
