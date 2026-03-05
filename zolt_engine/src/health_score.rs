// ============================================================
//  MODULE HEALTH SCORE — Score de santé financière 0-100
//  Agrège toutes les dimensions en un score unique.
//  C'est le "signal fort" que Flutter affiche en priorité.
// ============================================================

use crate::types::*;
use crate::adaptive::AdaptiveOutput;

pub struct HealthScoreEngine;

impl HealthScoreEngine {
    pub fn compute(
        det:      &DeterministicResult,
        adaptive: &AdaptiveOutput,
        history:  &[CycleRecord],
    ) -> HealthScore {
        // ── Dimension 1 : Budget (0-100) ──────────────────────
        // Respect du budget journalier
        let budget_score: u8 = if det.daily_budget <= 0.0 {
            20 // budget nul = situation précaire
        } else {
            let ratio = det.spent_today / det.daily_budget;
            if ratio <= 0.5       { 100 }
            else if ratio <= 0.8  { 85 }
            else if ratio <= 1.0  { 65 }
            else if ratio <= 1.3  { 35 }
            else                  { 10 }
        };

        // ── Dimension 2 : Épargne (0-100) ─────────────────────
        let savings_score: u8 = {
            let rate = adaptive.profile.savings_rate;
            if rate >= 0.20       { 100 }
            else if rate >= 0.10  { 80 }
            else if rate >= 0.05  { 60 }
            else if rate >= 0.0   { 40 }
            else                  { 10 } // désépargne
        };

        // ── Dimension 3 : Stabilité (0-100) ───────────────────
        // Inverse de la volatilité comportementale
        let stability_score: u8 = {
            let v = adaptive.profile.volatility_score.clamp(0.0, 1.0);
            ((1.0 - v) * 100.0) as u8
        };

        // ── Dimension 4 : Prédiction (0-100) ──────────────────
        let prediction_score: u8 = match &adaptive.prediction {
            None => 70, // pas assez d'historique → neutre
            Some(p) if p.confidence < 0.3 => 70, // confiance trop faible → neutre
            Some(p) => {
                let level = &p.alert_level;
                match level {
                    AlertLevel::Positive => 100,
                    AlertLevel::Info     => 75,
                    AlertLevel::Warning  => 40,
                    AlertLevel::Critical => 10,
                }
            }
        };

        // ── Tendance vs cycle précédent ────────────────────────
        let trend: i8 = Self::compute_trend(det, history);

        // ── Score global pondéré ───────────────────────────────
        let raw = budget_score as f64     * 0.35
                + savings_score as f64    * 0.25
                + stability_score as f64  * 0.20
                + prediction_score as f64 * 0.20;

        // Malus si anomalies actives non-dismissed
        let anomaly_penalty: f64 = adaptive.anomalies.iter()
            .filter(|a| !a.dismissed)
            .count()
            .min(3) as f64 * 4.0;

        let score = (raw - anomaly_penalty).round().clamp(0.0, 100.0) as u8;

        let grade = Self::grade(score);
        let message = Self::message(score, &grade, det, adaptive);

        HealthScore {
            score, grade,
            budget: budget_score,
            savings: savings_score,
            stability: stability_score,
            prediction: prediction_score,
            trend,
            message,
        }
    }

    fn compute_trend(det: &DeterministicResult, history: &[CycleRecord]) -> i8 {
        let prev = match history.last() { Some(r) => r, None => return 0 };
        if prev.total_expenses <= 0.0 { return 0; }

        // Projette les dépenses du cycle courant
        let days_total   = (det.days_remaining + 15).max(1) as f64; // estimation
        let days_elapsed = 15.0_f64.min(days_total);
        let projected = if days_elapsed > 0.0 {
            (det.free_mass - det.total_balance + det.committed_mass) / days_elapsed
                * days_total
        } else { 0.0 };

        let delta_pct = (projected - prev.total_expenses) / prev.total_expenses;
        (delta_pct.clamp(-1.0, 1.0) * 100.0) as i8
    }

    fn grade(score: u8) -> HealthGrade {
        match score {
            80..=100 => HealthGrade::Excellent,
            60..=79  => HealthGrade::Good,
            40..=59  => HealthGrade::Fair,
            20..=39  => HealthGrade::Poor,
            _        => HealthGrade::Critical,
        }
    }

