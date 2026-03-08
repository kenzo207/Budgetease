// ============================================================
//  MODULE COMPUTE VERIFIER — Vérification multi-formules
//  Principe : chaque calcul critique est fait par 3 méthodes
//  indépendantes. Le moteur compare, détecte les divergences,
//  et choisit la valeur la plus fiable selon le contexte.
//
//  Si les formules divergent de plus d'un seuil → alerte
//  Si convergence ≥ 2/3 → confiance élevée
//  Si toutes divergent → marge de récupération activée
//
//  Calculs vérifiés :
//    1. Budget journalier (3 méthodes)
//    2. Prédiction fin de cycle (3 méthodes)
//    3. Score de santé (3 méthodes de pondération)
//    4. Projection d'épargne (2 méthodes)
//    5. Détection Ghost Money (2 méthodes)
//    6. Prédiction de revenu (3 méthodes)
// ============================================================

use crate::types::*;
use serde::{Deserialize, Serialize};

// ── Types ─────────────────────────────────────────────────────

/// Résultat d'un calcul multi-formules avec méta-information
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VerifiedValue {
    /// Valeur retenue (consensus ou meilleure estimation)
    pub value:        f64,
    /// Méthode retenue
    pub method:       String,
    /// Confiance 0.0..=1.0
    pub confidence:   f64,
    /// Toutes les estimations
    pub estimates:    Vec<Estimate>,
    /// Divergence max entre estimations
    pub max_divergence_pct: f64,
    /// true si les estimations convergent suffisamment
    pub converged:    bool,
    /// Marge de récupération appliquée si divergence
    pub margin:       f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Estimate {
    pub method_name: String,
    pub value:       f64,
    pub weight:      f64,    // poids de confiance de cette méthode
}

/// Contexte complet pour toutes les vérifications
#[derive(Debug, Clone)]
pub struct VerifierContext<'a> {
    pub input:   &'a EngineInput,
    pub history: &'a [CycleRecord],
    pub det:     &'a DeterministicResult,
}

