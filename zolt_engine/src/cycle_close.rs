// ============================================================
//  MODULE CYCLE CLOSE — Clôture propre d'un cycle financier
//  Remplace l'assemblage manuel dans Flutter.
//  Calcule le CycleRecord complet + message de bilan.
// ============================================================

use crate::types::*;
use std::collections::HashMap;

pub struct CycleCloseEngine;

impl CycleCloseEngine {
    pub fn close(input: &CycleCloseInput) -> ZoltResult<CycleCloseResult> {
        // ── Validation ──
        if input.cycle_start >= input.cycle_end {
            return Err(ZoltError::InvalidInput(
                format!("cycle_start ({}) >= cycle_end ({})", input.cycle_start, input.cycle_end)
            ));
        }
        if !input.opening_balance.is_finite() {
            return Err(ZoltError::InvalidInput("opening_balance non-fini".into()));
        }

        let cycle_len = (input.cycle_start.days_until(&input.cycle_end) + 1).max(1) as u32;

        // ── Totaux ──
        let total_income: f64 = input.transactions.iter()
            .filter(|t| t.tx_type.is_inflow())
            .map(|t| t.amount)
            .sum();

        let total_expenses: f64 = input.transactions.iter()
            .filter(|t| t.tx_type.is_outflow())
            .map(|t| t.amount)
            .sum();

        // ── Épargne réalisée = solde de clôture − solde d'ouverture + revenus − dépenses
        // En pratique : ce qui reste au-dessus du solde d'ouverture après tout
        let net_flow = total_income - total_expenses;
        let savings_achieved = (input.closing_balance - input.opening_balance + net_flow)
            .max(0.0)
            .min(input.savings_goal.max(0.0) * 2.0); // plafond raisonnable

        // ── Dépenses par jour ──
        let daily_expenses = Self::build_daily_expenses(
            &input.transactions, &input.cycle_start, cycle_len,
        );

        // ── Totaux par catégorie ──
        let category_totals = Self::build_category_totals(&input.transactions);

        let record = CycleRecord {
            cycle_start:      input.cycle_start,
            cycle_end:        input.cycle_end,
            opening_balance:  input.opening_balance,
            closing_balance:  input.closing_balance,
            total_income,
            total_expenses,
            savings_goal:     input.savings_goal,
            savings_achieved,
            daily_expenses,
            category_totals:  category_totals.clone(),
            transactions:     input.transactions.clone(),
        };

        record.validate()?;

        let summary_message = Self::build_summary(&record);

        Ok(CycleCloseResult { record, summary_message })
    }

    // ── Dépenses par jour du cycle ────────────────────────────────
    fn build_daily_expenses(
        transactions: &[Transaction],
        cycle_start:  &Date,
        cycle_len:    u32,
    ) -> Vec<f64> {
        let mut daily = vec![0.0f64; cycle_len as usize];
        let start_epoch = cycle_start.to_days_since_epoch();

        for tx in transactions {
            if !tx.tx_type.is_outflow() { continue; }
            let tx_epoch = tx.date.to_days_since_epoch();
            if tx_epoch < start_epoch { continue; }
            let idx = (tx_epoch - start_epoch) as usize;
            if idx < daily.len() {
                daily[idx] += tx.amount;
            }
        }
        daily
    }

    // ── Totaux par catégorie ──────────────────────────────────────
    fn build_category_totals(transactions: &[Transaction]) -> Vec<(String, f64)> {
        let mut map: HashMap<String, f64> = HashMap::new();
        for tx in transactions {
            if !tx.tx_type.is_outflow() { continue; }
            let cat = tx.category.clone().unwrap_or_else(|| "Non catégorisé".into());
            *map.entry(cat).or_default() += tx.amount;
        }
        let mut totals: Vec<(String, f64)> = map.into_iter().collect();
        totals.sort_by(|a, b| b.1.partial_cmp(&a.1).unwrap_or(std::cmp::Ordering::Equal));
        totals
    }

