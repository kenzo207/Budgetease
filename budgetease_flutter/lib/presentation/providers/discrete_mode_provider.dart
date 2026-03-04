import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider global pour le mode discret (masquer les montants).
/// Partagé entre HomeScreen et tous les autres écrans qui affichent des montants.
final discreteModeProvider = StateProvider<bool>((ref) => false);