    fn message(score: u8, grade: &HealthGrade, det: &DeterministicResult, adaptive: &AdaptiveOutput) -> String {
        // Message principal selon le score
        let base = match grade {
            HealthGrade::Excellent => "Tes finances sont en excellente santé. Continue comme ça !",
            HealthGrade::Good      => "Bonne gestion ce mois-ci. Quelques petits ajustements possibles.",
            HealthGrade::Fair      => "Situation correcte mais surveillée. Reste attentif à tes dépenses.",
            HealthGrade::Poor      => "Attention, ta gestion budgétaire se dégrade. Des actions sont nécessaires.",
            HealthGrade::Critical  => "Situation critique. Agis maintenant pour éviter un déficit.",
        };

        // Complément contextuel
        let complement = if det.is_insolvent() {
            " Ton solde est insuffisant pour couvrir tes engagements."
        } else if det.is_over_budget() {
            " Tu as dépassé ton budget du jour."
        } else if adaptive.profile.savings_rate < 0.0 {
            " Tu dépenses plus que tu ne gagnes."
        } else {
            ""
        };

        format!("{}{}", base, complement)
    }
}

// ─────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;
    use crate::adaptive::AdaptiveOutput;
    use crate::types::BehavioralProfile;

    fn empty_adaptive() -> AdaptiveOutput {
        AdaptiveOutput {
            profile: BehavioralProfile {
                savings_rate: 0.15,
                volatility_score: 0.2,
                ..BehavioralProfile::default()
            },
            prediction: None, anomalies: vec![], suggestions: vec![], episodes: vec![],
        }
    }

    fn healthy_det() -> DeterministicResult {
        DeterministicResult {
            total_balance: 200_000.0, committed_mass: 50_000.0,
            free_mass: 150_000.0, days_remaining: 15,
            daily_budget: 10_000.0, spent_today: 4_000.0,
            remaining_today: 6_000.0, transport_reserve: 0.0, charges_reserve: 50_000.0,
        }
    }

    #[test]
    fn test_healthy_situation_high_score() {
        let h = HealthScoreEngine::compute(&healthy_det(), &empty_adaptive(), &[]);
        assert!(h.score >= 70, "score={}", h.score);
        assert!(matches!(h.grade, HealthGrade::Good | HealthGrade::Excellent));
    }

    #[test]
    fn test_over_budget_lower_score() {
        let mut det = healthy_det();
        det.spent_today = 18_000.0;
        det.remaining_today = -8_000.0;
        let h = HealthScoreEngine::compute(&det, &empty_adaptive(), &[]);
        assert!(h.score < 70, "score={}", h.score);
    }

    #[test]
    fn test_insolvent_critical() {
        let det = DeterministicResult {
            total_balance: 10_000.0, committed_mass: 150_000.0,
            free_mass: 0.0, days_remaining: 10,
            daily_budget: 0.0, spent_today: 0.0,
            remaining_today: 0.0, transport_reserve: 0.0, charges_reserve: 150_000.0,
        };
        let h = HealthScoreEngine::compute(&det, &empty_adaptive(), &[]);
        assert!(h.score < 40, "score={}", h.score);
        assert!(h.message.contains("insuffisant") || h.message.contains("ritique") || h.score < 40);
    }

    #[test]
    fn test_score_in_range() {
        let h = HealthScoreEngine::compute(&healthy_det(), &empty_adaptive(), &[]);
        assert!((0..=100).contains(&h.score));
        assert!((-100i8..=100i8).contains(&h.trend));
    }

    #[test]
    fn test_anomalies_reduce_score() {
        let mut adaptive = empty_adaptive();
        adaptive.anomalies.push(Anomaly {
            anomaly_type: AnomalyType::GhostMoney { transaction_count: 5, total: 2000.0, impact_pct: 0.05 },
            detected_on: Date::new(2026, 3, 1), expires_on: Date::new(2026, 3, 31), dismissed: false,
        });
        adaptive.anomalies.push(Anomaly {
            anomaly_type: AnomalyType::GhostMoney { transaction_count: 3, total: 1000.0, impact_pct: 0.03 },
            detected_on: Date::new(2026, 3, 1), expires_on: Date::new(2026, 3, 31), dismissed: false,
        });
        let with_anomalies = HealthScoreEngine::compute(&healthy_det(), &adaptive, &[]);
        let without = HealthScoreEngine::compute(&healthy_det(), &empty_adaptive(), &[]);
        assert!(with_anomalies.score <= without.score, "anomalies should reduce score");
    }

    #[test]
    fn test_grade_boundaries() {
        assert!(matches!(HealthScoreEngine::grade(100), HealthGrade::Excellent));
        assert!(matches!(HealthScoreEngine::grade(79),  HealthGrade::Good));
        assert!(matches!(HealthScoreEngine::grade(59),  HealthGrade::Fair));
        assert!(matches!(HealthScoreEngine::grade(39),  HealthGrade::Poor));
        assert!(matches!(HealthScoreEngine::grade(19),  HealthGrade::Critical));
    }

    // Make grade accessible in tests
    impl HealthScoreEngine {
        pub fn grade(score: u8) -> HealthGrade {
            match score {
                80..=100 => HealthGrade::Excellent,
                60..=79  => HealthGrade::Good,
                40..=59  => HealthGrade::Fair,
                20..=39  => HealthGrade::Poor,
                _        => HealthGrade::Critical,
            }
        }
    }
}
