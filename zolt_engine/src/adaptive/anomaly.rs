// ============================================================
//  MODULE C — DÉTECTION D'ANOMALIES
//  Trois types d'anomalies détectées :
//    1. Montant inhabituel (> 2 écarts-types de la catégorie)
//    2. Ghost Money (micro-dépenses répétées, seuil relatif)
//    3. Timing inhabituel (dépense hors semaine habituelle)
// ============================================================

use crate::types::*;
use super::{CycleRecord, profile::ProfileModule};

pub struct AnomalyModule;

impl AnomalyModule {
    pub fn detect(
        input:   &EngineInput,
        history: &[CycleRecord],
        profile: &BehavioralProfile,
        det:     &DeterministicResult,
    ) -> Vec<Anomaly> {
        let mut anomalies = Vec::new();

        // Ghost Money fonctionne dès le premier cycle (fenêtre 7 jours)
        if let Some(gm) = Self::detect_ghost_money(&input.transactions, &input.today, det) {
            anomalies.push(gm);
        }

        // Les deux autres nécessitent de l'historique
        if !history.is_empty() {
            anomalies.extend(Self::detect_unusual_amounts(
                &input.transactions, &input.today, history,
            ));
            anomalies.extend(Self::detect_unusual_timing(
                &input.transactions, &input.today, history, profile,
            ));
        }

        anomalies
    }

