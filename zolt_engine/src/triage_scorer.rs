// ============================================================
//  MODULE TRIAGE SCORER — Scoring des transactions SMS en attente
//  Le moteur enrichit chaque transaction en attente avec :
//  - Classification automatique (type + catégorie + confiance)
//  - Détection de doublons potentiels
//  - Impact budgétaire si confirmée
//  Flutter affiche le résultat, l'utilisateur valide/rejette.
// ============================================================

use crate::types::*;
use crate::classifier::TransactionClassifier;

pub struct TriageScorerEngine;

impl TriageScorerEngine {
    pub fn score(input: &TriageInput) -> Vec<TriageResult> {
        input.pending.iter().map(|pending| {
            Self::score_one(pending, &input.existing, &input.det)
        }).collect()
    }

    fn score_one(
        pending:  &PendingTransactionInput,
        existing: &[Transaction],
        det:      &DeterministicResult,
    ) -> TriageResult {
        // ── Classification ────────────────────────────────────
        let classification = TransactionClassifier::classify(&pending.raw);

        // ── Détection de doublon ──────────────────────────────
        let (suggest_ignore, ignore_reason) = Self::check_duplicate(pending, existing);

        // ── Impact budgétaire (seulement si probable dépense) ─
        let budget_impact = if classification.tx_type.is_outflow() && !suggest_ignore {
            Some(Self::compute_impact(pending.raw.amount, det))
        } else {
            None
        };

        TriageResult {
            id: pending.id.clone(),
            classification,
            suggest_ignore,
            ignore_reason,
            budget_impact,
        }
    }

    // ── Détection de doublon ──────────────────────────────────
    fn check_duplicate(
        pending:  &PendingTransactionInput,
        existing: &[Transaction],
    ) -> (bool, Option<String>) {
        // Cherche une transaction existante avec montant identique
        // dans une fenêtre de ±2 jours
        let window_start = pending.detected_at.to_days_since_epoch().saturating_sub(2);
        let window_end   = pending.detected_at.to_days_since_epoch() + 2;

        for tx in existing {
            let tx_epoch = tx.date.to_days_since_epoch();
            if tx_epoch < window_start || tx_epoch > window_end { continue; }

            // Même montant (tolérance 1 FCFA pour arrondis)
            if (tx.amount - pending.raw.amount).abs() < 1.0 {
                return (
                    true,
                    Some(format!(
                        "Probable doublon : transaction de {:.0} FCFA déjà enregistrée le {}",
                        tx.amount, tx.date
                    )),
                );
            }
        }

        // Cherche dans les autres pending (deux SMS pour la même opération)
        // (non applicable ici car on n'a pas les autres pending dans ce contexte,
        //  mais le champ ignore_reason reste disponible pour Flutter)

        (false, None)
    }

    // ── Impact sur le budget journalier ──────────────────────
    fn compute_impact(amount: f64, det: &DeterministicResult) -> BudgetImpact {
        let remaining_after     = (det.remaining_today - amount).max(f64::MIN);
        let daily_budget_pct    = if det.daily_budget > 0.0 {
            amount / det.daily_budget
        } else {
            1.0
        };
        let would_exceed_budget = remaining_after < 0.0;

        BudgetImpact {
            daily_budget_pct,
            remaining_after,
            would_exceed_budget,
        }
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

    fn pending(id: &str, amount: f64, desc: &str) -> PendingTransactionInput {
        PendingTransactionInput {
            id: id.into(),
            raw: RawTransaction {
                amount,
                description: Some(desc.into()),
                counterpart: None,
                sms_text:    None,
            },
            detected_at: Date::new(2026, 3, 15),
        }
    }

    #[test]
    fn test_recharge_classified_correctly() {
        let input = TriageInput {
            pending:  vec![pending("p1", 1_000.0, "Recharge MTN 1000 FCFA")],
            existing: vec![],
            det:      base_det(),
        };
        let results = TriageScorerEngine::score(&input);
        assert_eq!(results.len(), 1);
        assert_eq!(results[0].classification.category, "recharge_telecom");
        assert!(!results[0].suggest_ignore);
    }

    #[test]
    fn test_duplicate_detection() {
        let existing = vec![Transaction {
            id: "t1".into(),
            date:      Date::new(2026, 3, 15),
            amount:    5_000.0,
            tx_type:   TransactionType::Expense,
            category:  Some("transport".into()),
            account_id: "a1".into(),
            description: None, sms_confidence: None,
        }];
        let input = TriageInput {
            pending:  vec![pending("p1", 5_000.0, "taxi")],
            existing,
            det: base_det(),
        };
        let results = TriageScorerEngine::score(&input);
        assert!(results[0].suggest_ignore, "should detect duplicate");
        assert!(results[0].ignore_reason.is_some());
    }

    #[test]
    fn test_budget_impact_computed_for_expense() {
        let input = TriageInput {
            pending:  vec![pending("p1", 6_000.0, "achat marché")],
            existing: vec![],
            det:      base_det(),
        };
        let results = TriageScorerEngine::score(&input);
        let impact = results[0].budget_impact.as_ref().unwrap();
        // 6000 / 10000 = 60% du budget
        assert!((impact.daily_budget_pct - 0.6).abs() < 0.01);
        assert!(!impact.would_exceed_budget); // 7000 - 6000 = 1000 > 0
    }

    #[test]
    fn test_exceeds_budget_flagged() {
        let input = TriageInput {
            pending:  vec![pending("p1", 9_000.0, "achat")],
            existing: vec![],
            det:      base_det(),
        };
        let results = TriageScorerEngine::score(&input);
        let impact = results[0].budget_impact.as_ref().unwrap();
        assert!(impact.would_exceed_budget); // 7000 - 9000 = -2000
    }

    #[test]
    fn test_income_no_budget_impact() {
        let input = TriageInput {
            pending: vec![PendingTransactionInput {
                id: "p1".into(),
                raw: RawTransaction {
                    amount: 250_000.0,
                    description: Some("Vous avez reçu 250000 de ENTREPRISE - salaire".into()),
                    counterpart: Some("ENTREPRISE".into()),
                    sms_text: None,
                },
                detected_at: Date::new(2026, 3, 5),
            }],
            existing: vec![],
            det: base_det(),
        };
        let results = TriageScorerEngine::score(&input);
        // Income → pas d'impact budgétaire
        assert!(results[0].budget_impact.is_none() || results[0].classification.tx_type.is_inflow());
    }

    #[test]
    fn test_empty_pending_returns_empty() {
        let input = TriageInput { pending: vec![], existing: vec![], det: base_det() };
        let results = TriageScorerEngine::score(&input);
        assert!(results.is_empty());
    }

    #[test]
    fn test_duplicate_tolerance_outside_window() {
        // Transaction existante à J-5 → pas un doublon
        let existing = vec![Transaction {
            id: "t1".into(),
            date: Date::new(2026, 3, 10), // 5 jours avant
            amount: 5_000.0,
            tx_type: TransactionType::Expense,
            category: None, account_id: "a1".into(),
            description: None, sms_confidence: None,
        }];
        let input = TriageInput {
            pending:  vec![pending("p1", 5_000.0, "taxi")],
            existing,
            det: base_det(),
        };
        let results = TriageScorerEngine::score(&input);
        assert!(!results[0].suggest_ignore, "outside window should not be flagged");
    }
}
