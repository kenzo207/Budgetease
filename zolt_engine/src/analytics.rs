// ============================================================
//  MODULE ANALYTICS — Statistiques du cycle courant et comparaisons
//  Remplace les calculs faits côté Flutter pour l'écran Analyse.
//  Entrée : transactions + historique → sortie : AnalyticsResult
// ============================================================

use crate::types::*;
use std::collections::HashMap;

pub struct AnalyticsEngine;

impl AnalyticsEngine {
    pub fn compute(input: &AnalyticsInput) -> AnalyticsResult {
        let cycle_days = input.cycle_start.days_until(&input.cycle_end).max(1) as u32 + 1;

        // ── Totaux ──
        let total_expenses: f64 = input.transactions.iter()
            .filter(|t| t.tx_type.is_outflow())
            .map(|t| t.amount)
            .sum();

        let total_income: f64 = input.transactions.iter()
            .filter(|t| t.tx_type.is_inflow())
            .map(|t| t.amount)
            .sum();

        let net = total_income - total_expenses;

        // ── Par catégorie ──
        let by_category = Self::category_stats(
            &input.transactions,
            total_expenses,
            &input.history,
            &input.cycle_start,
        );

        // ── Moyenne journalière ──
        let daily_average = if cycle_days > 0 {
            total_expenses / cycle_days as f64
        } else {
            0.0
        };

        // ── Jour de pic ──
        let (peak_day, peak_day_amount) = Self::peak_day(&input.transactions, &input.cycle_start, &input.cycle_end);

        // ── Comparaison avec cycle précédent ──
        let comparison = Self::period_comparison(&input.transactions, &input.cycle_start, &input.history);

        // ── Taux d'épargne ──
        let savings_rate = if total_income > 0.0 {
            (net / total_income).clamp(-1.0, 1.0)
        } else {
            0.0
        };

        AnalyticsResult {
            total_expenses,
            total_income,
            net,
            by_category,
            daily_average,
            peak_day,
            peak_day_amount,
            comparison,
            savings_rate,
        }
    }

    // ── Stats par catégorie avec comparaison historique ──────────
    fn category_stats(
        transactions:   &[Transaction],
        total_expenses: f64,
        history:        &[CycleRecord],
        cycle_start:    &Date,
    ) -> Vec<CategoryStat> {
        // Groupe dépenses par catégorie
        let mut groups: HashMap<String, Vec<f64>> = HashMap::new();
        let mut counts: HashMap<String, u32>      = HashMap::new();

        for tx in transactions {
            if !tx.tx_type.is_outflow() { continue; }
            let cat = tx.category.clone().unwrap_or_else(|| "Non catégorisé".into());
            groups.entry(cat.clone()).or_default().push(tx.amount);
            *counts.entry(cat).or_default() += 1;
        }

        // Moyennes historiques par catégorie
        let hist_avgs = Self::historical_category_averages(history);

        let mut stats: Vec<CategoryStat> = groups.into_iter().map(|(cat, amounts)| {
            let total: f64  = amounts.iter().sum();
            let count       = *counts.get(&cat).unwrap_or(&1);
            let pct         = if total_expenses > 0.0 { total / total_expenses } else { 0.0 };
            let avg_per_tx  = total / count as f64;

            let vs_history = hist_avgs.get(&cat).map(|&hist_avg| {
                if hist_avg > 0.0 { (total - hist_avg) / hist_avg } else { 0.0 }
            });

            CategoryStat {
                category:       cat,
                total,
                pct_of_budget:  pct,
                tx_count:       count,
                avg_per_tx,
                vs_history_pct: vs_history,
            }
        }).collect();

        // Tri par total décroissant
        stats.sort_by(|a, b| b.total.partial_cmp(&a.total).unwrap_or(std::cmp::Ordering::Equal));
        stats
    }