    // ── GHOST MONEY — micro-dépenses répétées ───────────────────
    // Seuil relatif : micro = < 5% du budget journalier moyen
    // Alerte si : ≥ 5 micro-transactions ET impact ≥ 5% du budget dispo
    fn detect_ghost_money(
        transactions: &[Transaction],
        today: &Date,
        det: &DeterministicResult,
    ) -> Option<Anomaly> {
        // Fenêtre glissante : 7 derniers jours
        let window_start = Self::days_ago(today, 7);

        // Seuil de micro-dépense : relatif au budget journalier
        // Entre 200 et 2000 FCFA, centré sur 2% du B_j
        let micro_threshold = (det.daily_budget * 0.02).clamp(200.0, 2_000.0);

        let micro_txs: Vec<&Transaction> = transactions.iter()
            .filter(|t| {
                t.date >= window_start
                && t.date <= *today
                && t.tx_type.is_outflow()
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

    // ── MONTANT INHABITUEL ───────────────────────────────────────
    // Compare chaque dépense aux statistiques historiques de sa catégorie.
    // Signale si montant > moyenne + 2 * écart-type.
    fn detect_unusual_amounts(
        transactions: &[Transaction],
        today: &Date,
        history:      &[CycleRecord],
    ) -> Vec<Anomaly> {
        let mut anomalies = Vec::new();

        // Construit les stats par catégorie depuis l'historique
        let stats = Self::category_stats(history);

        // Vérifie les transactions des 7 derniers jours
        let window_start = Self::days_ago(today, 7);

        for tx in transactions {
            if !tx.date.within(window_start, *today) { continue; }
            if !tx.tx_type.is_outflow() { continue; }

            let category = match &tx.category {
                Some(c) => c.clone(),
                None    => continue, // pas de catégorie → pas d'analyse
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

    // ── TIMING INHABITUEL ────────────────────────────────────────
    // Si l'utilisateur dépense habituellement dans une catégorie
    // à une certaine semaine du mois, et qu'il le fait maintenant à
    // une semaine différente → signal (pas forcément négatif).
    fn detect_unusual_timing(
        transactions: &[Transaction],
        today:        &Date,
        history:      &[CycleRecord],
        _profile:     &BehavioralProfile,
    ) -> Vec<Anomaly> {
        let mut anomalies = Vec::new();

        // Semaine actuelle dans le cycle (1..=5)
        let current_week = ((today.day - 1) / 7 + 1) as u8;

        // Construit la semaine typique par catégorie
        let typical_weeks = Self::typical_week_by_category(history);

        let window_start = Self::days_ago(today, 3);

        for tx in transactions {
            if !tx.date.within(window_start, *today) { continue; }
            if !tx.tx_type.is_outflow() { continue; }

            let category = match &tx.category {
                Some(c) => c.clone(),
                None    => continue,
            };

            if let Some(typical_week) = typical_weeks.get(&category) {
                let diff = (current_week as i32 - *typical_week as i32).abs();
                if diff >= 2 {
                    anomalies.push(Anomaly {
                        anomaly_type: AnomalyType::UnusualTiming {
                            category:     category.clone(),
                            typical_week: *typical_week,
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

    // ── Statistiques par catégorie (moyenne + écart-type) ───────
    fn category_stats(
        history: &[CycleRecord],
    ) -> std::collections::HashMap<String, (f64, f64)> {
        let mut groups: std::collections::HashMap<String, Vec<f64>> =
            std::collections::HashMap::new();

        for record in history {
            for tx in &record.transactions {
                if let Some(cat) = &tx.category {
                    if tx.tx_type.is_outflow() {
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

    // ── Semaine typique par catégorie ────────────────────────────
    fn typical_week_by_category(
        history: &[CycleRecord],
    ) -> std::collections::HashMap<String, u8> {
        let mut groups: std::collections::HashMap<String, Vec<u8>> =
            std::collections::HashMap::new();

        for record in history {
            for tx in &record.transactions {
                if let Some(cat) = &tx.category {
                    if tx.tx_type.is_outflow() {
                        let days_in = record.cycle_start.days_until(&tx.date).max(0) as u8;
                        let week    = days_in / 7 + 1;
                        groups.entry(cat.clone()).or_default().push(week);
                    }
                }
            }
        }

        groups.into_iter().filter_map(|(cat, weeks)| {
            if weeks.is_empty() { return None; }
            // Semaine modale (la plus fréquente)
            let mut counts = [0u32; 6]; // semaines 1..=5
            for &w in &weeks {
                let idx = (w as usize).saturating_sub(1).min(4);
                counts[idx] += 1;
            }
            let modal_idx = counts.iter().enumerate()
                .max_by_key(|(_, &c)| c)
                .map(|(i, _)| i)
                .unwrap_or(0);
            Some((cat, (modal_idx + 1) as u8))
        }).collect()
    }

    // ── Utilitaires date ─────────────────────────────────────────
    fn days_ago(from: &Date, n: u32) -> Date {
        let epoch = from.to_days_since_epoch().saturating_sub(n);
        Date::from_days_since_epoch(epoch)
    }

    fn days_from(from: &Date, n: u32) -> Date {
        Date::from_days_since_epoch(from.to_days_since_epoch() + n)
    }
}

// Extension de Date pour les besoins du module
impl Date {
    pub fn within(&self, start: Date, end: Date) -> bool {
        *self >= start && *self <= end
    }

    pub fn from_days_since_epoch(days: u32) -> Self {
        // Algorithme inverse de Rata Die
        let z   = days + 719468;
        let era = z / 146097;
        let doe = z - era * 146097;
        let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
        let y   = yoe + era * 400;
        let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
        let mp  = (5 * doy + 2) / 153;
        let d   = doy - (153 * mp + 2) / 5 + 1;
        let m   = if mp < 10 { mp + 3 } else { mp - 9 };
        let y   = if m <= 2 { y + 1 } else { y };
        Date::new(y as u16, m as u8, d as u8)
    }
}

// ────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;
    use crate::deterministic::DeterministicEngine;

    fn make_det() -> DeterministicResult {
        DeterministicResult {
            total_balance: 300_000.0, committed_mass: 50_000.0,
            free_mass: 250_000.0, days_remaining: 20,
            daily_budget: 12_500.0, spent_today: 0.0,
            remaining_today: 12_500.0, transport_reserve: 0.0,
            charges_reserve: 50_000.0,
        }
    }

    #[test]
    fn test_ghost_money_triggered() {
        let today = Date::new(2026, 3, 15);
        // 8 micro-transactions de 200 FCFA en 7 jours
        let transactions: Vec<Transaction> = (0u8..8).map(|i| Transaction {
            id:             format!("t{i}"),
            date:           Date::new(2026, 3, 9 + i % 6),
            amount:         200.0,
            tx_type:        TransactionType::Expense,
            category:       Some("recharge".into()),
            account_id:     "a1".into(),
            description:    None,
            sms_confidence: None,
        }).collect();

        let det = make_det();
        let anomaly = AnomalyModule::detect(
            &EngineInput {
                today,
                accounts: vec![],
                charges: vec![],
                transactions: transactions.clone(),
                cycle: FinancialCycle {
                    cycle_type: CycleType::Monthly,
                    savings_goal: 0.0,
                    transport: TransportType::None,
                },
            },
            &[],
            &BehavioralProfile::default(),
            &det,
        );

        let ghost = anomaly.iter().find(|a| matches!(a.anomaly_type, AnomalyType::GhostMoney { .. }));
        assert!(ghost.is_some(), "Ghost Money devrait être détecté");
    }

    #[test]
    fn test_ghost_money_not_triggered_below_threshold() {
        let today = Date::new(2026, 3, 15);
        // Seulement 3 micro-transactions → pas assez
        let transactions: Vec<Transaction> = (0u8..3).map(|i| Transaction {
            id: format!("t{i}"), date: Date::new(2026, 3, 12 + i),
            amount: 200.0, tx_type: TransactionType::Expense,
            category: None, account_id: "a1".into(),
            description: None, sms_confidence: None,
        }).collect();

        let det = make_det();
        let anomalies = AnomalyModule::detect(
            &EngineInput {
                today, accounts: vec![], charges: vec![],
                transactions,
                cycle: FinancialCycle {
                    cycle_type: CycleType::Monthly,
                    savings_goal: 0.0, transport: TransportType::None,
                },
            },
            &[], &BehavioralProfile::default(), &det,
        );

        let ghost = anomalies.iter().find(|a| matches!(a.anomaly_type, AnomalyType::GhostMoney { .. }));
        assert!(ghost.is_none());
    }
}
