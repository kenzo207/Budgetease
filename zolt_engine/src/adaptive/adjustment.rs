// ============================================================
//  MODULE D — AJUSTEMENTS ADAPTATIFS
//  Propose des ajustements de paramètres basés sur les patterns.
//  Ne modifie JAMAIS directement les paramètres — toujours via suggestion.
// ============================================================

use crate::types::*;
use super::CycleRecord;

pub struct AdjustmentModule;

impl AdjustmentModule {
    pub fn suggest(
        history: &[CycleRecord],
        profile: &BehavioralProfile,
        det:     &DeterministicResult,
    ) -> Vec<AdaptiveSuggestion> {
        if history.len() < 3 {
            return vec![]; // Phase d'observation
        }

        let mut suggestions = Vec::new();

        if let Some(s) = Self::suggest_savings_revision(history) {
            suggestions.push(s);
        }
        if let Some(s) = Self::suggest_hidden_charge(history, profile) {
            suggestions.push(s);
        }
        if let Some(s) = Self::suggest_safety_margin(profile) {
            suggestions.push(s);
        }

        suggestions
    }

    // ── Révision de l'objectif d'épargne ─────────────────────────
    // Si l'utilisateur rate son objectif (< 90%) sur 3 cycles consécutifs.
    fn suggest_savings_revision(history: &[CycleRecord]) -> Option<AdaptiveSuggestion> {
        let last_3 = &history[history.len().saturating_sub(3)..];
        let all_missed = last_3.iter().all(|r| {
            r.savings_goal > 0.0 && r.savings_achieved < r.savings_goal * 0.90
        });

        if !all_missed { return None; }

        let mut achieved: Vec<f64> = last_3.iter()
            .map(|r| r.savings_achieved.max(0.0))
            .collect();
        achieved.sort_by(|a, b| a.partial_cmp(b).unwrap_or(std::cmp::Ordering::Equal));
        let median = achieved[achieved.len() / 2];

        let suggested    = median * 1.05;
        let current_goal = last_3.last()?.savings_goal;

        // Ne pas suggérer si la différence est trop faible
        if (suggested - current_goal).abs() < current_goal * 0.05 {
            return None;
        }

        // Ne pas suggérer si les deux sont à zéro
        if current_goal <= 0.0 && suggested <= 0.0 {
            return None;
        }

        let reason = format!(
            "Sur les 3 derniers cycles, tu as épargné en moyenne {:.0} FCFA \
             au lieu de {:.0} FCFA. Un objectif de {:.0} FCFA serait plus réaliste.",
            median, current_goal, suggested
        );

        Some(AdaptiveSuggestion::ReviseSavingsGoal {
            current: current_goal,
            suggested,
            reason,
        })
    }

    // ── Charge informelle récurrente ──────────────────────────────
    fn suggest_hidden_charge(
        history: &[CycleRecord],
        profile: &BehavioralProfile,
    ) -> Option<AdaptiveSuggestion> {
        if profile.hidden_charges_total < 1_000.0 { return None; }

        let pattern = Self::find_strongest_recurring_pattern(history)?;

        Some(AdaptiveSuggestion::AddHiddenCharge {
            estimated_amount:     pattern.amount,
            pattern_description:  pattern.description,
        })
    }

    // ── Marge de sécurité comportementale ────────────────────────
    fn suggest_safety_margin(profile: &BehavioralProfile) -> Option<AdaptiveSuggestion> {
        if profile.volatility_score < 0.3 { return None; }

        let margin_pct = (profile.volatility_score * 0.10).min(0.10);

        Some(AdaptiveSuggestion::AdjustSafetyMargin {
            new_margin_pct: margin_pct,
        })
    }

