import 'package:drift/drift.dart';

/// Types de catégories
enum CategoryType {
  expense,  // Catégorie de dépense
  income,   // Catégorie de revenu
}

/// Table des catégories
@DataClassName('Category')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get icon => text()();
  TextColumn get color => text()();
  IntColumn get type => intEnum<CategoryType>()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}
