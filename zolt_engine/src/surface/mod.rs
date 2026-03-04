// ============================================================
//  COUCHE 3 — SURFACE CONVERSATIONNELLE
//  Traduit tous les signaux des couches 1 et 2 en messages
//  lisibles, hiérarchisés, et actionnables.
//  Pas de LLM — système de templates contextuels enrichis.
//  Langue : français (Afrique de l'Ouest)
// ============================================================

use crate::types::*;
use crate::adaptive::{AdaptiveOutput, memory::Episode};


pub struct SurfaceEngine;

impl SurfaceEngine {
    pub fn generate(
        det:      &DeterministicResult,
        adaptive: &AdaptiveOutput,
        today:    &Date,
    ) -> Vec<ConversationalMessage> {
        let mut messages: Vec<ConversationalMessage> = Vec::new();

        // ── Niveau CRITIQUE (max 1 — stoppe tout) ───────────────
        if let Some(msg) = Self::critical_budget_message(det) {
            messages.push(msg);
            // Si critique → on n'empile pas les warnings, sauf prédiction
        }

        // ── Prédiction de fin de cycle ───────────────────────────
        if let Some(pred) = &adaptive.prediction {
            if let Some(msg) = Self::prediction_message(pred, det, today) {
                messages.push(msg);
            }
        }

        // ── Avertissements de charges imminentes ─────────────────
        // (générés à partir de det, pas besoin d'adaptive)
        // Placeholder : les charges viennent de l'input — passées via det.charges_reserve
        // En pratique Flutter passera les charges via l'EngineInput

        // ── Anomalies (max 2) ────────────────────────────────────
        let anomaly_msgs: Vec<_> = adaptive.anomalies.iter()
            .filter(|a| !a.dismissed)
            .take(2)
            .filter_map(|a| Self::anomaly_message(a, det))
            .collect();
        messages.extend(anomaly_msgs);

        // ── Mémoire épisodique : avertissements du passé ─────────
        if let Some(msg) = Self::memory_message(&adaptive.episodes, today) {
            messages.push(msg);
        }

        // ── Suggestions adaptatives ──────────────────────────────
        for suggestion in &adaptive.suggestions {
            if let Some(msg) = Self::suggestion_message(suggestion) {
                messages.push(msg);
                break; // une seule suggestion à la fois pour ne pas noyer l'user
            }
        }

        // ── Encouragement (1 seul, seulement si pas de critique) ─
        let has_critical = messages.iter().any(|m| m.level == AlertLevel::Critical);
        if !has_critical {
            if let Some(msg) = Self::encouragement_message(det, &adaptive.profile) {
                messages.push(msg);
            }
        }

        // Trie par niveau de sévérité décroissant
        messages.sort_by(|a, b| b.level.cmp(&a.level));
        messages
    }

    // ── Message critique : budget dépassé ou nul ────────────────
    fn critical_budget_message(det: &DeterministicResult) -> Option<ConversationalMessage> {
        if det.free_mass > 0.0 && det.daily_budget > 0.0 {
            return None;
        }

        let body = if det.free_mass <= 0.0 {
            format!(
                "Ton solde actuel ({:.0} FCFA) ne couvre pas tes engagements du mois \
                 ({:.0} FCFA). Vérifie tes charges ou réduis ton objectif d'épargne.",
                det.total_balance, det.committed_mass
            )
        } else {
            "Tu as dépensé tout ton budget d'aujourd'hui. \
             Évite toute nouvelle dépense jusqu'à demain.".into()
        };

        Some(ConversationalMessage {
            level:    AlertLevel::Critical,
            title:    "⚠️ Budget insuffisant".into(),
            body,
            ttl_days: None, // permanent
        })
    }