    // ── Moyennes historiques par catégorie (1 valeur par cycle) ──
    fn historical_category_averages(history: &[CycleRecord]) -> HashMap<String, f64> {
        if history.is_empty() { return HashMap::new(); }

        let mut sums:   HashMap<String, f64> = HashMap::new();
        let mut counts: HashMap<String, u32> = HashMap::new();

        for record in history {
            // Agrège les totaux par catégorie du cycle
            let mut cycle_cats: HashMap<String, f64> = HashMap::new();
            for tx in &record.transactions {
                if tx.tx_type.is_outflow() {
                    let cat = tx.category.clone().unwrap_or_else(|| "Non catégorisé".into());
                    *cycle_cats.entry(cat).or_default() += tx.amount;
                }
            }
            // Fallback : utilise category_totals si transactions vides
            if cycle_cats.is_empty() {
                for (cat, total) in &record.category_totals {
                    cycle_cats.insert(cat.clone(), *total);
                }
            }
            for (cat, total) in cycle_cats {
                *sums.entry(cat.clone()).or_default()   += total;
                *counts.entry(cat).or_default() += 1;
            }
        }

        sums.into_iter().filter_map(|(cat, sum)| {
            counts.get(&cat).map(|&n| (cat, sum / n as f64))
        }).collect()
    }

    // ── Jour de pic de dépenses ───────────────────────────────────
    fn peak_day(
        transactions: &[Transaction],
        start:        &Date,
        end:          &Date,
    ) -> (Option<Date>, f64) {
        let mut daily: HashMap<u32, f64> = HashMap::new();

        for tx in transactions {
            if !tx.tx_type.is_outflow() { continue; }
            if !tx.date.within(*start, *end) { continue; }
            let epoch = tx.date.to_days_since_epoch();
            *daily.entry(epoch).or_default() += tx.amount;
        }

        if daily.is_empty() {
            return (None, 0.0);
        }

        let (epoch, amount) = daily.iter()
            .max_by(|a, b| a.1.partial_cmp(b.1).unwrap_or(std::cmp::Ordering::Equal))
            .unwrap();

        (Some(Date::from_days_since_epoch(*epoch)), *amount)
    }

    // ── Comparaison avec le cycle précédent ───────────────────────
    fn period_comparison(
        transactions: &[Transaction],
        cycle_start:  &Date,
        history:      &[CycleRecord],
    ) -> Option<PeriodComparison> {
        let prev = history.last()?;

        let current_expenses: f64 = transactions.iter()
            .filter(|t| t.tx_type.is_outflow())
            .map(|t| t.amount)
            .sum();

        let current_income: f64 = transactions.iter()
            .filter(|t| t.tx_type.is_inflow())
            .map(|t| t.amount)
            .sum();

        let prev_expenses = prev.total_expenses;
        let prev_income   = prev.total_income;

        let delta_pct = if prev_expenses > 0.0 {
            (current_expenses - prev_expenses) / prev_expenses
        } else {
            0.0
        };

        Some(PeriodComparison {
            current_expenses,
            previous_expenses: prev_expenses,
            delta_pct,
            current_income,
            previous_income: prev_income,
        })
    }
}

