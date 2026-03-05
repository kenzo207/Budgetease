// ============================================================
//  COUCHE 1 — MOTEUR DÉTERMINISTE
//  Calculs exacts du budget journalier.
//  Aucun apprentissage, aucun état externe.
//  Toujours déterministe : mêmes entrées → même sortie.
// ============================================================

use crate::types::*;

pub struct DeterministicEngine;

impl DeterministicEngine {
    /// Point d'entrée principal. Valide les données puis calcule tout le budget.
    /// Retourne une erreur si les données sont incohérentes.
    pub fn compute(input: &EngineInput) -> ZoltResult<DeterministicResult> {
        // Validation avant tout calcul
        input.validate()?;

        let total_balance  = Self::total_balance(&input.accounts);
        let savings_goal   = input.cycle.savings_goal;
        let transport_res  = Self::transport_reserve(&input.cycle.transport, &input.today, &input.cycle);
        let charges_res    = Self::charges_reserve(&input.charges);
        let days_remaining = Self::days_remaining(&input.today, &input.cycle);

        // ── Vérification des valeurs intermédiaires ──
        if !total_balance.is_finite() {
            return Err(ZoltError::ComputationError(
                "solde total non-fini (NaN ou inf)".into()
            ));
        }

        // ── Masse engagée = tout ce qui est déjà destiné ──
        let committed_mass = savings_goal + transport_res + charges_res;

        // ── Masse libre = ce qui est réellement disponible (jamais négatif) ──
        let free_mass = (total_balance - committed_mass).max(0.0);

        // ── Budget journalier (inclut aujourd'hui dans les jours restants) ──
        // days_remaining ≥ 1 garanti par la logique interne
        let daily_budget = free_mass / days_remaining as f64;

        // ── Dépenses du jour courant uniquement ──
        let spent_today = input.transactions.iter()
            .filter(|t| t.date == input.today && t.tx_type.is_outflow())
            .map(|t| t.amount)
            .sum::<f64>();

        // remaining_today peut être négatif (dépassement du budget)
        let remaining_today = daily_budget - spent_today;

        Ok(DeterministicResult {
            total_balance,
            committed_mass,
            free_mass,
            days_remaining,
            daily_budget,
            spent_today,
            remaining_today,
            transport_reserve: transport_res,
            charges_reserve:   charges_res,
        })
    }

    // ── Solde total consolidé de tous les comptes actifs ──
    fn total_balance(accounts: &[Account]) -> f64 {
        accounts.iter()
            .filter(|a| a.is_active)
            .map(|a| a.balance)
            .sum()
    }

    // ── Réserve transport totale pour le reste du cycle ──
    fn transport_reserve(transport: &TransportType, today: &Date, cycle: &FinancialCycle) -> f64 {
        match transport {
            TransportType::None | TransportType::Subscription => 0.0,
            TransportType::Daily { cost_per_day, work_days } => {
                let cycle_end = Self::cycle_end_date(today, cycle);
                let remaining_days = Self::count_work_days(today, &cycle_end, work_days);
                cost_per_day * remaining_days as f64
            }
        }
    }

    /// Compte les jours ouvrables réels entre today (inclus) et end (inclus).
    /// Optimisé : évite les itérations inutiles si work_days est trié.
    fn count_work_days(start: &Date, end: &Date, work_days: &[u8]) -> u32 {
        if work_days.is_empty() || start > end {
            return 0;
        }
        let total_days = (start.days_until(end) + 1).max(0) as u32;
        let start_epoch = start.to_days_since_epoch();

        (0..total_days).filter(|&i| {
            let epoch = start_epoch + i;
            // Weekday: (epoch + 3) % 7 + 1, 1=lun..7=dim
            let wd = ((epoch + 3) % 7 + 1) as u8;
            work_days.contains(&wd)
        }).count() as u32
    }

    // ── Réserve totale des charges non payées ──
    fn charges_reserve(charges: &[RecurringCharge]) -> f64 {
        charges.iter()
            .filter(|c| c.is_active && c.status != ChargeStatus::Paid)
            .map(|c| c.remaining_amount())
            .sum()
    }

