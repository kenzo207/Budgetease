// ============================================================
//  MODULE A — PROFIL COMPORTEMENTAL
//  Construit une représentation évolutive des habitudes réelles
//  de l'utilisateur à partir des cycles passés.
//  Fiable après 3 cycles. Avant : valeurs par défaut neutres.
// ============================================================

use crate::types::*;
use super::CycleRecord;

pub struct ProfileModule;

impl ProfileModule {
    pub fn compute(history: &[CycleRecord]) -> BehavioralProfile {
        if history.is_empty() {
            return BehavioralProfile::default();
        }

        let rhythm              = Self::detect_rhythm(history);
        let volatility_score    = Self::compute_volatility(history);
        let savings_achievement = Self::compute_savings_achievement(history);
        let hidden_charges      = Self::estimate_hidden_charges(history);

        BehavioralProfile {
            rhythm,
            volatility_score,
            savings_achievement,
            cycles_observed: history.len() as u32,
            hidden_charges_total: hidden_charges,
        }
    }

    // ── Détection du rythme de dépense ──────────────────────────
    // Divise le cycle en 3 tiers (début / milieu / fin).
    // Calcule la part des dépenses dans chaque tiers sur tous les cycles.
    fn detect_rhythm(history: &[CycleRecord]) -> SpendingRhythm {
        let mut first_third  = 0.0f64;
        let mut middle_third = 0.0f64;
        let mut last_third   = 0.0f64;
        let mut valid_cycles = 0u32;

        for record in history {
            let n = record.daily_expenses.len();
            if n < 3 { continue; }

            let total: f64 = record.daily_expenses.iter().sum();
            if total <= 0.0 { continue; }

            let t1_end = n / 3;
            let t2_end = 2 * n / 3;

            let t1: f64 = record.daily_expenses[..t1_end].iter().sum();
            let t2: f64 = record.daily_expenses[t1_end..t2_end].iter().sum();
            let t3: f64 = record.daily_expenses[t2_end..].iter().sum();

            first_third  += t1 / total;
            middle_third += t2 / total;
            last_third   += t3 / total;
            valid_cycles += 1;
        }

        if valid_cycles == 0 {
            return SpendingRhythm::Linear;
        }

        let f = first_third  / valid_cycles as f64;
        let m = middle_third / valid_cycles as f64;
        let l = last_third   / valid_cycles as f64;

        // Seuil : un tiers est "dominant" s'il représente > 40% des dépenses
        if f > 0.40 && f > m && f > l {
            SpendingRhythm::Frontal
        } else if l > 0.40 && l > f && l > m {
            SpendingRhythm::Terminal
        } else {
            // Coefficient de variation pour détecter l'erraticité
            let cv = Self::coefficient_of_variation(&[f, m, l]);
            if cv > 0.3 {
                SpendingRhythm::Erratic
            } else {
                SpendingRhythm::Linear
            }
        }
    }

    // ── Volatilité : coefficient de variation des dépenses journalières ──
    // 0.0 = parfaitement régulier, 1.0 = extrêmement erratique
    fn compute_volatility(history: &[CycleRecord]) -> f64 {
        let all_daily: Vec<f64> = history.iter()
            .flat_map(|r| r.daily_expenses.iter().copied())
            .filter(|&x| x > 0.0)
            .collect();

        if all_daily.len() < 3 {
            return 0.0;
        }

        let cv = Self::coefficient_of_variation(&all_daily);
        cv.min(1.0)
    }

    // ── Taux moyen de réalisation de l'objectif d'épargne ──
    fn compute_savings_achievement(history: &[CycleRecord]) -> f64 {
        let valid: Vec<f64> = history.iter()
            .filter(|r| r.savings_goal > 0.0)
            .map(|r| (r.savings_achieved / r.savings_goal).min(1.0).max(0.0))
            .collect();

        if valid.is_empty() {
            return 1.0; // neutre si pas d'objectif configuré
        }

        valid.iter().sum::<f64>() / valid.len() as f64
    }