// ─────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;

    fn make_tx(date: Date, amount: f64, tx_type: TransactionType, category: &str) -> Transaction {
        Transaction {
            id: format!("t{}", amount as u32),
            date, amount, tx_type,
            category: Some(category.into()),
            account_id: "a1".into(),
            description: None, sms_confidence: None,
        }
    }

    fn base_input() -> AnalyticsInput {
        let start = Date::new(2026, 3, 1);
        let end   = Date::new(2026, 3, 31);
        AnalyticsInput {
            transactions: vec![
                make_tx(Date::new(2026, 3, 5),  15_000.0, TransactionType::Expense, "nourriture"),
                make_tx(Date::new(2026, 3, 10), 50_000.0, TransactionType::Expense, "loyer"),
                make_tx(Date::new(2026, 3, 12),  5_000.0, TransactionType::Expense, "nourriture"),
                make_tx(Date::new(2026, 3, 1),  200_000.0, TransactionType::Income, "salaire"),
            ],
            cycle_start: start,
            cycle_end:   end,
            history:     vec![],
        }
    }

    #[test]
    fn test_totals_correct() {
        let r = AnalyticsEngine::compute(&base_input());
        assert!((r.total_expenses - 70_000.0).abs() < 0.01);
        assert!((r.total_income - 200_000.0).abs() < 0.01);
        assert!((r.net - 130_000.0).abs() < 0.01);
    }

    #[test]
    fn test_category_stats_sorted_by_total() {
        let r = AnalyticsEngine::compute(&base_input());
        // loyer (50k) > nourriture (20k)
        assert_eq!(r.by_category[0].category, "loyer");
        assert_eq!(r.by_category[1].category, "nourriture");
    }

    #[test]
    fn test_category_pct_sums_to_one() {
        let r    = AnalyticsEngine::compute(&base_input());
        let sum: f64 = r.by_category.iter().map(|c| c.pct_of_budget).sum();
        assert!((sum - 1.0).abs() < 0.01, "sum={:.3}", sum);
    }

    #[test]
    fn test_peak_day_detected() {
        let r = AnalyticsEngine::compute(&base_input());
        assert_eq!(r.peak_day, Some(Date::new(2026, 3, 10)));
        assert!((r.peak_day_amount - 50_000.0).abs() < 0.01);
    }

    #[test]
    fn test_savings_rate() {
        let r = AnalyticsEngine::compute(&base_input());
        // (200k - 70k) / 200k = 0.65
        assert!((r.savings_rate - 0.65).abs() < 0.01);
    }

    #[test]
    fn test_comparison_with_history() {
        let mut input = base_input();
        input.history = vec![CycleRecord {
            cycle_start: Date::new(2026, 2, 1), cycle_end: Date::new(2026, 2, 28),
            opening_balance: 300_000.0, closing_balance: 230_000.0,
            total_income: 200_000.0, total_expenses: 50_000.0,
            savings_goal: 0.0, savings_achieved: 0.0,
            daily_expenses: vec![1_700.0; 28], category_totals: vec![], transactions: vec![],
        }];
        let r = AnalyticsEngine::compute(&input);
        let cmp = r.comparison.unwrap();
        // 70k vs 50k → +40%
        assert!((cmp.delta_pct - 0.4).abs() < 0.01);
    }

    #[test]
    fn test_vs_history_category() {
        let hist_txs = vec![
            make_tx(Date::new(2026, 2, 5), 10_000.0, TransactionType::Expense, "nourriture"),
        ];
        let mut input = base_input();
        input.history = vec![CycleRecord {
            cycle_start: Date::new(2026, 2, 1), cycle_end: Date::new(2026, 2, 28),
            opening_balance: 300_000.0, closing_balance: 280_000.0,
            total_income: 200_000.0, total_expenses: 10_000.0,
            savings_goal: 0.0, savings_achieved: 0.0,
            daily_expenses: vec![], category_totals: vec![],
            transactions: hist_txs,
        }];
        let r = AnalyticsEngine::compute(&input);
        let nourriture = r.by_category.iter().find(|c| c.category == "nourriture").unwrap();
        // 20k courant vs 10k historique → +100%
        let vs = nourriture.vs_history_pct.unwrap();
        assert!((vs - 1.0).abs() < 0.01, "vs={:.3}", vs);
    }

    #[test]
    fn test_no_transactions_returns_zeros() {
        let input = AnalyticsInput {
            transactions: vec![],
            cycle_start: Date::new(2026, 3, 1),
            cycle_end:   Date::new(2026, 3, 31),
            history:     vec![],
        };
        let r = AnalyticsEngine::compute(&input);
        assert_eq!(r.total_expenses, 0.0);
        assert_eq!(r.by_category.len(), 0);
        assert_eq!(r.peak_day, None);
    }
}
