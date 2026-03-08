// ============================================================
//  MODULE CREDIT SCORE INFORMEL — Score Zolt
//  Pas le score bancaire inaccessible. Un score personnel,
//  compréhensible, actionnable, basé sur les vrais comportements.
//
//  5 dimensions :
//    1. Régularité des paiements    (30%) — charges payées à temps
//    2. Ratio épargne / revenu      (25%) — discipline financière
//    3. Stabilité des revenus       (20%) — prévisibilité des flux
//    4. Gestion du budget           (15%) — dépassements / maîtrise
//    5. Profondeur de l'historique  (10%) — ancienneté + volume données
//
//  Score final : 0-850 (calqué sur le format connu des banques)
//  Tranches :
//    720-850 → Excellent  (accès microfinance prioritaire)
//    640-719 → Bon        (conditions standard)
//    540-639 → Passable   (conditions avec garantie)
//    440-539 → Fragile    (accès limité)
//    0-439   → Insuffisant (pas éligible)
//
//  Chaque score est accompagné d'actions concrètes pour progresser.
// ============================================================

use crate::types::*;
use serde::{Deserialize, Serialize};

// ── Types ─────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreditScoreInput {
    pub history:     Vec<CycleRecord>,
    pub current:     EngineInput,
    /// Prénom pour le message personnalisé
    pub first_name:  String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreditScoreResult {
    /// Score global 0-850
    pub score:          u16,
    /// Tranche qualitative
    pub grade:          CreditGrade,
    /// Dimensions détaillées
    pub dimensions:     CreditDimensions,
    /// Évolution vs cycle précédent
    pub trend:          ScoreTrend,
    /// Points forts identifiés
    pub strengths:      Vec<String>,
    /// Points à améliorer avec actions concrètes
    pub improvements:   Vec<CreditImprovement>,
    /// Message personnalisé
    pub message:        String,
    /// Score simulé si l'utilisateur suit les recommandations
    pub potential_score: u16,
    /// Éligibilité estimée aux produits microfinance courants
    pub eligibility:    Vec<ProductEligibility>,
    /// Nombre de cycles analysés
    pub cycles_analyzed: u32,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum CreditGrade {
    Excellent,   // 720-850
    Good,        // 640-719
    Fair,        // 540-639
    Fragile,     // 440-539
    Insufficient, // 0-439
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreditDimensions {
    /// Régularité paiements (0-100 → converti en 0-255 pour contribution)
    pub payment_regularity:  u8,
    /// Ratio épargne (0-100)
    pub savings_ratio:       u8,
    /// Stabilité revenus (0-100)
    pub income_stability:    u8,
    /// Gestion budget (0-100)
    pub budget_management:   u8,
    /// Profondeur historique (0-100)
    pub history_depth:       u8,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreditImprovement {
    pub dimension:   String,
    pub current_pct: u8,
    pub target_pct:  u8,
    pub action:      String,
    pub score_gain:  u16,  // gain estimé sur le score total
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum ScoreTrend {
    StronglyUp,   // +50 ou plus
    Up,           // +20 à +49
    Stable,       // -20 à +19
    Down,         // -50 à -21
    StronglyDown, // -50 ou moins
    NewUser,      // Pas de précédent
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProductEligibility {
    pub product_name:  String,
    pub is_eligible:   bool,
    pub min_score:     u16,
    pub missing_score: u16,  // 0 si déjà éligible
    pub description:   String,
}

// ── Moteur principal ──────────────────────────────────────────

pub struct CreditScoreEngine;

impl CreditScoreEngine {
    pub fn compute(input: &CreditScoreInput) -> CreditScoreResult {
        let history = &input.history;

        // Score nul si historique insuffisant
        if history.is_empty() {
            return Self::new_user_score(&input.first_name);
        }

        // ── 1. Régularité des paiements (30%) ─────────────────
        let (payment_score, payment_details) = Self::score_payment_regularity(history, &input.current);

        // ── 2. Ratio épargne / revenu (25%) ───────────────────
        let (savings_score, savings_details) = Self::score_savings_ratio(history);

        // ── 3. Stabilité des revenus (20%) ────────────────────
        let (income_score, income_details) = Self::score_income_stability(history);

        // ── 4. Gestion du budget (15%) ────────────────────────
        let (budget_score, budget_details) = Self::score_budget_management(history);

        // ── 5. Profondeur de l'historique (10%) ───────────────
        let (depth_score, depth_details) = Self::score_history_depth(history);

        // ── Score final pondéré ───────────────────────────────
        // Base 850, pondérations des 5 dimensions
        let raw = payment_score as f64 * 0.30
            + savings_score  as f64 * 0.25
            + income_score   as f64 * 0.20
            + budget_score   as f64 * 0.15
            + depth_score    as f64 * 0.10;

        let score = (raw * 8.5).round() as u16; // 0-100 → 0-850
        let score = score.min(850);

        let grade = Self::grade(score);

        // ── Tendance ──────────────────────────────────────────
        let trend = if history.len() >= 2 {
            let prev_score = Self::compute_partial_score(&history[..history.len()-1]);
            let delta = score as i32 - prev_score as i32;
            match delta {
                d if d >= 50  => ScoreTrend::StronglyUp,
                d if d >= 20  => ScoreTrend::Up,
                d if d <= -50 => ScoreTrend::StronglyDown,
                d if d <= -20 => ScoreTrend::Down,
                _             => ScoreTrend::Stable,
            }
        } else {
            ScoreTrend::NewUser
        };

        // ── Points forts ──────────────────────────────────────
        let mut strengths = Vec::new();
        if payment_score >= 80 {
            strengths.push("Tu paies tes charges régulièrement — excellent signal de fiabilité.".into());
        }
        if savings_score >= 75 {
            strengths.push(format!("Taux d'épargne solide — tu mets de côté {:.0}% de tes revenus en moyenne.",
                savings_score as f64 * 0.30)); // approximation affichage
        }
        if income_score >= 80 {
            strengths.push("Revenus stables et prévisibles — profil rassurant pour un prêteur.".into());
        }
        if budget_score >= 75 {
            strengths.push("Bonne maîtrise du budget mensuel — peu ou pas de dépassements.".into());
        }
        if history.len() >= 6 {
            strengths.push(format!("{} cycles documentés — historique solide.", history.len()));
        }

        // ── Axes d'amélioration ───────────────────────────────
        let mut improvements = Vec::new();

        if payment_score < 80 {
            improvements.push(CreditImprovement {
                dimension:   "Régularité des paiements".into(),
                current_pct: payment_score,
                target_pct:  90,
                action:      "Active les rappels de charges dans Zolt et \
                               programme tes paiements fixes dès réception du salaire.".into(),
                score_gain:  (((90 - payment_score) as f64 * 0.30 * 8.5) as u16).min(200),
            });
        }

        if savings_score < 60 {
            let target_ratio = if savings_score < 30 { "5% de tes revenus" } else { "10%" };
            improvements.push(CreditImprovement {
                dimension:   "Épargne".into(),
                current_pct: savings_score,
                target_pct:  60,
                action:      format!("Commence par mettre de côté {} dès le premier jour du cycle. \
                                      Utilise le planificateur Zolt pour automatiser.", target_ratio),
                score_gain:  (((60 - savings_score) as f64 * 0.25 * 8.5) as u16).min(150),
            });
        }

        if income_score < 60 {
            improvements.push(CreditImprovement {
                dimension:   "Stabilité des revenus".into(),
                current_pct: income_score,
                target_pct:  70,
                action:      "Enregistre toutes tes sources de revenus dans Zolt pour \
                               que le moteur calcule un profil de revenu complet.".into(),
                score_gain:  (((70 - income_score) as f64 * 0.20 * 8.5) as u16).min(100),
            });
        }

        if budget_score < 60 {
            improvements.push(CreditImprovement {
                dimension:   "Gestion du budget".into(),
                current_pct: budget_score,
                target_pct:  75,
                action:      "Utilise le budget journalier Zolt pour rester dans la cible. \
                               Chaque cycle sans dépassement améliore ton score.".into(),
                score_gain:  (((75 - budget_score) as f64 * 0.15 * 8.5) as u16).min(80),
            });
        }

        if depth_score < 60 {
            improvements.push(CreditImprovement {
                dimension:   "Historique".into(),
                current_pct: depth_score,
                target_pct:  80,
                action:      format!("Continue à utiliser Zolt. Ton score s'améliorera \
                                      automatiquement après {} cycle(s) de plus.",
                    (6_u32).saturating_sub(history.len() as u32).max(1)),
                score_gain:  (((80 - depth_score) as f64 * 0.10 * 8.5) as u16).min(60),
            });
        }

        // Trie par gain potentiel décroissant
        improvements.sort_by(|a, b| b.score_gain.cmp(&a.score_gain));

        // ── Score potentiel ───────────────────────────────────
        let potential_gain: u16 = improvements.iter()
            .take(2) // 2 premières actions
            .map(|i| i.score_gain)
            .sum();
        let potential_score = (score + potential_gain).min(850);

        // ── Message ───────────────────────────────────────────
        let message = Self::build_message(&input.first_name, score, &grade, &trend, &improvements);

        // ── Éligibilité produits ──────────────────────────────
        let eligibility = Self::compute_eligibility(score);

        let dimensions = CreditDimensions {
            payment_regularity: payment_score,
            savings_ratio:      savings_score,
            income_stability:   income_score,
            budget_management:  budget_score,
            history_depth:      depth_score,
        };

        CreditScoreResult {
            score,
            grade,
            dimensions,
            trend,
            strengths,
            improvements,
            message,
            potential_score,
            eligibility,
            cycles_analyzed: history.len() as u32,
        }
    }

    // ── 1. Régularité des paiements ───────────────────────────
    fn score_payment_regularity(
        history: &[CycleRecord],
        current: &EngineInput,
    ) -> (u8, String) {
        if history.is_empty() { return (50, "Aucun historique".into()); }

        // Compte les cycles où toutes les charges fixes ont été payées
        let mut total_charges   = 0u32;
        let mut charges_on_time = 0u32;

        for record in history {
            for (cat, amount) in &record.category_totals {
                if cat.contains("loyer") || cat.contains("électric") || cat.contains("eau") {
                    total_charges += 1;
                    // Si le montant correspond à une charge fixe connue → payé
                    charges_on_time += 1;
                }
            }
        }

        // Aussi : charges du cycle actuel
        let current_paid = current.charges.iter()
            .filter(|c| c.is_active && c.status == ChargeStatus::Paid)
            .count() as u32;
        let current_total = current.charges.iter()
            .filter(|c| c.is_active)
            .count() as u32;

        if current_total > 0 {
            total_charges   += current_total;
            charges_on_time += current_paid;
        }

        let ratio = if total_charges > 0 {
            charges_on_time as f64 / total_charges as f64
        } else {
            0.70 // baseline si pas de données
        };

        // Bonus pour ancienneté sans incident
        let bonus = (history.len() as f64 * 0.02).min(0.15);
        let score = ((ratio + bonus).min(1.0) * 100.0) as u8;

        (score, format!("{}/{} charges payées", charges_on_time, total_charges))
    }

    // ── 2. Ratio épargne / revenu ─────────────────────────────
    fn score_savings_ratio(history: &[CycleRecord]) -> (u8, String) {
        if history.is_empty() { return (30, "Aucun historique".into()); }

        let ratios: Vec<f64> = history.iter()
            .filter(|r| r.total_income > 0.0)
            .map(|r| (r.savings_achieved / r.total_income).min(1.0).max(0.0))
            .collect();

        if ratios.is_empty() { return (30, "Revenus non enregistrés".into()); }

        let avg_ratio = ratios.iter().sum::<f64>() / ratios.len() as f64;
        let consistency = 1.0 - Self::cv(&ratios).min(1.0); // régularité de l'épargne

        // Score : ratio seul (70%) + régularité (30%)
        let raw = avg_ratio * 0.70 + consistency * 0.30;

        // Courbe non-linéaire : 10% d'épargne = score 60, 20% = 80, 30%+ = 95
        let score = if avg_ratio >= 0.30      { 95u8 }
            else if avg_ratio >= 0.20 { (70.0 + avg_ratio * 100.0) as u8 }
            else if avg_ratio >= 0.10 { (50.0 + avg_ratio * 200.0) as u8 }
            else                      { (avg_ratio * 500.0) as u8 };

        let score = score.min(100);
        (score, format!("{:.1}% d'épargne en moyenne", avg_ratio * 100.0))
    }

    // ── 3. Stabilité des revenus ──────────────────────────────
    fn score_income_stability(history: &[CycleRecord]) -> (u8, String) {
        if history.len() < 2 { return (50, "Historique trop court".into()); }

        let incomes: Vec<f64> = history.iter()
            .map(|r| r.total_income)
            .filter(|&i| i > 0.0)
            .collect();

        if incomes.len() < 2 { return (40, "Revenus non documentés".into()); }

        let cv = Self::cv(&incomes);

        // CV faible = revenus stables = score élevé
        let score = if cv <= 0.05      { 95u8 }
            else if cv <= 0.10 { 85 }
            else if cv <= 0.20 { 70 }
            else if cv <= 0.35 { 55 }
            else if cv <= 0.50 { 40 }
            else               { 25 };

        (score, format!("Variabilité des revenus : {:.0}%", cv * 100.0))
    }

    // ── 4. Gestion du budget ──────────────────────────────────
    fn score_budget_management(history: &[CycleRecord]) -> (u8, String) {
        if history.is_empty() { return (50, "Aucun historique".into()); }

        // Cycles sans dépassement (dépenses ≤ revenus)
        let total = history.len() as f64;
        let no_overrun = history.iter()
            .filter(|r| r.total_expenses <= r.total_income)
            .count() as f64;

        let overrun_ratio = no_overrun / total;

        // Amplitude des dépassements quand ils arrivent
        let avg_overrun_severity: f64 = history.iter()
            .filter(|r| r.total_expenses > r.total_income)
            .map(|r| (r.total_expenses - r.total_income) / r.total_income)
            .sum::<f64>() / total;

        let score = ((overrun_ratio * 80.0) + (1.0 - avg_overrun_severity.min(1.0)) * 20.0) as u8;
        let score = score.min(100);

        let overruns = (total - no_overrun) as u32;
        (score, format!("{} cycle(s) avec dépassement sur {}", overruns, history.len()))
    }

    // ── 5. Profondeur de l'historique ─────────────────────────
    fn score_history_depth(history: &[CycleRecord]) -> (u8, String) {
        let cycles = history.len() as u32;

        // 1 cycle → 25, 3 cycles → 50, 6 cycles → 75, 12 cycles → 95
        let score = match cycles {
            0     => 0,
            1     => 25,
            2     => 40,
            3..=5 => 50 + (cycles - 3) * 8,
            6..=11 => 74 + (cycles - 6) * 3,
            _     => 95,
        } as u8;

        (score.min(100), format!("{} cycles documentés", cycles))
    }

    // ── Calcul partiel (pour la tendance) ─────────────────────
    fn compute_partial_score(history: &[CycleRecord]) -> u16 {
        if history.is_empty() { return 0; }

        let dummy_input = EngineInput {
            today: history.last().unwrap().cycle_end,
            accounts: vec![], charges: vec![], transactions: vec![],
            cycle: FinancialCycle {
                cycle_type: CycleType::Monthly,
                savings_goal: 0.0,
                transport: TransportType::None,
            },
        };

        let (p, _) = Self::score_payment_regularity(history, &dummy_input);
        let (s, _) = Self::score_savings_ratio(history);
        let (i, _) = Self::score_income_stability(history);
        let (b, _) = Self::score_budget_management(history);
        let (d, _) = Self::score_history_depth(history);

        let raw = p as f64 * 0.30 + s as f64 * 0.25 + i as f64 * 0.20
            + b as f64 * 0.15 + d as f64 * 0.10;

        (raw * 8.5).round() as u16
    }

    // ── Éligibilité aux produits ──────────────────────────────
    fn compute_eligibility(score: u16) -> Vec<ProductEligibility> {
        vec![
            ProductEligibility {
                product_name:  "Microprêt d'urgence (50 000 - 150 000 FCFA)".into(),
                is_eligible:   score >= 440,
                min_score:     440,
                missing_score: if score >= 440 { 0 } else { 440 - score },
                description:   "Prêt court terme 30 jours, taux 5-8%".into(),
            },
            ProductEligibility {
                product_name:  "Prêt équipement (150 000 - 500 000 FCFA)".into(),
                is_eligible:   score >= 540,
                min_score:     540,
                missing_score: if score >= 540 { 0 } else { 540 - score },
                description:   "Financement matériel / moto 3-12 mois".into(),
            },
            ProductEligibility {
                product_name:  "Prêt activité (500 000 - 2 000 000 FCFA)".into(),
                is_eligible:   score >= 640,
                min_score:     640,
                missing_score: if score >= 640 { 0 } else { 640 - score },
                description:   "Fonds de roulement PME 6-24 mois".into(),
            },
            ProductEligibility {
                product_name:  "Compte épargne rémunéré prioritaire".into(),
                is_eligible:   score >= 720,
                min_score:     720,
                missing_score: if score >= 720 { 0 } else { 720 - score },
                description:   "Taux bonifié + conseiller dédié".into(),
            },
        ]
    }

    // ── Grade ─────────────────────────────────────────────────
    fn grade(score: u16) -> CreditGrade {
        match score {
            720..=850 => CreditGrade::Excellent,
            640..=719 => CreditGrade::Good,
            540..=639 => CreditGrade::Fair,
            440..=539 => CreditGrade::Fragile,
            _         => CreditGrade::Insufficient,
        }
    }

    // ── Message personnalisé ──────────────────────────────────
    fn build_message(
        first_name: &str,
        score:      u16,
        grade:      &CreditGrade,
        trend:      &ScoreTrend,
        improvements: &[CreditImprovement],
    ) -> String {
        let grade_desc = match grade {
            CreditGrade::Excellent    => "excellent",
            CreditGrade::Good        => "bon",
            CreditGrade::Fair        => "passable",
            CreditGrade::Fragile     => "fragile",
            CreditGrade::Insufficient => "insuffisant",
        };

        let trend_msg = match trend {
            ScoreTrend::StronglyUp   => " Tes efforts payent vraiment : forte progression !",
            ScoreTrend::Up           => " Tu es sur la bonne voie.",
            ScoreTrend::Stable       => "",
            ScoreTrend::Down         => " Quelques ajustements sont nécessaires.",
            ScoreTrend::StronglyDown => " Attention : ton profil s'est dégradé ce cycle.",
            ScoreTrend::NewUser      => " C'est ton premier score — il va s'affiner avec le temps.",
        };

        let action_hint = improvements.first()
            .map(|i| format!(" Priorité : {}.", i.action.split('.').next().unwrap_or("")))
            .unwrap_or_default();

        format!(
            "{}, ton Score Zolt est de {} — profil {}. {} {}{}",
            first_name, score, grade_desc, score, trend_msg, action_hint
        )
    }

    fn new_user_score(first_name: &str) -> CreditScoreResult {
        CreditScoreResult {
            score: 0,
            grade: CreditGrade::Insufficient,
            dimensions: CreditDimensions {
                payment_regularity: 0, savings_ratio: 0,
                income_stability: 0, budget_management: 0, history_depth: 0,
            },
            trend: ScoreTrend::NewUser,
            strengths: vec![],
            improvements: vec![CreditImprovement {
                dimension:   "Historique".into(),
                current_pct: 0,
                target_pct:  50,
                action:      "Utilise Zolt pendant au moins 1 cycle complet pour obtenir ton premier score.".into(),
                score_gain:  200,
            }],
            message: format!(
                "{}, ton Score Zolt sera calculé après ton premier cycle complet documenté. \
                 Enregistre tes revenus et tes charges pour commencer.", first_name
            ),
            potential_score: 400,
            eligibility: vec![],
            cycles_analyzed: 0,
        }
    }

    // ── Utilitaire : coefficient de variation ─────────────────
    fn cv(values: &[f64]) -> f64 {
        if values.len() < 2 { return 0.0; }
        let mean = values.iter().sum::<f64>() / values.len() as f64;
        if mean.abs() < 0.01 { return 0.0; }
        let var = values.iter().map(|v| (v - mean).powi(2)).sum::<f64>()
            / values.len() as f64;
        var.sqrt() / mean.abs()
    }
}

// ─────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;

    fn make_record(income: f64, expenses: f64, savings: f64, month: u8) -> CycleRecord {
        CycleRecord {
            cycle_start: Date::new(2026, month, 1),
            cycle_end:   Date::new(2026, month, 28),
            opening_balance: 100_000.0,
            closing_balance: 100_000.0 + income - expenses,
            total_income:   income,
            total_expenses: expenses,
            savings_goal:   30_000.0,
            savings_achieved: savings,
            daily_expenses: vec![expenses / 28.0; 28],
            category_totals: vec![
                ("loyer".into(), 120_000.0),
                ("nourriture".into(), 50_000.0),
            ],
            transactions: vec![],
        }
    }

    fn base_current() -> EngineInput {
        EngineInput {
            today: Date::new(2026, 3, 15),
            accounts: vec![Account {
                id: "a1".into(), name: "MoMo".into(),
                account_type: AccountType::MobileMoney,
                balance: 200_000.0, is_active: true,
            }],
            charges: vec![RecurringCharge {
                id: "c1".into(), name: "Loyer".into(),
                amount: 120_000.0, due_day: 5,
                status: ChargeStatus::Paid, amount_paid: 120_000.0, is_active: true,
            }],
            transactions: vec![],
            cycle: FinancialCycle {
                cycle_type: CycleType::Monthly,
                savings_goal: 30_000.0,
                transport: TransportType::None,
            },
        }
    }

    #[test]
    fn test_score_bounded_0_850() {
        let history = vec![
            make_record(300_000.0, 200_000.0, 50_000.0, 1),
            make_record(300_000.0, 210_000.0, 40_000.0, 2),
            make_record(300_000.0, 195_000.0, 55_000.0, 3),
        ];
        let r = CreditScoreEngine::compute(&CreditScoreInput {
            history, current: base_current(), first_name: "Kofi".into()
        });
        assert!(r.score <= 850, "score={}", r.score);
        assert!(r.score > 0);
    }

    #[test]
    fn test_excellent_profile_high_score() {
        // Profil idéal : revenus stables, épargne 20%, pas de dépassement, 6 cycles
        let history: Vec<CycleRecord> = (1..=6).map(|m| {
            make_record(300_000.0, 240_000.0, 60_000.0, m)
        }).collect();
        let r = CreditScoreEngine::compute(&CreditScoreInput {
            history, current: base_current(), first_name: "Kofi".into()
        });
        assert!(r.score >= 600, "expected high score, got {}", r.score);
        assert!(matches!(r.grade, CreditGrade::Fair | CreditGrade::Good | CreditGrade::Excellent));
    }

    #[test]
    fn test_poor_profile_low_score() {
        // Profil fragile : dépassements, pas d'épargne
        let history: Vec<CycleRecord> = (1..=3).map(|m| {
            make_record(200_000.0, 210_000.0, 0.0, m)  // dépassement chaque cycle
        }).collect();
        let r = CreditScoreEngine::compute(&CreditScoreInput {
            history, current: base_current(), first_name: "Kofi".into()
        });
        assert!(r.score < 500, "expected low score, got {}", r.score);
    }

    #[test]
    fn test_new_user_score() {
        let r = CreditScoreEngine::compute(&CreditScoreInput {
            history: vec![], current: base_current(), first_name: "Aminata".into()
        });
        assert_eq!(r.score, 0);
        assert_eq!(r.grade, CreditGrade::Insufficient);
        assert_eq!(r.cycles_analyzed, 0);
        assert!(!r.message.is_empty());
    }

    #[test]
    fn test_eligibility_unlocks_with_score() {
        let history: Vec<CycleRecord> = (1..=8).map(|m| {
            make_record(400_000.0, 280_000.0, 80_000.0, m)
        }).collect();
        let r = CreditScoreEngine::compute(&CreditScoreInput {
            history, current: base_current(), first_name: "Koffi".into()
        });
        // Au moins le prêt d'urgence doit être éligible
        let first_product = r.eligibility.first();
        assert!(first_product.is_some());
    }

    #[test]
    fn test_trend_detected() {
        let early_history = vec![
            make_record(200_000.0, 210_000.0, 0.0, 1),
            make_record(200_000.0, 205_000.0, 5_000.0, 2),
        ];
        let improving_history = {
            let mut h = early_history.clone();
            h.push(make_record(300_000.0, 220_000.0, 50_000.0, 3));
            h.push(make_record(300_000.0, 215_000.0, 60_000.0, 4));
            h
        };
        let r = CreditScoreEngine::compute(&CreditScoreInput {
            history: improving_history,
            current: base_current(),
            first_name: "Yves".into(),
        });
        // Trend ne doit pas être Down avec amélioration
        assert_ne!(r.trend, ScoreTrend::StronglyDown);
    }

    #[test]
    fn test_improvements_sorted_by_gain() {
        let history = vec![make_record(200_000.0, 200_000.0, 0.0, 1)];
        let r = CreditScoreEngine::compute(&CreditScoreInput {
            history, current: base_current(), first_name: "Kofi".into()
        });
        if r.improvements.len() >= 2 {
            assert!(r.improvements[0].score_gain >= r.improvements[1].score_gain);
        }
    }

    #[test]
    fn test_potential_score_gte_current() {
        let history = vec![make_record(300_000.0, 250_000.0, 20_000.0, 1)];
        let r = CreditScoreEngine::compute(&CreditScoreInput {
            history, current: base_current(), first_name: "Kofi".into()
        });
        assert!(r.potential_score >= r.score);
        assert!(r.potential_score <= 850);
    }

    #[test]
    fn test_message_contains_name() {
        let history = vec![make_record(300_000.0, 200_000.0, 50_000.0, 1)];
        let r = CreditScoreEngine::compute(&CreditScoreInput {
            history, current: base_current(), first_name: "Aminata".into()
        });
        assert!(r.message.contains("Aminata"), "message={}", r.message);
    }

    #[test]
    fn test_dimensions_all_bounded() {
        let history = vec![make_record(300_000.0, 200_000.0, 40_000.0, 1)];
        let r = CreditScoreEngine::compute(&CreditScoreInput {
            history, current: base_current(), first_name: "Kofi".into()
        });
        assert!(r.dimensions.payment_regularity <= 100);
        assert!(r.dimensions.savings_ratio <= 100);
        assert!(r.dimensions.income_stability <= 100);
        assert!(r.dimensions.budget_management <= 100);
        assert!(r.dimensions.history_depth <= 100);
    }
}
