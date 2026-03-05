// ============================================================
//  MODULE C — DÉTECTION D'ANOMALIES
//  1. Montant inhabituel (> 2 écarts-types de la catégorie)
//  2. Ghost Money (micro-dépenses répétées, seuil relatif)
//  3. Timing inhabituel (dépense hors semaine habituelle)
// ============================================================

use crate::types::*;
use super::CycleRecord;
use std::collections::HashMap;

pub struct AnomalyModule;

impl AnomalyModule {
    pub fn detect(
        input:   &EngineInput,
        history: &[CycleRecord],
        profile: &BehavioralProfile,
        det:     &DeterministicResult,
    ) -> Vec<Anomaly> {
        let mut anomalies = Vec::new();

        // Ghost Money : fonctionne dès le premier cycle (fenêtre 7 jours)
        if let Some(gm) = Self::detect_ghost_money(&input.transactions, &input.today, det) {
            anomalies.push(gm);
        }

        // Les détections suivantes nécessitent de l'historique
        if !history.is_empty() {
            let stats = Self::category_stats(history);
            anomalies.extend(Self::detect_unusual_amounts(
                &input.transactions, &input.today, &stats,
            ));
            let typical_weeks = Self::typical_week_by_category(history);
            anomalies.extend(Self::detect_unusual_timing(
                &input.transactions, &input.today, &typical_weeks,
            ));
        }

        anomalies
    }

    // ── GHOST MONEY ──────────────────────────────────────────────
    fn detect_ghost_money(
        transactions: &[Transaction],
        today: &Date,
        det: &DeterministicResult,
    ) -> Option<Anomaly> {
        let window_start = Self::days_ago(today, 7);

        // Seuil relatif au budget journalier : entre 200 et 2 000 FCFA
        let micro_threshold = (det.daily_budget * 0.02).clamp(200.0, 2_000.0);

        let micro_txs: Vec<&Transaction> = transactions.iter()
            .filter(|t| {
                t.date >= window_start
                && t.date <= *today
                && t.tx_type.is_outflow()
                && t.amount > 0.0
                && t.amount <= micro_threshold
            })
            .collect();

        if micro_txs.len() < 5 { return None; }

        let total: f64 = micro_txs.iter().map(|t| t.amount).sum();
        let available = det.free_mass.max(1.0);
        let impact_pct = total / available;

        if impact_pct < 0.05 { return None; }

        Some(Anomaly {
            anomaly_type: AnomalyType::GhostMoney {
                transaction_count: micro_txs.len() as u32,
                total,
                impact_pct,
            },
            detected_on: *today,
            expires_on:  Self::days_from(today, 7),
            dismissed:   false,
        })
    }

    // ── MONTANT INHABITUEL ────────────────────────────────────────
    fn detect_unusual_amounts(
        transactions: &[Transaction],
        today:        &Date,
        stats:        &HashMap<String, (f64, f64)>,
    ) -> Vec<Anomaly> {
        let window_start = Self::days_ago(today, 7);
        let mut anomalies = Vec::new();
        // Évite les doublons par transaction_id
        let mut seen: std::collections::HashSet<&str> = std::collections::HashSet::new();

        for tx in transactions {
            if !tx.date.within(window_start, *today) { continue; }
            if !tx.tx_type.is_outflow() { continue; }
            if !seen.insert(tx.id.as_str()) { continue; }

            let category = match &tx.category {
                Some(c) if !c.is_empty() => c.clone(),
                _ => continue,
            };

            if let Some((mean, std_dev)) = stats.get(&category) {
                if *std_dev > 0.0 && tx.amount > mean + 2.0 * std_dev {
                    anomalies.push(Anomaly {
                        anomaly_type: AnomalyType::UnusualAmount {
                            category:       category.clone(),
                            amount:         tx.amount,
                            historical_avg: *mean,
                        },
                        detected_on: *today,
                        expires_on:  Self::days_from(today, 7),
                        dismissed:   false,
                    });
                }
            }
        }
        anomalies
    }