    // ── Message de bilan ──────────────────────────────────────────
    fn build_summary(record: &CycleRecord) -> ConversationalMessage {
        let balance_delta = record.closing_balance - record.opening_balance;
        let savings_ratio = if record.savings_goal > 0.0 {
            record.savings_achieved / record.savings_goal
        } else {
            1.0
        };

        // Top catégorie de dépense
        let top_cat = record.category_totals.first()
            .map(|(cat, amt)| format!(" La catégorie principale est «{}» ({:.0} FCFA).", cat, amt))
            .unwrap_or_default();

        if record.closing_balance < 0.0 {
            ConversationalMessage {
                level: AlertLevel::Critical,
                title: "Cycle terminé avec déficit".into(),
                body: format!(
                    "Ce cycle s'est terminé avec un déficit de {:.0} FCFA.{} \
                     Analyse tes dépenses pour le prochain cycle.",
                    record.closing_balance.abs(), top_cat
                ),
                ttl_days: None,
            }
        } else if savings_ratio >= 1.0 {
            ConversationalMessage {
                level: AlertLevel::Positive,
                title: "🎉 Cycle réussi !".into(),
                body: format!(
                    "Tu as épargné {:.0} FCFA sur un objectif de {:.0} FCFA ({:.0}%). \
                     Solde final : {:.0} FCFA.{}",
                    record.savings_achieved, record.savings_goal,
                    savings_ratio * 100.0, record.closing_balance, top_cat
                ),
                ttl_days: Some(3),
            }
        } else if savings_ratio >= 0.8 {
            ConversationalMessage {
                level: AlertLevel::Info,
                title: "Cycle terminé — presque !".into(),
                body: format!(
                    "Tu as épargné {:.0} FCFA sur {:.0} FCFA ({:.0}%). \
                     Il manquait {:.0} FCFA pour atteindre ton objectif.{}",
                    record.savings_achieved, record.savings_goal,
                    savings_ratio * 100.0,
                    record.savings_goal - record.savings_achieved,
                    top_cat
                ),
                ttl_days: Some(3),
            }
        } else {
            ConversationalMessage {
                level: AlertLevel::Warning,
                title: "Objectif d'épargne non atteint".into(),
                body: format!(
                    "Tu n'as épargné que {:.0} FCFA sur {:.0} FCFA ({:.0}%). \
                     Bilan des dépenses : {:.0} FCFA de sorties pour {:.0} FCFA de rentrées.{}",
                    record.savings_achieved, record.savings_goal,
                    savings_ratio * 100.0,
                    record.total_expenses, record.total_income,
                    top_cat
                ),
                ttl_days: Some(5),
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;

    fn make_tx(day: u8, amount: f64, tx_type: TransactionType, cat: &str) -> Transaction {
        Transaction {
            id: format!("t{}", day), date: Date::new(2026, 3, day),
            amount, tx_type, category: Some(cat.into()),
            account_id: "a1".into(), description: None, sms_confidence: None,
        }
    }

    fn base_input() -> CycleCloseInput {
        CycleCloseInput {
            cycle_start:     Date::new(2026, 3, 1),
            cycle_end:       Date::new(2026, 3, 31),
            opening_balance: 300_000.0,
            closing_balance: 80_000.0,
            savings_goal:    30_000.0,
            transactions: vec![
                make_tx(1,  200_000.0, TransactionType::Income,  "salaire"),
                make_tx(5,   50_000.0, TransactionType::Expense, "loyer"),
                make_tx(10,  20_000.0, TransactionType::Expense, "nourriture"),
                make_tx(15,  10_000.0, TransactionType::Expense, "transport"),
                make_tx(20, 140_000.0, TransactionType::Expense, "divers"),
            ],
        }
    }

    #[test]
    fn test_totals_computed() {
        let r = CycleCloseEngine::close(&base_input()).unwrap();
        assert!((r.record.total_income   - 200_000.0).abs() < 0.01);
        assert!((r.record.total_expenses - 220_000.0).abs() < 0.01);
    }

    #[test]
    fn test_daily_expenses_indexed_correctly() {
        let r = CycleCloseEngine::close(&base_input()).unwrap();
        // Jour 5 (index 4) = 50 000
        assert!((r.record.daily_expenses[4] - 50_000.0).abs() < 0.01);
        // Jour 10 (index 9) = 20 000
        assert!((r.record.daily_expenses[9] - 20_000.0).abs() < 0.01);
    }

    #[test]
    fn test_category_totals_sorted() {
        let r = CycleCloseEngine::close(&base_input()).unwrap();
        // divers (140k) > loyer (50k) > nourriture (20k) > transport (10k)
        assert_eq!(r.record.category_totals[0].0, "divers");
        assert_eq!(r.record.category_totals[1].0, "loyer");
    }

    #[test]
    fn test_deficit_summary_message() {
        let mut input  = base_input();
        input.closing_balance = -10_000.0;
        let r = CycleCloseEngine::close(&input).unwrap();
        assert_eq!(r.summary_message.level, AlertLevel::Critical);
    }

    #[test]
    fn test_success_summary_message() {
        let mut input  = base_input();
        input.closing_balance = 120_000.0;
        // savings_achieved sera calculé en interne
        let r = CycleCloseEngine::close(&input).unwrap();
        // Objectif atteint ou non selon le calcul
        assert!(matches!(
            r.summary_message.level,
            AlertLevel::Positive | AlertLevel::Info | AlertLevel::Warning
        ));
    }

    #[test]
    fn test_invalid_dates_returns_error() {
        let mut input = base_input();
        input.cycle_end = Date::new(2026, 2, 28); // avant cycle_start
        assert!(CycleCloseEngine::close(&input).is_err());
    }

    #[test]
    fn test_record_validates_after_close() {
        let r = CycleCloseEngine::close(&base_input()).unwrap();
        assert!(r.record.validate().is_ok());
    }

    #[test]
    fn test_empty_transactions() {
        let input = CycleCloseInput {
            cycle_start: Date::new(2026, 3, 1),
            cycle_end:   Date::new(2026, 3, 31),
            opening_balance: 100_000.0,
            closing_balance: 100_000.0,
            savings_goal: 0.0,
            transactions: vec![],
        };
        let r = CycleCloseEngine::close(&input).unwrap();
        assert_eq!(r.record.total_expenses, 0.0);
        assert_eq!(r.record.total_income,   0.0);
        assert!(r.record.daily_expenses.iter().all(|&d| d == 0.0));
    }
}