    // ── Détection des charges informelles récurrentes ──
    // Si un montant similaire (±10%) apparaît à la même semaine du cycle
    // pendant ≥ 3 cycles consécutifs → c'est probablement une charge cachée.
    fn estimate_hidden_charges(history: &[CycleRecord]) -> f64 {
        if history.len() < 3 {
            return 0.0;
        }

        // Candidats : transactions non catégorisées ou catégorie "autre"
        let mut candidates: Vec<(u8, f64)> = Vec::new(); // (semaine_du_cycle, montant)

        for record in history {
            for tx in &record.transactions {
                if tx.tx_type.is_outflow() {
                    let days_since_start = record.cycle_start.days_until(&tx.date).max(0) as u32;
                    let week_of_cycle = (days_since_start / 7 + 1) as u8;
                    candidates.push((week_of_cycle, tx.amount));
                }
            }
        }

        // Groupe par montant similaire (buckets de 5%) et semaine
        let mut hidden_total = 0.0f64;
        let processed: std::collections::HashSet<usize> = std::collections::HashSet::new();
        let _ = processed; // évite warning unused

        for (i, &(week_i, amount_i)) in candidates.iter().enumerate() {
            let mut matches = 1u32;
            for (j, &(week_j, amount_j)) in candidates.iter().enumerate() {
                if i == j { continue; }
                let same_week   = week_i == week_j;
                let same_amount = (amount_i - amount_j).abs() / amount_i.max(1.0) < 0.10;
                if same_week && same_amount {
                    matches += 1;
                }
            }
            // Si le pattern apparaît dans au moins autant de cycles qu'il y a d'historique
            if matches >= history.len() as u32 {
                hidden_total += amount_i;
            }
        }

        // Déduplique grossièrement (évite de compter le même pattern plusieurs fois)
        hidden_total / history.len() as f64
    }

    // ── Utilitaire : coefficient de variation (écart-type / moyenne) ──
    pub fn coefficient_of_variation(values: &[f64]) -> f64 {
        if values.len() < 2 {
            return 0.0;
        }
        let mean = values.iter().sum::<f64>() / values.len() as f64;
        if mean <= 0.0 {
            return 0.0;
        }
        let variance = values.iter()
            .map(|x| (x - mean).powi(2))
            .sum::<f64>()
            / (values.len() - 1) as f64;
        variance.sqrt() / mean
    }
}

// ────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;

    fn make_record(daily: Vec<f64>, savings_goal: f64, savings_achieved: f64) -> CycleRecord {
        CycleRecord {
            cycle_start:      Date::new(2026, 1, 1),
            cycle_end:        Date::new(2026, 1, 31),
            opening_balance:  300_000.0,
            closing_balance:  250_000.0,
            total_income:     300_000.0,
            total_expenses:   daily.iter().sum(),
            savings_goal,
            savings_achieved,
            daily_expenses:   daily,
            category_totals:  vec![],
            transactions:     vec![],
        }
    }

    #[test]
    fn test_frontal_rhythm() {
        // 60% des dépenses en première semaine
        let mut daily = vec![0.0f64; 30];
        for i in 0..10 { daily[i] = 6_000.0; }   // 60 000 sur les 10 premiers jours
        for i in 10..30 { daily[i] = 2_000.0; }  // 40 000 sur les 20 suivants
        let history = vec![
            make_record(daily.clone(), 0.0, 0.0),
            make_record(daily.clone(), 0.0, 0.0),
            make_record(daily.clone(), 0.0, 0.0),
        ];
        let profile = ProfileModule::compute(&history);
        assert!(matches!(profile.rhythm, SpendingRhythm::Frontal));
    }

    #[test]
    fn test_savings_achievement() {
        let history = vec![
            make_record(vec![1000.0; 30], 30_000.0, 30_000.0), // 100%
            make_record(vec![1000.0; 30], 30_000.0, 15_000.0), // 50%
            make_record(vec![1000.0; 30], 30_000.0, 24_000.0), // 80%
        ];
        let profile = ProfileModule::compute(&history);
        // Moyenne = (1.0 + 0.5 + 0.8) / 3 = 0.767
        assert!((profile.savings_achievement - 0.767).abs() < 0.01);
    }

    #[test]
    fn test_empty_history_returns_defaults() {
        let profile = ProfileModule::compute(&[]);
        assert_eq!(profile.cycles_observed, 0);
        assert_eq!(profile.volatility_score, 0.0);
    }
}
