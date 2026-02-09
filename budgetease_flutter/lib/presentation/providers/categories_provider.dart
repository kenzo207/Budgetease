import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/database/app_database.dart';
import '../../data/database/tables/categories_table.dart';

part 'categories_provider.g.dart';

/// Provider des catégories
@riverpod
class CategoriesProvider extends _$CategoriesProvider {
  @override
  Future<List<Category>> build() async {
    final database = AppDatabase();
    return await database.select(database.categories).get();
  }

  /// Récupérer les catégories par type
  Future<List<Category>> getCategoriesByType(CategoryType type) async {
    final database = AppDatabase();
    return await (database.select(database.categories)
          ..where((c) => c.type.equals(type.index)))
        .get();
  }
}
