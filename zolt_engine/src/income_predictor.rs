// ============================================================
//  MODULE INCOME PREDICTOR — Prédiction du prochain revenu
//  Analyse les patterns de revenus passés pour prédire
//  le montant et la date du prochain revenu.
// ============================================================

use crate::types::*;

pub struct IncomePredictorEngine;

impl IncomePredictorEngine {
    pub fn predict(history: &[CycleRecord], today: &Date) -> Option<IncomePrediction> {
        if history.is_empty() { return None; }

        // Collecte tous les revenus des cycles passés avec leur jour dans le cycle
        let income_events: Vec<IncomeEvent> = history.iter()
            .flat_map(|r| Self::extract_income_events(r))
            .collect();

        if income_events.is_empty() { return None; }

        // Groupe par pattern (source similaire)
        let patterns = Self::detect_patterns(&income_events, history);
        let best     = patterns.into_iter().max_by(|a, b| {
            a.confidence.partial_cmp(&b.confidence).unwrap_or(std::cmp::Ordering::Equal)
        })?;

        // Calcule la date estimée
        let predicted_date = Self::predict_next_date(today, &best, history);

        Some(IncomePrediction {
            predicted_amount:    best.avg_amount,
            predicted_date,
            confidence:          best.confidence,
            pattern_description: best.description,
            based_on_cycles:     best.occurrences,
        })
    }

    // ── Extrait les événements de revenu d'un cycle ───────────────
    fn extract_income_events(record: &CycleRecord) -> Vec<IncomeEvent> {
        record.transactions.iter()
            .filter(|t| t.tx_type.is_inflow() && t.amount > 0.0)
            .map(|t| {
                let day_in_cycle = record.cycle_start.days_until(&t.date).max(0) as u32 + 1;
                IncomeEvent {
                    amount:       t.amount,
                    day_in_cycle,
                    day_of_month: t.date.day,
                    category:     t.category.clone().unwrap_or_else(|| "revenu".into()),
                    cycle_start:  record.cycle_start,
                }
            })
            .collect()
    }

    // ── Détecte les patterns récurrents ──────────────────────────
    fn detect_patterns(events: &[IncomeEvent], history: &[CycleRecord]) -> Vec<IncomePattern> {
        if events.is_empty() { return vec![]; }

        let mut patterns: Vec<IncomePattern> = Vec::new();

        // Groupe par catégorie
        let mut by_cat: std::collections::HashMap<String, Vec<&IncomeEvent>> =
            std::collections::HashMap::new();
        for e in events {
            by_cat.entry(e.category.clone()).or_default().push(e);
        }

        for (cat, cat_events) in by_cat {
            if cat_events.len() < 2 { continue; }

            let amounts: Vec<f64> = cat_events.iter().map(|e| e.amount).collect();
            let days:    Vec<u32> = cat_events.iter().map(|e| e.day_of_month as u32).collect();

            let avg_amount  = amounts.iter().sum::<f64>() / amounts.len() as f64;
            let avg_day     = (days.iter().sum::<u32>() as f64 / days.len() as f64).round() as u8;

            // Stabilité du montant (CV)
            let amount_cv = Self::coefficient_of_variation(&amounts);
            // Stabilité du jour
            let day_floats: Vec<f64> = days.iter().map(|&d| d as f64).collect();
            let day_cv = Self::coefficient_of_variation(&day_floats);

            // Confiance = fonction inverse de la variabilité + bonus occurrences
            let stability = 1.0 - (amount_cv * 0.5 + day_cv * 0.5).min(1.0);
            let occ_bonus = ((cat_events.len() as f64).ln() / (history.len() as f64).ln().max(1.0))
                .min(0.3);
            let confidence = (stability * 0.7 + occ_bonus * 0.3).min(0.95);

            if confidence < 0.3 { continue; }

            let desc = format!(
                "Revenu de type «{}» d'environ {:.0} FCFA détecté vers le {} du mois \
                 sur {} cycles ({:.0}% de fiabilité).",
                cat, avg_amount, avg_day, cat_events.len(), confidence * 100.0
            );

            patterns.push(IncomePattern {
                category:    cat,
                avg_amount,
                typical_day: avg_day,
                occurrences: cat_events.len() as u32,
                confidence,
                description: desc,
            });
        }

        patterns
    }

