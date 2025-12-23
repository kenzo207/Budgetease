class Category {
  final String name;
  final String icon;
  final bool isDefault;

  const Category({
    required this.name,
    required this.icon,
    this.isDefault = true,
  });
}

const List<Category> defaultCategories = [
  Category(name: 'Mobile Money', icon: '📱'),
  Category(name: 'Transport', icon: '🚌'),
  Category(name: 'Alimentation', icon: '🍽️'),
  Category(name: 'Logement', icon: '🏠'),
  Category(name: 'Santé', icon: '🏥'),
  Category(name: 'Éducation', icon: '📚'),
  Category(name: 'Loisirs', icon: '🎮'),
  Category(name: 'Vêtements', icon: '👕'),
  Category(name: 'Autres', icon: '📦'),
];
