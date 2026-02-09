import '../../data/database/tables/settings_table.dart';
import 'cycle_manager_service.dart';

/// Service de gestion du transport quotidien
class TransportManagerService {
  final TransportMode mode;
  final double? dailyCost;
  final int? daysPerWeek;
  final CycleManagerService cycleManager;

  TransportManagerService({
    required this.mode,
    this.dailyCost,
    this.daysPerWeek,
    required this.cycleManager,
  });

  /// Calculer le nombre de jours de transport restants dans le cycle
  int calculateTransportDays({
    required int daysRemaining,
    required int daysPerWeek,
  }) {
    if (daysPerWeek == 7) {
      return daysRemaining;
    }

    // Calculer le nombre de semaines complètes restantes
    final weeksRemaining = (daysRemaining / 7).floor();
    final extraDays = daysRemaining % 7;

    // Jours de transport dans les semaines complètes
    int transportDays = weeksRemaining * daysPerWeek;

    // Ajouter les jours de la semaine partielle
    // (Simplification : on suppose que les jours de transport sont répartis uniformément)
    final transportDaysInPartialWeek = (extraDays * daysPerWeek / 7).ceil();
    transportDays += transportDaysInPartialWeek;

    return transportDays;
  }

  /// Calculer la réserve totale nécessaire pour le transport
  double calculateTransportReserve() {
    if (mode == TransportMode.none) {
      return 0.0;
    }

    if (mode == TransportMode.fixed) {
      // Le transport fixe est géré dans les charges fixes
      return 0.0;
    }

    // Transport quotidien
    if (mode == TransportMode.daily && dailyCost != null && daysPerWeek != null) {
      final daysRemaining = cycleManager.getDaysRemainingInCycle();
      final transportDays = calculateTransportDays(
        daysRemaining: daysRemaining,
        daysPerWeek: daysPerWeek!,
      );
      return dailyCost! * transportDays;
    }

    return 0.0;
  }
}
