// ============================================================
//  MODULE B — PRÉDICTION FIN DE CYCLE
//  Projette le solde à la fin du cycle courant en tenant compte
//  du rythme comportemental observé sur les cycles passés.
//  Confiance faible si < 3 cycles d'historique.
// ============================================================

use crate::types::*;
use crate::deterministic::DeterministicEngine;
use super::{CycleRecord, profile::ProfileModule};

pub struct PredictionModule;

impl PredictionModule {
    pub fn compute(
        input:   &EngineInput,
        det:     &DeterministicResult,
        history: &[CycleRecord],
        profile: &BehavioralProfile,
    ) -> Option<EndOfCyclePrediction> {
        // Pas de prédiction le premier jour du cycle (pas assez de signal)
        let cycle_end    = DeterministicEngine::cycle_end_date(&input.today, &input.cycle);
        let days_elapsed = {
            let start = Self::cycle_start(&input.today, &input.cycle);
            start.days_until(&input.today).max(0) as u32
        };

        if days_elapsed == 0 { return None; }

        let days_total    = days_elapsed + det.days_remaining;
        let spent_so_far  = Self::total_spent_this_cycle(&input.transactions, &input.today, &input.cycle);

        // ── Taux de dépense journalier actuel ──
        let current_daily_rate = spent_so_far / days_elapsed as f64;

        // ── Facteur de correction selon le rythme ──
        let rhythm_factor = Self::rhythm_correction_factor(
            profile,
            days_elapsed,
            days_total,
            history,
        );

        // ── Taux projeté pour les jours restants ──
        let projected_daily_rate = current_daily_rate * rhythm_factor;
        let projected_remaining  = projected_daily_rate * det.days_remaining as f64;

        // ── Solde projeté en fin de cycle ──
        // On part du solde actuel et on soustrait les dépenses projetées + charges restantes
        let projected_final = det.total_balance
            - projected_remaining
            - det.committed_mass;  // épargne + transport + charges déjà réservées

        let projected_deficit = (-projected_final).max(0.0);

        // ── Niveau d'alerte ──
        let monthly_budget   = det.free_mass + spent_so_far;
        let alert_level = if projected_deficit > monthly_budget * 0.15 {
            AlertLevel::Critical
        } else if projected_deficit > 0.0 {
            AlertLevel::Warning
        } else if projected_final > monthly_budget * 0.20 {
            AlertLevel::Positive // va finir avec une bonne marge
        } else {
            AlertLevel::Info
        };

        // ── Score de confiance ──
        let confidence = Self::compute_confidence(history, days_elapsed, days_total);

        let _ = cycle_end; // utilisé implicitement via days_remaining

        Some(EndOfCyclePrediction {
            projected_final_balance: projected_final,
            projected_deficit,
            confidence,
            alert_level,
        })
    }

    // ── Facteur de correction du rythme ──────────────────────────
    // Ajuste le taux de dépense futur selon où on en est dans le cycle
    // et le profil comportemental observé.
    //
    // Principe :
    //   - Rythme frontal  : l'utilisateur dépense bcp en début de mois.
    //     Si on est en début de mois, le taux actuel est élevé mais va baisser.
    //     → facteur < 1.0
    //   - Rythme terminal : inverse
    //     → facteur > 1.0 si on est encore en début de mois
    //   - Linear / Erratic : facteur ≈ 1.0
    fn rhythm_correction_factor(
        profile:      &BehavioralProfile,
        days_elapsed: u32,
        days_total:   u32,
        history:      &[CycleRecord],
    ) -> f64 {
        if history.len() < 2 {
            return 1.0; // pas assez d'historique → projection linéaire
        }

        let progress = days_elapsed as f64 / days_total as f64; // 0.0..=1.0

        match &profile.rhythm {
            SpendingRhythm::Frontal => {
                // Courbe décroissante : début de mois → facteur bas, fin de mois → facteur ≈ 1
                // f(progress) = 0.5 + 0.5 * progress
                // A progress=0 : 0.5 (on projette que la dépense va diminuer de moitié)
                // A progress=1 : 1.0 (plus de correction)
                0.5 + 0.5 * progress
            }
            SpendingRhythm::Terminal => {
                // Courbe croissante : début de mois → facteur > 1 (anticipation des grosses dépenses à venir)
                // f(progress) = 1.5 - 0.5 * progress
                1.5 - 0.5 * progress
            }
            SpendingRhythm::Linear => 1.0,
            SpendingRhythm::Erratic => {
                // Pour l'erratique, on utilise la médiane historique plutôt que le taux actuel
                // → facteur = médiane_historique / current_rate (calculé à l'extérieur)
                // Ici on retourne 1.0 et on laisse la variance gérer ça via volatility
                1.0
            }
        }
    }