    // ── Message de prédiction ────────────────────────────────────
    fn prediction_message(
        pred:  &EndOfCyclePrediction,
        det:   &DeterministicResult,
        today: &Date,
    ) -> Option<ConversationalMessage> {
        if pred.confidence < 0.3 { return None; } // trop incertain pour afficher

        match pred.alert_level {
            AlertLevel::Critical if pred.projected_deficit > 0.0 => {
                let reduction = pred.projected_deficit / det.days_remaining.max(1) as f64;
                Some(ConversationalMessage {
                    level: AlertLevel::Critical,
                    title: "Fin de mois difficile en vue".into(),
                    body:  format!(
                        "À ton rythme actuel, il te manquera environ {:.0} FCFA \
                         à la fin du cycle. Réduis tes dépenses de {:.0} FCFA/jour \
                         pour éviter le déficit.",
                        pred.projected_deficit, reduction
                    ),
                    ttl_days: Some(3),
                })
            }
            AlertLevel::Warning if pred.projected_deficit > 0.0 => {
                Some(ConversationalMessage {
                    level: AlertLevel::Warning,
                    title: "Attention à la fin du mois".into(),
                    body:  format!(
                        "Tu risques un petit déficit de {:.0} FCFA si tu continues \
                         à ce rythme. Sois prudent(e) ces prochains jours.",
                        pred.projected_deficit
                    ),
                    ttl_days: Some(5),
                })
            }
            AlertLevel::Positive => {
                Some(ConversationalMessage {
                    level: AlertLevel::Positive,
                    title: "Bonne trajectoire 👍".into(),
                    body:  format!(
                        "Tu devrais finir le mois avec environ {:.0} FCFA de marge. \
                         Continue comme ça.",
                        pred.projected_final_balance
                    ),
                    ttl_days: Some(7),
                })
            }
            _ => None,
        }
    }

    // ── Message d'anomalie ───────────────────────────────────────
    fn anomaly_message(anomaly: &Anomaly, det: &DeterministicResult) -> Option<ConversationalMessage> {
        match &anomaly.anomaly_type {
            AnomalyType::GhostMoney { transaction_count, total, impact_pct } => {
                Some(ConversationalMessage {
                    level: AlertLevel::Warning,
                    title: "💸 Argent fantôme détecté".into(),
                    body:  format!(
                        "{} petites dépenses cette semaine représentent {:.0} FCFA \
                         — soit {:.0}% de ton budget disponible. \
                         Ces micro-achats s'accumulent sans qu'on s'en rende compte.",
                        transaction_count, total, impact_pct * 100.0
                    ),
                    ttl_days: Some(7),
                })
            }
            AnomalyType::UnusualAmount { category, amount, historical_avg } => {
                Some(ConversationalMessage {
                    level: AlertLevel::Warning,
                    title: format!("Dépense inhabituelle — {}", category),
                    body:  format!(
                        "Tu as dépensé {:.0} FCFA en «{}» — \
                         plus du double de ta moyenne habituelle ({:.0} FCFA). \
                         C'est normal ?",
                        amount, category, historical_avg
                    ),
                    ttl_days: Some(3),
                })
            }
            AnomalyType::UnusualTiming { category, typical_week, actual_week } => {
                Some(ConversationalMessage {
                    level: AlertLevel::Info,
                    title: format!("Timing inhabituel — {}", category),
                    body:  format!(
                        "Tu dépenses habituellement pour «{}» en semaine {}, \
                         mais cette dépense est arrivée en semaine {}. \
                         À surveiller si ça devient un pattern.",
                        category, typical_week, actual_week
                    ),
                    ttl_days: Some(3),
                })
            }
        }
    }

    // ── Message mémoire épisodique ───────────────────────────────
    fn memory_message(episodes: &[Episode], today: &Date) -> Option<ConversationalMessage> {
        use crate::adaptive::memory::EpisodeType;

        // Prioritise les épisodes critiques du passé à la même période
        let critical = episodes.iter().find(|e| {
            matches!(
                e.episode_type,
                EpisodeType::CriticalLowBalance | EpisodeType::MonthlyDeficit
            )
        });

        if let Some(ep) = critical {
            let month_name = Self::month_name(ep.cycle_start.month);
            return Some(ConversationalMessage {
                level: AlertLevel::Warning,
                title: "📆 Rappel du passé".into(),
                body:  format!(
                    "En {}, tu avais eu des difficultés à cette période du mois : {}. \
                     Reste vigilant(e) ces prochains jours.",
                    month_name, ep.description
                ),
                ttl_days: Some(5),
            });
        }

        None
    }

