// ============================================================
//  MODULE B — PRÉDICTION FIN DE CYCLE
//  Projette le solde final en tenant compte du rythme comportemental.
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
        let days_elapsed = {
            let start = Self::cycle_start(&input.today, &input.cycle);
            start.days_until(&input.today).max(0) as u32
        };

        // Pas de prédiction le premier jour du cycle (aucun signal)
        if days_elapsed == 0 { return None; }

        let days_total   = days_elapsed + det.days_remaining;
        let spent_so_far = Self::total_spent_this_cycle(&input.transactions, &input.today, &input.cycle);

        // Évite la division par zéro si aucune dépense n'a été faite
        let current_daily_rate = if days_elapsed > 0 {
            spent_so_far / days_elapsed as f64
        } else {
            0.0
        };

        let rhythm_factor = Self::rhythm_correction_factor(profile, days_elapsed, days_total);

        let projected_daily_rate = current_daily_rate * rhythm_factor;
        let projected_remaining  = projected_daily_rate * det.days_remaining as f64;

        // Solde projeté = solde actuel − dépenses futures projetées − masse engagée
        let projected_final = det.total_balance - projected_remaining - det.committed_mass;
        let projected_deficit = (-projected_final).max(0.0);

        // Seuil d'alerte
        let monthly_budget = det.free_mass + spent_so_far;
        let alert_level = if projected_deficit > monthly_budget * 0.15 {
            AlertLevel::Critical
        } else if projected_deficit > 0.0 {
            AlertLevel::Warning
        } else if projected_final > monthly_budget * 0.20 {
            AlertLevel::Positive
        } else {
            AlertLevel::Info
        };

        let confidence = Self::compute_confidence(history, days_elapsed, days_total);

        Some(EndOfCyclePrediction {
            projected_final_balance: projected_final,
            projected_deficit,
            confidence,
            alert_level,
        })
    }

    // ── Facteur de correction selon le rythme ──────────────────
    fn rhythm_correction_factor(
        profile:      &BehavioralProfile,
        days_elapsed: u32,
        days_total:   u32,
    ) -> f64 {
        if days_total == 0 { return 1.0; }
        let progress = days_elapsed as f64 / days_total as f64;

        match &profile.rhythm {
            SpendingRhythm::Frontal  => 0.5 + 0.5 * progress,
            SpendingRhythm::Terminal => (1.5 - 0.5 * progress).max(0.5),
            SpendingRhythm::Linear   => 1.0,
            SpendingRhythm::Erratic  => {
                // Pour les profils erratiques : utilise la volatilité
                // comme amortisseur — tendance vers 1.0
                1.0 + (profile.volatility_score - 0.5).clamp(-0.2, 0.2)
            }
        }
    }

    fn cycle_start(today: &Date, cycle: &FinancialCycle) -> Date {
        match &cycle.cycle_type {
            CycleType::Monthly => Date::new(today.year, today.month, 1),
            CycleType::Weekly  => {
                // Rewind jusqu'au lundi
                let wd = today.weekday(); // 1=lun
                let days_back = (wd - 1) as u32;
                Date::from_days_since_epoch(
                    today.to_days_since_epoch().saturating_sub(days_back)
                )
            }
            CycleType::Daily => *today,
            CycleType::Irregular { cycle_start, .. } => *cycle_start,
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

    fn compute_confidence(history: &[CycleRecord], days_elapsed: u32, days_total: u32) -> f64 {
        let history_factor  = (history.len() as f64 / 3.0).min(1.0);
        let progress_factor = if days_total > 0 {
            days_elapsed as f64 / days_total as f64
        } else { 0.0 };
        (history_factor * progress_factor).sqrt().min(1.0)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

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
        let det  = crate::deterministic::DeterministicEngine::compute(&input).unwrap();
        let pred = PredictionModule::compute(&input, &det, &[], &BehavioralProfile::default());
        assert!(pred.is_none());
    }

    #[test]
    fn test_prediction_deficit_detected() {
        let today = Date::new(2026, 3, 6);
        let transactions: Vec<Transaction> = (1u8..=5).map(|d| Transaction {
            id: format!("t{d}"),
            date: Date::new(2026, 3, d),
            amount: 20_000.0,
            tx_type: TransactionType::Expense,
            category: None, account_id: "a1".into(),
            description: None, sms_confidence: None,
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
        let det  = crate::deterministic::DeterministicEngine::compute(&input).unwrap();
        let pred = PredictionModule::compute(&input, &det, &[], &BehavioralProfile::default());

        let pred = pred.expect("prédiction attendue");
        assert!(pred.projected_deficit > 0.0);
        assert_eq!(pred.alert_level, AlertLevel::Critical);
    }

    #[test]
    fn test_frontal_rhythm_reduces_future_spend() {
        // Profil frontal → facteur < 1 en début de cycle → moins de dépenses projetées
        let today = Date::new(2026, 3, 5); // début du mois
        let transactions: Vec<Transaction> = (1u8..=4).map(|d| Transaction {
            id: format!("t{d}"),
            date: Date::new(2026, 3, d),
            amount: 10_000.0,
            tx_type: TransactionType::Expense,
            category: None, account_id: "a1".into(),
            description: None, sms_confidence: None,
        }).collect();

        let input = EngineInput {
            today,
            accounts: vec![Account {
                id: "a1".into(), name: "Cash".into(),
                account_type: AccountType::Cash,
                balance: 200_000.0, is_active: true,
            }],
            charges: vec![], transactions,
            cycle: FinancialCycle {
                cycle_type: CycleType::Monthly,
                savings_goal: 0.0, transport: TransportType::None,
            },
        };

        let det_base    = crate::deterministic::DeterministicEngine::compute(&input).unwrap();
        let pred_linear = PredictionModule::compute(
            &input, &det_base, &[],
            &BehavioralProfile { rhythm: SpendingRhythm::Linear, ..Default::default() }
        );
        let pred_frontal = PredictionModule::compute(
            &input, &det_base, &[],
            &BehavioralProfile { rhythm: SpendingRhythm::Frontal, ..Default::default() }
        );

        let lin  = pred_linear.unwrap().projected_final_balance;
        let fron = pred_frontal.unwrap().projected_final_balance;
        // Frontal → moins de dépenses projetées → solde final plus élevé
        assert!(fron > lin, "frontal ({:.0}) devrait être > linéaire ({:.0})", fron, lin);
    }

    #[test]
    fn test_confidence_increases_with_history_and_progress() {
        let c0 = PredictionModule::compute_confidence(&[], 5, 30);
        let c1 = PredictionModule::compute_confidence(&[Default::default(); 3], 5, 30);
        let c2 = PredictionModule::compute_confidence(&[Default::default(); 3], 25, 30);
        assert!(c0 < c1, "plus d'historique → plus de confiance");
        assert!(c1 < c2, "plus avancé dans le cycle → plus de confiance");
    }
}