    // ── TIMING INHABITUEL ─────────────────────────────────────────
    fn detect_unusual_timing(
        transactions:  &[Transaction],
        today:         &Date,
        typical_weeks: &HashMap<String, u8>,
    ) -> Vec<Anomaly> {
        let current_week = ((today.day - 1) / 7 + 1) as u8;
        let window_start = Self::days_ago(today, 3);
        let mut anomalies = Vec::new();
        let mut seen: std::collections::HashSet<String> = std::collections::HashSet::new();

        for tx in transactions {
            if !tx.date.within(window_start, *today) { continue; }
            if !tx.tx_type.is_outflow() { continue; }

            let category = match &tx.category {
                Some(c) if !c.is_empty() => c.clone(),
                _ => continue,
            };

            // Une anomalie par catégorie dans la fenêtre
            if !seen.insert(category.clone()) { continue; }

            if let Some(&typical_week) = typical_weeks.get(&category) {
                let diff = (current_week as i32 - typical_week as i32).abs();
                if diff >= 2 {
                    anomalies.push(Anomaly {
                        anomaly_type: AnomalyType::UnusualTiming {
                            category:     category,
                            typical_week,
                            actual_week:  current_week,
                        },
                        detected_on: *today,
                        expires_on:  Self::days_from(today, 3),
                        dismissed:   false,
                    });
                }
            }
        }
        anomalies
    }

    // ── Statistiques par catégorie (moyenne + écart-type) ────────
    fn category_stats(history: &[CycleRecord]) -> HashMap<String, (f64, f64)> {
        let mut groups: HashMap<String, Vec<f64>> = HashMap::new();

        for record in history {
            for tx in &record.transactions {
                if let Some(cat) = &tx.category {
                    if !cat.is_empty() && tx.tx_type.is_outflow() && tx.amount > 0.0 {
                        groups.entry(cat.clone()).or_default().push(tx.amount);
                    }
                }
            }
        }

        groups.into_iter().filter_map(|(cat, amounts)| {
            if amounts.len() < 2 { return None; }
            let mean = amounts.iter().sum::<f64>() / amounts.len() as f64;
            let variance = amounts.iter()
                .map(|x| (x - mean).powi(2))
                .sum::<f64>()
                / (amounts.len() - 1) as f64;
            let std_dev = variance.sqrt();
            Some((cat, (mean, std_dev)))
        }).collect()
    }

    // ── Semaine typique par catégorie ─────────────────────────────
    fn typical_week_by_category(history: &[CycleRecord]) -> HashMap<String, u8> {
        let mut groups: HashMap<String, Vec<u8>> = HashMap::new();

        for record in history {
            for tx in &record.transactions {
                if let Some(cat) = &tx.category {
                    if !cat.is_empty() && tx.tx_type.is_outflow() {
                        let days_in = record.cycle_start.days_until(&tx.date).max(0) as u32;
                        let week    = ((days_in / 7) + 1).min(5) as u8;
                        groups.entry(cat.clone()).or_default().push(week);
                    }
                }
            }
        }

        groups.into_iter().filter_map(|(cat, weeks)| {
            if weeks.is_empty() { return None; }
            // Semaine modale
            let mut counts = [0u32; 5];
            for &w in &weeks {
                counts[(w as usize).saturating_sub(1).min(4)] += 1;
            }
            let modal = counts.iter().enumerate()
                .max_by_key(|(_, &c)| c)
                .map(|(i, _)| (i + 1) as u8)
                .unwrap_or(1);
            Some((cat, modal))
        }).collect()
    }

    // ── Utilitaires date ──────────────────────────────────────────
    pub fn days_ago(from: &Date, n: u32) -> Date {
        Date::from_days_since_epoch(from.to_days_since_epoch().saturating_sub(n))
    }

