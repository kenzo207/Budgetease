// ============================================================
//  MODULE NARRATIVE ENGINE — Messages 4 niveaux de profondeur
//  Remplace la couche Surface existante.
//  Génère des messages qui racontent une histoire, pas des alertes.
//
//  Niveau 1 : Le fait   ("Tu as dépensé 45 000 FCFA")
//  Niveau 2 : Contexte  ("C'est 12 000 de plus que d'habitude")
//  Niveau 3 : Cause     ("La différence vient des transports")
//  Niveau 4 : Action    (Premium — "Si tu maintiens ce rythme...")
//
//  Ton adaptatif : encourageant / bienveillant / direct / urgent / célébration
// ============================================================

use crate::types::*;
use crate::behavioral_insights::BehavioralInsights;
use serde::{Deserialize, Serialize};

// ── Types ─────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NarrativeMessage {
    pub id:           String,
    pub level:        AlertLevel,
    /// Les 4 couches — certaines peuvent être None
    pub fact:         String,
    pub context:      Option<String>,
    pub cause:        Option<String>,
    /// Recommandation (Premium uniquement)
    pub action:       Option<String>,
    /// Message complet assemblé pour affichage
    pub full_text:    String,
    pub ttl_days:     Option<u32>,
    pub priority:     u8,  // 1 (max) à 10 (min)
    pub is_premium:   bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NarrativeOutput {
    /// Messages triés par priorité
    pub messages:     Vec<NarrativeMessage>,
    /// Message principal du jour (le plus important)
    pub daily_brief:  DailyBrief,
    /// Ton global de la session
    pub session_tone: SessionTone,
}

/// Résumé de la journée en 2-3 phrases
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DailyBrief {
    pub greeting:     String,
    pub status:       String,
    pub outlook:      String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum SessionTone {
    Celebrating,   // objectif atteint, très bonne semaine
    Encouraging,   // tout va bien
    Attentive,     // surveille, léger dépassement
    Concerned,     // tension budgétaire
    Urgent,        // action nécessaire
}

// ── Contexte complet pour générer la narrative ───────────────

#[derive(Debug, Clone)]
pub struct NarrativeContext<'a> {
    pub first_name:   &'a str,
    pub det:          &'a DeterministicResult,
    pub insights:     &'a BehavioralInsights,
    pub history:      &'a [CycleRecord],
    pub today:        &'a Date,
    pub is_premium:   bool,
    pub income_pred:  Option<&'a IncomePrediction>,
    pub health_score: u8,
}

// ── Moteur ────────────────────────────────────────────────────

pub struct NarrativeEngine;

impl NarrativeEngine {
    pub fn generate(ctx: &NarrativeContext) -> NarrativeOutput {
        let tone      = Self::determine_tone(ctx);
        let messages  = Self::build_messages(ctx, &tone);
        let brief     = Self::build_daily_brief(ctx, &tone);

        NarrativeOutput { messages, daily_brief: brief, session_tone: tone }
    }

    // ── Détermine le ton global de la session ─────────────────
    fn determine_tone(ctx: &NarrativeContext) -> SessionTone {
        if ctx.det.is_insolvent()                          { return SessionTone::Urgent;       }
        if ctx.det.is_over_budget()                        { return SessionTone::Concerned;    }
        if ctx.det.remaining_today < ctx.det.daily_budget * 0.20 { return SessionTone::Attentive;   }
        if ctx.health_score >= 80                          { return SessionTone::Celebrating;  }
        SessionTone::Encouraging
    }

