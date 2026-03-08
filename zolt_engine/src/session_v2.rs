// ============================================================
//  SESSION ENGINE v1.4.0 — Orchestration complète
//  Un seul appel FFI → tout l'état de l'app.
//
//  Flutter fait :
//    1. Lit SQLite → construit SessionInputV2
//    2. Appelle zolt_session_v2(input_json)
//    3. Reçoit SessionStateV2 JSON → affiche
//
//  Aucune logique dans Flutter. Le moteur décide tout.
//
//  Ordre d'exécution :
//    1. Intégrité des données
//    2. Calcul déterministe
//    3. Moteur adaptatif
//    4. Prédiction de revenu
//    5. Score de santé
//    6. État du cycle
//    7. Suivi des charges
//    8. Triage SMS
//    9. Cash tracker  ← NEW
//   10. Behavioral insights  ← NEW
//   11. Narrative engine  ← NEW (remplace Surface)
//   12. Notifications
//   13. Assemblage SessionStateV2
// ============================================================

use crate::types::*;
use crate::deterministic::DeterministicEngine;
use crate::adaptive::AdaptiveEngine;
use crate::analytics::AnalyticsEngine;
use crate::health_score::HealthScoreEngine;
use crate::triage_scorer::TriageScorerEngine;
use crate::cycle_detector::CycleDetectorEngine;
use crate::income_predictor::IncomePredictorEngine;
use crate::notifications::NotificationsEngine;
use crate::ops::{ChargeTrackerEngine, DataIntegrityEngine};
use crate::cash_tracker::{CashTrackerEngine, CashTrackerInput};
use crate::behavioral_insights::BehavioralInsightsEngine;
use crate::narrative_engine::{NarrativeEngine, NarrativeContext};
use crate::compute_verifier::{ComputeVerifier, VerificationReport, VerifierContext};
use crate::credit_score::{CreditScoreEngine, CreditScoreResult};
use crate::tight_month::{TightMonthEngine, TightMonthResult, WidgetState};


// ── Types propres à la session v1.4.0 ─────────────────────────
// Définis ici plutôt que dans types.rs pour éviter
// les dépendances circulaires (types.rs ← cash_tracker ← types.rs)

/// Entrée session v1.4.0
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct SessionInputV2 {
    pub engine_input:   EngineInput,
    pub history:        Vec<CycleRecord>,
    pub pending_sms:    Vec<PendingTransactionInput>,
    pub cash_envelopes: Vec<CashEnvelope>,
    pub first_name:     String,
    pub is_premium:     bool,
}

/// SessionState v1.4.0 — sortie complète avec cash + behavioral + narrative
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct SessionStateV2 {
    pub engine:            ZoltEngineOutputV2,
    pub health:            HealthScore,
    pub cycle:             CycleDetectionResult,
    pub charge_tracking:   Vec<ChargeTrackingResult>,
    pub triage:            Vec<TriageResult>,
    pub integrity:         IntegrityReport,
    pub cash:              CashState,
    pub behavioral:        BehavioralInsights,
    pub narrative:         NarrativeOutput,
    /// Rapport de vérification multi-formules — transparence totale
    pub verification:      VerificationReport,
    /// Score de crédit informel Zolt
    pub credit_score:      CreditScoreResult,
    /// Mode fin de mois serré + calendrier de tension
    pub tight_month:       TightMonthResult,
    /// État compact pour le widget OS
    pub widget:            WidgetState,
    pub computed_at_epoch: u32,
}

pub struct SessionEngineV2;

