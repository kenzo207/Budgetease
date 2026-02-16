import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categories_table.dart';

part 'categories_dao.g.dart';

/// DAO pour la gestion des catégories
@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  /// Récupérer toutes les catégories
  Future<List<Category>> getAllCategories() => select(categories).get();

  /// Récupérer les catégories par type
  Future<List<Category>> getCategoriesByType(CategoryType type) {
    return (select(categories)..where((c) => c.type.equals(type.index))).get();
  }

  /// Récupérer une catégorie par ID
  Future<Category?> getCategoryById(int id) {
    return (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  /// Créer une nouvelle catégorie
  Future<int> insertCategory(CategoriesCompanion category) {
    return into(categories).insert(category);
  }

  /// Mettre à jour une catégorie
  Future<bool> updateCategory(Category category) {
    return update(categories).replace(category);
  }

  /// Supprimer une catégorie (seulement si non par défaut)
  Future<int> deleteCategory(int categoryId) {
    return (delete(categories)
          ..where((c) => c.id.equals(categoryId) & c.isDefault.equals(false)))
        .go();
  }

  /// Récupérer les catégories par défaut
  Future<List<Category>> getDefaultCategories() {
    return (select(categories)..where((c) => c.isDefault.equals(true))).get();
  }

  /// Récupérer les catégories personnalisées
  Future<List<Category>> getCustomCategories() {
    return (select(categories)..where((c) => c.isDefault.equals(false))).get();
  }
}
