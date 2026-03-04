// ============================================================
//  MODULE D — AJUSTEMENTS ADAPTATIFS
//  Propose des ajustements de paramètres basés sur les patterns
//  observés. Ne modifie JAMAIS directement les paramètres —
//  toujours via suggestion acceptée par l'utilisateur.
// ============================================================

use crate::types::*;
use super::{CycleRecord, profile::ProfileModule};

pub struct AdjustmentModule;

impl AdjustmentModule {
    pub fn suggest(
        history: &[CycleRecord],
        profile: &BehavioralProfile,
        det:     &DeterministicResult,
    ) -> Vec<AdaptiveSuggestion> {
        if history.len() < 3 {
            return vec![]; // Phase d'observation : pas de suggestions encore
        }

        let mut suggestions = Vec::new();

        if let Some(s) = Self::suggest_savings_revision(history, profile, det) {
            suggestions.push(s);
        }
        if let Some(s) = Self::suggest_hidden_charge(history, profile) {
            suggestions.push(s);
        }
        if let Some(s) = Self::suggest_safety_margin(profile, det) {
            suggestions.push(s);
        }

        suggestions
    }

    // ── Suggestion 1 : Révision de l'objectif d'épargne ─────────
    // Si l'utilisateur n'atteint pas son objectif sur 3 cycles consécutifs,
    // on propose un objectif plus réaliste (médiane historique + 5% d'aspiration).
    fn suggest_savings_revision(
        history: &[CycleRecord],
        profile: &BehavioralProfile,
        det:     &DeterministicResult,
    ) -> Option<AdaptiveSuggestion> {
        // Vérifie les 3 derniers cycles uniquement
        let last_3 = &history[history.len().saturating_sub(3)..];
        let all_missed = last_3.iter().all(|r| {
            r.savings_goal > 0.0 && r.savings_achieved < r.savings_goal * 0.90
        });

        if !all_missed { return None; }

        // Médiane des épargnes réellement réalisées
        let mut achieved: Vec<f64> = last_3.iter()
            .map(|r| r.savings_achieved)
            .collect();
        achieved.sort_by(|a, b| a.partial_cmp(b).unwrap());
        let median = achieved[achieved.len() / 2];

        let suggested = median * 1.05; // +5% d'aspiration

        let current_goal = last_3.last()?.savings_goal;
        if (suggested - current_goal).abs() < current_goal * 0.05 {
            return None; // différence trop faible pour valoir une suggestion
        }

        let reason = format!(
            "Sur les 3 derniers cycles, tu as épargné en moyenne {:.0} FCFA \
             au lieu de {:.0} FCFA. Un objectif de {:.0} FCFA serait plus réaliste.",
            median, current_goal, suggested
        );

        Some(AdaptiveSuggestion::ReviseSavingsGoal {
            current:   current_goal,
            suggested,
            reason,
        })
    }

    // ── Suggestion 2 : Charge informelle récurrente ──────────────
    // Si des dépenses similaires (±10%) apparaissent à la même semaine
    // du mois sur ≥ 3 cycles → proposition de charge fixe.
    fn suggest_hidden_charge(
        history: &[CycleRecord],
        profile: &BehavioralProfile,
    ) -> Option<AdaptiveSuggestion> {
        if profile.hidden_charges_total < 1_000.0 { return None; }

        // Trouve le pattern dominant
        let pattern = Self::find_strongest_recurring_pattern(history)?;

        Some(AdaptiveSuggestion::AddHiddenCharge {
            estimated_amount:     pattern.amount,
            pattern_description: pattern.description,
        })
    }

    // ── Suggestion 3 : Marge de sécurité comportementale ────────
    // Pour les utilisateurs volatils, ajoute une marge invisible
    // dans le calcul de la masse libre.
    // Coefficient : volatility_score × 0.10 (max 10% de la masse libre)
    fn suggest_safety_margin(
        profile: &BehavioralProfile,
        det:     &DeterministicResult,
    ) -> Option<AdaptiveSuggestion> {
        if profile.volatility_score < 0.3 { return None; } // pas assez volatile

        let margin_pct = profile.volatility_score * 0.10;
        let margin_pct = margin_pct.min(0.10); // plafond 10%

        Some(AdaptiveSuggestion::AdjustSafetyMargin {
            new_margin_pct: margin_pct,
        })
    }

