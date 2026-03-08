// ============================================================
//  MODULE CASH TRACKER — Suivi intelligent des espèces
//  Problème : en West Africa, 30-40% des flux passent en cash.
//  Solution : 3 niveaux combinés
//    1. Enveloppe automatique à chaque retrait détecté
//    2. Enveloppes nommées par l'utilisateur
//    3. Solde cash estimé par déduction + taux de couverture
//
//  Flutter ne calcule rien. Il passe les retraits détectés
//  et les dépenses déclarées. Le moteur déduit le reste.
// ============================================================

use crate::types::*;
use serde::{Deserialize, Serialize};

// ── Types propres au module ───────────────────────────────────

/// Une enveloppe cash — créée automatiquement sur retrait
/// ou manuellement par l'utilisateur.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CashEnvelope {
    pub id:           String,
    pub label:        String,
    pub created_at:   Date,
    /// Montant total de l'enveloppe (= montant retiré)
    pub total:        f64,
    /// Montant déclaré comme dépensé dans cette enveloppe
    pub spent:        f64,
    /// Source : retrait automatique ou création manuelle
    pub source:       EnvelopeSource,
    /// Transactions cash liées à cette enveloppe
    pub allocations:  Vec<CashAllocation>,
}

impl CashEnvelope {
    pub fn remaining(&self) -> f64 {
        (self.total - self.spent).max(0.0)
    }

    pub fn coverage_pct(&self) -> f64 {
        if self.total <= 0.0 { return 1.0; }
        (self.spent / self.total).min(1.0)
    }

