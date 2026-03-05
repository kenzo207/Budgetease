// ============================================================
//  MODULE E — MÉMOIRE ÉPISODIQUE
//  Enregistre les événements marquants des cycles passés.
//  Réutilise les épisodes similaires pour anticiper les risques.
// ============================================================

use crate::types::*;
use super::CycleRecord;
use crate::adaptive::anomaly::AnomalyModule;

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct Episode {
    pub episode_type: EpisodeType,
    pub cycle_start:  Date,
    pub day_of_cycle: u32,
    pub amount:       Option<f64>,
    pub description:  String,
}

#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub enum EpisodeType {
    /// Solde tombé sous 10% du budget mensuel
    CriticalLowBalance,
    /// Objectif d'épargne atteint
    SavingsGoalReached,
    /// Objectif d'épargne raté de plus de 20%
    SavingsGoalMissed,
    /// Dépense exceptionnelle (> 3× la moyenne journalière)
    ExceptionalExpense { category: String },
    /// Fin de mois avec déficit (charges non couvertes)
    MonthlyDeficit,
    /// Fin de mois confortable (> 20% de marge)
    ComfortableEnd,
}

pub struct MemoryModule;

impl MemoryModule {
    pub fn relevant_episodes(input: &EngineInput, history: &[CycleRecord]) -> Vec<Episode> {
        let all = Self::extract_all_episodes(history);
        Self::filter_relevant(&all, &input.today)
    }

    pub fn extract_all_episodes(history: &[CycleRecord]) -> Vec<Episode> {
        let mut episodes = Vec::new();

        for record in history {
            let cycle_len    = record.cycle_length();
            let total_budget = record.total_income.max(1.0);

            // ── Solde critique ──
            let mut running = record.opening_balance;
            let threshold   = total_budget * 0.10;

            for (day_idx, &expense) in record.daily_expenses.iter().enumerate() {
                running -= expense;
                if running < threshold {
                    episodes.push(Episode {
                        episode_type: EpisodeType::CriticalLowBalance,
                        cycle_start:  record.cycle_start,
                        day_of_cycle: day_idx as u32 + 1,
                        amount:       Some(running),
                        description:  format!(
                            "Solde critique de {:.0} FCFA atteint au jour {} du cycle.",
                            running, day_idx + 1
                        ),
                    });
                    break; // un seul épisode par cycle
                }
            }

            // ── Objectif d'épargne ──
            if record.savings_goal > 0.0 {
                let ratio = record.savings_achieved / record.savings_goal;
                if ratio >= 1.0 {
                    episodes.push(Episode {
                        episode_type: EpisodeType::SavingsGoalReached,
                        cycle_start:  record.cycle_start,
                        day_of_cycle: cycle_len,
                        amount:       Some(record.savings_achieved),
                        description:  format!(
                            "Objectif d'épargne de {:.0} FCFA atteint ({:.0}%).",
                            record.savings_goal, ratio * 100.0
                        ),
                    });
                } else if ratio < 0.80 {
                    episodes.push(Episode {
                        episode_type: EpisodeType::SavingsGoalMissed,
                        cycle_start:  record.cycle_start,
                        day_of_cycle: cycle_len,
                        amount:       Some(record.savings_goal - record.savings_achieved),
                        description:  format!(
                            "Objectif d'épargne raté : il manquait {:.0} FCFA.",
                            record.savings_goal - record.savings_achieved
                        ),
                    });
                }
            }

            // ── Dépenses exceptionnelles ──
            if cycle_len > 0 {
                let daily_avg = record.total_expenses / cycle_len as f64;
                if daily_avg > 0.0 {
                    for (day_idx, &expense) in record.daily_expenses.iter().enumerate() {
                        if expense <= daily_avg * 3.0 { continue; }

                        let day_date = AnomalyModule::days_from(
                            &record.cycle_start,
                            day_idx as u32,
                        );
                        let dominant_cat = record.transactions.iter()
                            .filter(|t| t.date == day_date && t.tx_type.is_outflow())
                            .max_by(|a, b| a.amount.partial_cmp(&b.amount)
                                .unwrap_or(std::cmp::Ordering::Equal))
                            .and_then(|t| t.category.clone())
                            .unwrap_or_else(|| "non catégorisé".into());

                        episodes.push(Episode {
                            episode_type: EpisodeType::ExceptionalExpense {
                                category: dominant_cat.clone()
                            },
                            cycle_start:  record.cycle_start,
                            day_of_cycle: day_idx as u32 + 1,
                            amount:       Some(expense),
                            description:  format!(
                                "Dépense exceptionnelle de {:.0} FCFA ({}) — {:.1}× la moyenne.",
                                expense, dominant_cat, expense / daily_avg
                            ),
                        });
                    }
                }
            }

            // ── Fin de cycle ──
            let final_balance = record.closing_balance;
            if final_balance < 0.0 {
                episodes.push(Episode {
                    episode_type: EpisodeType::MonthlyDeficit,
                    cycle_start:  record.cycle_start,
                    day_of_cycle: cycle_len,
                    amount:       Some(final_balance.abs()),
                    description:  format!(
                        "Déficit de {:.0} FCFA en fin de cycle.", final_balance.abs()
                    ),
                });
            } else if final_balance > total_budget * 0.20 {
                episodes.push(Episode {
                    episode_type: EpisodeType::ComfortableEnd,
                    cycle_start:  record.cycle_start,
                    day_of_cycle: cycle_len,
                    amount:       Some(final_balance),
                    description:  format!(
                        "Fin de cycle confortable avec {:.0} FCFA de marge.", final_balance
                    ),
                });
            }
        }

        episodes
    }