    pub fn days_from(from: &Date, n: u32) -> Date {
        Date::from_days_since_epoch(from.to_days_since_epoch() + n)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::adaptive::CycleRecord;

    fn make_det() -> DeterministicResult {
        DeterministicResult {
            total_balance: 300_000.0, committed_mass: 50_000.0,
            free_mass: 250_000.0, days_remaining: 20,
            daily_budget: 12_500.0, spent_today: 0.0,
            remaining_today: 12_500.0, transport_reserve: 0.0,
            charges_reserve: 50_000.0,
        }
    }

    fn make_engine_input(today: Date, transactions: Vec<Transaction>) -> EngineInput {
        EngineInput {
            today, accounts: vec![], charges: vec![],
            transactions,
            cycle: FinancialCycle {
                cycle_type: CycleType::Monthly,
                savings_goal: 0.0, transport: TransportType::None,
            },
        }
    }

    #[test]
    fn test_ghost_money_triggered() {
        let today = Date::new(2026, 3, 15);
        let transactions: Vec<Transaction> = (0u8..8).map(|i| Transaction {
            id: format!("t{i}"),
            date: Date::new(2026, 3, 9 + i % 6),
            amount: 200.0,
            tx_type: TransactionType::Expense,
            category: Some("recharge".into()),
            account_id: "a1".into(),
            description: None, sms_confidence: None,
        }).collect();

        let det      = make_det();
        let input    = make_engine_input(today, transactions);
        let anomalies = AnomalyModule::detect(&input, &[], &BehavioralProfile::default(), &det);

        assert!(anomalies.iter().any(|a| matches!(a.anomaly_type, AnomalyType::GhostMoney { .. })));
    }

    #[test]
    fn test_ghost_money_not_triggered_below_count() {
        let today = Date::new(2026, 3, 15);
        let transactions: Vec<Transaction> = (0u8..3).map(|i| Transaction {
            id: format!("t{i}"),
            date: Date::new(2026, 3, 12 + i),
            amount: 200.0, tx_type: TransactionType::Expense,
            category: None, account_id: "a1".into(),
            description: None, sms_confidence: None,
        }).collect();

        let det      = make_det();
        let input    = make_engine_input(today, transactions);
        let anomalies = AnomalyModule::detect(&input, &[], &BehavioralProfile::default(), &det);
        assert!(!anomalies.iter().any(|a| matches!(a.anomaly_type, AnomalyType::GhostMoney { .. })));
    }

    #[test]
    fn test_ghost_money_not_triggered_low_impact() {
        let today = Date::new(2026, 3, 15);
        // 8 micro-transactions mais solde très élevé → impact < 5%
        let det = DeterministicResult {
            free_mass: 100_000_000.0, // 100M → impact négligeable
            daily_budget: 12_500.0,
            ..make_det()
        };
        let transactions: Vec<Transaction> = (0u8..8).map(|i| Transaction {
            id: format!("t{i}"),
            date: Date::new(2026, 3, 9 + i % 6),
            amount: 200.0, tx_type: TransactionType::Expense,
            category: Some("recharge".into()), account_id: "a1".into(),
            description: None, sms_confidence: None,
        }).collect();

        let input = make_engine_input(today, transactions);
        let anomalies = AnomalyModule::detect(&input, &[], &BehavioralProfile::default(), &det);
        assert!(!anomalies.iter().any(|a| matches!(a.anomaly_type, AnomalyType::GhostMoney { .. })));
    }

    #[test]
    fn test_unusual_amount_detected() {
        let today = Date::new(2026, 3, 15);

        // Historique : moyenne restaurant = 5 000 FCFA
        let history_txs: Vec<Transaction> = (1u8..=5).map(|i| Transaction {
            id: format!("h{i}"), date: Date::new(2026, 2, i * 4),
            amount: 5_000.0, tx_type: TransactionType::Expense,
            category: Some("restaurant".into()), account_id: "a1".into(),
            description: None, sms_confidence: None,
        }).collect();

        let record = CycleRecord {
            cycle_start: Date::new(2026, 2, 1), cycle_end: Date::new(2026, 2, 28),
            opening_balance: 300_000.0, closing_balance: 250_000.0,
            total_income: 300_000.0, total_expenses: 25_000.0,
            savings_goal: 0.0, savings_achieved: 0.0,
            daily_expenses: vec![1000.0; 28], category_totals: vec![],
            transactions: history_txs,
        };

        // Dépense actuelle = 30 000 → très au-dessus de la moyenne
        let current_tx = Transaction {
            id: "curr1".into(),
            date: today,
            amount: 30_000.0,
            tx_type: TransactionType::Expense,
            category: Some("restaurant".into()),
            account_id: "a1".into(),
            description: None, sms_confidence: None,
        };

        let input = make_engine_input(today, vec![current_tx]);
        let anomalies = AnomalyModule::detect(&input, &[record], &BehavioralProfile::default(), &make_det());

        assert!(anomalies.iter().any(|a| matches!(
            &a.anomaly_type,
            AnomalyType::UnusualAmount { category, .. } if category == "restaurant"
        )));
    }

    #[test]
    fn test_no_anomaly_for_income_transactions() {
        let today = Date::new(2026, 3, 15);
        // Revenus → ne doivent jamais déclencher d'anomalie
        let transactions: Vec<Transaction> = (0u8..10).map(|i| Transaction {
            id: format!("t{i}"),
            date: Date::new(2026, 3, 9 + i % 6),
            amount: 200.0,
            tx_type: TransactionType::Income, // revenu
            category: Some("salaire".into()), account_id: "a1".into(),
            description: None, sms_confidence: None,
        }).collect();

        let det   = make_det();
        let input = make_engine_input(today, transactions);
        let anomalies = AnomalyModule::detect(&input, &[], &BehavioralProfile::default(), &det);
        assert!(anomalies.is_empty());
    }
}
