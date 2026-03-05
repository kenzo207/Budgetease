// ============================================================
//  MODULE SESSION STATE — L'appel unique de Flutter
//  Un seul appel FFI → tout ce dont l'app a besoin.
//
//  Flutter fait :
//    1. Lit SQLite → construit SessionInput
//    2. Appelle zolt_session(input_json)
//    3. Reçoit SessionState JSON → affiche
//
//  C'est tout. Aucune logique dans Flutter.
// ============================================================

use crate::types::*;
use crate::deterministic::DeterministicEngine;
use crate::adaptive::AdaptiveEngine;
use crate::surface::SurfaceEngine;
use crate::analytics::AnalyticsEngine;
use crate::health_score::HealthScoreEngine;
use crate::triage_scorer::TriageScorerEngine;
use crate::cycle_detector::CycleDetectorEngine;
use crate::income_predictor::IncomePredictorEngine;
use crate::notifications::NotificationsEngine;
use crate::ops::{ChargeTrackerEngine, DataIntegrityEngine};

pub struct SessionEngine;

impl SessionEngine {
    /// Point d'entrée principal. Calcule tout l'état de l'app en une passe.
    pub fn compute(input: &SessionInput) -> SessionState {
        let today = &input.engine_input.today;

        // ── 1. Intégrité des données en premier ───────────────
        // Si fatal, retourne un état dégradé mais sûr.
        let integrity = DataIntegrityEngine::check(&input.engine_input, &input.history);

        // ── 2. Calcul déterministe ─────────────────────────────
        let det = match DeterministicEngine::compute(&input.engine_input) {
            Ok(d)  => d,
            Err(e) => {
                // Retourne un état minimal d'urgence
                return Self::emergency_state(input, integrity, &e.to_string());
            }
        };

        // ── 3. Moteur adaptatif ────────────────────────────────
        let adaptive = AdaptiveEngine::run(&input.engine_input, &input.history, &det);

        // ── 4. Prédiction de revenu ────────────────────────────
        let income_pred = IncomePredictorEngine::predict(&input.history, today);

        // ── 5. Notifications ──────────────────────────────────
        let notifications = NotificationsEngine::compute(
            &det, &adaptive, &input.engine_input, income_pred.as_ref()
        );

        // ── 6. Messages conversationnels ──────────────────────
        let messages = SurfaceEngine::generate(&det, &adaptive, today);

        // ── 7. Score de santé ─────────────────────────────────
        let health = HealthScoreEngine::compute(&det, &adaptive, &input.history);

        // ── 8. État du cycle ──────────────────────────────────
        let cycle = CycleDetectorEngine::detect(&input.engine_input);

        // ── 9. Suivi des charges ──────────────────────────────
        let charge_tracking = ChargeTrackerEngine::track(&input.engine_input.charges, today);

        // ── 10. Triage SMS ────────────────────────────────────
        let triage = if !input.pending_sms.is_empty() {
            TriageScorerEngine::score(&TriageInput {
                pending:  input.pending_sms.clone(),
                existing: input.engine_input.transactions.clone(),
                det:      det.clone(),
            })
        } else {
            vec![]
        };

        // ── 11. Assemblage de la sortie v2 ────────────────────
        let engine = ZoltEngineOutputV2 {
            deterministic:     det,
            profile:           adaptive.profile,
            prediction:        adaptive.prediction,
            income_prediction: income_pred,
            anomalies:         adaptive.anomalies,
            messages,
            suggestions:       adaptive.suggestions,
            notifications,
        };

        SessionState {
            engine,
            health,
            cycle,
            charge_tracking,
            triage,
            integrity,
            computed_at_epoch: today.to_days_since_epoch(),
        }
    }

    // ── État d'urgence si le calcul principal échoue ──────────
    fn emergency_state(
        input:     &SessionInput,
        integrity: IntegrityReport,
        error:     &str,
    ) -> SessionState {
        let today = &input.engine_input.today;

        // Score d'urgence minimal
        let health = HealthScore {
            score: 0, grade: HealthGrade::Critical,
            budget: 0, savings: 0, stability: 0, prediction: 0, trend: 0,
            message: format!("Erreur de calcul : {}. Vérifiez vos données.", error),
        };

        // Cycle détecté quand même (ne dépend pas du calcul)
        let cycle = CycleDetectorEngine::detect(&input.engine_input);

        // Suivi des charges sans le budget
        let charge_tracking = ChargeTrackerEngine::track(&input.engine_input.charges, today);

        // Message d'erreur critique
        let error_msg = ConversationalMessage {
            level: AlertLevel::Critical,
            title: "Calcul impossible".into(),
            body:  format!("Le moteur n'a pas pu calculer votre budget : {}. Vérifiez vos comptes et charges.", error),
            ttl_days: None,
        };

        // DeterministicResult vide mais valide
        let det_empty = DeterministicResult {
            total_balance: input.engine_input.accounts.iter()
                .filter(|a| a.is_active)
                .map(|a| a.balance)
                .sum(),
            committed_mass: 0.0, free_mass: 0.0,
            days_remaining: 0, daily_budget: 0.0,
            spent_today: 0.0, remaining_today: 0.0,
            transport_reserve: 0.0, charges_reserve: 0.0,
        };

        let engine = ZoltEngineOutputV2 {
            deterministic:     det_empty,
            profile:           BehavioralProfile::default(),
            prediction:        None,
            income_prediction: None,
            anomalies:         vec![],
            messages:          vec![error_msg],
            suggestions:       vec![],
            notifications:     vec![],
        };

        SessionState {
            engine, health, cycle,
            charge_tracking, triage: vec![],
            integrity,
            computed_at_epoch: today.to_days_since_epoch(),
        }
    }
}