impl SessionEngineV2 {
    /// Point d'entrée principal v1.4.0.
    pub fn compute(input: &SessionInputV2) -> SessionStateV2 {
        let today = &input.engine_input.today;

        // ── 1. Intégrité ──────────────────────────────────────
        let integrity = DataIntegrityEngine::check(&input.engine_input, &input.history);

        // ── 2. Calcul déterministe ────────────────────────────
        let det = match DeterministicEngine::compute(&input.engine_input) {
            Ok(d)  => d,
            Err(e) => return Self::emergency_state(input, integrity, &e.to_string()),
        };

        // ── 3. Moteur adaptatif ───────────────────────────────
        let adaptive = AdaptiveEngine::run(&input.engine_input, &input.history, &det);

        // ── 4. Prédiction de revenu ───────────────────────────
        let income_pred = IncomePredictorEngine::predict(&input.history, today);

        // ── 5. Score de santé ─────────────────────────────────
        let health = HealthScoreEngine::compute(&det, &adaptive, &input.history);

        // ── 6. État du cycle ──────────────────────────────────
        let cycle = CycleDetectorEngine::detect(&input.engine_input);

        // ── 7. Suivi des charges ──────────────────────────────
        let charge_tracking = ChargeTrackerEngine::track(&input.engine_input.charges, today);

        // ── 8. Triage SMS ─────────────────────────────────────
        let triage = if !input.pending_sms.is_empty() {
            TriageScorerEngine::score(&TriageInput {
                pending:  input.pending_sms.clone(),
                existing: input.engine_input.transactions.clone(),
                det:      det.clone(),
            })
        } else {
            vec![]
        };

        // ── 9. Cash tracker ───────────────────────────────────
        let cash = CashTrackerEngine::compute(&CashTrackerInput {
            envelopes:    input.cash_envelopes.clone(),
            transactions: input.engine_input.transactions.clone(),
            today:        *today,
            det:          det.clone(),
        });

        // ── 10. Behavioral insights ───────────────────────────
        let behavioral = BehavioralInsightsEngine::compute(
            &input.engine_input.transactions,
            &input.history,
            today,
            &det,
        );

        // ── 11. Narrative engine ──────────────────────────────
        let narrative = NarrativeEngine::generate(&NarrativeContext {
            first_name:  &input.first_name,
            det:         &det,
            insights:    &behavioral,
            history:     &input.history,
            today,
            is_premium:  input.is_premium,
            income_pred: income_pred.as_ref(),
            health_score: health.score,
        });

        // ── 12. Vérification multi-formules ──────────────────
        let verification = ComputeVerifier::verify_all(&VerifierContext {
            input:   &input.engine_input,
            history: &input.history,
            det:     &det,
        });

        // ── 13. Score de crédit informel ─────────────────────
        let credit_score = CreditScoreEngine::compute(
            &crate::credit_score::CreditScoreInput {
                history:    input.history.clone(),
                current:    input.engine_input.clone(),
                first_name: input.first_name.clone(),
            }
        );

        // ── 14. Mode fin de mois serré + widget ──────────────
        let tight_input = crate::tight_month::TightMonthInput {
            engine_input: input.engine_input.clone(),
            det:          det.clone(),
            history:      input.history.clone(),
        };
        let tight_month = TightMonthEngine::compute(&tight_input);
        let widget      = TightMonthEngine::compute_widget(&tight_input);

        // ── 15. Notifications ─────────────────────────────────
        let notifications = NotificationsEngine::compute(
            &det, &adaptive, &input.engine_input, income_pred.as_ref()
        );

        // ── 13. Assemblage ────────────────────────────────────
        let engine = ZoltEngineOutputV2 {
            deterministic:     det,
            profile:           adaptive.profile,
            prediction:        adaptive.prediction,
            income_prediction: income_pred,
            anomalies:         adaptive.anomalies,
            // messages legacy (Surface) — remplacés par narrative mais conservés
            // pour compatibilité avec les FFI v1.3.0
            messages:          vec![],
            suggestions:       adaptive.suggestions,
            notifications,
        };

        SessionStateV2 {
            engine,
            health,
            cycle,
            charge_tracking,
            triage,
            integrity,
            cash,
            behavioral,
            narrative,
            verification,
            credit_score,
            tight_month,
            widget,
            computed_at_epoch: today.to_days_since_epoch(),
        }
    }