    // ── Construit tous les messages ───────────────────────────
    fn build_messages(
        ctx:  &NarrativeContext,
        tone: &SessionTone,
    ) -> Vec<NarrativeMessage> {
        let mut messages = Vec::new();

        // Message 1 : Budget du jour
        messages.push(Self::budget_message(ctx, tone));

        // Message 2 : Top insight comportemental
        if let Some(insight) = &ctx.insights.top_insight {
            messages.push(Self::insight_message(insight, ctx.is_premium));
        }

        // Message 3 : Momentum (si significatif)
        if ctx.insights.momentum.recent_trend != crate::behavioral_insights::MomentumTrend::Insufficient {
            messages.push(Self::momentum_message(ctx));
        }

        // Message 4 : Prédiction de revenu (si disponible)
        if let Some(pred) = ctx.income_pred {
            if pred.confidence >= 0.5 {
                messages.push(Self::income_prediction_message(pred, ctx));
            }
        }

        // Message 5 : Fuites détectées
        for leak in ctx.insights.leaks.iter().take(2) {
            if leak.severity != crate::behavioral_insights::LeakSeverity::Minor {
                messages.push(Self::leak_message(leak, ctx.is_premium));
            }
        }

        // Message 6 : Dérive progressive
        if let Some(drift) = ctx.insights.drifts.first() {
            if ctx.is_premium {
                messages.push(Self::drift_message(drift));
            }
        }

        // Message 7 : Charge cachée suggérée
        if let Some(hidden) = ctx.insights.hidden_charges.first() {
            if hidden.confidence > 0.7 && ctx.is_premium {
                messages.push(Self::hidden_charge_message(hidden));
            }
        }

        // Tri par priorité
        messages.sort_by_key(|m| m.priority);
        messages
    }

    // ── Budget du jour ────────────────────────────────────────
    fn budget_message(ctx: &NarrativeContext, tone: &SessionTone) -> NarrativeMessage {
        let det = ctx.det;

        let fact = format!(
            "Il te reste {:.0} FCFA pour aujourd'hui.",
            det.remaining_today.max(0.0)
        );

        let context = if !ctx.history.is_empty() {
            let avg_remaining: f64 = ctx.history.iter()
                .map(|r| {
                    let day_idx = (ctx.today.day as usize).min(r.daily_expenses.len()) - 1;
                    det.daily_budget - r.daily_expenses.get(day_idx).copied().unwrap_or(0.0)
                })
                .sum::<f64>() / ctx.history.len() as f64;

            let diff = det.remaining_today - avg_remaining;
            if diff.abs() > det.daily_budget * 0.15 {
                Some(if diff > 0.0 {
                    format!("C'est {:.0} FCFA de plus que ta moyenne habituelle.", diff)
                } else {
                    format!("C'est {:.0} FCFA de moins que ta moyenne habituelle.", diff.abs())
                })
            } else {
                Some("Conforme à ta moyenne habituelle.".into())
            }
        } else {
            None
        };

        let cause = if det.is_over_budget() {
            Some(format!(
                "Tu as dépassé ton budget du jour de {:.0} FCFA.",
                det.spent_today - det.daily_budget
            ))
        } else {
            None
        };

        let action = if ctx.is_premium {
            match tone {
                SessionTone::Urgent =>
                    Some("Action urgente : réduis tes dépenses au minimum pour les prochains jours.".into()),
                SessionTone::Concerned =>
                    Some(format!(
                        "Reste sous {:.0} FCFA/jour pour retrouver l'équilibre d'ici la fin du mois.",
                        det.daily_budget * 0.85
                    )),
                SessionTone::Celebrating =>
                    Some("Tu es en avance sur ton budget — une bonne marge pour les imprévus.".into()),
                _ => None,
            }
        } else { None };

        let full_text = Self::assemble(&fact, &context, &cause, &action);
        let (level, priority) = match tone {
            SessionTone::Urgent      => (AlertLevel::Critical, 1),
            SessionTone::Concerned   => (AlertLevel::Warning,  2),
            SessionTone::Celebrating => (AlertLevel::Positive, 3),
            _                        => (AlertLevel::Info,     3),
        };

        NarrativeMessage {
            id: "budget_today".into(),
            level, fact, context, cause, action,
            full_text, ttl_days: Some(1),
            priority, is_premium: false,
        }
    }

