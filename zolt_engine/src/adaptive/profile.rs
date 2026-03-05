// ============================================================
//  MODULE A — PROFIL COMPORTEMENTAL
//  Construit une représentation évolutive des habitudes réelles.
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

        BehavioralProfile {
            rhythm:               Self::detect_rhythm(history),
            volatility_score:     Self::compute_volatility(history),
            savings_achievement:  Self::compute_savings_achievement(history),
            cycles_observed:      history.len() as u32,
            hidden_charges_total: Self::estimate_hidden_charges(history),
        }
    }

    // ── Détection du rythme de dépense ──────────────────────────
    fn detect_rhythm(history: &[CycleRecord]) -> SpendingRhythm {
        let mut first_sum  = 0.0f64;
        let mut middle_sum = 0.0f64;
        let mut last_sum   = 0.0f64;
        let mut valid      = 0u32;

        for record in history {
            let n = record.daily_expenses.len();
            if n < 3 { continue; }

            let total: f64 = record.daily_expenses.iter().sum();
            if total <= 0.0 { continue; }

            let t1 = n / 3;
            let t2 = 2 * n / 3;

            let s1: f64 = record.daily_expenses[..t1].iter().sum::<f64>() / total;
            let s2: f64 = record.daily_expenses[t1..t2].iter().sum::<f64>() / total;
            let s3: f64 = record.daily_expenses[t2..].iter().sum::<f64>() / total;

            first_sum  += s1;
            middle_sum += s2;
            last_sum   += s3;
            valid      += 1;
        }

        if valid == 0 {
            return SpendingRhythm::Linear;
        }

        let f = first_sum  / valid as f64;
        let m = middle_sum / valid as f64;
        let l = last_sum   / valid as f64;

        if f > 0.40 && f > m && f > l {
            SpendingRhythm::Frontal
        } else if l > 0.40 && l > f && l > m {
            SpendingRhythm::Terminal
        } else if Self::coefficient_of_variation(&[f, m, l]) > 0.3 {
            SpendingRhythm::Erratic
        } else {
            SpendingRhythm::Linear
        }
    }

    // ── Volatilité : coefficient de variation des dépenses journalières ──
    fn compute_volatility(history: &[CycleRecord]) -> f64 {
        let all_daily: Vec<f64> = history.iter()
            .flat_map(|r| r.daily_expenses.iter().copied())
            .filter(|&x| x > 0.0 && x.is_finite())
            .collect();

        if all_daily.len() < 3 {
            return 0.0;
        }
        Self::coefficient_of_variation(&all_daily).min(1.0)
    }

    // ── Taux moyen de réalisation de l'objectif d'épargne ──
    fn compute_savings_achievement(history: &[CycleRecord]) -> f64 {
        let valid: Vec<f64> = history.iter()
            .filter(|r| r.savings_goal > 0.0)
            .map(|r| (r.savings_achieved / r.savings_goal).clamp(0.0, 1.0))
            .collect();

        if valid.is_empty() { return 1.0; }
        valid.iter().sum::<f64>() / valid.len() as f64
    }

    // ── Détection des charges informelles récurrentes ──
    fn estimate_hidden_charges(history: &[CycleRecord]) -> f64 {
        if history.len() < 3 {
            return 0.0;
        }

        // (semaine_du_cycle, bucket_500) → montants
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

        let min_occurrences = history.len() as u32;
        let mut hidden_total = 0.0f64;

        // Déduplique en ne comptant qu'une fois par (semaine, bucket)
        for (_, amounts) in &pattern_map {
            if amounts.len() as u32 >= min_occurrences {
                let avg = amounts.iter().sum::<f64>() / amounts.len() as f64;
                hidden_total += avg;
            }
        }

        hidden_total / history.len() as f64
    }

    pub fn coefficient_of_variation(values: &[f64]) -> f64 {
        let n = values.len();
        if n < 2 { return 0.0; }

        let mean = values.iter().sum::<f64>() / n as f64;
        if mean <= 0.0 { return 0.0; }

        let variance = values.iter()
            .map(|x| (x - mean).powi(2))
            .sum::<f64>()
            / (n - 1) as f64;

        variance.sqrt() / mean
    }
}

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
        let mut daily = vec![0.0f64; 30];
        for i in 0..10  { daily[i] = 6_000.0; }
        for i in 10..30 { daily[i] = 2_000.0; }
        let history = vec![
            make_record(daily.clone(), 0.0, 0.0),
            make_record(daily.clone(), 0.0, 0.0),
            make_record(daily.clone(), 0.0, 0.0),
        ];
        let profile = ProfileModule::compute(&history);
        assert!(matches!(profile.rhythm, SpendingRhythm::Frontal));
    }

    #[test]
    fn test_terminal_rhythm() {
        let mut daily = vec![0.0f64; 30];
        for i in 0..20  { daily[i] = 1_000.0; }
        for i in 20..30 { daily[i] = 8_000.0; }
        let history = vec![
            make_record(daily.clone(), 0.0, 0.0),
            make_record(daily.clone(), 0.0, 0.0),
            make_record(daily.clone(), 0.0, 0.0),
        ];
        let profile = ProfileModule::compute(&history);
        assert!(matches!(profile.rhythm, SpendingRhythm::Terminal));
    }

    #[test]
    fn test_savings_achievement() {
        let history = vec![
            make_record(vec![1000.0; 30], 30_000.0, 30_000.0), // 100%
            make_record(vec![1000.0; 30], 30_000.0, 15_000.0), //  50%
            make_record(vec![1000.0; 30], 30_000.0, 24_000.0), //  80%
        ];
        let profile = ProfileModule::compute(&history);
        assert!((profile.savings_achievement - (1.0 + 0.5 + 0.8) / 3.0).abs() < 0.01);
    }

    #[test]
    fn test_empty_history_returns_defaults() {
        let profile = ProfileModule::compute(&[]);
        assert_eq!(profile.cycles_observed, 0);
        assert_eq!(profile.volatility_score, 0.0);
        assert_eq!(profile.savings_achievement, 1.0);
    }

    #[test]
    fn test_coefficient_of_variation_uniform() {
        // CV d'une distribution uniforme = 0
        let cv = ProfileModule::coefficient_of_variation(&[5.0, 5.0, 5.0, 5.0]);
        assert_eq!(cv, 0.0);
    }
}