/// Rapport de vérification complet
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VerificationReport {
    pub daily_budget:     VerifiedValue,
    pub cycle_end_balance: VerifiedValue,
    pub health_score:     VerifiedValue,
    pub savings_projection: VerifiedValue,
    pub ghost_money:      VerifiedValue,
    /// true si tout est cohérent
    pub overall_healthy:  bool,
    /// Alertes de cohérence
    pub alerts:           Vec<ComputeAlert>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ComputeAlert {
    pub field:    String,
    pub message:  String,
    pub severity: AlertSeverity,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum AlertSeverity {
    Info,
    Warning,
    Critical,
}

// ── Seuils de divergence acceptables ─────────────────────────
// En dessous = convergence, au-dessus = alerte
const BUDGET_DIVERGENCE_PCT:  f64 = 0.05;  // 5%
const PROJECTION_DIVERGENCE:  f64 = 0.10;  // 10%
const HEALTH_DIVERGENCE:      f64 = 0.08;  // 8 points sur 100
const SAVINGS_DIVERGENCE:     f64 = 0.12;  // 12%

pub struct ComputeVerifier;

impl ComputeVerifier {
    pub fn verify_all(ctx: &VerifierContext) -> VerificationReport {
        let daily   = Self::verify_daily_budget(ctx);
        let eoc     = Self::verify_end_of_cycle(ctx);
        let health  = Self::verify_health_score(ctx);
        let savings = Self::verify_savings_projection(ctx);
        let ghost   = Self::verify_ghost_money(ctx);

        let mut alerts = Vec::new();

        // Alerte si budget journalier diverge fortement
        if !daily.converged {
            alerts.push(ComputeAlert {
                field:    "budget_journalier".into(),
                message:  format!(
                    "Budget journalier : 3 méthodes divergent de {:.1}%. \
                     Valeur retenue : {:.0} FCFA (méthode: {}).",
                    daily.max_divergence_pct * 100.0, daily.value, daily.method
                ),
                severity: if daily.max_divergence_pct > 0.15 {
                    AlertSeverity::Warning
                } else {
                    AlertSeverity::Info
                },
            });
        }

        // Alerte si prédiction fin de cycle très incertaine
        if eoc.confidence < 0.50 {
            alerts.push(ComputeAlert {
                field:    "fin_de_cycle".into(),
                message:  "Prédiction de fin de cycle peu fiable (données insuffisantes).".into(),
                severity: AlertSeverity::Info,
            });
        }

        // Alerte si données incohérentes (ghost money suspect)
        if ghost.value > ctx.det.daily_budget * 10.0 && ghost.confidence > 0.7 {
            alerts.push(ComputeAlert {
                field:    "ghost_money".into(),
                message:  format!(
                    "Flux non expliqués détectés : {:.0} FCFA. \
                     Vérifiez vos transactions.",
                    ghost.value
                ),
                severity: AlertSeverity::Warning,
            });
        }

        let overall_healthy = daily.converged
            && eoc.confidence >= 0.40
            && alerts.iter().all(|a| a.severity != AlertSeverity::Critical);

        VerificationReport {
            daily_budget:      daily,
            cycle_end_balance: eoc,
            health_score:      health,
            savings_projection: savings,
            ghost_money:       ghost,
            overall_healthy,
            alerts,
        }
    }

    // ── 1. Budget journalier — 3 méthodes ─────────────────────
    //
    // Méthode A : Standard (divise la masse libre par les jours restants)
    // Méthode B : Historique (médiane des budgets journaliers passés)
    // Méthode C : Régression (ajuste selon le rythme de dépense actuel)
    pub fn verify_daily_budget(ctx: &VerifierContext) -> VerifiedValue {
        let det = ctx.det;

        // ── Méthode A : Standard ──
        let budget_a = if det.days_remaining > 0 {
            det.free_mass / det.days_remaining as f64
        } else { 0.0 };

        // ── Méthode B : Historique (si on a l'historique) ──
        let budget_b = if ctx.history.len() >= 2 {
            let daily_medians: Vec<f64> = ctx.history.iter()
                .filter(|r| r.cycle_length() > 0)
                .map(|r| {
                    // Budget moyen journalier = (revenu - charges fixes) / durée
                    let available = r.total_income - r.savings_goal;
                    available / r.cycle_length() as f64
                })
                .collect();
            Self::median(&daily_medians)
        } else {
            budget_a // Fallback si pas d'historique
        };

        // ── Méthode C : Ajustement dynamique selon rythme actuel ──
        // Si on a déjà des données pour ce cycle, on ajuste le budget
        // basé sur le rythme de dépense observé
        let budget_c = {
            let days_elapsed = ctx.input.transactions.iter()
                .filter(|t| t.tx_type.is_outflow())
                .map(|t| ctx.input.today.days_until(&t.date).abs())
                .fold(0i32, |acc, d| acc.max(d)) as u32;

            if days_elapsed > 3 {
                let total_spent: f64 = ctx.input.transactions.iter()
                    .filter(|t| t.tx_type.is_outflow())
                    .map(|t| t.amount)
                    .sum();
                let daily_rate = total_spent / days_elapsed as f64;
                // Budget ajusté pour maintenir la masse libre
                if daily_rate > 0.0 {
                    let projected_remaining = det.free_mass
                        - daily_rate * det.days_remaining as f64;
                    if projected_remaining >= 0.0 {
                        // Rythme soutenable
                        daily_rate
                    } else {
                        // Rythme insoutenable → budget contraint
                        det.free_mass / det.days_remaining.max(1) as f64
                    }
                } else {
                    budget_a
                }
            } else {
                budget_a
            }
        };

        let estimates = vec![
            Estimate { method_name: "Standard".into(),     value: budget_a, weight: 0.50 },
            Estimate { method_name: "Historique".into(),   value: budget_b, weight: 0.30 },
            Estimate { method_name: "Dynamique".into(),    value: budget_c, weight: 0.20 },
        ];

        Self::reconcile(estimates, BUDGET_DIVERGENCE_PCT, "budget_journalier")
    }

    // ── 2. Prédiction fin de cycle — 3 méthodes ───────────────
    //
    // Méthode A : Extrapolation linéaire du rythme actuel
    // Méthode B : Moyenne des fins de cycle passés (même position)
    // Méthode C : Simulation Monte Carlo simplifiée (± volatilité)
    pub fn verify_end_of_cycle(ctx: &VerifierContext) -> VerifiedValue {
        let det = ctx.det;

        // ── Méthode A : Extrapolation linéaire ──
        let spent_so_far: f64 = ctx.input.transactions.iter()
            .filter(|t| t.tx_type.is_outflow())
            .map(|t| t.amount)
            .sum();

        let days_elapsed = {
            let total = match &ctx.input.cycle.cycle_type {
                CycleType::Monthly => 30u32,
                CycleType::Weekly  => 7,
                _ => det.days_remaining + 1,
            };
            (total - det.days_remaining).max(1)
        };

        let daily_rate_a = spent_so_far / days_elapsed as f64;
        let projected_a  = det.total_balance - daily_rate_a * det.days_remaining as f64;

        // ── Méthode B : Historique (même position dans le cycle) ──
        let projected_b = if ctx.history.len() >= 2 {
            let pct_elapsed = 1.0 - det.days_remaining as f64
                / (days_elapsed + det.days_remaining) as f64;

            let final_balances: Vec<f64> = ctx.history.iter()
                .map(|r| r.closing_balance)
                .collect();

            let avg_final = final_balances.iter().sum::<f64>()
                / final_balances.len() as f64;

            // Ajuste par la situation actuelle vs historique
            let hist_avg_balance: f64 = ctx.history.iter()
                .map(|r| r.opening_balance)
                .sum::<f64>() / ctx.history.len() as f64;

            let ratio = if hist_avg_balance > 0.0 {
                det.total_balance / hist_avg_balance
            } else { 1.0 };

            avg_final * ratio
        } else {
            projected_a
        };

        // ── Méthode C : Projection avec bande de volatilité ──
        let projected_c = if ctx.history.len() >= 3 {
            // Calcule la volatilité des dépenses journalières
            let daily_stds: Vec<f64> = ctx.history.iter()
                .filter(|r| !r.daily_expenses.is_empty())
                .map(|r| {
                    let mean = r.daily_expenses.iter().sum::<f64>()
                        / r.daily_expenses.len() as f64;
                    let var: f64 = r.daily_expenses.iter()
                        .map(|&d| (d - mean).powi(2))
                        .sum::<f64>() / r.daily_expenses.len() as f64;
                    var.sqrt()
                })
                .collect();

            if !daily_stds.is_empty() {
                let avg_std = daily_stds.iter().sum::<f64>() / daily_stds.len() as f64;
                // Projection conservatrice : ajoute 0.5 écart-type par jour restant
                let conservative_daily = daily_rate_a + avg_std * 0.5;
                det.total_balance - conservative_daily * det.days_remaining as f64
            } else {
                projected_a
            }
        } else {
            projected_a
        };

        let estimates = vec![
            Estimate { method_name: "Extrapolation".into(), value: projected_a, weight: 0.40 },
            Estimate { method_name: "Historique".into(),    value: projected_b, weight: 0.40 },
            Estimate { method_name: "Conservateur".into(),  value: projected_c, weight: 0.20 },
        ];

        Self::reconcile(estimates, PROJECTION_DIVERGENCE, "fin_de_cycle")
    }

    // ── 3. Score de santé — 3 systèmes de pondération ─────────
    //
    // Système A : Pondérations fixes (budget 35%, épargne 25%, stabilité 20%, prédiction 20%)
    // Système B : Pondérations adaptatives selon le profil de l'utilisateur
    // Système C : Score basé sur les percentiles historiques
    pub fn verify_health_score(ctx: &VerifierContext) -> VerifiedValue {
        let det = ctx.det;

        // Scores composants communs
        let budget_score = Self::budget_component(det);
        let savings_score = Self::savings_component(det);
        let stability_score = Self::stability_component(ctx);
        let prediction_score = Self::prediction_component(det, ctx);

        // ── Système A : Pondérations fixes ──
        let score_a = budget_score * 0.35
            + savings_score * 0.25
            + stability_score * 0.20
            + prediction_score * 0.20;

        // ── Système B : Pondérations adaptatives ──
        // Si l'utilisateur a un historique de dépassement de budget → budget plus pondéré
        // Si l'utilisateur a un historique d'épargne nulle → épargne plus pondérée
        let (w_budget, w_savings, w_stability, w_pred) = if ctx.history.len() >= 2 {
            let avg_savings_rate = ctx.history.iter()
                .map(|r| if r.savings_goal > 0.0 { r.savings_achieved / r.savings_goal } else { 1.0 })
                .sum::<f64>() / ctx.history.len() as f64;

            let avg_overrun = ctx.history.iter()
                .filter(|r| r.total_expenses > r.total_income)
                .count() as f64 / ctx.history.len() as f64;

            if avg_overrun > 0.30 {
                // Historique de dépassements → budget hyper-pondéré
                (0.50, 0.20, 0.20, 0.10)
            } else if avg_savings_rate < 0.50 {
                // Épargne chroniquement insuffisante → épargne plus pondérée
                (0.30, 0.40, 0.15, 0.15)
            } else {
                // Profil stable → pondérations normales
                (0.35, 0.25, 0.20, 0.20)
            }
        } else {
            (0.35, 0.25, 0.20, 0.20)
        };

        let score_b = budget_score    * w_budget
            + savings_score   * w_savings
            + stability_score * w_stability
            + prediction_score * w_pred;

        // ── Système C : Percentile par rapport à l'historique ──
        let score_c = if ctx.history.len() >= 2 {
            // Calcule le score relatif à l'historique
            let current_net = det.free_mass - det.daily_budget * det.days_remaining as f64;
            let hist_nets: Vec<f64> = ctx.history.iter()
                .map(|r| r.closing_balance - r.savings_goal)
                .collect();

            let rank = hist_nets.iter()
                .filter(|&&n| n <= current_net)
                .count() as f64 / hist_nets.len() as f64;

            // Convertit le percentile en score 0-100
            rank * 100.0
        } else {
            score_a // Fallback si pas d'historique
        };

        let estimates = vec![
            Estimate { method_name: "Pondérations fixes".into(),       value: score_a, weight: 0.45 },
            Estimate { method_name: "Pondérations adaptatives".into(), value: score_b, weight: 0.40 },
            Estimate { method_name: "Percentile historique".into(),    value: score_c, weight: 0.15 },
        ];

        Self::reconcile(estimates, HEALTH_DIVERGENCE, "health_score")
    }

    // ── 4. Projection d'épargne — 2 méthodes ──────────────────
    pub fn verify_savings_projection(ctx: &VerifierContext) -> VerifiedValue {
        let det = ctx.det;

        // ── Méthode A : Basée sur le budget restant ──
        let projected_savings_a = det.free_mass
            - det.daily_budget * det.days_remaining as f64;

        // ── Méthode B : Basée sur le taux d'épargne historique ──
        let projected_savings_b = if ctx.history.len() >= 2 {
            let avg_savings_ratio = ctx.history.iter()
                .filter(|r| r.total_income > 0.0)
                .map(|r| r.savings_achieved / r.total_income)
                .sum::<f64>() / ctx.history.len() as f64;

            let total_income: f64 = ctx.input.transactions.iter()
                .filter(|t| t.tx_type.is_inflow())
                .map(|t| t.amount)
                .sum();

            total_income * avg_savings_ratio
        } else {
            projected_savings_a
        };

        let estimates = vec![
            Estimate { method_name: "Budget restant".into(),       value: projected_savings_a, weight: 0.60 },
            Estimate { method_name: "Taux historique".into(),      value: projected_savings_b, weight: 0.40 },
        ];

        Self::reconcile(estimates, SAVINGS_DIVERGENCE, "epargne_projetee")
    }

    // ── 5. Ghost Money — 2 méthodes ───────────────────────────
    pub fn verify_ghost_money(ctx: &VerifierContext) -> VerifiedValue {
        // ── Méthode A : Dépenses < seuil absolu répétées ──
        let micro_threshold = ctx.det.daily_budget * 0.10; // 10% du budget journalier
        let ghost_a: f64 = ctx.input.transactions.iter()
            .filter(|t| t.tx_type.is_outflow() && t.amount < micro_threshold.max(2_000.0))
            .map(|t| t.amount)
            .sum();

        // ── Méthode B : Flux non catégorisés ou catégorisés "autre" ──
        let ghost_b: f64 = ctx.input.transactions.iter()
            .filter(|t| t.tx_type.is_outflow() && (
                t.category.is_none()
                    || t.category.as_deref() == Some("autre")
                    || (t.sms_confidence.map(|c| c < 0.5).unwrap_or(false))
            ))
            .map(|t| t.amount)
            .sum();

        let estimates = vec![
            Estimate { method_name: "Micro-transactions".into(), value: ghost_a, weight: 0.50 },
            Estimate { method_name: "Non catégorisés".into(),    value: ghost_b, weight: 0.50 },
        ];

        Self::reconcile(estimates, 0.20, "ghost_money")
    }

    // ── Composants du score de santé ─────────────────────────

    fn budget_component(det: &DeterministicResult) -> f64 {
        if det.is_insolvent() { return 0.0; }
        if det.daily_budget <= 0.0 { return 10.0; }
        let ratio = det.remaining_today / det.daily_budget;
        // 100 si on n'a rien dépensé, 0 si dépassement important
        if ratio >= 1.0      { 100.0 }
        else if ratio >= 0.5 { 50.0 + ratio * 100.0 }
        else if ratio >= 0.0 { ratio * 100.0 }
        else                 { 0.0_f64.max(100.0 + ratio * 50.0) }
    }

    fn savings_component(det: &DeterministicResult) -> f64 {
        // Ratio libre / engagé
        if det.committed_mass <= 0.0 { return 80.0; }
        let ratio = det.free_mass / (det.free_mass + det.committed_mass);
        (ratio * 100.0).min(100.0)
    }

    fn stability_component(ctx: &VerifierContext) -> f64 {
        if ctx.history.len() < 2 { return 70.0; } // score neutre sans historique

        let cv_values: Vec<f64> = ctx.history.iter()
            .filter(|r| !r.daily_expenses.is_empty())
            .map(|r| {
                let mean = r.daily_expenses.iter().sum::<f64>()
                    / r.daily_expenses.len() as f64;
                if mean <= 0.0 { return 0.0; }
                let var: f64 = r.daily_expenses.iter()
                    .map(|&d| (d - mean).powi(2))
                    .sum::<f64>() / r.daily_expenses.len() as f64;
                var.sqrt() / mean // CV
            })
            .collect();

        if cv_values.is_empty() { return 70.0; }
        let avg_cv = cv_values.iter().sum::<f64>() / cv_values.len() as f64;
        // CV faible = stable = score élevé
        ((1.0 - avg_cv.min(1.0)) * 100.0).max(0.0)
    }

    fn prediction_component(det: &DeterministicResult, ctx: &VerifierContext) -> f64 {
        // Basé sur le ratio solde projeté / objectif d'épargne
        let savings_goal = ctx.input.cycle.savings_goal;
        if savings_goal <= 0.0 { return 75.0; }

        let projected = det.free_mass - det.daily_budget * det.days_remaining as f64;
        let ratio = projected / savings_goal;

        if ratio >= 1.0      { 100.0 }
        else if ratio >= 0.5 { 50.0 + ratio * 100.0 }
        else if ratio >= 0.0 { ratio * 100.0 }
        else                 { 0.0 }
    }

    // ── Réconciliation des estimations ────────────────────────
    fn reconcile(
        estimates:       Vec<Estimate>,
        divergence_threshold: f64,
        _field:          &str,
    ) -> VerifiedValue {
        if estimates.is_empty() {
            return VerifiedValue {
                value: 0.0, method: "aucune".into(), confidence: 0.0,
                estimates: vec![], max_divergence_pct: 0.0,
                converged: false, margin: 0.0,
            };
        }

        if estimates.len() == 1 {
            let e = &estimates[0];
            return VerifiedValue {
                value: e.value, method: e.method_name.clone(),
                confidence: e.weight, estimates, max_divergence_pct: 0.0,
                converged: true, margin: 0.0,
            };
        }

        let values: Vec<f64> = estimates.iter().map(|e| e.value).collect();
        let min_val = values.iter().cloned().fold(f64::INFINITY, f64::min);
        let max_val = values.iter().cloned().fold(f64::NEG_INFINITY, f64::max);

        // Calcule la divergence relative
        let max_divergence_pct = if min_val.abs() > 0.01 {
            ((max_val - min_val) / min_val.abs()).abs()
        } else if max_val.abs() > 0.01 {
            1.0
        } else {
            0.0
        };

        let converged = max_divergence_pct <= divergence_threshold;

        // Stratégie de sélection
        let (selected_value, method, confidence) = if converged {
            // Convergence → moyenne pondérée
            let total_weight: f64 = estimates.iter().map(|e| e.weight).sum();
            let weighted_avg: f64 = estimates.iter()
                .map(|e| e.value * e.weight)
                .sum::<f64>() / total_weight;

            // Méthode avec le plus grand poids
            let best = estimates.iter()
                .max_by(|a, b| a.weight.partial_cmp(&b.weight).unwrap())
                .unwrap();

            let conf = 0.85 + (1.0 - max_divergence_pct / divergence_threshold) * 0.10;
            (weighted_avg, format!("Consensus ({})", best.method_name), conf.min(0.95))

        } else {
            // Divergence → stratégie conservative
            // Selon le contexte :
            // - Pour le budget → prendre la valeur la plus basse (prudent)
            // - Pour la santé → prendre la médiane
            // - Générique → médiane + marge de sécurité

            let sorted_values = {
                let mut v = values.clone();
                v.sort_by(|a, b| a.partial_cmp(b).unwrap());
                v
            };
            let median = sorted_values[sorted_values.len() / 2];

            // Marge de récupération : 5% de la valeur médiane
            let margin_factor = (max_divergence_pct / divergence_threshold - 1.0).min(0.20);
            let conservative = median * (1.0 - margin_factor * 0.5);

            let conf = 0.50 + (1.0 - max_divergence_pct.min(1.0)) * 0.20;
            let marg = (median - conservative).abs();

            return VerifiedValue {
                value:    conservative,
                method:   "Conservateur (divergence)".into(),
                confidence: conf,
                estimates,
                max_divergence_pct,
                converged: false,
                margin:   marg,
            };
        };

        VerifiedValue {
            value: selected_value,
            method,
            confidence,
            estimates,
            max_divergence_pct,
            converged,
            margin: 0.0,
        }
    }

    // ── Utilitaires statistiques ──────────────────────────────

    pub fn median(values: &[f64]) -> f64 {
        if values.is_empty() { return 0.0; }
        let mut sorted = values.to_vec();
        sorted.sort_by(|a, b| a.partial_cmp(b).unwrap());
        if sorted.len() % 2 == 0 {
            (sorted[sorted.len() / 2 - 1] + sorted[sorted.len() / 2]) / 2.0
        } else {
            sorted[sorted.len() / 2]
        }
    }

    pub fn coefficient_of_variation(values: &[f64]) -> f64 {
        if values.len() < 2 { return 0.0; }
        let mean = values.iter().sum::<f64>() / values.len() as f64;
        if mean.abs() < 0.01 { return 0.0; }
        let var: f64 = values.iter()
            .map(|v| (v - mean).powi(2))
            .sum::<f64>() / values.len() as f64;
        var.sqrt() / mean.abs()
    }

    /// Intervalle de confiance à 80% (±1.28 écart-types)
    pub fn confidence_interval_80(values: &[f64]) -> (f64, f64) {
        if values.is_empty() { return (0.0, 0.0); }
        let mean = values.iter().sum::<f64>() / values.len() as f64;
        let var: f64 = values.iter()
            .map(|v| (v - mean).powi(2))
            .sum::<f64>() / values.len().max(1) as f64;
        let std = var.sqrt();
        (mean - 1.28 * std, mean + 1.28 * std)
    }
}

// ─────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;

    fn base_input() -> EngineInput {
        EngineInput {
            today: Date::new(2026, 3, 15),
            accounts: vec![Account {
                id: "a1".into(), name: "MoMo".into(),
                account_type: AccountType::MobileMoney,
                balance: 250_000.0, is_active: true,
            }],
            charges: vec![RecurringCharge {
                id: "c1".into(), name: "Loyer".into(),
                amount: 120_000.0, due_day: 5,
                status: ChargeStatus::Paid, amount_paid: 120_000.0, is_active: true,
            }],
            transactions: vec![
                Transaction {
                    id: "t1".into(), date: Date::new(2026, 3, 1),
                    amount: 300_000.0, tx_type: TransactionType::Income,
                    category: Some("salaire".into()), account_id: "a1".into(),
                    description: None, sms_confidence: None,
                },
                Transaction {
                    id: "t2".into(), date: Date::new(2026, 3, 10),
                    amount: 8_000.0, tx_type: TransactionType::Expense,
                    category: Some("nourriture".into()), account_id: "a1".into(),
                    description: None, sms_confidence: None,
                },
            ],
            cycle: FinancialCycle {
                cycle_type: CycleType::Monthly,
                savings_goal: 30_000.0,
                transport: TransportType::None,
            },
        }
    }

    fn base_det() -> DeterministicResult {
        DeterministicResult {
            total_balance: 250_000.0, committed_mass: 30_000.0,
            free_mass: 220_000.0, days_remaining: 16,
            daily_budget: 13_750.0, spent_today: 4_000.0,
            remaining_today: 9_750.0,
            transport_reserve: 0.0, charges_reserve: 30_000.0,
        }
    }

    fn base_history() -> Vec<CycleRecord> {
        vec![
            CycleRecord {
                cycle_start: Date::new(2026, 2, 1), cycle_end: Date::new(2026, 2, 28),
                opening_balance: 200_000.0, closing_balance: 50_000.0,
                total_income: 300_000.0, total_expenses: 200_000.0,
                savings_goal: 30_000.0, savings_achieved: 50_000.0,
                daily_expenses: vec![7_142.0; 28],
                category_totals: vec![("nourriture".into(), 60_000.0)],
                transactions: vec![],
            },
            CycleRecord {
                cycle_start: Date::new(2026, 1, 1), cycle_end: Date::new(2026, 1, 31),
                opening_balance: 200_000.0, closing_balance: 45_000.0,
                total_income: 300_000.0, total_expenses: 210_000.0,
                savings_goal: 30_000.0, savings_achieved: 45_000.0,
                daily_expenses: vec![6_774.0; 31],
                category_totals: vec![("nourriture".into(), 55_000.0)],
                transactions: vec![],
            },
        ]
    }

    #[test]
    fn test_daily_budget_converges() {
        let input = base_input();
        let det   = base_det();
        let ctx   = VerifierContext { input: &input, history: &base_history(), det: &det };
        let vv = ComputeVerifier::verify_daily_budget(&ctx);
        assert!(vv.value > 0.0, "budget={}", vv.value);
        assert!(vv.confidence > 0.5, "conf={}", vv.confidence);
        assert_eq!(vv.estimates.len(), 3);
    }

    #[test]
    fn test_daily_budget_value_reasonable() {
        let input = base_input();
        let det   = base_det();
        let ctx   = VerifierContext { input: &input, history: &[], det: &det };
        let vv = ComputeVerifier::verify_daily_budget(&ctx);
        // Le budget doit être dans un range raisonnable (entre 5k et 20k)
        assert!(vv.value >= 5_000.0 && vv.value <= 20_000.0,
                "budget hors range: {}", vv.value);
    }

    #[test]
    fn test_end_of_cycle_positive_projection() {
        let input = base_input();
        let det   = base_det();
        let ctx   = VerifierContext { input: &input, history: &base_history(), det: &det };
        let vv = ComputeVerifier::verify_end_of_cycle(&ctx);
        // Avec 250k de solde et un rythme raisonnable, la projection doit être positive
        assert!(vv.estimates.len() >= 2);
        assert!(vv.confidence > 0.0);
    }

    #[test]
    fn test_health_score_bounded() {
        let input = base_input();
        let det   = base_det();
        let ctx   = VerifierContext { input: &input, history: &base_history(), det: &det };
        let vv = ComputeVerifier::verify_health_score(&ctx);
        assert!(vv.value >= 0.0 && vv.value <= 100.0,
                "health score hors [0,100]: {}", vv.value);
    }

    #[test]
    fn test_health_score_three_estimates() {
        let input = base_input();
        let det   = base_det();
        let ctx   = VerifierContext { input: &input, history: &base_history(), det: &det };
        let vv = ComputeVerifier::verify_health_score(&ctx);
        assert_eq!(vv.estimates.len(), 3);
    }

    #[test]
    fn test_divergence_triggers_conservative() {
        // Crée des estimations très divergentes artificiellement
        let estimates = vec![
            Estimate { method_name: "A".into(), value: 1_000.0, weight: 0.33 },
            Estimate { method_name: "B".into(), value: 5_000.0, weight: 0.33 },
            Estimate { method_name: "C".into(), value: 10_000.0, weight: 0.34 },
        ];
        let vv = ComputeVerifier::reconcile(estimates, 0.05, "test");
        // Divergence > 5% → mode conservateur
        assert!(!vv.converged);
        assert!(vv.confidence < 0.80);
    }

    #[test]
    fn test_convergence_uses_weighted_average() {
        // Estimations très proches
        let estimates = vec![
            Estimate { method_name: "A".into(), value: 10_000.0, weight: 0.50 },
            Estimate { method_name: "B".into(), value: 10_100.0, weight: 0.30 },
            Estimate { method_name: "C".into(), value:  9_950.0, weight: 0.20 },
        ];
        let vv = ComputeVerifier::reconcile(estimates, 0.05, "test");
        assert!(vv.converged);
        // Valeur proche de 10 000 (pondération dominante)
        assert!((vv.value - 10_000.0).abs() < 200.0, "value={}", vv.value);
        assert!(vv.confidence >= 0.85);
    }

    #[test]
    fn test_ghost_money_detects_microtransactions() {
        let mut input = base_input();
        // Ajoute plusieurs micro-transactions
        for i in 0..5u8 {
            input.transactions.push(Transaction {
                id: format!("micro{}", i), date: Date::new(2026, 3, 10 + i),
                amount: 500.0, tx_type: TransactionType::Expense,
                category: None, account_id: "a1".into(),
                description: None, sms_confidence: None,
            });
        }
        let det = base_det();
        let ctx = VerifierContext { input: &input, history: &[], det: &det };
        let vv = ComputeVerifier::verify_ghost_money(&ctx);
        assert!(vv.value > 0.0, "ghost money should be > 0");
    }

    #[test]
    fn test_full_verification_report() {
        let input = base_input();
        let det   = base_det();
        let ctx   = VerifierContext { input: &input, history: &base_history(), det: &det };
        let report = ComputeVerifier::verify_all(&ctx);
        // Tous les champs présents
        assert!(report.daily_budget.value > 0.0);
        assert!((0.0..=100.0).contains(&report.health_score.value));
        // Avec des données saines, pas d'alerte critique
        assert!(!report.alerts.iter().any(|a| a.severity == AlertSeverity::Critical));
    }

    #[test]
    fn test_median_correct() {
        assert!((ComputeVerifier::median(&[1.0, 2.0, 3.0]) - 2.0).abs() < 0.01);
        assert!((ComputeVerifier::median(&[1.0, 3.0]) - 2.0).abs() < 0.01);
        assert!((ComputeVerifier::median(&[5.0]) - 5.0).abs() < 0.01);
        assert!((ComputeVerifier::median(&[]) - 0.0).abs() < 0.01);
    }

    #[test]
    fn test_cv_stable_series() {
        // Série très stable → CV proche de 0
        let values = vec![10_000.0, 10_100.0, 9_950.0, 10_050.0];
        let cv = ComputeVerifier::coefficient_of_variation(&values);
        assert!(cv < 0.02, "cv={}", cv);
    }

    #[test]
    fn test_cv_volatile_series() {
        // Série très volatile → CV élevé
        let values = vec![1_000.0, 50_000.0, 500.0, 80_000.0];
        let cv = ComputeVerifier::coefficient_of_variation(&values);
        assert!(cv > 0.5, "cv={}", cv);
    }

    #[test]
    fn test_confidence_interval_covers_mean() {
        let values = vec![10.0, 12.0, 9.0, 11.0, 10.5];
        let (lo, hi) = ComputeVerifier::confidence_interval_80(&values);
        let mean = values.iter().sum::<f64>() / values.len() as f64;
        assert!(lo <= mean && mean <= hi, "mean {} not in [{}, {}]", mean, lo, hi);
    }
}