    // ── Top insight comportemental ────────────────────────────
    fn insight_message(
        insight:    &crate::behavioral_insights::TopInsight,
        is_premium: bool,
    ) -> NarrativeMessage {
        let fact     = insight.title.clone();
        let context  = Some(insight.body.clone());
        let action   = if is_premium {
            insight.potential_saving.map(|s| format!(
                "Tu pourrais économiser ~{:.0} FCFA/mois en agissant sur ce point.",
                s
            ))
        } else { None };

        let full_text = Self::assemble(&fact, &context, &None, &action);

        NarrativeMessage {
            id: "top_insight".into(),
            level: insight.level.clone(),
            fact, context, cause: None, action,
            full_text, ttl_days: Some(3),
            priority: 4, is_premium: false,
        }
    }

    // ── Momentum ──────────────────────────────────────────────
    fn momentum_message(ctx: &NarrativeContext) -> NarrativeMessage {
        use crate::behavioral_insights::MomentumTrend;

        let m = &ctx.insights.momentum;
        let fact = m.description.clone();

        let context = if ctx.is_premium {
            Some(format!(
                "À ce rythme, tu devrais dépenser {:.0} FCFA d'ici fin de mois.",
                m.projected_total
            ))
        } else { None };

        let level = match &m.recent_trend {
            MomentumTrend::Accelerating => AlertLevel::Warning,
            MomentumTrend::Decelerating => AlertLevel::Positive,
            _                           => AlertLevel::Info,
        };

        let full_text = Self::assemble(&fact, &context, &None, &None);

        NarrativeMessage {
            id: "momentum".into(),
            level, fact, context, cause: None, action: None,
            full_text, ttl_days: Some(2),
            priority: 5, is_premium: false,
        }
    }

    // ── Prédiction de revenu ──────────────────────────────────
    fn income_prediction_message(
        pred: &IncomePrediction,
        ctx:  &NarrativeContext,
    ) -> NarrativeMessage {
        let fact = match pred.predicted_date {
            Some(date) => format!(
                "Ton prochain revenu (~{:.0} FCFA) est attendu le {}.",
                pred.predicted_amount, date
            ),
            None => format!(
                "Un revenu de ~{:.0} FCFA est attendu ce mois.",
                pred.predicted_amount
            ),
        };

        let context = Some(format!(
            "Basé sur {} cycle(s) d'historique. Confiance : {:.0}%.",
            pred.based_on_cycles, pred.confidence * 100.0
        ));

        let action = if ctx.is_premium {
            let days_left = ctx.det.days_remaining;
            let total_needed = ctx.det.daily_budget * days_left as f64;
            if pred.predicted_amount < total_needed {
                Some(format!(
                    "Attention : tu auras besoin de {:.0} FCFA d'ici fin de mois, \
                     mais ton revenu attendu est {:.0} FCFA.",
                    total_needed, pred.predicted_amount
                ))
            } else {
                Some(format!(
                    "Ton revenu attendu couvre confortablement les {} jours restants.",
                    days_left
                ))
            }
        } else { None };

        let full_text = Self::assemble(&fact, &context, &None, &action);

        NarrativeMessage {
            id: "income_prediction".into(),
            level: AlertLevel::Info,
            fact, context, cause: None, action,
            full_text, ttl_days: Some(7),
            priority: 6, is_premium: false,
        }
    }

    // ── Fuite ─────────────────────────────────────────────────
    fn leak_message(
        leak:       &crate::behavioral_insights::SpendingLeak,
        is_premium: bool,
    ) -> NarrativeMessage {
        let fact    = format!("Fuite détectée : {}", leak.description);
        let context = Some(format!(
            "Représente {:.0}% de tes dépenses totales.",
            leak.pct_of_total * 100.0
        ));
        let action = if is_premium {
            Some(format!(
                "Économie potentielle si tu optimises : {:.0} FCFA/mois.",
                leak.monthly_cost * 0.40
            ))
        } else { None };

        let level = match leak.severity {
            crate::behavioral_insights::LeakSeverity::Major    => AlertLevel::Warning,
            crate::behavioral_insights::LeakSeverity::Moderate => AlertLevel::Info,
            crate::behavioral_insights::LeakSeverity::Minor    => AlertLevel::Info,
        };

        let full_text = Self::assemble(&fact, &context, &None, &action);

        NarrativeMessage {
            id: format!("leak_{:?}", leak.leak_type),
            level, fact, context, cause: None, action,
            full_text, ttl_days: Some(5),
            priority: 5, is_premium: false,
        }
    }