    pub fn is_exhausted(&self) -> bool {
        self.remaining() < 1.0
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum EnvelopeSource {
    /// Retrait détecté via SMS
    AutoWithdrawal { sms_ref: String },
    /// Créé manuellement par l'utilisateur
    Manual,
    /// Espèces reçues en main propre
    CashReceived,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CashAllocation {
    pub tx_id:    String,
    pub amount:   f64,
    pub category: String,
    pub date:     Date,
    pub label:    Option<String>,
}

/// Entrée du module — tout ce que Flutter passe
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CashTrackerInput {
    /// Enveloppes existantes (depuis SQLite)
    pub envelopes:    Vec<CashEnvelope>,
    /// Toutes les transactions du cycle (pour calculer les flux)
    pub transactions: Vec<Transaction>,
    /// Date du jour
    pub today:        Date,
    /// Résultat déterministe (pour contexte budget)
    pub det:          DeterministicResult,
}

/// État complet du cash — retourné au Flutter
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CashState {
    /// Toutes les enveloppes actives
    pub envelopes:         Vec<CashEnvelopeSummary>,
    /// Cash total retiré ce cycle
    pub total_withdrawn:   f64,
    /// Cash explicitement dépensé (déclaré)
    pub total_accounted:   f64,
    /// Cash non expliqué = retiré - déclaré
    pub unaccounted:       f64,
    /// Taux de couverture 0.0..=1.0
    pub coverage_rate:     f64,
    /// Fiabilité des prédictions selon la couverture
    pub reliability:       CashReliability,
    /// Alertes et suggestions
    pub insights:          Vec<CashInsight>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CashEnvelopeSummary {
    pub id:          String,
    pub label:       String,
    pub total:       f64,
    pub remaining:   f64,
    pub coverage:    f64,   // 0.0..=1.0
    pub created_at:  Date,
    pub days_old:    u32,
    pub is_stale:    bool,  // > 7 jours sans activité
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum CashReliability {
    /// ≥ 80% couvert — prédictions fiables
    High,
    /// 60-79% — prédictions avec réserve
    Medium,
    /// < 60% — prédictions peu fiables
    Low,
    /// Aucun retrait détecté — on ne sait pas
    Unknown,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CashInsight {
    pub level:   AlertLevel,
    pub message: String,
    /// Suggestion d'action pour Flutter
    pub action:  Option<CashAction>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum CashAction {
    /// Demander à l'utilisateur de déclarer ses dépenses cash
    DeclareExpenses { envelope_id: String, suggested_amount: f64 },
    /// Suggérer de créer une enveloppe nommée
    CreateEnvelope  { amount: f64, suggested_label: String },
    /// Enveloppe ancienne — proposer de clôturer
    CloseEnvelope   { envelope_id: String },
}

// ── Moteur principal ──────────────────────────────────────────

pub struct CashTrackerEngine;

impl CashTrackerEngine {
    pub fn compute(input: &CashTrackerInput) -> CashState {
        // ── 1. Calcul des flux cash ───────────────────────────
        let total_withdrawn = Self::total_withdrawals(&input.transactions);
        let total_accounted = Self::total_cash_expenses(&input.transactions, &input.envelopes);

        let unaccounted = (total_withdrawn - total_accounted).max(0.0);

        let coverage_rate = if total_withdrawn > 0.0 {
            (total_accounted / total_withdrawn).min(1.0)
        } else {
            1.0 // pas de retrait = pas de cash non tracké
        };

        let reliability = Self::reliability(coverage_rate, total_withdrawn);

        // ── 2. Résumé des enveloppes ──────────────────────────
        let envelopes = input.envelopes.iter()
            .map(|e| Self::summarize(e, &input.today))
            .collect::<Vec<_>>();

        // ── 3. Insights contextuels ───────────────────────────
        let insights = Self::build_insights(
            &envelopes, coverage_rate, unaccounted,
            total_withdrawn, &input.today, &input.det,
        );

        CashState {
            envelopes,
            total_withdrawn,
            total_accounted,
            unaccounted,
            coverage_rate,
            reliability,
            insights,
        }
    }

    // ── Crée une enveloppe automatique depuis un retrait SMS ──
    pub fn envelope_from_withdrawal(
        tx:    &Transaction,
        today: &Date,
    ) -> CashEnvelope {
        let label = format!("Retrait du {}", today);
        CashEnvelope {
            id:          format!("env_{}", tx.id),
            label,
            created_at:  *today,
            total:       tx.amount,
            spent:       0.0,
            source:      EnvelopeSource::AutoWithdrawal {
                sms_ref: tx.id.clone(),
            },
            allocations: vec![],
        }
    }

    // ── Privé ─────────────────────────────────────────────────

    fn total_withdrawals(transactions: &[Transaction]) -> f64 {
        transactions.iter()
            .filter(|t| matches!(t.tx_type, TransactionType::Withdrawal))
            .map(|t| t.amount)
            .sum()
    }

    fn total_cash_expenses(
        transactions: &[Transaction],
        envelopes:    &[CashEnvelope],
    ) -> f64 {
        // Dépenses explicitement liées à une enveloppe
        let allocated: f64 = envelopes.iter()
            .flat_map(|e| &e.allocations)
            .map(|a| a.amount)
            .sum();

        // Dépenses cash déclarées sans enveloppe (account_type = Cash)
        let unallocated: f64 = transactions.iter()
            .filter(|t| {
                t.tx_type.is_outflow()
                    && t.category.as_deref() == Some("cash")
                    && !envelopes.iter()
                        .any(|e| e.allocations.iter().any(|a| a.tx_id == t.id))
            })
            .map(|t| t.amount)
            .sum();

        allocated + unallocated
    }

    fn reliability(coverage: f64, withdrawn: f64) -> CashReliability {
        if withdrawn <= 0.0  { return CashReliability::Unknown; }
        if coverage >= 0.80  { CashReliability::High   }
        else if coverage >= 0.60 { CashReliability::Medium }
        else                 { CashReliability::Low    }
    }

    fn summarize(e: &CashEnvelope, today: &Date) -> CashEnvelopeSummary {
        let days_old = e.created_at.days_until(today).max(0) as u32;
        let is_stale = days_old > 7 && !e.is_exhausted();
        CashEnvelopeSummary {
            id:         e.id.clone(),
            label:      e.label.clone(),
            total:      e.total,
            remaining:  e.remaining(),
            coverage:   e.coverage_pct(),
            created_at: e.created_at,
            days_old,
            is_stale,
        }
    }

    fn build_insights(
        envelopes:      &[CashEnvelopeSummary],
        coverage_rate:  f64,
        unaccounted:    f64,
        total_withdrawn:f64,
        today:          &Date,
        det:            &DeterministicResult,
    ) -> Vec<CashInsight> {
        let mut insights = Vec::new();

        // ── Faible couverture ─────────────────────────────────
        if total_withdrawn > 0.0 && coverage_rate < 0.60 {
            insights.push(CashInsight {
                level: AlertLevel::Warning,
                message: format!(
                    "{:.0} FCFA retirés ne sont pas expliqués. \
                     Tes prédictions sont moins précises.",
                    unaccounted
                ),
                action: None,
            });
        }

        // ── Enveloppes anciennes avec solde restant ───────────
        for env in envelopes.iter().filter(|e| e.is_stale) {
            insights.push(CashInsight {
                level: AlertLevel::Info,
                message: format!(
                    "Tu as retiré {:.0} FCFA il y a {} jours. \
                     Il en reste ~{:.0} non déclarés.",
                    env.total, env.days_old, env.remaining
                ),
                action: Some(CashAction::DeclareExpenses {
                    envelope_id:      env.id.clone(),
                    suggested_amount: env.remaining,
                }),
            });
        }

        // ── Cash non alloué important ─────────────────────────
        if unaccounted > det.daily_budget * 3.0 && total_withdrawn > 0.0 {
            insights.push(CashInsight {
                level: AlertLevel::Warning,
                message: format!(
                    "{:.0} FCFA en cash ne sont pas alloués. \
                     Veux-tu créer une enveloppe pour mieux suivre ?",
                    unaccounted
                ),
                action: Some(CashAction::CreateEnvelope {
                    amount:           unaccounted,
                    suggested_label:  "Dépenses diverses".into(),
                }),
            });
        }

        // ── Bonne couverture → encouragement ─────────────────
        if total_withdrawn > 0.0 && coverage_rate >= 0.90 {
            insights.push(CashInsight {
                level: AlertLevel::Positive,
                message: "Excellent suivi de tes espèces ce mois — 90%+ déclarés.".into(),
                action: None,
            });
        }

        insights
    }
}

// ─────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;

    fn base_det() -> DeterministicResult {
        DeterministicResult {
            total_balance: 200_000.0, committed_mass: 50_000.0,
            free_mass: 150_000.0, days_remaining: 15,
            daily_budget: 10_000.0, spent_today: 3_000.0,
            remaining_today: 7_000.0,
            transport_reserve: 0.0, charges_reserve: 50_000.0,
        }
    }

    fn withdrawal_tx(id: &str, amount: f64) -> Transaction {
        Transaction {
            id: id.into(), date: Date::new(2026, 3, 1),
            amount, tx_type: TransactionType::Withdrawal,
            category: None, account_id: "a1".into(),
            description: None, sms_confidence: Some(0.95),
        }
    }

    #[test]
    fn test_no_withdrawals_high_reliability() {
        let input = CashTrackerInput {
            envelopes: vec![], transactions: vec![],
            today: Date::new(2026, 3, 15), det: base_det(),
        };
        let state = CashTrackerEngine::compute(&input);
        assert_eq!(state.reliability, CashReliability::Unknown);
        assert_eq!(state.total_withdrawn, 0.0);
        assert!((state.coverage_rate - 1.0).abs() < 0.01);
    }

    #[test]
    fn test_withdrawal_creates_unaccounted_cash() {
        let input = CashTrackerInput {
            envelopes:    vec![],
            transactions: vec![withdrawal_tx("w1", 50_000.0)],
            today:        Date::new(2026, 3, 10),
            det:          base_det(),
        };
        let state = CashTrackerEngine::compute(&input);
        assert!((state.total_withdrawn - 50_000.0).abs() < 0.01);
        assert!((state.unaccounted - 50_000.0).abs() < 0.01);
        assert_eq!(state.reliability, CashReliability::Low);
    }

    #[test]
    fn test_envelope_from_withdrawal() {
        let tx = withdrawal_tx("w1", 30_000.0);
        let env = CashTrackerEngine::envelope_from_withdrawal(&tx, &Date::new(2026, 3, 5));
        assert!((env.total - 30_000.0).abs() < 0.01);
        assert!((env.remaining() - 30_000.0).abs() < 0.01);
        assert!(!env.is_exhausted());
    }

    #[test]
    fn test_stale_envelope_generates_insight() {
        let env = CashEnvelope {
            id: "e1".into(), label: "Retrait du 2026-03-01".into(),
            created_at: Date::new(2026, 3, 1),
            total: 40_000.0, spent: 5_000.0,
            source: EnvelopeSource::Manual, allocations: vec![],
        };
        let input = CashTrackerInput {
            envelopes:    vec![env],
            transactions: vec![withdrawal_tx("w1", 40_000.0)],
            today:        Date::new(2026, 3, 15),
            det:          base_det(),
        };
        let state = CashTrackerEngine::compute(&input);
        assert!(state.envelopes[0].is_stale);
        assert!(state.insights.iter().any(|i| matches!(
            &i.action,
            Some(CashAction::DeclareExpenses { .. })
        )));
    }

    #[test]
    fn test_high_coverage_positive_insight() {
        // Retrait 10k, 9.5k déclaré via allocations
        let env = CashEnvelope {
            id: "e1".into(), label: "Marché".into(),
            created_at: Date::new(2026, 3, 14),
            total: 10_000.0, spent: 9_500.0,
            source: EnvelopeSource::Manual,
            allocations: vec![CashAllocation {
                tx_id: "t1".into(), amount: 9_500.0,
                category: "nourriture".into(),
                date: Date::new(2026, 3, 14), label: None,
            }],
        };
        let input = CashTrackerInput {
            envelopes:    vec![env],
            transactions: vec![withdrawal_tx("w1", 10_000.0)],
            today:        Date::new(2026, 3, 15),
            det:          base_det(),
        };
        let state = CashTrackerEngine::compute(&input);
        assert_eq!(state.reliability, CashReliability::High);
        assert!(state.insights.iter().any(|i| i.level == AlertLevel::Positive));
    }

    #[test]
    fn test_coverage_rate_clamped() {
        let state = CashTrackerEngine::compute(&CashTrackerInput {
            envelopes: vec![], transactions: vec![],
            today: Date::new(2026, 3, 15), det: base_det(),
        });
        assert!((0.0..=1.0).contains(&state.coverage_rate));
    }
}
