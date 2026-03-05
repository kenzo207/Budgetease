import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../engine/engine_output.dart';
import '../../presentation/providers/engine_provider.dart';

/// Service de prédiction de revenus — lit uniquement les données du moteur Rust.
///
/// La prédiction [IncomePredictionResult] est calculée par le moteur Rust dans
/// [ZoltEngineOutputV2.incomePrediction] (zolt_session pipeline).
/// Aucun calcul n'est effectué côté Dart.
class IncomePredictorService {
  final Ref _ref;

  IncomePredictorService({required Ref ref}) : _ref = ref;

  /// Retourne la prédiction de revenu calculée par le moteur Rust.
  /// Retourne null si le moteur est indisponible ou si les données
  /// sont insuffisantes.
  Future<IncomePrediction?> predictNextIncome() async {
    final session = await _ref.read(zoltEngineProviderProvider.future);
    final result  = session.engine.incomePrediction;
    if (result == null) return null;
    return IncomePrediction.fromResult(result);
  }

  /// Retourne le revenu estimé du mois courant.
  ///
  /// Utilise [DeterministicResult.totalBalance] + la prédiction Rust.
  /// Si une prédiction Rust est disponible, retourne le montant prédit.
  /// Sinon retourne 0.
  Future<double> getEstimatedMonthlyIncome() async {
    final pred = await predictNextIncome();
    return pred?.predictedAmount ?? 0.0;
  }
}

/// Modèle de résultat de prédiction de revenu.
class IncomePrediction {
  final double predictedAmount;
  final DateTime? predictedDate;
  final double confidence;
  final String patternDescription;
  final int basedOnCycles;

  const IncomePrediction({
    required this.predictedAmount,
    required this.predictedDate,
    required this.confidence,
    required this.patternDescription,
    required this.basedOnCycles,
  });

  factory IncomePrediction.fromResult(IncomePredictionResult r) {
    return IncomePrediction(
      predictedAmount:     r.predictedAmount,
      predictedDate:       r.predictedDate,
      confidence:          r.confidence,
      patternDescription:  r.patternDescription,
      basedOnCycles:       r.basedOnCycles,
    );
  }

  /// Vrai si la prédiction est fiable (confiance >= 30 %).
  bool get isReliable => confidence >= 0.30;

  /// Nombre de jours jusqu'à la prochaine rentrée prédite.
  int? get daysUntilNext {
    if (predictedDate == null) return null;
    final diff = predictedDate!.difference(DateTime.now()).inDays;
    return diff >= 0 ? diff : 0;
  }

  /// Message lisible sur le pattern détecté.
  String get statusMessage {
    if (!isReliable) return 'Pas assez de données pour une prédiction fiable.';
    return patternDescription;
  }
}
