import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 7)
class Category extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String icon;

  @HiveField(3)
  bool isCustom;

  @HiveField(4)
  DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    this.isCustom = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Helper to create from default category
  factory Category.fromDefault(String name, String icon) {
    return Category(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      icon: icon,
      isCustom: false,
    );
  }
}

// Default categories as constant list
const List<Map<String, String>> defaultCategoriesData = [
  {'name': 'Mobile Money', 'icon': '📱'},
  {'name': 'Transport', 'icon': '🚌'},
  {'name': 'Alimentation', 'icon': '🍽️'},
  {'name': 'Logement', 'icon': '🏠'},
  {'name': 'Santé', 'icon': '🏥'},
  {'name': 'Éducation', 'icon': '📚'},
  {'name': 'Loisirs', 'icon': '🎮'},
  {'name': 'Vêtements', 'icon': '👕'},
  {'name': 'Autres', 'icon': '📦'},
];

// Helper to get default categories as Category objects
List<Category> getDefaultCategories() {
  return defaultCategoriesData
      .map((data) => Category.fromDefault(data['name']!, data['icon']!))
      .toList();
}
