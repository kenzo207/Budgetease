// ============================================================
//  COUCHE 1 — MOTEUR DÉTERMINISTE
//  Calculs exacts du budget journalier.
//  Aucun apprentissage, aucun état externe.
//  Toujours déterministe : mêmes entrées → même sortie.
// ============================================================

use crate::types::*;

pub struct DeterministicEngine;

impl DeterministicEngine {
    /// Point d'entrée principal. Calcule tout le budget en une passe.
    pub fn compute(input: &EngineInput) -> DeterministicResult {
        let total_balance   = Self::total_balance(&input.accounts);
        let savings_goal    = input.cycle.savings_goal;
        let transport_res   = Self::transport_reserve(&input.cycle.transport, &input.today, &input.cycle);
        let charges_res     = Self::charges_reserve(&input.charges, &input.today);
        let days_remaining  = Self::days_remaining(&input.today, &input.cycle);

        // ── Masse engagée = tout ce qui est déjà destiné ──
        let committed_mass = savings_goal + transport_res + charges_res;

        // ── Masse libre = ce qui est réellement disponible ──
        let free_mass = (total_balance - committed_mass).max(0.0);

        // ── Budget journalier ──
        let daily_budget = if days_remaining == 0 {
            // Dernier jour du cycle : tout ce qui reste est dispo aujourd'hui
            free_mass
        } else {
            free_mass / days_remaining as f64
        };

        // ── Dépenses du jour courant uniquement ──
        let spent_today = input.transactions.iter()
            .filter(|t| t.date == input.today && t.tx_type.is_outflow())
            .map(|t| t.amount)
            .sum::<f64>();

        let remaining_today = daily_budget - spent_today;

        DeterministicResult {
            total_balance,
            committed_mass,
            free_mass,
            days_remaining,
            daily_budget,
            spent_today,
            remaining_today,
            transport_reserve: transport_res,
            charges_reserve:   charges_res,
        }
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
            TransportType::None => 0.0,
            // Abonnement → géré comme charge fixe, pas ici
            TransportType::Subscription => 0.0,
            TransportType::Daily { cost_per_day, work_days } => {
                let cycle_end     = Self::cycle_end_date(today, cycle);
                let remaining_days = Self::count_work_days(today, &cycle_end, work_days);
                cost_per_day * remaining_days as f64
            }
        }
    }

    /// Compte les jours ouvrables réels entre today (inclus) et end (inclus).
    fn count_work_days(start: &Date, end: &Date, work_days: &[u8]) -> u32 {
        let mut count  = 0u32;
        let mut cursor = *start;
        // Itère jour par jour — au maximum 31 jours, coût négligeable
        while cursor <= *end {
            if work_days.contains(&cursor.weekday()) {
                count += 1;
            }
            cursor = Self::next_day(&cursor);
        }
        count
    }

    // ── Réserve totale des charges non payées ──
    fn charges_reserve(charges: &[RecurringCharge], today: &Date) -> f64 {
        charges.iter()
            .filter(|c| c.is_active && c.status != ChargeStatus::Paid)
            .map(|c| c.remaining_amount())
            .sum()
        // Note : on prend le montant TOTAL restant de chaque charge,
        // pas la réserve journalière — conformément à la logique de masse engagée.
        // La réserve journalière (daily_reserve) est utilisée uniquement
        // dans les alertes de pression (module B), pas dans le calcul central.
    }

    // ── Nombre de jours restants dans le cycle (inclut aujourd'hui) ──
    pub fn days_remaining(today: &Date, cycle: &FinancialCycle) -> u32 {
        let end = Self::cycle_end_date(today, cycle);
        let diff = today.days_until(&end);
        (diff + 1).max(1) as u32  // +1 = aujourd'hui inclus, min 1
    }

    /// Date de fin du cycle courant selon le type de cycle.
    pub fn cycle_end_date(today: &Date, cycle: &FinancialCycle) -> Date {
        match &cycle.cycle_type {
            CycleType::Monthly => {
                // Dernier jour du mois en cours
                let last_day = Self::last_day_of_month(today.year, today.month);
                Date::new(today.year, today.month, last_day)
            }
            CycleType::Weekly => {
                // Dimanche de la semaine en cours
                let days_to_sunday = 7 - today.weekday(); // weekday: 1=lun, 7=dim
                let mut end = *today;
                for _ in 0..days_to_sunday {
                    end = Self::next_day(&end);
                }
                end
            }
            CycleType::Daily => *today,
            CycleType::Irregular { cycle_end, .. } => *cycle_end,
        }
    }

    fn last_day_of_month(year: u16, month: u8) -> u8 {
        match month {
            1 | 3 | 5 | 7 | 8 | 10 | 12 => 31,
            4 | 6 | 9 | 11              => 30,
            2 => {
                let y = year as u32;
                if y % 400 == 0 || (y % 4 == 0 && y % 100 != 0) { 29 } else { 28 }
            }
            _ => 30, // ne devrait pas arriver
        }
    }

    pub fn next_day(date: &Date) -> Date {
        let last = Self::last_day_of_month(date.year, date.month);
        if date.day < last {
            Date::new(date.year, date.month, date.day + 1)
        } else if date.month < 12 {
            Date::new(date.year, date.month + 1, 1)
        } else {
            Date::new(date.year + 1, 1, 1)
        }
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
        let result = DeterministicEngine::compute(&input);

        assert_eq!(result.total_balance,    300_000.0);
        assert_eq!(result.committed_mass,    30_000.0);
        assert_eq!(result.free_mass,        270_000.0);
        assert_eq!(result.days_remaining,        22);
        // 270 000 / 22 = 12 272.72...
        let expected = 270_000.0 / 22.0;
        assert!((result.daily_budget - expected).abs() < 0.01);
    }

    #[test]
    fn test_budget_with_loyer() {
        // 300 000 FCFA, épargne 30 000, loyer 150 000 FCFA dû le 31
        let loyer = RecurringCharge {
            id:          "c1".into(),
            name:        "Loyer".into(),
            amount:      150_000.0,
            due_day:     31,
            status:      ChargeStatus::Pending,
            amount_paid: 0.0,
            is_active:   true,
        };
        let input  = make_input(300_000.0, 30_000.0, vec![loyer]);
        let result = DeterministicEngine::compute(&input);

        // Masse engagée = 30 000 + 150 000 = 180 000
        // Masse libre   = 300 000 - 180 000 = 120 000
        // Jours         = 22
        // B_j           = 120 000 / 22 = 5 454.54...
        assert!((result.committed_mass - 180_000.0).abs() < 0.01);
        assert!((result.free_mass      - 120_000.0).abs() < 0.01);
        let expected = 120_000.0 / 22.0;
        assert!((result.daily_budget   -   expected).abs() < 0.01);
    }

    #[test]
    fn test_negative_free_mass_clamped() {
        // Solde insuffisant pour couvrir les engagements
        let loyer = RecurringCharge {
            id: "c1".into(), name: "Loyer".into(),
            amount: 500_000.0, due_day: 31,
            status: ChargeStatus::Pending, amount_paid: 0.0, is_active: true,
        };
        let input  = make_input(100_000.0, 30_000.0, vec![loyer]);
        let result = DeterministicEngine::compute(&input);

        // Masse libre < 0 → clampée à 0, budget = 0
        assert_eq!(result.free_mass,    0.0);
        assert_eq!(result.daily_budget, 0.0);
    }

    #[test]
    fn test_paid_charge_excluded() {
        let charge = RecurringCharge {
            id: "c1".into(), name: "Electricité".into(),
            amount: 20_000.0, due_day: 15,
            status: ChargeStatus::Paid,  // déjà payée
            amount_paid: 20_000.0, is_active: true,
        };
        let input  = make_input(200_000.0, 0.0, vec![charge]);
        let result = DeterministicEngine::compute(&input);

        // Charge payée → masse engagée = 0
        assert_eq!(result.charges_reserve, 0.0);
        assert_eq!(result.free_mass,   200_000.0);
    }

    #[test]
    fn test_last_day_of_cycle() {
        // Dernier jour : days_remaining = 1, daily_budget = free_mass
        let input = EngineInput {
            today: Date::new(2026, 3, 31),
            accounts: vec![Account {
                id: "a1".into(), name: "Cash".into(),
                account_type: AccountType::Cash,
                balance: 50_000.0, is_active: true,
            }],
            charges:      vec![],
            transactions: vec![],
            cycle: FinancialCycle {
                cycle_type:   CycleType::Monthly,
                savings_goal: 10_000.0,
                transport:    TransportType::None,
            },
        };
        let result = DeterministicEngine::compute(&input);
        assert_eq!(result.days_remaining,  1);
        assert_eq!(result.daily_budget,  40_000.0);
    }

    #[test]
    fn test_transport_daily_work_days() {
        // Transport 500 FCFA/j, lun-ven, aujourd'hui = mercredi 11 mars 2026
        // Jours ouvrables restants jusqu'au 31 mars : mer 11 → ven 13 (3)
        // + sem 16-20 (5) + sem 23-27 (5) + sem 30-31 (2) = 15 jours
        let input = EngineInput {
            today: Date::new(2026, 3, 11),
            accounts: vec![Account {
                id: "a1".into(), name: "MoMo".into(),
                account_type: AccountType::MobileMoney,
                balance: 200_000.0, is_active: true,
            }],
            charges: vec![],
            transactions: vec![],
            cycle: FinancialCycle {
                cycle_type:   CycleType::Monthly,
                savings_goal: 0.0,
                transport:    TransportType::Daily {
                    cost_per_day: 500.0,
                    work_days: vec![1, 2, 3, 4, 5], // lun-ven
                },
            },
        };
        let result = DeterministicEngine::compute(&input);
        // Transport = 15 × 500 = 7 500
        assert_eq!(result.transport_reserve, 7_500.0);
    }
}
