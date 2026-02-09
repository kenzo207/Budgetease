import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider pour gérer l'index de la navigation principale
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Enum pour les onglets de l'application
enum AppTab {
  home,
  transactions,
  analysis,
  settings;
}
