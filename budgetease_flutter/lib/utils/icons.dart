// Icon library for custom categories
const List<Map<String, dynamic>> iconLibrary = [
  {
    'group': 'Finance',
    'icons': ['💰', '💵', '💳', '💸', '🏦', '📱', '💼', '📊', '💹']
  },
  {
    'group': 'Transport',
    'icons': ['🚗', '🚌', '🚕', '🚙', '🚎', '🏍️', '🚲', '🛵', '✈️', '🚆']
  },
  {
    'group': 'Nourriture',
    'icons': ['🍽️', '🍕', '🍔', '🍟', '🌮', '🍜', '🍱', '🥗', '☕', '🍺']
  },
  {
    'group': 'Maison',
    'icons': ['🏠', '🏡', '🛋️', '🛏️', '🚿', '🔌', '💡', '🔑', '🪴']
  },
  {
    'group': 'Santé',
    'icons': ['🏥', '💊', '💉', '🩺', '⚕️', '🧘', '💪', '🏃']
  },
  {
    'group': 'Éducation',
    'icons': ['📚', '📖', '✏️', '📝', '🎓', '🖊️', '📐', '🖍️']
  },
  {
    'group': 'Loisirs',
    'icons': ['🎮', '🎬', '🎵', '🎸', '🎨', '🎭', '🎪', '🎯', '🎲', '🎳']
  },
  {
    'group': 'Shopping',
    'icons': ['👕', '👔', '👗', '👠', '👟', '🛍️', '🎁', '💄', '👜']
  },
  {
    'group': 'Technologie',
    'icons': ['💻', '⌨️', '🖥️', '📱', '⌚', '🎧', '📷', '🖨️']
  },
  {
    'group': 'Autres',
    'icons': ['📦', '🔧', '🔨', '⚙️', '🎈', '🌟', '⭐', '❤️', '🎉']
  },
];

// Flatten all icons for quick access
List<String> getAllIcons() {
  return iconLibrary
      .expand((group) => group['icons'] as List<String>)
      .toList();
}
