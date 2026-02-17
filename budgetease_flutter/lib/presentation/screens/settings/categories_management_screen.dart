import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/tables/categories_table.dart';
import '../../providers/categories_provider.dart';

/// Écran de gestion des catégories
class CategoriesManagementScreen extends ConsumerWidget {
  const CategoriesManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProviderProvider);

    return Scaffold(
      // backgroundColor: AppColors.backgroundColor, // Removed
      appBar: AppBar(
        title: const Text('Gérer les catégories'),
        // backgroundColor: AppColors.backgroundColor, // Removed
      ),
      body: categoriesAsync.when(
        data: (categories) {
          // Group by type
          final expenseCategories = categories.where((c) => c.type == CategoryType.expense).toList();
          final incomeCategories = categories.where((c) => c.type == CategoryType.income).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Expense Categories
              Text(
                'Catégories de dépenses',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...expenseCategories.map((category) => _buildCategoryCard(
                    context,
                    ref,
                    category,
                  )),
              
              const SizedBox(height: 24),
              
              // Income Categories
              Text(
                'Catégories de revenus',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...incomeCategories.map((category) => _buildCategoryCard(
                    context,
                    ref,
                    category,
                  )),
              
              const SizedBox(height: 80),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => const Center(child: Text('Erreur de chargement')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: UIHelpers.getCategoryColor(category.type).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            UIHelpers.getIconForCategory(category.icon, category.type),
            color: UIHelpers.getCategoryColor(category.type),
          ),
        ),
        title: Text(category.name),
        subtitle: Text(category.type == CategoryType.expense ? 'Dépense' : 'Revenu'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showEditCategoryDialog(context, ref, category),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: AppColors.errorColor),
              onPressed: () => _showDeleteConfirmation(context, ref, category),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    CategoryType selectedType = CategoryType.expense;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nouvelle catégorie'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la catégorie',
                  hintText: 'Ex: Restaurant, Salaire...',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<CategoryType>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(
                    value: CategoryType.expense,
                    child: Text('Dépense'),
                  ),
                  DropdownMenuItem(
                    value: CategoryType.income,
                    child: Text('Revenu'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedType = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  await _addCategory(context, ref, name, selectedType);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, WidgetRef ref, Category category) {
    final nameController = TextEditingController(text: category.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la catégorie'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nom de la catégorie',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                await _updateCategory(context, ref, category, name);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la catégorie ?'),
        content: Text('Voulez-vous vraiment supprimer "${category.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteCategory(context, ref, category);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.errorColor),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _addCategory(
    BuildContext context,
    WidgetRef ref,
    String name,
    CategoryType type,
  ) async {
    try {
      final database = AppDatabase();
      await database.into(database.categories).insert(
        CategoriesCompanion.insert(
          name: name,
          type: type,
          icon: '',
          color: '',
          createdAt: DateTime.now(),
        ),
      );

      ref.invalidate(categoriesProviderProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catégorie ajoutée'),
            backgroundColor: AppColors.accentColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _updateCategory(
    BuildContext context,
    WidgetRef ref,
    Category category,
    String newName,
  ) async {
    try {
      final database = AppDatabase();
      await database.update(database.categories).replace(
        category.copyWith(name: newName),
      );

      ref.invalidate(categoriesProviderProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catégorie modifiée'),
            backgroundColor: AppColors.accentColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _deleteCategory(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    try {
      final database = AppDatabase();
      
      // Check if category is used in transactions
      final transactionsCount = await (database.select(database.transactions)
            ..where((t) => t.categoryId.equals(category.id)))
          .get()
          .then((list) => list.length);

      if (transactionsCount > 0) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Impossible de supprimer: $transactionsCount transaction(s) utilisent cette catégorie'),
              backgroundColor: AppColors.errorColor,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      await (database.delete(database.categories)
            ..where((c) => c.id.equals(category.id)))
          .go();

      ref.invalidate(categoriesProviderProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catégorie supprimée'),
            backgroundColor: AppColors.accentColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }
}
