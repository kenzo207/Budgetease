// ============================================================
//  MODULE CYCLE DETECTOR — Détecte l'état du cycle en cours
//  Flutter ne surveille plus les dates. C'est le moteur qui dit :
//  "ton cycle se termine dans 2 jours", "tu dois clôturer",
//  "voici le template pour le prochain cycle".
// ============================================================

use crate::types::*;

pub struct CycleDetectorEngine;

impl CycleDetectorEngine {
    pub fn detect(input: &EngineInput) -> CycleDetectionResult {
        let today      = &input.today;
        let cycle      = &input.cycle;

        match &cycle.cycle_type {
            CycleType::Monthly => Self::detect_monthly(today, input),
            CycleType::Weekly  => Self::detect_weekly(today, input),
            CycleType::Daily   => Self::detect_daily(today, input),
            CycleType::Irregular { cycle_end } => Self::detect_irregular(today, cycle_end, input),
        }
    }

    // ── Cycle mensuel ─────────────────────────────────────────
    fn detect_monthly(today: &Date, input: &EngineInput) -> CycleDetectionResult {
        let last_day     = Date::last_day_of_month_static(today.year, today.month);
        let days_total   = last_day as u32;
        let current_day  = today.day as u32;
        let days_left    = (last_day as i32 - today.day as i32).max(0) as u32;
        let pct_elapsed  = current_day as f64 / days_total as f64;

        let status = if days_left == 0 {
            CycleStatus::ShouldClose
        } else if days_left <= 3 {
            CycleStatus::EndingSoon { days_remaining: days_left }
        } else {
            CycleStatus::Active
        };

        let next_template = if matches!(status, CycleStatus::ShouldClose | CycleStatus::EndingSoon { .. }) {
            Some(Self::build_next_template(input))
        } else {
            None
        };

        CycleDetectionResult {
            status,
            current_day,
            total_days: days_total,
            pct_elapsed,
            next_input_template: next_template,
        }
    }

    // ── Cycle hebdomadaire ────────────────────────────────────
    fn detect_weekly(today: &Date, input: &EngineInput) -> CycleDetectionResult {
        // Semaine du lundi au dimanche
        let weekday    = today.weekday(); // 1=lundi..7=dimanche
        let days_total = 7u32;
        let current_day = weekday as u32;
        let days_left   = (7 - weekday as i32).max(0) as u32;
        let pct_elapsed = current_day as f64 / days_total as f64;

        let status = if days_left == 0 {
            CycleStatus::ShouldClose
        } else if days_left <= 1 {
            CycleStatus::EndingSoon { days_remaining: days_left }
        } else {
            CycleStatus::Active
        };

        CycleDetectionResult {
            status,
            current_day, total_days: days_total, pct_elapsed,
            next_input_template: None, // semaine → pas de template nécessaire
        }
    }

    // ── Cycle quotidien ───────────────────────────────────────
    fn detect_daily(today: &Date, input: &EngineInput) -> CycleDetectionResult {
        // Cycle de 1 jour : toujours actif, clôture en fin de journée
        CycleDetectionResult {
            status:               CycleStatus::Active,
            current_day:          1,
            total_days:           1,
            pct_elapsed:          0.5, // estimation milieu de journée
            next_input_template:  None,
        }
    }

    // ── Cycle irrégulier ──────────────────────────────────────
    fn detect_irregular(today: &Date, cycle_end: &Date, input: &EngineInput) -> CycleDetectionResult {
        let days_left    = today.days_until(cycle_end).max(0) as u32;
        // Estimation de la durée totale du cycle (30j par défaut si inconnu)
        let total_days   = 30u32;
        let current_day  = (total_days.saturating_sub(days_left)).max(1);
        let pct_elapsed  = current_day as f64 / total_days as f64;

        let status = if days_left == 0 {
            CycleStatus::ShouldClose
        } else if days_left <= 3 {
            CycleStatus::EndingSoon { days_remaining: days_left }
        } else {
            CycleStatus::Active
        };

        let next_template = if matches!(status, CycleStatus::ShouldClose | CycleStatus::EndingSoon { .. }) {
            Some(Self::build_next_template(input))
        } else {
            None
        };

        CycleDetectionResult {
            status,
            current_day, total_days, pct_elapsed,
            next_input_template: next_template,
        }
    }

