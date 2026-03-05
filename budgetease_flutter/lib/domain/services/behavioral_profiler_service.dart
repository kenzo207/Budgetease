import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../engine/engine_output.dart';
import '../../presentation/providers/engine_provider.dart';

/// Service de profil comportemental — lit uniquement les données du moteur Rust.
///
/// Le profil [BehavioralProfile] est calculé par le moteur Rust dans
/// [ZoltEngineOutputV2.profile] (zolt_session / zolt_run).
/// Aucun calcul n'est effectué côté Dart.
class BehavioralProfilerService {
  final Ref _ref;

  BehavioralProfilerService({required Ref ref}) : _ref = ref;

  /// Retourne le profil comportemental calculé par le moteur Rust.
  Future<BehavioralReport> buildProfile() async {
    final session = await _ref.read(zoltEngineProviderProvider.future);
    return BehavioralReport.fromRust(session.engine.profile, session.health);
  }

  /// Alias : toujours retourner le profil Rust actuel.
  Future<BehavioralReport> getOrCreateProfile() => buildProfile();

  /// Dépensier du soir si le rythme Rust est "Terminal" ou "Frontal".
  Future<bool> isEveningSpender() async {
    final session = await _ref.read(zoltEngineProviderProvider.future);
    return session.engine.profile.rhythm == 'Terminal';
  }

  /// Heure de dépense préférée : null (non disponible depuis le moteur Rust).
  Future<int?> getPreferredSpendingHour() async => null;
}

/// Rapport comportemental construit depuis les données Rust.
class BehavioralReport {
  final double spendingFrequency;   // volatilityScore 0..1
  final String rhythmLabel;         // Linear | Frontal | Terminal | Erratic
  final int cyclesObserved;
  final double savingsAchievement;  // ratio 0..1
  final double hiddenChargesTotal;
  final String advisoryLevel;
  final DateTime lastUpdated;

  // Champs conservés pour la rétrocompatibilité avec les widgets existants
  final Map<int, int> hourlyPattern;
  final int overrunCount;
  final double averageOverrun;

  BehavioralReport({
    required this.spendingFrequency,
    required this.rhythmLabel,
    required this.cyclesObserved,
    required this.savingsAchievement,
    required this.hiddenChargesTotal,
    required this.advisoryLevel,
    required this.lastUpdated,
    this.hourlyPattern = const {},
    this.overrunCount  = 0,
    this.averageOverrun = 0.0,
  });

  factory BehavioralReport.fromRust(BehavioralProfile profile, HealthScore health) {
    // Mapper le score de santé sur le niveau de conseil
    final level = health.score >= 70
        ? 'minimal'
        : health.score < 40
            ? 'frequent'
            : 'standard';

    return BehavioralReport(
      spendingFrequency:   profile.volatilityScore,
      rhythmLabel:         profile.rhythmLabel,
      cyclesObserved:      profile.cyclesObserved,
      savingsAchievement:  profile.savingsAchievement,
      hiddenChargesTotal:  profile.hiddenChargesTotal,
      advisoryLevel:       level,
      lastUpdated:         DateTime.now(),
    );
  }

  String get advisoryLevelText {
    switch (advisoryLevel) {
      case 'minimal':  return 'Minimal';
      case 'frequent': return 'Fréquent';
      default:         return 'Standard';
    }
  }

  String get behaviorDescription {
    switch (rhythmLabel) {
      case 'Dépensier en début de mois': return 'Vous dépensez surtout en début de mois';
      case 'Dépensier en fin de mois':   return 'Vous dépensez surtout en fin de mois';
      case 'Irrégulier':                 return 'Vos dépenses sont irrégulières';
      default:                           return 'Vous avez une fréquence de dépense régulière';
    }
  }
}