    // ── Prédit la date du prochain revenu ─────────────────────────
    fn predict_next_date(today: &Date, pattern: &IncomePattern, history: &[CycleRecord]) -> Option<Date> {
        // Dernier cycle connu
        let last = history.last()?;

        // Si le cycle est mensuel : prochaine occurrence = mois prochain au jour typique
        let next_month = if today.month == 12 {
            (today.year + 1, 1u8)
        } else {
            (today.year, today.month + 1)
        };

        let max_day = Date::last_day_of_month_static(next_month.0, next_month.1);
        let target_day = pattern.typical_day.min(max_day);

        let candidate = Date::new(next_month.0, next_month.1, target_day);

        // Si la date est encore dans ce mois (pas encore passée)
        let this_month_candidate = {
            let max_this = Date::last_day_of_month_static(today.year, today.month);
            let d = pattern.typical_day.min(max_this);
            Date::new(today.year, today.month, d)
        };

        if this_month_candidate > *today {
            Some(this_month_candidate)
        } else {
            Some(candidate)
        }
    }

    fn coefficient_of_variation(values: &[f64]) -> f64 {
        if values.len() < 2 { return 0.0; }
        let mean = values.iter().sum::<f64>() / values.len() as f64;
        if mean <= 0.0 { return 1.0; }
        let variance = values.iter().map(|x| (x - mean).powi(2)).sum::<f64>()
            / (values.len() - 1) as f64;
        (variance.sqrt() / mean).min(1.0)
    }
}

struct IncomeEvent {
    amount:       f64,
    day_in_cycle: u32,
    day_of_month: u8,
    category:     String,
    cycle_start:  Date,
}

struct IncomePattern {
    category:    String,
    avg_amount:  f64,
    typical_day: u8,
    occurrences: u32,
    confidence:  f64,
    description: String,
}

// ─────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;

    fn make_salary_record(month: u8, amount: f64) -> CycleRecord {
        CycleRecord {
            cycle_start: Date::new(2026, month, 1),
            cycle_end:   Date::new(2026, month, 28),
            opening_balance: 50_000.0, closing_balance: 80_000.0,
            total_income: amount, total_expenses: amount * 0.7,
            savings_goal: 30_000.0, savings_achieved: 25_000.0,
            daily_expenses: vec![amount * 0.7 / 28.0; 28],
            category_totals: vec![],
            transactions: vec![Transaction {
                id: format!("sal_{}", month),
                date: Date::new(2026, month, 5), // toujours le 5
                amount,
                tx_type: TransactionType::Income,
                category: Some("salaire".into()),
                account_id: "a1".into(),
                description: None, sms_confidence: None,
            }],
        }
    }

    #[test]
    fn test_predicts_regular_salary() {
        let history = vec![
            make_salary_record(1, 250_000.0),
            make_salary_record(2, 250_000.0),
            make_salary_record(3, 250_000.0),
        ];
        let today = Date::new(2026, 3, 20);
        let pred  = IncomePredictorEngine::predict(&history, &today).unwrap();

        assert!((pred.predicted_amount - 250_000.0).abs() < 1_000.0);
        assert!(pred.confidence > 0.5);
        assert_eq!(pred.based_on_cycles, 3);
    }

    #[test]
    fn test_predicts_next_month_if_this_month_passed() {
        let history = vec![
            make_salary_record(1, 250_000.0),
            make_salary_record(2, 250_000.0),
        ];
        // Le 20 du mois → le 5 est déjà passé → prédit pour le mois prochain
        let today = Date::new(2026, 3, 20);
        let pred  = IncomePredictorEngine::predict(&history, &today).unwrap();
        if let Some(date) = pred.predicted_date {
            assert!(date > today, "date prédite devrait être dans le futur");
        }
    }

    #[test]
    fn test_predicts_this_month_if_not_yet() {
        let history = vec![
            make_salary_record(1, 250_000.0),
            make_salary_record(2, 250_000.0),
        ];
        // Le 2 du mois → le 5 n'est pas encore passé → prédit pour ce mois
        let today = Date::new(2026, 3, 2);
        let pred  = IncomePredictorEngine::predict(&history, &today).unwrap();
        if let Some(date) = pred.predicted_date {
            assert_eq!(date.month, 3);
            assert_eq!(date.day, 5);
        }
    }

    #[test]
    fn test_no_prediction_without_history() {
        let pred = IncomePredictorEngine::predict(&[], &Date::new(2026, 3, 15));
        assert!(pred.is_none());
    }

    #[test]
    fn test_irregular_income_low_confidence() {
        let history = vec![
            make_salary_record(1, 100_000.0),
            {
                let mut r = make_salary_record(2, 350_000.0); // montant très différent
                r.transactions[0].date = Date::new(2026, 2, 25); // jour très différent
                r
            },
        ];
        let today = Date::new(2026, 3, 15);
        // Soit pas de prédiction, soit confiance faible
        if let Some(pred) = IncomePredictorEngine::predict(&history, &today) {
            // Confiance doit être limitée sur données irrégulières
            assert!(pred.confidence < 0.85);
        }
    }
}