    // ── Construit le template du prochain cycle ───────────────
    fn build_next_template(input: &EngineInput) -> NextCycleTemplate {
        // Réinitialise les charges actives (statut Pending, paidAmount = 0)
        let charges: Vec<RecurringCharge> = input.charges.iter()
            .filter(|c| c.is_active)
            .map(|c| c.reset_for_new_cycle())
            .collect();

        // Solde d'ouverture suggéré = solde actuel de tous les comptes actifs
        let suggested_opening_balance: f64 = input.accounts.iter()
            .filter(|a| a.is_active)
            .map(|a| a.balance)
            .sum();

        NextCycleTemplate { charges, suggested_opening_balance }
    }
}

// ─────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;

    fn base_input(day: u8, cycle_type: CycleType) -> EngineInput {
        EngineInput {
            today: Date::new(2026, 3, day),
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
            cycle: FinancialCycle { cycle_type, savings_goal: 0.0, transport: TransportType::None },
        }
    }

    #[test]
    fn test_monthly_active_mid_month() {
        let r = CycleDetectorEngine::detect(&base_input(15, CycleType::Monthly));
        assert_eq!(r.status, CycleStatus::Active);
        assert_eq!(r.current_day, 15);
        assert_eq!(r.total_days, 31);
        assert!(r.next_input_template.is_none());
    }

    #[test]
    fn test_monthly_ending_soon() {
        let r = CycleDetectorEngine::detect(&base_input(29, CycleType::Monthly));
        assert!(matches!(r.status, CycleStatus::EndingSoon { .. }));
        assert!(r.next_input_template.is_some());
    }

    #[test]
    fn test_monthly_should_close_last_day() {
        let r = CycleDetectorEngine::detect(&base_input(31, CycleType::Monthly));
        assert_eq!(r.status, CycleStatus::ShouldClose);
        assert!(r.next_input_template.is_some());
    }

    #[test]
    fn test_weekly_active_monday() {
        // 2026-03-09 = lundi
        let input = base_input(9, CycleType::Weekly);
        let r = CycleDetectorEngine::detect(&input);
        assert_eq!(r.status, CycleStatus::Active);
        assert_eq!(r.total_days, 7);
    }

    #[test]
    fn test_weekly_should_close_sunday() {
        // 2026-03-15 = dimanche
        let input = base_input(15, CycleType::Weekly);
        let r = CycleDetectorEngine::detect(&input);
        assert_eq!(r.status, CycleStatus::ShouldClose);
    }

    #[test]
    fn test_next_template_resets_charges() {
        let r = CycleDetectorEngine::detect(&base_input(31, CycleType::Monthly));
        let template = r.next_input_template.unwrap();
        // La charge doit être réinitialisée à Pending
        assert_eq!(template.charges[0].status, ChargeStatus::Pending);
        assert_eq!(template.charges[0].amount_paid, 0.0);
    }

    #[test]
    fn test_opening_balance_from_accounts() {
        let r = CycleDetectorEngine::detect(&base_input(31, CycleType::Monthly));
        let template = r.next_input_template.unwrap();
        assert!((template.suggested_opening_balance - 200_000.0).abs() < 0.01);
    }

    #[test]
    fn test_pct_elapsed_correct() {
        let r = CycleDetectorEngine::detect(&base_input(15, CycleType::Monthly));
        // 15/31 ≈ 0.484
        assert!((r.pct_elapsed - 15.0/31.0).abs() < 0.01);
    }
}