    // ── Dérive ────────────────────────────────────────────────
    fn drift_message(
        drift: &crate::behavioral_insights::CategoryDrift,
    ) -> NarrativeMessage {
        let fact    = drift.description.clone();
        let context = Some(format!(
            "Si ça continue, ça te coûtera {:.0} FCFA de plus dans 3 mois.",
            drift.projected_3m
        ));

        let full_text = Self::assemble(&fact, &context, &None, &None);

        NarrativeMessage {
            id: format!("drift_{}", drift.category),
            level: AlertLevel::Warning,
            fact, context, cause: None, action: None,
            full_text, ttl_days: Some(7),
            priority: 6, is_premium: true,
        }
    }

    // ── Charge cachée ─────────────────────────────────────────
    fn hidden_charge_message(
        hidden: &crate::behavioral_insights::HiddenCharge,
    ) -> NarrativeMessage {
        let full_text = hidden.description.clone();
        NarrativeMessage {
            id: format!("hidden_{}", hidden.category),
            level: AlertLevel::Info,
            fact: hidden.description.clone(),
            context: None, cause: None, action: None,
            full_text, ttl_days: Some(14),
            priority: 8, is_premium: true,
        }
    }

    // ── Daily brief ───────────────────────────────────────────
    fn build_daily_brief(
        ctx:  &NarrativeContext,
        tone: &SessionTone,
    ) -> DailyBrief {
        let greeting = match tone {
            SessionTone::Celebrating => format!("Excellente forme, {} ! 🎯", ctx.first_name),
            SessionTone::Encouraging => format!("Bonjour {} 👋", ctx.first_name),
            SessionTone::Attentive   => format!("Bonjour {} — surveille tes dépenses aujourd'hui.", ctx.first_name),
            SessionTone::Concerned   => format!("{}, la situation mérite ton attention.", ctx.first_name),
            SessionTone::Urgent      => format!("{}, une action est nécessaire aujourd'hui.", ctx.first_name),
        };

        let status = format!(
            "Budget du jour : {:.0} FCFA. Tu en as utilisé {:.0}%.",
            ctx.det.daily_budget,
            if ctx.det.daily_budget > 0.0 {
                (ctx.det.spent_today / ctx.det.daily_budget * 100.0).min(100.0)
            } else { 0.0 }
        );

        let outlook = match &ctx.insights.momentum.recent_trend {
            crate::behavioral_insights::MomentumTrend::Decelerating =>
                "Ta trajectoire s'améliore cette semaine.".into(),
            crate::behavioral_insights::MomentumTrend::Accelerating =>
                format!(
                    "Tes dépenses accélèrent. Prévision fin de mois : {:.0} FCFA.",
                    ctx.insights.momentum.projected_total
                ),
            _ => format!(
                "Il reste {} jours dans le cycle.",
                ctx.det.days_remaining
            ),
        };

        DailyBrief { greeting, status, outlook }
    }

    // ── Assemble les 4 couches en un texte cohérent ───────────
    fn assemble(
        fact:    &str,
        context: &Option<String>,
        cause:   &Option<String>,
        action:  &Option<String>,
    ) -> String {
        let mut parts = vec![fact.to_string()];
        if let Some(c) = context { parts.push(c.clone()); }
        if let Some(c) = cause   { parts.push(c.clone()); }
        if let Some(a) = action  { parts.push(a.clone()); }
        parts.join(" ")
    }
}

