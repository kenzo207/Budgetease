// ============================================================
//  MODULE SCENARIO ENGINE — Simulation de scénarios financiers
//  "Et si je réduisais mes dépenses restaurant de 30% ?"
//  "Et si j'ajoutais un abonnement à 15 000 FCFA/mois ?"
//  "Je veux 200 000 FCFA d'ici 6 mois — comment ?"
//
//  Le moteur calcule toutes les implications :
//  impact sur le budget, sur l'épargne, sur la faisabilité.
//  Fonctionnalité Premium — différenciante et engouement garanti.
// ============================================================

use crate::types::*;
use serde::{Deserialize, Serialize};

// ── Types ─────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ScenarioRequest {
    /// "Et si je réduisais [catégorie] de [pct]% ?"
    ReduceCategory {
        category:     String,
        reduce_by_pct: f64,  // 0.0..=1.0
    },
    /// "Et si j'ajoutais une charge de [montant]/mois ?"
    AddCharge {
        name:   String,
        amount: f64,
    },
    /// "Et si j'augmentais mon épargne à [montant]/mois ?"
    IncreaseSavings {
        new_monthly_goal: f64,
    },
    /// "Je veux [target] FCFA d'ici [months] mois — c'est faisable ?"
    ReachGoal {
        target_amount:  f64,
        months:         u32,
    },
    /// "Et si je recevais [montant] de plus par mois ?"
    IncreaseIncome {
        additional_monthly: f64,
    },
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScenarioResult {
    pub request:          ScenarioRequest,
    /// Résumé en une phrase
    pub headline:         String,
    /// Détail chiffré
    pub details:          Vec<ScenarioDetail>,
    /// Impact mensuel net (positif = économie/gain)
    pub monthly_impact:   f64,
    /// Impact annuel
    pub annual_impact:    f64,
    /// Faisabilité estimée 0.0..=1.0
    pub feasibility:      f64,
    /// Niveau d'opportunité
    pub opportunity:      OpportunityLevel,
    /// Plan d'action concret
    pub action_plan:      Vec<String>,
    /// Comparaison : situation actuelle vs avec ce scénario
    pub comparison:       ScenarioComparison,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScenarioDetail {
    pub label: String,
    pub value: String,
    pub delta: Option<f64>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum OpportunityLevel {
    /// Fort impact positif, facile à mettre en place
    HighValue,
    /// Bon impact, effort modéré
    GoodValue,
    /// Impact limité ou effort important
    LowValue,
    /// Non recommandé
    NotRecommended,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScenarioComparison {
    pub current_daily_budget:   f64,
    pub scenario_daily_budget:  f64,
    pub current_monthly_savings: f64,
    pub scenario_monthly_savings: f64,
    pub budget_change_pct:      f64,
}

/// Contexte nécessaire pour simuler
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScenarioContext {
    pub det:         DeterministicResult,
    pub history:     Vec<CycleRecord>,
    pub today:       Date,
    pub first_name:  String,
}

// ── Moteur ────────────────────────────────────────────────────

pub struct ScenarioEngine;

impl ScenarioEngine {
    pub fn simulate(request: &ScenarioRequest, ctx: &ScenarioContext) -> ScenarioResult {
        match request {
            ScenarioRequest::ReduceCategory { category, reduce_by_pct } =>
                Self::sim_reduce_category(category, *reduce_by_pct, ctx, request),
            ScenarioRequest::AddCharge { name, amount } =>
                Self::sim_add_charge(name, *amount, ctx, request),
            ScenarioRequest::IncreaseSavings { new_monthly_goal } =>
                Self::sim_increase_savings(*new_monthly_goal, ctx, request),
            ScenarioRequest::ReachGoal { target_amount, months } =>
                Self::sim_reach_goal(*target_amount, *months, ctx, request),
            ScenarioRequest::IncreaseIncome { additional_monthly } =>
                Self::sim_increase_income(*additional_monthly, ctx, request),
        }
    }

    // ── Scénario 1 : réduire une catégorie ───────────────────
    fn sim_reduce_category(
        category:      &str,
        reduce_pct:    f64,
        ctx:           &ScenarioContext,
        request:       &ScenarioRequest,
    ) -> ScenarioResult {
        // Calcule la dépense moyenne mensuelle dans cette catégorie
        let avg_monthly = if ctx.history.is_empty() {
            0.0
        } else {
            let totals: Vec<f64> = ctx.history.iter()
                .map(|r| {
                    r.category_totals.iter()
                        .find(|(c, _)| c == category)
                        .map(|(_, a)| *a)
                        .unwrap_or(0.0)
                })
                .collect();
            totals.iter().sum::<f64>() / totals.len() as f64
        };

        let monthly_saving = avg_monthly * reduce_pct;
        let annual_saving  = monthly_saving * 12.0;
        let reduce_pct_display = (reduce_pct * 100.0) as u32;

        // Impact sur le budget journalier
        let days = ctx.det.days_remaining.max(1) as f64;
        let new_daily = ctx.det.daily_budget + (monthly_saving / 30.0);
        let budget_change_pct = if ctx.det.daily_budget > 0.0 {
            monthly_saving / 30.0 / ctx.det.daily_budget
        } else { 0.0 };

        let feasibility = if reduce_pct <= 0.20 { 0.90 }
                          else if reduce_pct <= 0.40 { 0.70 }
                          else { 0.45 };

        let headline = format!(
            "Réduire {} de {}% = +{:.0} FCFA/mois de liberté.",
            category, reduce_pct_display, monthly_saving
        );

        let action_plan = vec![
            format!("Fixe-toi un budget de {:.0} FCFA/mois pour {}.",
                    avg_monthly * (1.0 - reduce_pct), category),
            format!("Soit {:.0} FCFA/semaine maximum.", avg_monthly * (1.0 - reduce_pct) / 4.0),
            "Active les notifications de catégorie dans Zolt pour suivre en temps réel.".into(),
        ];

        ScenarioResult {
            request: request.clone(),
            headline,
            details: vec![
                ScenarioDetail {
                    label: "Économie mensuelle".into(),
                    value: format!("{:.0} FCFA", monthly_saving),
                    delta: Some(monthly_saving),
                },
                ScenarioDetail {
                    label: "Économie annuelle".into(),
                    value: format!("{:.0} FCFA", annual_saving),
                    delta: Some(annual_saving),
                },
                ScenarioDetail {
                    label: "Nouveau budget journalier".into(),
                    value: format!("{:.0} FCFA/jour", new_daily),
                    delta: Some(new_daily - ctx.det.daily_budget),
                },
                ScenarioDetail {
                    label: "Faisabilité".into(),
                    value: format!("{:.0}%", feasibility * 100.0),
                    delta: None,
                },
            ],
            monthly_impact: monthly_saving,
            annual_impact:  annual_saving,
            feasibility,
            opportunity: if monthly_saving > 20_000.0 { OpportunityLevel::HighValue }
                         else if monthly_saving > 5_000.0 { OpportunityLevel::GoodValue }
                         else { OpportunityLevel::LowValue },
            action_plan,
            comparison: ScenarioComparison {
                current_daily_budget:    ctx.det.daily_budget,
                scenario_daily_budget:   new_daily,
                current_monthly_savings: ctx.det.free_mass - ctx.det.daily_budget * 30.0,
                scenario_monthly_savings: ctx.det.free_mass - ctx.det.daily_budget * 30.0 + monthly_saving,
                budget_change_pct,
            },
        }
    }

    // ── Scénario 2 : ajouter une charge ──────────────────────
    fn sim_add_charge(
        name:    &str,
        amount:  f64,
        ctx:     &ScenarioContext,
        request: &ScenarioRequest,
    ) -> ScenarioResult {
        let daily_impact   = amount / 30.0;
        let new_daily      = (ctx.det.daily_budget - daily_impact).max(0.0);
        let budget_loss_pct = if ctx.det.daily_budget > 0.0 {
            daily_impact / ctx.det.daily_budget
        } else { 1.0 };

        // Mois les plus risqués (où les charges existantes sont déjà lourdes)
        let risky_months: Vec<String> = ctx.history.iter()
            .filter(|r| r.savings_achieved < 0.0)
            .map(|r| format!("{}/{}", r.cycle_start.month, r.cycle_start.year))
            .take(2)
            .collect();

        let headline = format!(
            "{} à {:.0} FCFA/mois réduirait ton budget journalier de {:.0} FCFA.",
            name, amount, daily_impact
        );

        let recommendation = if budget_loss_pct < 0.05 {
            "Cela reste gérable — tu peux l'absorber.".into()
        } else if budget_loss_pct < 0.15 {
            "Impact modéré. Compense en réduisant une autre catégorie.".into()
        } else {
            "Impact significatif. Bien réfléchir avant de s'engager.".into()
        };

        let feasibility = if budget_loss_pct < 0.10 { 0.85 }
                          else if budget_loss_pct < 0.20 { 0.65 }
                          else { 0.40 };

        ScenarioResult {
            request: request.clone(),
            headline,
            details: vec![
                ScenarioDetail {
                    label: "Coût mensuel".into(),
                    value: format!("{:.0} FCFA/mois", amount),
                    delta: Some(-amount),
                },
                ScenarioDetail {
                    label: "Impact sur budget journalier".into(),
                    value: format!("-{:.0} FCFA/jour", daily_impact),
                    delta: Some(-daily_impact),
                },
                ScenarioDetail {
                    label: "Nouveau budget journalier".into(),
                    value: format!("{:.0} FCFA/jour", new_daily),
                    delta: None,
                },
                ScenarioDetail {
                    label: "Recommandation".into(),
                    value: recommendation,
                    delta: None,
                },
            ],
            monthly_impact: -amount,
            annual_impact:  -amount * 12.0,
            feasibility,
            opportunity: if budget_loss_pct < 0.05 { OpportunityLevel::GoodValue }
                         else if budget_loss_pct < 0.15 { OpportunityLevel::LowValue }
                         else { OpportunityLevel::NotRecommended },
            action_plan: vec![
                format!("Si tu ajoutes {}, compense {:.0} FCFA/mois ailleurs.", name, amount),
                "Identifie la catégorie où tu peux économiser ce montant.".into(),
            ],
            comparison: ScenarioComparison {
                current_daily_budget:    ctx.det.daily_budget,
                scenario_daily_budget:   new_daily,
                current_monthly_savings: ctx.det.free_mass,
                scenario_monthly_savings: (ctx.det.free_mass - amount).max(0.0),
                budget_change_pct:       -budget_loss_pct,
            },
        }
    }

    // ── Scénario 3 : augmenter l'épargne ─────────────────────
    fn sim_increase_savings(
        new_goal: f64,
        ctx:      &ScenarioContext,
        request:  &ScenarioRequest,
    ) -> ScenarioResult {
        let current_savings = ctx.history.iter()
            .map(|r| r.savings_achieved)
            .sum::<f64>()
            / ctx.history.len().max(1) as f64;

        let additional = (new_goal - current_savings).max(0.0);
        let annual_extra = additional * 12.0;
        let daily_impact = additional / 30.0;
        let new_daily = (ctx.det.daily_budget - daily_impact).max(0.0);

        // Faisabilité basée sur l'historique
        let max_saved = ctx.history.iter()
            .map(|r| r.savings_achieved)
            .fold(f64::NEG_INFINITY, f64::max);
        let feasibility = if new_goal <= max_saved { 0.90 }
                          else if new_goal <= max_saved * 1.3 { 0.70 }
                          else { 0.45 };

        let headline = format!(
            "Épargner {:.0} FCFA/mois = {:.0} FCFA de plus en fin d'année.",
            new_goal, annual_extra
        );

        ScenarioResult {
            request: request.clone(),
            headline,
            details: vec![
                ScenarioDetail {
                    label: "Épargne supplémentaire/mois".into(),
                    value: format!("+{:.0} FCFA", additional),
                    delta: Some(additional),
                },
                ScenarioDetail {
                    label: "Épargne annuelle totale".into(),
                    value: format!("{:.0} FCFA", new_goal * 12.0),
                    delta: Some(annual_extra),
                },
                ScenarioDetail {
                    label: "Nouveau budget journalier".into(),
                    value: format!("{:.0} FCFA", new_daily),
                    delta: Some(new_daily - ctx.det.daily_budget),
                },
                ScenarioDetail {
                    label: "Ton record actuel".into(),
                    value: format!("{:.0} FCFA épargné en un mois", max_saved.max(0.0)),
                    delta: None,
                },
            ],
            monthly_impact: -additional,
            annual_impact:  annual_extra,
            feasibility,
            opportunity: OpportunityLevel::HighValue,
            action_plan: vec![
                format!("Vire {:.0} FCFA dès réception du salaire (automatisme).", new_goal),
                "Traite l'épargne comme une charge fixe, pas comme le reste.".into(),
                format!("Budget quotidien cible : {:.0} FCFA.", new_daily),
            ],
            comparison: ScenarioComparison {
                current_daily_budget:    ctx.det.daily_budget,
                scenario_daily_budget:   new_daily,
                current_monthly_savings: current_savings,
                scenario_monthly_savings: new_goal,
                budget_change_pct:       if ctx.det.daily_budget > 0.0 {
                    -daily_impact / ctx.det.daily_budget
                } else { 0.0 },
            },
        }
    }

    // ── Scénario 4 : atteindre un objectif ───────────────────
    fn sim_reach_goal(
        target:  f64,
        months:  u32,
        ctx:     &ScenarioContext,
        request: &ScenarioRequest,
    ) -> ScenarioResult {
        let monthly_needed = target / months as f64;
        let daily_needed   = monthly_needed / 30.0;
        let daily_reduction = daily_needed; // doit économiser ça/jour de plus
        let new_daily = (ctx.det.daily_budget - daily_needed).max(0.0);

        let avg_income: f64 = if ctx.history.is_empty() { 0.0 } else {
            ctx.history.iter().map(|r| r.total_income).sum::<f64>()
                / ctx.history.len() as f64
        };
        let avg_expenses: f64 = if ctx.history.is_empty() { 0.0 } else {
            ctx.history.iter().map(|r| r.total_expenses).sum::<f64>()
                / ctx.history.len() as f64
        };
        let current_margin = (avg_income - avg_expenses).max(0.0);

        let feasibility = if monthly_needed <= current_margin * 0.5 { 0.90 }
                          else if monthly_needed <= current_margin * 0.8 { 0.72 }
                          else if monthly_needed <= current_margin      { 0.55 }
                          else { 0.30 };

        // Calcule où couper pour économiser monthly_needed
        let cuts = Self::suggest_cuts(monthly_needed, ctx);

        let headline = format!(
            "{:.0} FCFA en {} mois = {:.0} FCFA/mois à économiser.",
            target, months, monthly_needed
        );

        let mut details = vec![
            ScenarioDetail {
                label: "Économie nécessaire/mois".into(),
                value: format!("{:.0} FCFA", monthly_needed),
                delta: Some(-monthly_needed),
            },
            ScenarioDetail {
                label: "Économie nécessaire/jour".into(),
                value: format!("{:.0} FCFA", daily_needed),
                delta: Some(-daily_needed),
            },
            ScenarioDetail {
                label: "Nouveau budget journalier".into(),
                value: format!("{:.0} FCFA", new_daily),
                delta: None,
            },
            ScenarioDetail {
                label: "Faisabilité selon ton historique".into(),
                value: format!("{:.0}%", feasibility * 100.0),
                delta: None,
            },
        ];

        for (cat, cut) in &cuts {
            details.push(ScenarioDetail {
                label: format!("Réduire {}", cat),
                value: format!("-{:.0} FCFA/mois", cut),
                delta: Some(-cut),
            });
        }

        ScenarioResult {
            request: request.clone(),
            headline,
            details,
            monthly_impact: -monthly_needed,
            annual_impact:  -monthly_needed * 12.0,
            feasibility,
            opportunity: if feasibility >= 0.70 { OpportunityLevel::HighValue }
                         else if feasibility >= 0.50 { OpportunityLevel::GoodValue }
                         else { OpportunityLevel::LowValue },
            action_plan: vec![
                format!("Mets de côté {:.0} FCFA dès le 1er du mois.", monthly_needed),
                format!("Budget quotidien : {:.0} FCFA (au lieu de {:.0} FCFA).",
                        new_daily, ctx.det.daily_budget),
                if feasibility < 0.55 {
                    "L'objectif est ambitieux. Envisage de l'étendre à {} mois.".into()
                } else {
                    "Tu as les moyens d'y arriver selon ton historique.".into()
                },
            ],
            comparison: ScenarioComparison {
                current_daily_budget:    ctx.det.daily_budget,
                scenario_daily_budget:   new_daily,
                current_monthly_savings: current_margin,
                scenario_monthly_savings: current_margin - monthly_needed,
                budget_change_pct:       if ctx.det.daily_budget > 0.0 {
                    -daily_needed / ctx.det.daily_budget
                } else { 0.0 },
            },
        }
    }

    // ── Scénario 5 : augmenter les revenus ───────────────────
    fn sim_increase_income(
        additional: f64,
        ctx:        &ScenarioContext,
        request:    &ScenarioRequest,
    ) -> ScenarioResult {
        let daily_gain    = additional / 30.0;
        let new_daily     = ctx.det.daily_budget + daily_gain;
        let annual_gain   = additional * 12.0;

        let headline = format!(
            "+{:.0} FCFA/mois = +{:.0} FCFA/jour et +{:.0} FCFA épargnés/an.",
            additional, daily_gain, annual_gain
        );

        ScenarioResult {
            request: request.clone(),
            headline,
            details: vec![
                ScenarioDetail {
                    label: "Gain mensuel".into(),
                    value: format!("+{:.0} FCFA", additional),
                    delta: Some(additional),
                },
                ScenarioDetail {
                    label: "Gain annuel".into(),
                    value: format!("+{:.0} FCFA", annual_gain),
                    delta: Some(annual_gain),
                },
                ScenarioDetail {
                    label: "Nouveau budget journalier".into(),
                    value: format!("{:.0} FCFA", new_daily),
                    delta: Some(daily_gain),
                },
            ],
            monthly_impact: additional,
            annual_impact:  annual_gain,
            feasibility:    0.50, // dépend de l'utilisateur
            opportunity:    OpportunityLevel::HighValue,
            action_plan: vec![
                "Identifie une source de revenu secondaire stable.".into(),
                format!("Avec +{:.0} FCFA/mois, tu atteins ton objectif d'épargne en moins de temps.", additional),
            ],
            comparison: ScenarioComparison {
                current_daily_budget:    ctx.det.daily_budget,
                scenario_daily_budget:   new_daily,
                current_monthly_savings: ctx.det.free_mass,
                scenario_monthly_savings: ctx.det.free_mass + additional,
                budget_change_pct:       if ctx.det.daily_budget > 0.0 {
                    daily_gain / ctx.det.daily_budget
                } else { 0.0 },
            },
        }
    }

    // ── Aide : où couper pour atteindre un objectif ──────────
    fn suggest_cuts(target: f64, ctx: &ScenarioContext) -> Vec<(String, f64)> {
        if ctx.history.is_empty() { return vec![]; }

        // Catégories triées par montant décroissant (hors loyer/charges fixes)
        let skip = ["loyer", "électricité", "eau", "salaire"];
        let mut cat_avgs: Vec<(String, f64)> = {
            let mut map: std::collections::HashMap<String, Vec<f64>> =
                std::collections::HashMap::new();
            for r in &ctx.history {
                for (cat, amt) in &r.category_totals {
                    if !skip.contains(&cat.as_str()) {
                        map.entry(cat.clone()).or_default().push(*amt);
                    }
                }
            }
            map.into_iter()
                .map(|(cat, amounts)| {
                    let avg = amounts.iter().sum::<f64>() / amounts.len() as f64;
                    (cat, avg)
                })
                .collect()
        };
        cat_avgs.sort_by(|a, b| b.1.partial_cmp(&a.1).unwrap());

        // Sélectionne les catégories pour couvrir target avec -20% chacune
        let mut cuts = Vec::new();
        let mut covered = 0f64;
        for (cat, avg) in &cat_avgs {
            if covered >= target { break; }
            let cut = avg * 0.20;
            covered += cut;
            cuts.push((cat.clone(), cut));
        }
        cuts
    }
}

// ─────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;

    fn base_ctx() -> ScenarioContext {
        ScenarioContext {
            det: DeterministicResult {
                total_balance: 200_000.0, committed_mass: 50_000.0,
                free_mass: 150_000.0, days_remaining: 15,
                daily_budget: 10_000.0, spent_today: 3_000.0,
                remaining_today: 7_000.0,
                transport_reserve: 0.0, charges_reserve: 50_000.0,
            },
            history: vec![
                CycleRecord {
                    cycle_start: Date::new(2026, 2, 1),
                    cycle_end: Date::new(2026, 2, 28),
                    total_income: 300_000.0, total_expenses: 220_000.0,
                    savings_goal: 30_000.0, savings_achieved: 40_000.0,
                    opening_balance: 0.0, closing_balance: 40_000.0,
                    daily_expenses: vec![7_857.0; 28],
                    category_totals: vec![
                        ("nourriture".into(), 60_000.0),
                        ("transport".into(), 30_000.0),
                        ("loisirs".into(), 25_000.0),
                        ("loyer".into(), 120_000.0),
                    ],
                    transactions: vec![],
                },
            ],
            today: Date::new(2026, 3, 15),
            first_name: "Kofi".into(),
        }
    }

    #[test]
    fn test_reduce_category_positive_impact() {
        let req = ScenarioRequest::ReduceCategory {
            category: "loisirs".into(),
            reduce_by_pct: 0.30,
        };
        let result = ScenarioEngine::simulate(&req, &base_ctx());
        assert!(result.monthly_impact > 0.0);
        assert!(result.annual_impact > result.monthly_impact);
        assert!((0.0..=1.0).contains(&result.feasibility));
        assert!(!result.headline.is_empty());
    }

    #[test]
    fn test_add_charge_negative_impact() {
        let req = ScenarioRequest::AddCharge {
            name: "Netflix".into(), amount: 10_000.0,
        };
        let result = ScenarioEngine::simulate(&req, &base_ctx());
        assert!(result.monthly_impact < 0.0);
        assert!(result.comparison.scenario_daily_budget < result.comparison.current_daily_budget);
    }

    #[test]
    fn test_reach_goal_feasibility_high() {
        // Objectif atteignable : 50 000 FCFA en 4 mois = 12 500/mois
        // Historique montre 40 000 d'épargne/mois → faisable
        let req = ScenarioRequest::ReachGoal {
            target_amount: 50_000.0, months: 4,
        };
        let result = ScenarioEngine::simulate(&req, &base_ctx());
        assert!(result.feasibility >= 0.50, "feasibility={}", result.feasibility);
        assert!(!result.details.is_empty());
    }

    #[test]
    fn test_reach_goal_action_plan_not_empty() {
        let req = ScenarioRequest::ReachGoal {
            target_amount: 200_000.0, months: 6,
        };
        let result = ScenarioEngine::simulate(&req, &base_ctx());
        assert!(!result.action_plan.is_empty());
    }

    #[test]
    fn test_increase_income_positive() {
        let req = ScenarioRequest::IncreaseIncome {
            additional_monthly: 50_000.0,
        };
        let result = ScenarioEngine::simulate(&req, &base_ctx());
        assert!(result.monthly_impact > 0.0);
        assert!(result.comparison.scenario_daily_budget > result.comparison.current_daily_budget);
    }

    #[test]
    fn test_increase_savings_feasibility() {
        let req = ScenarioRequest::IncreaseSavings {
            new_monthly_goal: 60_000.0,
        };
        let result = ScenarioEngine::simulate(&req, &base_ctx());
        assert!((0.0..=1.0).contains(&result.feasibility));
        assert!(result.annual_impact.abs() > result.monthly_impact.abs());
    }

    #[test]
    fn test_large_charge_not_recommended() {
        let req = ScenarioRequest::AddCharge {
            name: "Grosse charge".into(), amount: 200_000.0,
        };
        let result = ScenarioEngine::simulate(&req, &base_ctx());
        assert_eq!(result.opportunity, OpportunityLevel::NotRecommended);
    }
}