// ─────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;

    fn base_session() -> SessionInput {
        SessionInput {
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
        }
    }

    #[test]
    fn test_session_full_output() {
        let s = SessionEngine::compute(&base_session());
        // Tous les champs sont présents
        assert!(s.engine.deterministic.daily_budget > 0.0,
                "budget={}", s.engine.deterministic.daily_budget);
        assert!((0..=100).contains(&s.health.score),
                "health={}", s.health.score);
        assert!(matches!(s.cycle.status, CycleStatus::Active | CycleStatus::EndingSoon { .. }));
        assert_eq!(s.integrity.is_valid, true);
    }

    #[test]
    fn test_session_charge_tracking() {
        let s = SessionEngine::compute(&base_session());
        // 2 charges actives → 2 résultats de tracking
        assert_eq!(s.charge_tracking.len(), 2);
        // Loyer payé = pas d'alerte
        let loyer = s.charge_tracking.iter().find(|c| c.charge_name == "Loyer").unwrap();
        assert!(loyer.is_fully_paid);
        // Électricité en attente → alerte possible
        let elec = s.charge_tracking.iter().find(|c| c.charge_name == "Électricité").unwrap();
        assert!(!elec.is_fully_paid);
    }

    #[test]
    fn test_session_triage_empty_when_no_pending_sms() {
        let s = SessionEngine::compute(&base_session());
        assert!(s.triage.is_empty());
    }

    #[test]
    fn test_session_triage_scores_sms() {
        let mut session = base_session();
        session.pending_sms = vec![
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
        let s = SessionEngine::compute(&session);
        assert_eq!(s.triage.len(), 1);
        assert_eq!(s.triage[0].classification.category, "recharge_telecom");
    }

    #[test]
    fn test_session_emergency_on_no_active_account() {
        let mut session = base_session();
        session.engine_input.accounts[0].is_active = false;
        let s = SessionEngine::compute(&session);
        // Doit retourner un état d'urgence sans crasher
        assert_eq!(s.health.score, 0);
        assert!(s.engine.messages.iter().any(|m| m.level == AlertLevel::Critical));
        assert!(!s.integrity.is_valid);
    }

    #[test]
    fn test_session_computed_at_matches_today() {
        let s = SessionEngine::compute(&base_session());
        let expected = Date::new(2026, 3, 15).to_days_since_epoch();
        assert_eq!(s.computed_at_epoch, expected);
    }

    #[test]
    fn test_session_notifications_non_empty() {
        let s = SessionEngine::compute(&base_session());
        // Au moins le rappel quotidien
        assert!(!s.engine.notifications.is_empty());
    }

    #[test]
    fn test_session_with_history_has_profile() {
        let mut session = base_session();
        session.history = vec![CycleRecord {
            cycle_start: Date::new(2026, 2, 1), cycle_end: Date::new(2026, 2, 28),
            opening_balance: 200_000.0, closing_balance: 250_000.0,
            total_income: 300_000.0, total_expenses: 200_000.0,
            savings_goal: 30_000.0, savings_achieved: 50_000.0,
            daily_expenses: vec![7_142.0; 28],
            category_totals: vec![("loyer".into(), 120_000.0)],
            transactions: vec![],
        }];
        let s = SessionEngine::compute(&session);
        // Profile doit avoir des données
        assert!(s.engine.profile.observed_cycles >= 1);
    }

    #[test]
    fn test_session_end_of_month_has_close_template() {
        let mut session = base_session();
        session.engine_input.today = Date::new(2026, 3, 31); // dernier jour
        let s = SessionEngine::compute(&session);
        assert!(matches!(s.cycle.status, CycleStatus::ShouldClose));
        assert!(s.cycle.next_input_template.is_some());
    }
}