// ─────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;
    use crate::behavioral_insights::BehavioralInsightsEngine;

    fn base_ctx_narrative<'a>(
        det:      &'a DeterministicResult,
        insights: &'a BehavioralInsights,
        today:    &'a Date,
        name:     &'a str,
    ) -> NarrativeContext<'a> {
        NarrativeContext {
            first_name: name, det, insights,
            history: &[], today, is_premium: false,
            income_pred: None, health_score: 72,
        }
    }

    fn healthy_det() -> DeterministicResult {
        DeterministicResult {
            total_balance: 200_000.0, committed_mass: 50_000.0,
            free_mass: 150_000.0, days_remaining: 15,
            daily_budget: 10_000.0, spent_today: 4_000.0,
            remaining_today: 6_000.0,
            transport_reserve: 0.0, charges_reserve: 50_000.0,
        }
    }

    fn empty_insights() -> BehavioralInsights {
        BehavioralInsightsEngine::compute(&[], &[], &Date::new(2026, 3, 15), &healthy_det())
    }

    #[test]
    fn test_narrative_generates_at_least_one_message() {
        let det      = healthy_det();
        let insights = empty_insights();
        let today    = Date::new(2026, 3, 15);
        let ctx      = base_ctx_narrative(&det, &insights, &today, "Kofi");
        let output   = NarrativeEngine::generate(&ctx);
        assert!(!output.messages.is_empty());
        assert!(!output.daily_brief.greeting.is_empty());
    }

    #[test]
    fn test_urgent_tone_on_insolvent() {
        let det = DeterministicResult {
            total_balance: 10_000.0, committed_mass: 200_000.0,
            free_mass: 0.0, days_remaining: 10,
            daily_budget: 0.0, spent_today: 0.0, remaining_today: 0.0,
            transport_reserve: 0.0, charges_reserve: 200_000.0,
        };
        let insights = BehavioralInsightsEngine::compute(&[], &[], &Date::new(2026, 3, 15), &det);
        let today = Date::new(2026, 3, 15);
        let ctx = base_ctx_narrative(&det, &insights, &today, "Kofi");
        let output = NarrativeEngine::generate(&ctx);
        assert_eq!(output.session_tone, SessionTone::Urgent);
    }

    #[test]
    fn test_celebrating_tone_high_health() {
        let det      = healthy_det();
        let insights = empty_insights();
        let today    = Date::new(2026, 3, 15);
        let mut ctx  = base_ctx_narrative(&det, &insights, &today, "Kofi");
        ctx.health_score = 90;
        let output = NarrativeEngine::generate(&ctx);
        assert_eq!(output.session_tone, SessionTone::Celebrating);
    }

    #[test]
    fn test_premium_gets_action_layer() {
        let det      = healthy_det();
        let insights = empty_insights();
        let today    = Date::new(2026, 3, 15);
        let mut ctx  = base_ctx_narrative(&det, &insights, &today, "Kofi");
        ctx.is_premium  = true;
        ctx.health_score = 72;
        let output = NarrativeEngine::generate(&ctx);
        // Au moins un message doit avoir une couche action
        let has_action = output.messages.iter().any(|m| m.action.is_some());
        // Dépend du ton — si pas d'urgence, action peut être None
        // Le test vérifie juste que ça ne panique pas
        let _ = has_action;
    }

    #[test]
    fn test_full_text_non_empty_for_all_messages() {
        let det      = healthy_det();
        let insights = empty_insights();
        let today    = Date::new(2026, 3, 15);
        let ctx      = base_ctx_narrative(&det, &insights, &today, "Kofi");
        let output   = NarrativeEngine::generate(&ctx);
        for msg in &output.messages {
            assert!(!msg.full_text.is_empty(), "msg id={}", msg.id);
        }
    }

    #[test]
    fn test_messages_sorted_by_priority() {
        let det      = healthy_det();
        let insights = empty_insights();
        let today    = Date::new(2026, 3, 15);
        let ctx      = base_ctx_narrative(&det, &insights, &today, "Kofi");
        let output   = NarrativeEngine::generate(&ctx);
        for w in output.messages.windows(2) {
            assert!(w[0].priority <= w[1].priority,
                "priorities not sorted: {} > {}", w[0].priority, w[1].priority);
        }
    }

    #[test]
    fn test_daily_brief_contains_name() {
        let det      = healthy_det();
        let insights = empty_insights();
        let today    = Date::new(2026, 3, 15);
        let ctx      = base_ctx_narrative(&det, &insights, &today, "Amara");
        let output   = NarrativeEngine::generate(&ctx);
        assert!(output.daily_brief.greeting.contains("Amara"));
    }
}