    // ── Trouve le pattern récurrent le plus fort ─────────────────
    fn find_strongest_recurring_pattern(history: &[CycleRecord]) -> Option<RecurringPattern> {
        // Structure : (semaine_du_cycle, bucket_montant) → occurrences
        let mut pattern_map: std::collections::HashMap<(u8, u64), Vec<f64>> =
            std::collections::HashMap::new();

        for record in history {
            for tx in &record.transactions {
                if !tx.tx_type.is_outflow() { continue; }
                let days_in     = record.cycle_start.days_until(&tx.date).max(0) as u8;
                let week        = days_in / 7 + 1;
                // Bucket de 500 FCFA pour regrouper les montants similaires
                let bucket      = (tx.amount / 500.0).round() as u64;
                pattern_map.entry((week, bucket)).or_default().push(tx.amount);
            }
        }

        // Cherche le pattern qui apparaît dans le plus de cycles distincts
        let best = pattern_map.into_iter()
            .filter(|(_, amounts)| amounts.len() >= 3)
            .max_by_key(|(_, amounts)| amounts.len())?;

        let (week, _bucket)  = best.0;
        let amounts          = best.1;
        let avg_amount: f64  = amounts.iter().sum::<f64>() / amounts.len() as f64;

        let week_label = match week {
            1 => "la première semaine",
            2 => "la deuxième semaine",
            3 => "la troisième semaine",
            4 => "la quatrième semaine",
            _ => "la fin",
        };

        Some(RecurringPattern {
            amount:      avg_amount,
            description: format!(
                "Tu dépenses environ {:.0} FCFA {} du mois depuis {} cycles.",
                avg_amount, week_label, amounts.len()
            ),
        })
    }
}

struct RecurringPattern {
    amount:      f64,
    description: String,
}

// ────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;
    use crate::adaptive::CycleRecord;

    fn make_cycle(savings_goal: f64, savings_achieved: f64) -> CycleRecord {
        CycleRecord {
            cycle_start:     Date::new(2026, 1, 1),
            cycle_end:       Date::new(2026, 1, 31),
            opening_balance: 300_000.0,
            closing_balance: 250_000.0,
            total_income:    300_000.0,
            total_expenses:  50_000.0,
            savings_goal,
            savings_achieved,
            daily_expenses:  vec![1_000.0; 30],
            category_totals: vec![],
            transactions:    vec![],
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
        let profile = BehavioralProfile::default();
        let det     = make_det();
        let suggestions = AdjustmentModule::suggest(&history, &profile, &det);
        assert!(suggestions.is_empty());
    }

    #[test]
    fn test_savings_revision_suggested() {
        let history = vec![
            make_cycle(30_000.0, 10_000.0),
            make_cycle(30_000.0, 12_000.0),
            make_cycle(30_000.0,  9_000.0),
        ];
        let profile = BehavioralProfile { cycles_observed: 3, ..Default::default() };
        let det     = make_det();
        let suggestions = AdjustmentModule::suggest(&history, &profile, &det);

        let has_revision = suggestions.iter().any(|s| {
            matches!(s, AdaptiveSuggestion::ReviseSavingsGoal { .. })
        });
        assert!(has_revision, "Devrait suggérer une révision d'épargne");
    }

    #[test]
    fn test_safety_margin_for_volatile_user() {
        let history: Vec<CycleRecord> = (0..3).map(|_| make_cycle(0.0, 0.0)).collect();
        let profile = BehavioralProfile {
            volatility_score: 0.7,
            cycles_observed:  3,
            ..Default::default()
        };
        let det = make_det();
        let suggestions = AdjustmentModule::suggest(&history, &profile, &det);

        let has_margin = suggestions.iter().any(|s| {
            matches!(s, AdaptiveSuggestion::AdjustSafetyMargin { .. })
        });
        assert!(has_margin);
    }
}