    // ── Pattern récurrent le plus fort ───────────────────────────
    fn find_strongest_recurring_pattern(history: &[CycleRecord]) -> Option<RecurringPattern> {
        let mut pattern_map: std::collections::HashMap<(u8, u64), Vec<f64>> =
            std::collections::HashMap::new();

        for record in history {
            for tx in &record.transactions {
                if !tx.tx_type.is_outflow() || tx.amount <= 0.0 { continue; }
                let days_in = record.cycle_start.days_until(&tx.date).max(0) as u32;
                let week    = ((days_in / 7) + 1).min(5) as u8;
                let bucket  = (tx.amount / 500.0).round() as u64;
                pattern_map.entry((week, bucket)).or_default().push(tx.amount);
            }
        }

        let best = pattern_map.into_iter()
            .filter(|(_, amounts)| amounts.len() >= 3)
            .max_by_key(|(_, amounts)| amounts.len())?;

        let (week, _) = best.0;
        let amounts   = best.1;
        let avg: f64  = amounts.iter().sum::<f64>() / amounts.len() as f64;

        let week_label = match week {
            1 => "la première semaine",
            2 => "la deuxième semaine",
            3 => "la troisième semaine",
            4 => "la quatrième semaine",
            _ => "la fin",
        };

        Some(RecurringPattern {
            amount: avg,
            description: format!(
                "Tu dépenses environ {:.0} FCFA {} du mois depuis {} cycles.",
                avg, week_label, amounts.len()
            ),
        })
    }
}

struct RecurringPattern {
    amount:      f64,
    description: String,
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_cycle(savings_goal: f64, savings_achieved: f64) -> CycleRecord {
        CycleRecord {
            cycle_start: Date::new(2026, 1, 1), cycle_end: Date::new(2026, 1, 31),
            opening_balance: 300_000.0, closing_balance: 250_000.0,
            total_income: 300_000.0, total_expenses: 50_000.0,
            savings_goal, savings_achieved,
            daily_expenses: vec![1_000.0; 30],
            category_totals: vec![], transactions: vec![],
        }
    }

    fn make_det() -> DeterministicResult {
        DeterministicResult {
            total_balance: 300_000.0, committed_mass: 30_000.0,
            free_mass: 270_000.0, days_remaining: 20,
            daily_budget: 13_500.0, spent_today: 0.0,
            remaining_today: 13_500.0, transport_reserve: 0.0,
            charges_reserve: 30_000.0,
        }
    }

    #[test]
    fn test_no_suggestions_before_3_cycles() {
        let history = vec![make_cycle(30_000.0, 10_000.0), make_cycle(30_000.0, 12_000.0)];
        let suggestions = AdjustmentModule::suggest(&history, &BehavioralProfile::default(), &make_det());
        assert!(suggestions.is_empty());
    }

    #[test]
    fn test_savings_revision_suggested() {
        let history = vec![
            make_cycle(30_000.0, 10_000.0),
            make_cycle(30_000.0, 12_000.0),
            make_cycle(30_000.0,  9_000.0),
        ];
        let suggestions = AdjustmentModule::suggest(
            &history,
            &BehavioralProfile { cycles_observed: 3, ..Default::default() },
            &make_det(),
        );
        assert!(suggestions.iter().any(|s| matches!(s, AdaptiveSuggestion::ReviseSavingsGoal { .. })));
    }

    #[test]
    fn test_no_revision_when_goal_is_met() {
        let history = vec![
            make_cycle(30_000.0, 30_000.0),
            make_cycle(30_000.0, 28_000.0), // 93% → ok
            make_cycle(30_000.0, 27_500.0), // 91.7% → ok
        ];
        let suggestions = AdjustmentModule::suggest(
            &history,
            &BehavioralProfile { cycles_observed: 3, ..Default::default() },
            &make_det(),
        );
        assert!(!suggestions.iter().any(|s| matches!(s, AdaptiveSuggestion::ReviseSavingsGoal { .. })));
    }

    #[test]
    fn test_safety_margin_for_volatile_user() {
        let history: Vec<CycleRecord> = (0..3).map(|_| make_cycle(0.0, 0.0)).collect();
        let profile = BehavioralProfile {
            volatility_score: 0.7, cycles_observed: 3, ..Default::default()
        };
        let suggestions = AdjustmentModule::suggest(&history, &profile, &make_det());
        assert!(suggestions.iter().any(|s| matches!(s, AdaptiveSuggestion::AdjustSafetyMargin { .. })));
    }

    #[test]
    fn test_no_safety_margin_for_stable_user() {
        let history: Vec<CycleRecord> = (0..3).map(|_| make_cycle(0.0, 0.0)).collect();
        let profile = BehavioralProfile {
            volatility_score: 0.1, cycles_observed: 3, ..Default::default()
        };
        let suggestions = AdjustmentModule::suggest(&history, &profile, &make_det());
        assert!(!suggestions.iter().any(|s| matches!(s, AdaptiveSuggestion::AdjustSafetyMargin { .. })));
    }
}
