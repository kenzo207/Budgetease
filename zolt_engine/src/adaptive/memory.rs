// ============================================================
//  MODULE E — MÉMOIRE ÉPISODIQUE
//  Enregistre les événements marquants des cycles passés.
//  Réutilise les épisodes similaires pour anticiper les risques.
//  Utile après 12 mois pour la détection des patterns saisonniers.
// ============================================================

use crate::types::*;
use super::CycleRecord;

/// Un épisode = un événement marquant d'un cycle passé.
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct Episode {
    pub episode_type: EpisodeType,
    pub cycle_start:  Date,
    pub day_of_cycle: u32,  // quel jour du cycle l'événement s'est produit
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
    /// Extrait les épisodes pertinents pour le contexte actuel.
    /// "Pertinent" = même période du cycle, ou même mois de l'année.
    pub fn relevant_episodes(input: &EngineInput, history: &[CycleRecord]) -> Vec<Episode> {
        let all_episodes = Self::extract_all_episodes(history);
        Self::filter_relevant(&all_episodes, &input.today)
    }

    /// Extrait tous les épisodes de tous les cycles passés.
    pub fn extract_all_episodes(history: &[CycleRecord]) -> Vec<Episode> {
        let mut episodes = Vec::new();

        for record in history {
            let cycle_len  = record.cycle_length();
            let total_budget = record.total_income;

            // ── Solde critique ──
            let mut min_balance = record.opening_balance;
            let mut running     = record.opening_balance;
            for (day_idx, &expense) in record.daily_expenses.iter().enumerate() {
                running -= expense;
                if running < min_balance { min_balance = running; }
                if running < total_budget * 0.10 {
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
                    break; // un seul épisode par cycle pour ce type
                }
            }

            // ── Objectif d'épargne ──
            if record.savings_goal > 0.0 {
                let achievement = record.savings_achieved / record.savings_goal;
                if achievement >= 1.0 {
                    episodes.push(Episode {
                        episode_type: EpisodeType::SavingsGoalReached,
                        cycle_start:  record.cycle_start,
                        day_of_cycle: cycle_len,
                        amount:       Some(record.savings_achieved),
                        description:  format!(
                            "Objectif d'épargne de {:.0} FCFA atteint ({:.0}%).",
                            record.savings_goal, achievement * 100.0
                        ),
                    });
                } else if achievement < 0.80 {
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
            let daily_avg = if cycle_len > 0 {
                record.total_expenses / cycle_len as f64
            } else { 1.0 };

            for (day_idx, &expense) in record.daily_expenses.iter().enumerate() {
                if expense > daily_avg * 3.0 {
                    // Trouve la catégorie dominante ce jour-là
                    let day_date = Date::from_days_since_epoch(
                        record.cycle_start.to_days_since_epoch() + day_idx as u32
                    );
                    let dominant_cat = record.transactions.iter()
                        .filter(|t| t.date == day_date && t.tx_type.is_outflow())
                        .max_by(|a, b| a.amount.partial_cmp(&b.amount).unwrap())
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

            // ── Fin de mois ──
            let final_balance = record.closing_balance;
            let comfort_threshold = total_budget * 0.20;
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
            } else if final_balance > comfort_threshold {
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

    /// Filtre les épisodes pertinents pour la date courante.
    /// Critères :
    ///   1. Même semaine du mois dans un cycle passé
    ///   2. Même mois de l'année (saisonnalité, si historique > 12 mois)
    fn filter_relevant(episodes: &[Episode], today: &Date) -> Vec<Episode> {
        let current_week = (today.day - 1) / 7 + 1; // 1..=5
        let current_month = today.month;

        episodes.iter()
            .filter(|ep| {
                // Semaine équivalente dans le cycle
                let ep_week = (ep.day_of_cycle.saturating_sub(1) / 7 + 1) as u8;
                let same_week = (ep_week as i32 - current_week as i32).abs() <= 1;

                // Même mois de l'année (saisonnalité)
                let same_season = ep.cycle_start.month == current_month;

                // Épisodes critiques ou négatifs → toujours pertinents si même semaine
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

// Extension de Date (utilisée ici)
use crate::adaptive::anomaly::*; // réutilise from_days_since_epoch

// ────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;

    fn make_record_with_low_balance() -> CycleRecord {
        let mut daily = vec![5_000.0f64; 30];
        daily[25] = 180_000.0; // dépense énorme jour 26 → solde critique

        CycleRecord {
            cycle_start:     Date::new(2025, 3, 1),
            cycle_end:       Date::new(2025, 3, 31),
            opening_balance: 200_000.0,
            closing_balance: -30_000.0,
            total_income:    200_000.0,
            total_expenses:  daily.iter().sum(),
            savings_goal:    30_000.0,
            savings_achieved: 0.0,
            daily_expenses:  daily,
            category_totals: vec![],
            transactions:    vec![],
        }
    }

    #[test]
    fn test_episodes_extracted() {
        let history = vec![make_record_with_low_balance()];
        let episodes = MemoryModule::extract_all_episodes(&history);

        // Doit détecter : solde critique, objectif raté, dépense exceptionnelle, déficit
        assert!(episodes.iter().any(|e| e.episode_type == EpisodeType::CriticalLowBalance));
        assert!(episodes.iter().any(|e| e.episode_type == EpisodeType::SavingsGoalMissed));
        assert!(episodes.iter().any(|e| e.episode_type == EpisodeType::MonthlyDeficit));
    }

    #[test]
    fn test_relevant_episodes_filtered() {
        let history = vec![make_record_with_low_balance()];
        let all     = MemoryModule::extract_all_episodes(&history);

        // Aujourd'hui = fin de mois → les épisodes de la semaine 4-5 doivent ressortir
        let today   = Date::new(2026, 3, 28);
        let relevant = MemoryModule::filter_relevant(&all, &today);
        assert!(!relevant.is_empty());
    }
}