    // ── Message de suggestion adaptative ────────────────────────
    fn suggestion_message(suggestion: &AdaptiveSuggestion) -> Option<ConversationalMessage> {
        match suggestion {
            AdaptiveSuggestion::ReviseSavingsGoal { current, suggested, reason } => {
                Some(ConversationalMessage {
                    level: AlertLevel::Info,
                    title: "💡 Suggestion : objectif d'épargne".into(),
                    body:  format!(
                        "{} Veux-tu ajuster ton objectif à {:.0} FCFA ?",
                        reason, suggested
                    ),
                    ttl_days: Some(14),
                })
            }
            AdaptiveSuggestion::AddHiddenCharge { estimated_amount, pattern_description } => {
                Some(ConversationalMessage {
                    level: AlertLevel::Info,
                    title: "💡 Charge récurrente détectée".into(),
                    body:  format!(
                        "{} Veux-tu l'ajouter comme charge fixe ?",
                        pattern_description
                    ),
                    ttl_days: Some(14),
                })
            }
            AdaptiveSuggestion::AdjustSafetyMargin { new_margin_pct } => {
                Some(ConversationalMessage {
                    level: AlertLevel::Info,
                    title: "🛡️ Marge de sécurité activée".into(),
                    body:  format!(
                        "Tes dépenses sont assez variables. \
                         Une marge de sécurité de {:.0}% a été ajoutée \
                         à ton budget journalier pour éviter les mauvaises surprises.",
                        new_margin_pct * 100.0
                    ),
                    ttl_days: None,
                })
            }
        }
    }

    // ── Encouragement ────────────────────────────────────────────
    fn encouragement_message(
        det:     &DeterministicResult,
        profile: &BehavioralProfile,
    ) -> Option<ConversationalMessage> {
        // Seulement si l'épargne est bien respectée et le budget en bonne santé
        if profile.savings_achievement < 0.9 { return None; }
        if det.remaining_today < det.daily_budget * 0.3 { return None; }

        if profile.cycles_observed >= 2 && profile.savings_achievement >= 0.95 {
            return Some(ConversationalMessage {
                level: AlertLevel::Positive,
                title: "🌟 Bel effort !".into(),
                body:  format!(
                    "Tu as atteint ton objectif d'épargne sur {} cycles consécutifs. \
                     C'est une vraie discipline financière.",
                    profile.cycles_observed
                ),
                ttl_days: Some(3),
            });
        }

        None
    }

    fn month_name(month: u8) -> &'static str {
        match month {
            1 => "janvier", 2 => "février",  3 => "mars",
            4 => "avril",   5 => "mai",       6 => "juin",
            7 => "juillet", 8 => "août",      9 => "septembre",
            10 => "octobre",11 => "novembre",12 => "décembre",
            _  => "mois inconnu",
        }
    }
}

// ────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;
    use crate::adaptive::{AdaptiveOutput, memory::Episode};

    fn make_det(free_mass: f64, daily: f64, remaining: f64) -> DeterministicResult {
        DeterministicResult {
            total_balance: free_mass + 30_000.0,
            committed_mass: 30_000.0,
            free_mass, days_remaining: 15,
            daily_budget: daily, spent_today: 0.0,
            remaining_today: remaining,
            transport_reserve: 0.0, charges_reserve: 30_000.0,
        }
    }

    fn empty_adaptive() -> AdaptiveOutput {
        AdaptiveOutput {
            profile:     BehavioralProfile::default(),
            prediction:  None,
            anomalies:   vec![],
            suggestions: vec![],
            episodes:    vec![],
        }
    }

    #[test]
    fn test_critical_message_when_no_free_mass() {
        let det      = make_det(0.0, 0.0, 0.0);
        let adaptive = empty_adaptive();
        let msgs     = SurfaceEngine::generate(&det, &adaptive, &Date::new(2026, 3, 15));

        assert!(msgs.iter().any(|m| m.level == AlertLevel::Critical));
    }

    #[test]
    fn test_no_critical_message_when_healthy() {
        let det      = make_det(200_000.0, 13_000.0, 13_000.0);
        let adaptive = empty_adaptive();
        let msgs     = SurfaceEngine::generate(&det, &adaptive, &Date::new(2026, 3, 10));

        assert!(!msgs.iter().any(|m| m.level == AlertLevel::Critical));
    }

    #[test]
    fn test_messages_sorted_by_severity() {
        let det  = make_det(100_000.0, 6_500.0, 6_500.0);
        let mut adaptive = empty_adaptive();

        // Ajoute une anomalie warning
        adaptive.anomalies.push(Anomaly {
            anomaly_type: AnomalyType::GhostMoney {
                transaction_count: 6,
                total: 1_500.0,
                impact_pct: 0.07,
            },
            detected_on: Date::new(2026, 3, 10),
            expires_on:  Date::new(2026, 3, 17),
            dismissed:   false,
        });

        let msgs = SurfaceEngine::generate(&det, &adaptive, &Date::new(2026, 3, 10));

        // Vérifie l'ordre décroissant
        for i in 1..msgs.len() {
            assert!(msgs[i-1].level >= msgs[i].level,
                "Messages non triés par sévérité à l'index {}", i);
        }
    }
}