    // ── État d'urgence si le calcul principal échoue ──────────
    fn emergency_state(
        input:     &SessionInputV2,
        integrity: IntegrityReport,
        error:     &str,
    ) -> SessionStateV2 {
        let today = &input.engine_input.today;

        let health = HealthScore {
            score: 0, grade: HealthGrade::Critical,
            budget: 0, savings: 0, stability: 0, prediction: 0, trend: 0,
            message: format!("Erreur de calcul : {}. Vérifiez vos données.", error),
        };

        let cycle = CycleDetectorEngine::detect(&input.engine_input);
        let charge_tracking = ChargeTrackerEngine::track(
            &input.engine_input.charges, today
        );

        let det_empty = DeterministicResult {
            total_balance: input.engine_input.accounts.iter()
                .filter(|a| a.is_active).map(|a| a.balance).sum(),
            committed_mass: 0.0, free_mass: 0.0,
            days_remaining: 1, daily_budget: 0.0,
            spent_today: 0.0, remaining_today: 0.0,
            transport_reserve: 0.0, charges_reserve: 0.0,
        };

        // Cash en mode dégradé
        let cash = CashTrackerEngine::compute(&CashTrackerInput {
            envelopes:    input.cash_envelopes.clone(),
            transactions: input.engine_input.transactions.clone(),
            today:        *today,
            det:          det_empty.clone(),
        });

        let empty_insights = BehavioralInsightsEngine::compute(
            &[], &[], today, &det_empty
        );

        let emergency_narrative = NarrativeEngine::generate(&NarrativeContext {
            first_name:  &input.first_name,
            det:         &det_empty,
            insights:    &empty_insights,
            history:     &[],
            today,
            is_premium:  false,
            income_pred: None,
            health_score: 0,
        });

        let engine = ZoltEngineOutputV2 {
            deterministic:    det_empty,
            profile:          BehavioralProfile::default(),
            prediction:       None,
            income_prediction: None,
            anomalies:        vec![],
            messages:         vec![ConversationalMessage {
                level: AlertLevel::Critical,
                title: "Calcul impossible".into(),
                body:  format!("Le moteur n'a pas pu calculer votre budget : {}.", error),
                ttl_days: None,
            }],
            suggestions:   vec![],
            notifications: vec![],
        };

        // Rapport de vérification minimal pour l'état d'urgence
        let emergency_verification = ComputeVerifier::verify_all(&VerifierContext {
            input:   &input.engine_input,
            history: &[],
            det:     &det_empty,
        });

        let emergency_tight = {
            let ti = crate::tight_month::TightMonthInput {
                engine_input: input.engine_input.clone(),
                det:          det_empty.clone(),
                history:      vec![],
            };
            (TightMonthEngine::compute(&ti), TightMonthEngine::compute_widget(&ti))
        };

        let emergency_credit = CreditScoreEngine::compute(
            &crate::credit_score::CreditScoreInput {
                history:    vec![],
                current:    input.engine_input.clone(),
                first_name: input.first_name.clone(),
            }
        );

        SessionStateV2 {
            engine, health, cycle,
            charge_tracking, triage: vec![],
            integrity, cash,
            behavioral: empty_insights,
            narrative: emergency_narrative,
            verification: emergency_verification,
            credit_score: emergency_credit,
            tight_month:  emergency_tight.0,
            widget:       emergency_tight.1,
            computed_at_epoch: today.to_days_since_epoch(),
        }
    }
}