    fn cycle_start(today: &Date, cycle: &FinancialCycle) -> Date {
        match &cycle.cycle_type {
            CycleType::Monthly     => Date::new(today.year, today.month, 1),
            CycleType::Weekly      => {
                // Rewind jusqu'au lundi
                let mut d = *today;
                while d.weekday() != 1 {
                    d = Self::prev_day(&d);
                }
                d
            }
            CycleType::Daily       => *today,
            CycleType::Irregular { cycle_start, .. } => *cycle_start,
        }
    }

    fn prev_day(date: &Date) -> Date {
        if date.day > 1 {
            Date::new(date.year, date.month, date.day - 1)
        } else if date.month > 1 {
            let prev_month = date.month - 1;
            let last_day   = DeterministicEngine::cycle_end_date(
                &Date::new(date.year, prev_month, 1),
                &FinancialCycle {
                    cycle_type:   CycleType::Monthly,
                    savings_goal: 0.0,
                    transport:    TransportType::None,
                },
            ).day;
            Date::new(date.year, prev_month, last_day)
        } else {
            Date::new(date.year - 1, 12, 31)
        }
    }

    fn total_spent_this_cycle(
        transactions: &[Transaction],
        today: &Date,
        cycle: &FinancialCycle,
    ) -> f64 {
        let start = Self::cycle_start(today, cycle);
        transactions.iter()
            .filter(|t| t.date >= start && t.date <= *today && t.tx_type.is_outflow())
            .map(|t| t.amount)
            .sum()
    }

    // ── Score de confiance ────────────────────────────────────────
    // Basé sur : nombre de cycles d'historique + avancement du cycle courant
    fn compute_confidence(history: &[CycleRecord], days_elapsed: u32, days_total: u32) -> f64 {
        let history_factor = (history.len() as f64 / 3.0).min(1.0); // max à 3 cycles
        let progress_factor = days_elapsed as f64 / days_total as f64;
        // Confiance = racine carrée du produit (pénalise si l'un des deux est faible)
        (history_factor * progress_factor).sqrt()
    }
}

// ────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;
    use crate::adaptive::AdaptiveEngine;

    #[test]
    fn test_no_prediction_on_first_day() {
        let input = EngineInput {
            today: Date::new(2026, 3, 1),
            accounts: vec![Account {
                id: "a1".into(), name: "MoMo".into(),
                account_type: AccountType::MobileMoney,
                balance: 200_000.0, is_active: true,
            }],
            charges: vec![], transactions: vec![],
            cycle: FinancialCycle {
                cycle_type: CycleType::Monthly,
                savings_goal: 0.0, transport: TransportType::None,
            },
        };
        let det  = crate::deterministic::DeterministicEngine::compute(&input);
        let pred = PredictionModule::compute(&input, &det, &[], &BehavioralProfile::default());
        assert!(pred.is_none());
    }

    #[test]
    fn test_prediction_deficit_detected() {
        // Utilisateur a dépensé 100 000 en 5 jours → rythme = 20 000/j
        // Reste 20 jours → projection = 400 000 de plus
        // Mais solde = 300 000 → déficit

        let today = Date::new(2026, 3, 6);
        let transactions: Vec<Transaction> = (1u8..=5).map(|d| Transaction {
            id:             format!("t{d}"),
            date:           Date::new(2026, 3, d),
            amount:         20_000.0,
            tx_type:        TransactionType::Expense,
            category:       None,
            account_id:     "a1".into(),
            description:    None,
            sms_confidence: None,
        }).collect();

        let input = EngineInput {
            today,
            accounts: vec![Account {
                id: "a1".into(), name: "MoMo".into(),
                account_type: AccountType::MobileMoney,
                balance: 300_000.0, is_active: true,
            }],
            charges: vec![], transactions,
            cycle: FinancialCycle {
                cycle_type: CycleType::Monthly,
                savings_goal: 0.0, transport: TransportType::None,
            },
        };
        let det  = crate::deterministic::DeterministicEngine::compute(&input);
        let pred = PredictionModule::compute(&input, &det, &[], &BehavioralProfile::default());
        assert!(pred.is_some());
        let pred = pred.unwrap();
        assert!(pred.projected_deficit > 0.0);
        assert_eq!(pred.alert_level, AlertLevel::Critical);
    }
}