    // ── Nombre de jours restants dans le cycle (inclut aujourd'hui, min 1) ──
    pub fn days_remaining(today: &Date, cycle: &FinancialCycle) -> u32 {
        let end = Self::cycle_end_date(today, cycle);
        let diff = today.days_until(&end);
        (diff + 1).max(1) as u32
    }

    /// Date de fin du cycle courant selon le type de cycle.
    pub fn cycle_end_date(today: &Date, cycle: &FinancialCycle) -> Date {
        match &cycle.cycle_type {
            CycleType::Monthly => {
                let last_day = Date::last_day_of_month_static(today.year, today.month);
                Date::new(today.year, today.month, last_day)
            }
            CycleType::Weekly => {
                // Dimanche de la semaine courante
                let wd = today.weekday(); // 1=lun, 7=dim
                let days_to_sunday = (7 - wd) as u32;
                Date::from_days_since_epoch(today.to_days_since_epoch() + days_to_sunday)
            }
            CycleType::Daily => *today,
            CycleType::Irregular { cycle_end, .. } => *cycle_end,
        }
    }

    /// Avance d'un jour (utilisé en externe par d'autres modules).
    pub fn next_day(date: &Date) -> Date {
        Date::from_days_since_epoch(date.to_days_since_epoch() + 1)
    }
}