// ─────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;
    use crate::cash_tracker::CashEnvelope;

    fn base_session() -> SessionInputV2 {
        SessionInputV2 {
            engine_input: EngineInput {
                today: Date::new(2026, 3, 15),
                accounts: vec![Account {
                    id: "a1".into(), name: "MoMo MTN".into(),
                    account_type: AccountType::MobileMoney,
                    balance: 350_000.0, is_active: true,
                }],
                charges: vec![
                    RecurringCharge {
                        id: "c1".into(), name: "Loyer".into(),
                        amount: 120_000.0, due_day: 5,
                        status: ChargeStatus::Paid, amount_paid: 120_000.0, is_active: true,
                    },
                    RecurringCharge {
                        id: "c2".into(), name: "Électricité".into(),
                        amount: 15_000.0, due_day: 20,
                        status: ChargeStatus::Pending, amount_paid: 0.0, is_active: true,
                    },
                ],
                transactions: vec![
                    Transaction {
                        id: "t1".into(), date: Date::new(2026, 3, 1),
                        amount: 300_000.0, tx_type: TransactionType::Income,
                        category: Some("salaire".into()), account_id: "a1".into(),
                        description: None, sms_confidence: None,
                    },
                    Transaction {
                        id: "t2".into(), date: Date::new(2026, 3, 15),
                        amount: 8_000.0, tx_type: TransactionType::Expense,
                        category: Some("nourriture".into()), account_id: "a1".into(),
                        description: None, sms_confidence: None,
                    },
                    Transaction {
                        id: "t3".into(), date: Date::new(2026, 3, 10),
                        amount: 30_000.0, tx_type: TransactionType::Withdrawal,
                        category: None, account_id: "a1".into(),
                        description: None, sms_confidence: Some(0.95),
                    },
                ],
                cycle: FinancialCycle {
                    cycle_type: CycleType::Monthly,
                    savings_goal: 30_000.0,
                    transport: TransportType::Daily {
                        cost_per_day: 1_000.0,
                        work_days: vec![1, 2, 3, 4, 5],
                    },
                },
            },
            history: vec![],
            pending_sms: vec![],
            cash_envelopes: vec![],
            first_name: "Kofi".into(),
            is_premium: false,
        }
    }

    #[test]
    fn test_session_v2_full_output() {
        let s = SessionEngineV2::compute(&base_session());
        assert!(s.engine.deterministic.daily_budget > 0.0);
        assert!((0..=100).contains(&s.health.score));
        assert_eq!(s.integrity.is_valid, true);
        assert!(!s.narrative.messages.is_empty());
        assert!(!s.narrative.daily_brief.greeting.is_empty());
    }

    #[test]
    fn test_session_v2_cash_tracks_withdrawal() {
        let s = SessionEngineV2::compute(&base_session());
        // Un retrait de 30 000 a été enregistré
        assert!((s.cash.total_withdrawn - 30_000.0).abs() < 1.0,
                "total_withdrawn={}", s.cash.total_withdrawn);
    }

    #[test]
    fn test_session_v2_cash_with_envelope() {
        let mut sess = base_session();
        sess.cash_envelopes = vec![CashEnvelope {
            id: "e1".into(), label: "Marché".into(),
            created_at: Date::new(2026, 3, 10),
            total: 30_000.0, spent: 12_000.0,
            source: crate::cash_tracker::EnvelopeSource::AutoWithdrawal {
                sms_ref: "t3".into()
            },
            allocations: vec![crate::cash_tracker::CashAllocation {
                tx_id: "t3".into(), amount: 12_000.0,
                category: "nourriture".into(),
                date: Date::new(2026, 3, 11), label: None,
            }],
        }];
        let s = SessionEngineV2::compute(&sess);
        assert!(!s.cash.envelopes.is_empty());
        assert!((s.cash.envelopes[0].remaining - 18_000.0).abs() < 1.0);
    }

    #[test]
    fn test_session_v2_premium_narrative() {
        let mut sess = base_session();
        sess.is_premium = true;
        let s = SessionEngineV2::compute(&sess);
        // Premium → doit avoir au moins un message avec action
        // (dépend du contexte — test de non-panic)
        assert!(!s.narrative.messages.is_empty());
    }

    #[test]
    fn test_session_v2_greeting_contains_name() {
        let s = SessionEngineV2::compute(&base_session());
        assert!(s.narrative.daily_brief.greeting.contains("Kofi"),
                "greeting={}", s.narrative.daily_brief.greeting);
    }

    #[test]
    fn test_session_v2_triage_with_sms() {
        let mut sess = base_session();
        sess.pending_sms = vec![
            PendingTransactionInput {
                id: "sms1".into(),
                raw: RawTransaction {
                    amount: 1_000.0,
                    description: Some("Recharge MTN".into()),
                    counterpart: None, sms_text: None,
                },
                detected_at: Date::new(2026, 3, 15),
            }
        ];
        let s = SessionEngineV2::compute(&sess);
        assert_eq!(s.triage.len(), 1);
        assert_eq!(s.triage[0].classification.category, "recharge_telecom");
    }

    #[test]
    fn test_session_v2_emergency_on_no_active_account() {
        let mut sess = base_session();
        sess.engine_input.accounts[0].is_active = false;
        let s = SessionEngineV2::compute(&sess);
        assert_eq!(s.health.score, 0);
        assert!(!s.integrity.is_valid);
        // La narrative doit quand même fonctionner
        assert!(!s.narrative.daily_brief.greeting.is_empty());
    }

    #[test]
    fn test_session_v2_behavioral_insights_no_panic() {
        let s = SessionEngineV2::compute(&base_session());
        // Avec peu de données, les insights sont vides mais pas de panique
        let _ = &s.behavioral.temporal;
        let _ = &s.behavioral.leaks;
        let _ = &s.behavioral.momentum;
    }

    #[test]
    fn test_session_v2_with_history_has_behavioral() {
        let mut sess = base_session();
        sess.history = vec![CycleRecord {
            cycle_start: Date::new(2026, 2, 1),
            cycle_end:   Date::new(2026, 2, 28),
            opening_balance: 200_000.0, closing_balance: 250_000.0,
            total_income: 300_000.0, total_expenses: 200_000.0,
            savings_goal: 30_000.0, savings_achieved: 50_000.0,
            daily_expenses: vec![7_142.0; 28],
            category_totals: vec![
                ("nourriture".into(), 60_000.0),
                ("transport".into(), 30_000.0),
                ("loyer".into(), 120_000.0),
            ],
            transactions: vec![],
        }];
        let s = SessionEngineV2::compute(&sess);
        assert!(s.engine.profile.cycles_observed >= 1);
    }

    #[test]
    fn test_computed_at_matches_today() {
        let s = SessionEngineV2::compute(&base_session());
        assert_eq!(s.computed_at_epoch, Date::new(2026, 3, 15).to_days_since_epoch());
    }
}