    fn filter_relevant(episodes: &[Episode], today: &Date) -> Vec<Episode> {
        let current_week  = (today.day - 1) / 7 + 1;
        let current_month = today.month;

        episodes.iter()
            .filter(|ep| {
                let ep_week   = ((ep.day_of_cycle.saturating_sub(1) / 7) + 1) as u8;
                let same_week = (ep_week as i32 - current_week as i32).abs() <= 1;
                let same_season = ep.cycle_start.month == current_month;

                let is_negative = matches!(
                    ep.episode_type,
                    EpisodeType::CriticalLowBalance
                    | EpisodeType::SavingsGoalMissed
                    | EpisodeType::MonthlyDeficit
                );

                (same_week && is_negative) || same_season
            })
            .cloned()
            .collect()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_record_with_deficit() -> CycleRecord {
        let mut daily = vec![5_000.0f64; 30];
        daily[25] = 180_000.0; // dépense énorme → déficit

        CycleRecord {
            cycle_start:      Date::new(2025, 3, 1),
            cycle_end:        Date::new(2025, 3, 31),
            opening_balance:  200_000.0,
            closing_balance:  -30_000.0,
            total_income:     200_000.0,
            total_expenses:   daily.iter().sum(),
            savings_goal:     30_000.0,
            savings_achieved: 0.0,
            daily_expenses:   daily,
            category_totals:  vec![],
            transactions:     vec![],
        }
    }

    #[test]
    fn test_episodes_extracted() {
        let history  = vec![make_record_with_deficit()];
        let episodes = MemoryModule::extract_all_episodes(&history);

        assert!(episodes.iter().any(|e| e.episode_type == EpisodeType::CriticalLowBalance));
        assert!(episodes.iter().any(|e| e.episode_type == EpisodeType::SavingsGoalMissed));
        assert!(episodes.iter().any(|e| e.episode_type == EpisodeType::MonthlyDeficit));
    }

    #[test]
    fn test_comfortable_end_episode() {
        let record = CycleRecord {
            cycle_start: Date::new(2025, 2, 1), cycle_end: Date::new(2025, 2, 28),
            opening_balance: 200_000.0, closing_balance: 60_000.0, // 30% → confortable
            total_income: 200_000.0, total_expenses: 140_000.0,
            savings_goal: 0.0, savings_achieved: 0.0,
            daily_expenses: vec![5_000.0; 28], category_totals: vec![], transactions: vec![],
        };
        let episodes = MemoryModule::extract_all_episodes(&[record]);
        assert!(episodes.iter().any(|e| e.episode_type == EpisodeType::ComfortableEnd));
    }

    #[test]
    fn test_relevant_episodes_filtered() {
        let history  = vec![make_record_with_deficit()];
        let all      = MemoryModule::extract_all_episodes(&history);
        let today    = Date::new(2026, 3, 28); // fin du mois
        let relevant = MemoryModule::filter_relevant(&all, &today);
        assert!(!relevant.is_empty());
    }

    #[test]
    fn test_no_episodes_for_healthy_cycle() {
        let record = CycleRecord {
            cycle_start: Date::new(2025, 1, 1), cycle_end: Date::new(2025, 1, 31),
            opening_balance: 300_000.0, closing_balance: 150_000.0,
            total_income: 300_000.0, total_expenses: 150_000.0,
            savings_goal: 30_000.0, savings_achieved: 30_000.0,
            daily_expenses: vec![5_000.0; 30],
            category_totals: vec![], transactions: vec![],
        };
        let episodes = MemoryModule::extract_all_episodes(&[record]);
        // Pas de déficit, objectif atteint → seul un ComfortableEnd possible
        assert!(!episodes.iter().any(|e| e.episode_type == EpisodeType::MonthlyDeficit));
        assert!(!episodes.iter().any(|e| e.episode_type == EpisodeType::SavingsGoalMissed));
    }
}