// ────────────────────────────────────────────────────────────
//  TESTS UNITAIRES — Couche 1
// ────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;

    fn make_input(balance: f64, savings: f64, charges: Vec<RecurringCharge>) -> EngineInput {
        EngineInput {
            today: Date::new(2026, 3, 10),
            accounts: vec![Account {
                id:           "acc1".into(),
                name:         "MoMo".into(),
                account_type: AccountType::MobileMoney,
                balance,
                is_active:    true,
            }],
            charges,
            cycle: FinancialCycle {
                cycle_type:   CycleType::Monthly,
                savings_goal: savings,
                transport:    TransportType::None,
            },
            transactions: vec![],
        }
    }

    #[test]
    fn test_basic_budget_no_charges() {
        // 300 000 FCFA, épargne 30 000, pas de charges
        // Jours restants : 10 mars → 31 mars = 22 jours
        let input  = make_input(300_000.0, 30_000.0, vec![]);
        let result = DeterministicEngine::compute(&input).unwrap();

        assert_eq!(result.total_balance,  300_000.0);
        assert_eq!(result.committed_mass,  30_000.0);
        assert_eq!(result.free_mass,      270_000.0);
        assert_eq!(result.days_remaining,       22);
        let expected = 270_000.0 / 22.0;
        assert!((result.daily_budget - expected).abs() < 0.01);
    }

    #[test]
    fn test_budget_with_loyer() {
        let loyer = RecurringCharge {
            id: "c1".into(), name: "Loyer".into(),
            amount: 150_000.0, due_day: 31,
            status: ChargeStatus::Pending, amount_paid: 0.0, is_active: true,
        };
        let input  = make_input(300_000.0, 30_000.0, vec![loyer]);
        let result = DeterministicEngine::compute(&input).unwrap();

        assert!((result.committed_mass - 180_000.0).abs() < 0.01);
        assert!((result.free_mass      - 120_000.0).abs() < 0.01);
        let expected = 120_000.0 / 22.0;
        assert!((result.daily_budget   -   expected).abs() < 0.01);
    }

    #[test]
    fn test_negative_free_mass_clamped() {
        let loyer = RecurringCharge {
            id: "c1".into(), name: "Loyer".into(),
            amount: 500_000.0, due_day: 31,
            status: ChargeStatus::Pending, amount_paid: 0.0, is_active: true,
        };
        let input  = make_input(100_000.0, 30_000.0, vec![loyer]);
        let result = DeterministicEngine::compute(&input).unwrap();

        assert_eq!(result.free_mass,    0.0);
        assert_eq!(result.daily_budget, 0.0);
        assert!(result.is_insolvent());
    }

    #[test]
    fn test_paid_charge_excluded() {
        let charge = RecurringCharge {
            id: "c1".into(), name: "Electricité".into(),
            amount: 20_000.0, due_day: 15,
            status: ChargeStatus::Paid,
            amount_paid: 20_000.0, is_active: true,
        };
        let input  = make_input(200_000.0, 0.0, vec![charge]);
        let result = DeterministicEngine::compute(&input).unwrap();

        assert_eq!(result.charges_reserve, 0.0);
        assert_eq!(result.free_mass,   200_000.0);
    }

    #[test]
    fn test_partially_paid_charge() {
        let charge = RecurringCharge {
            id: "c1".into(), name: "Loyer".into(),
            amount: 150_000.0, due_day: 31,
            status: ChargeStatus::PartiallyPaid,
            amount_paid: 50_000.0, is_active: true,
        };
        let input  = make_input(200_000.0, 0.0, vec![charge]);
        let result = DeterministicEngine::compute(&input).unwrap();

        // Seulement 100 000 restants à réserver
        assert!((result.charges_reserve - 100_000.0).abs() < 0.01);
        assert!((result.free_mass       - 100_000.0).abs() < 0.01);
    }

    #[test]
    fn test_last_day_of_cycle() {
        let input = EngineInput {
            today: Date::new(2026, 3, 31),
            accounts: vec![Account {
                id: "a1".into(), name: "Cash".into(),
                account_type: AccountType::Cash,
                balance: 50_000.0, is_active: true,
            }],
            charges: vec![], transactions: vec![],
            cycle: FinancialCycle {
                cycle_type:   CycleType::Monthly,
                savings_goal: 10_000.0,
                transport:    TransportType::None,
            },
        };
        let result = DeterministicEngine::compute(&input).unwrap();
        assert_eq!(result.days_remaining, 1);
        assert_eq!(result.daily_budget, 40_000.0);
    }

    #[test]
    fn test_transport_daily_work_days() {
        // Mercredi 11 mars 2026, jours ouvrables restants jusqu'au 31 mars
        // mer 11 → ven 13 = 3 jours
        // + lun 16 → ven 20 = 5 jours
        // + lun 23 → ven 27 = 5 jours
        // + lun 30 → mar 31 = 2 jours
        // Total = 15 jours × 500 = 7 500 FCFA
        let input = EngineInput {
            today: Date::new(2026, 3, 11),
            accounts: vec![Account {
                id: "a1".into(), name: "MoMo".into(),
                account_type: AccountType::MobileMoney,
                balance: 200_000.0, is_active: true,
            }],
            charges: vec![], transactions: vec![],
            cycle: FinancialCycle {
                cycle_type:   CycleType::Monthly,
                savings_goal: 0.0,
                transport: TransportType::Daily {
                    cost_per_day: 500.0,
                    work_days: vec![1, 2, 3, 4, 5],
                },
            },
        };
        let result = DeterministicEngine::compute(&input).unwrap();
        assert_eq!(result.transport_reserve, 7_500.0);
    }

    #[test]
    fn test_weekly_cycle_end_date() {
        // Lundi 9 mars 2026 → fin de semaine = dimanche 15 mars
        let cycle = FinancialCycle {
            cycle_type: CycleType::Weekly,
            savings_goal: 0.0,
            transport: TransportType::None,
        };
        let today = Date::new(2026, 3, 9);
        let end   = DeterministicEngine::cycle_end_date(&today, &cycle);
        assert_eq!(end, Date::new(2026, 3, 15));
        assert_eq!(DeterministicEngine::days_remaining(&today, &cycle), 7);
    }

    #[test]
    fn test_irregular_cycle() {
        let input = EngineInput {
            today: Date::new(2026, 3, 15),
            accounts: vec![Account {
                id: "a1".into(), name: "Cash".into(),
                account_type: AccountType::Cash,
                balance: 100_000.0, is_active: true,
            }],
            charges: vec![], transactions: vec![],
            cycle: FinancialCycle {
                cycle_type: CycleType::Irregular {
                    cycle_start: Date::new(2026, 3, 5),
                    cycle_end:   Date::new(2026, 3, 25),
                },
                savings_goal: 0.0,
                transport: TransportType::None,
            },
        };
        let result = DeterministicEngine::compute(&input).unwrap();
        // Du 15 au 25 inclus = 11 jours
        assert_eq!(result.days_remaining, 11);
    }

    #[test]
    fn test_spent_today_reduces_remaining() {
        let mut input = make_input(200_000.0, 0.0, vec![]);
        input.today = Date::new(2026, 3, 10);
        input.transactions = vec![Transaction {
            id: "t1".into(),
            date: Date::new(2026, 3, 10),
            amount: 5_000.0,
            tx_type: TransactionType::Expense,
            category: None,
            account_id: "acc1".into(),
            description: None,
            sms_confidence: None,
        }];
        let result = DeterministicEngine::compute(&input).unwrap();
        assert!((result.spent_today - 5_000.0).abs() < 0.01);
        assert!((result.remaining_today - (result.daily_budget - 5_000.0)).abs() < 0.01);
    }

    #[test]
    fn test_income_transaction_not_counted_as_expense() {
        let mut input = make_input(200_000.0, 0.0, vec![]);
        input.transactions = vec![Transaction {
            id: "t1".into(),
            date: Date::new(2026, 3, 10),
            amount: 50_000.0,
            tx_type: TransactionType::Income, // revenu, pas dépense
            category: None,
            account_id: "acc1".into(),
            description: None,
            sms_confidence: None,
        }];
        let result = DeterministicEngine::compute(&input).unwrap();
        assert_eq!(result.spent_today, 0.0);
    }

    #[test]
    fn test_multiple_active_accounts() {
        let input = EngineInput {
            today: Date::new(2026, 3, 10),
            accounts: vec![
                Account { id: "a1".into(), name: "MoMo".into(),
                    account_type: AccountType::MobileMoney,
                    balance: 100_000.0, is_active: true },
                Account { id: "a2".into(), name: "Cash".into(),
                    account_type: AccountType::Cash,
                    balance: 50_000.0, is_active: true },
                Account { id: "a3".into(), name: "Inactif".into(),
                    account_type: AccountType::Bank,
                    balance: 999_000.0, is_active: false }, // ne compte pas
            ],
            charges: vec![], transactions: vec![],
            cycle: FinancialCycle {
                cycle_type: CycleType::Monthly,
                savings_goal: 0.0, transport: TransportType::None,
            },
        };
        let result = DeterministicEngine::compute(&input).unwrap();
        assert_eq!(result.total_balance, 150_000.0);
    }

    #[test]
    fn test_validation_error_returned() {
        let bad_input = EngineInput {
            today: Date::new(2026, 3, 10),
            accounts: vec![], // aucun compte
            charges: vec![], transactions: vec![],
            cycle: FinancialCycle {
                cycle_type: CycleType::Monthly,
                savings_goal: 0.0, transport: TransportType::None,
            },
        };
        assert!(DeterministicEngine::compute(&bad_input).is_err());
    }

    #[test]
    fn test_overdue_charge_fully_reserved() {
        let charge = RecurringCharge {
            id: "c1".into(), name: "Eau".into(),
            amount: 30_000.0, due_day: 5, // déjà passé (on est le 10)
            status: ChargeStatus::Overdue,
            amount_paid: 0.0, is_active: true,
        };
        let input = make_input(200_000.0, 0.0, vec![charge]);
        let result = DeterministicEngine::compute(&input).unwrap();
        // Overdue ≠ Paid → entièrement réservé
        assert!((result.charges_reserve - 30_000.0).abs() < 0.01);
    }

    #[test]
    fn test_daily_cycle() {
        let input = EngineInput {
            today: Date::new(2026, 3, 10),
            accounts: vec![Account {
                id: "a1".into(), name: "Cash".into(),
                account_type: AccountType::Cash,
                balance: 10_000.0, is_active: true,
            }],
            charges: vec![], transactions: vec![],
            cycle: FinancialCycle {
                cycle_type: CycleType::Daily,
                savings_goal: 0.0, transport: TransportType::None,
            },
        };
        let result = DeterministicEngine::compute(&input).unwrap();
        assert_eq!(result.days_remaining, 1);
        assert_eq!(result.daily_budget, 10_000.0);
    }
}
