// ============================================================
//  MODULE CHARGE TRACKER — Suivi des paiements partiels
//  Calcule l'état exact de chaque charge : payé, restant dû,
//  retard, réserve journalière nécessaire, alerte contextuelle.
// ============================================================

use crate::types::*;

pub struct ChargeTrackerEngine;

impl ChargeTrackerEngine {
    pub fn track(charges: &[RecurringCharge], today: &Date) -> Vec<ChargeTrackingResult> {
        charges.iter()
            .filter(|c| c.is_active)
            .map(|c| Self::track_one(c, today))
            .collect()
    }

    fn track_one(charge: &RecurringCharge, today: &Date) -> ChargeTrackingResult {
        let remaining        = charge.remaining_amount().max(0.0);
        let is_fully_paid    = remaining <= 0.0;

        // Calcule les jours jusqu'à la date d'échéance
        let max_day     = Date::last_day_of_month_static(today.year, today.month);
        let effective   = charge.due_day.min(max_day);
        let due_date    = Date::new(today.year, today.month, effective);
        let days_until  = today.days_until(&due_date);
        let is_overdue  = days_until < 0 && !is_fully_paid;

        // Réserve journalière encore nécessaire
        let daily_reserve = if is_fully_paid {
            0.0
        } else {
            let days_left = days_until.max(1) as f64;
            remaining / days_left
        };

        let alert = Self::build_alert(charge, remaining, days_until, is_overdue, is_fully_paid);

        ChargeTrackingResult {
            charge_id:   charge.id.clone(),
            charge_name: charge.name.clone(),
            total_amount: charge.amount,
            paid_amount:  charge.amount_paid,
            remaining,
            is_fully_paid,
            is_overdue,
            days_until_due: days_until,
            daily_reserve_needed: daily_reserve,
            alert,
        }
    }

    fn build_alert(
        charge:       &RecurringCharge,
        remaining:    f64,
        days_until:   i32,
        is_overdue:   bool,
        is_fully_paid: bool,
    ) -> Option<ConversationalMessage> {
        if is_fully_paid { return None; }

        if is_overdue {
            return Some(ConversationalMessage {
                level: AlertLevel::Critical,
                title: format!("⚠️ {} — En retard", charge.name),
                body:  format!(
                    "{:.0} FCFA non payés depuis {} jour(s). Régularise dès que possible.",
                    remaining, (-days_until)
                ),
                ttl_days: None,
            });
        }

        match days_until {
            0 => Some(ConversationalMessage {
                level: AlertLevel::Critical,
                title: format!("{} — À payer aujourd'hui", charge.name),
                body:  format!("{:.0} FCFA à régler aujourd'hui.", remaining),
                ttl_days: Some(1),
            }),
            1 => Some(ConversationalMessage {
                level: AlertLevel::Warning,
                title: format!("{} — Demain", charge.name),
                body:  format!("{:.0} FCFA à prévoir pour demain.", remaining),
                ttl_days: Some(2),
            }),
            2..=5 => Some(ConversationalMessage {
                level: AlertLevel::Info,
                title: format!("{} dans {} jours", charge.name, days_until),
                body:  format!(
                    "Prévois {:.0} FCFA/jour pour couvrir {:.0} FCFA d'ici {} jours.",
                    remaining / days_until as f64, remaining, days_until
                ),
                ttl_days: Some(days_until as u32 + 1),
            }),
            _ => {
                // Avertissement si paiement partiel avancé
                if charge.amount_paid > 0.0 {
                    Some(ConversationalMessage {
                        level: AlertLevel::Positive,
                        title: format!("{} — Paiement partiel enregistré", charge.name),
                        body:  format!(
                            "{:.0} FCFA payés sur {:.0} FCFA. Reste {:.0} FCFA.",
                            charge.amount_paid, charge.amount, remaining
                        ),
                        ttl_days: Some(3),
                    })
                } else {
                    None
                }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────
//  MODULE DATA INTEGRITY — Validation de l'état global
// ─────────────────────────────────────────────────────────────

pub struct DataIntegrityEngine;

impl DataIntegrityEngine {
    pub fn check(input: &EngineInput, history: &[CycleRecord]) -> IntegrityReport {
        let mut errors:     Vec<IntegrityError> = Vec::new();
        let mut warnings:   Vec<String>         = Vec::new();
        let mut auto_fixed: Vec<String>         = Vec::new();

        // ── Validation de base ────────────────────────────────
        if let Err(e) = input.validate() {
            errors.push(IntegrityError {
                code:    "INVALID_INPUT".into(),
                message: e.to_string(),
                fatal:   true,
            });
        }

        // ── Comptes ───────────────────────────────────────────
        let active_accounts: Vec<_> = input.accounts.iter().filter(|a| a.is_active).collect();

        if active_accounts.is_empty() {
            errors.push(IntegrityError {
                code: "NO_ACTIVE_ACCOUNT".into(),
                message: "Aucun compte actif. Le calcul du budget est impossible.".into(),
                fatal: true,
            });
        }

        for acc in &input.accounts {
            if !acc.balance.is_finite() {
                errors.push(IntegrityError {
                    code:    format!("ACCOUNT_BALANCE_NAN_{}", acc.id),
                    message: format!("Solde non-fini pour le compte '{}'", acc.name),
                    fatal:   false,
                });
            }
            if acc.balance < 0.0 && acc.account_type != AccountType::Bank {
                warnings.push(format!(
                    "Compte '{}' a un solde négatif ({:.0} FCFA). Vérifier si normal.",
                    acc.name, acc.balance
                ));
            }
        }

        // ── Charges ───────────────────────────────────────────
        let total_charges: f64 = input.charges.iter()
            .filter(|c| c.is_active)
            .map(|c| c.amount)
            .sum();
        let total_balance: f64 = active_accounts.iter().map(|a| a.balance).sum();

        if total_charges > total_balance * 1.5 {
            warnings.push(format!(
                "Total des charges ({:.0} FCFA) très supérieur au solde total ({:.0} FCFA).",
                total_charges, total_balance
            ));
        }

        for charge in &input.charges {
            if let Err(e) = charge.validate() {
                errors.push(IntegrityError {
                    code:    format!("INVALID_CHARGE_{}", charge.id),
                    message: e.to_string(),
                    fatal:   false,
                });
            }
            if charge.amount_paid > charge.amount {
                warnings.push(format!(
                    "Charge '{}': montant payé ({:.0}) > montant total ({:.0}). Possible erreur de saisie.",
                    charge.name, charge.amount_paid, charge.amount
                ));
            }
        }

        // ── Transactions ──────────────────────────────────────
        let mut tx_ids = std::collections::HashSet::new();
        for tx in &input.transactions {
            if !tx_ids.insert(tx.id.clone()) {
                errors.push(IntegrityError {
                    code:    format!("DUPLICATE_TX_{}", tx.id),
                    message: format!("Transaction en double: id={}", tx.id),
                    fatal:   false,
                });
            }
            if !tx.amount.is_finite() || tx.amount <= 0.0 {
                errors.push(IntegrityError {
                    code:    format!("INVALID_TX_AMOUNT_{}", tx.id),
                    message: format!("Montant invalide pour la transaction {}", tx.id),
                    fatal:   false,
                });
            }
        }

        // ── Historique ────────────────────────────────────────
        let valid_history: Vec<_> = history.iter().filter(|r| r.validate().is_ok()).collect();
        let invalid_count = history.len() - valid_history.len();

        if invalid_count > 0 {
            auto_fixed.push(format!(
                "{} cycle(s) corrompus dans l'historique filtrés automatiquement.",
                invalid_count
            ));
        }

        // Vérifie la chronologie de l'historique
        for i in 1..history.len() {
            if history[i].cycle_start < history[i-1].cycle_end {
                warnings.push(format!(
                    "Chevauchement de cycles entre {} et {}.",
                    history[i-1].cycle_end, history[i].cycle_start
                ));
            }
        }

        // ── Score de confiance ────────────────────────────────
        let fatal_count   = errors.iter().filter(|e| e.fatal).count();
        let error_count   = errors.len();
        let warning_count = warnings.len();

        let data_confidence: u8 = if fatal_count > 0 {
            0
        } else {
            let penalty = (error_count * 15 + warning_count * 5).min(100);
            (100 - penalty) as u8
        };

        IntegrityReport {
            is_valid:    fatal_count == 0,
            errors,
            warnings,
            auto_fixed,
            data_confidence,
        }
    }
}

// ─────────────────────────────────────────────────────────────
//  MODULE ONBOARDING — Validation et construction de l'EngineInput
// ─────────────────────────────────────────────────────────────

pub struct OnboardingEngine;

impl OnboardingEngine {
    pub fn build(input: &OnboardingInput) -> OnboardingResult {
        let mut errors: Vec<String> = Vec::new();

        // ── Prénom ────────────────────────────────────────────
        if input.first_name.trim().is_empty() {
            errors.push("Le prénom est requis.".into());
        }

        // ── Devise ────────────────────────────────────────────
        let supported_currencies = ["FCFA", "EUR", "USD", "GHS", "NGN", "XOF", "XAF"];
        if !supported_currencies.contains(&input.currency.as_str()) {
            errors.push(format!(
                "Devise '{}' non supportée. Devises disponibles: {}",
                input.currency,
                supported_currencies.join(", ")
            ));
        }

        // ── Comptes ───────────────────────────────────────────
        if input.accounts.is_empty() {
            errors.push("Au moins un compte est requis.".into());
        }

        let total_balance: f64 = input.accounts.iter().map(|a| a.balance).sum();
        if !total_balance.is_finite() || total_balance < 0.0 {
            errors.push("Le solde total des comptes doit être positif.".into());
        }

        // ── Charges ───────────────────────────────────────────
        for (i, charge) in input.charges.iter().enumerate() {
            if charge.name.trim().is_empty() {
                errors.push(format!("Charge #{} : le nom est requis.", i + 1));
            }
            if charge.amount <= 0.0 {
                errors.push(format!("Charge '{}' : le montant doit être positif.", charge.name));
            }
            if charge.due_day == 0 || charge.due_day > 31 {
                errors.push(format!("Charge '{}' : jour d'échéance invalide ({}).", charge.name, charge.due_day));
            }
        }

        // ── Épargne ───────────────────────────────────────────
        if input.savings_goal < 0.0 {
            errors.push("L'objectif d'épargne ne peut pas être négatif.".into());
        }

        // ── Transport ─────────────────────────────────────────
        let transport = Self::build_transport(input, &mut errors);

        if !errors.is_empty() {
            return OnboardingResult { engine_input: None, validation_errors: errors, is_ready: false };
        }

        // ── Construction de l'EngineInput ─────────────────────
        let accounts: Vec<Account> = input.accounts.iter().enumerate().map(|(i, a)| {
            Account {
                id:           format!("acc_{}", i),
                name:         a.name.clone(),
                account_type: Self::parse_account_type(&a.account_type),
                balance:      a.balance,
                is_active:    true,
            }
        }).collect();

        let charges: Vec<RecurringCharge> = input.charges.iter().enumerate().map(|(i, c)| {
            RecurringCharge {
                id:           format!("charge_{}", i),
                name:         c.name.clone(),
                amount:       c.amount,
                due_day:      c.due_day,
                status:       ChargeStatus::Pending,
                amount_paid:  0.0,
                is_active:    true,
            }
        }).collect();

        let engine_input = EngineInput {
            today:    input.today,
            accounts,
            charges,
            transactions: vec![],
            cycle: FinancialCycle {
                cycle_type:   input.cycle_type.clone(),
                savings_goal: input.savings_goal,
                transport,
            },
        };

        // Validation finale
        if let Err(e) = engine_input.validate() {
            return OnboardingResult {
                engine_input: None,
                validation_errors: vec![e.to_string()],
                is_ready: false,
            };
        }

        OnboardingResult { engine_input: Some(engine_input), validation_errors: vec![], is_ready: true }
    }

    fn build_transport(input: &OnboardingInput, errors: &mut Vec<String>) -> TransportType {
        match input.transport_type.as_str() {
            "None" | "none" | "" => TransportType::None,
            "Fixed" | "fixed" => {
                match input.transport_cost {
                    Some(cost) if cost > 0.0 => TransportType::Fixed { monthly_cost: cost },
                    _ => {
                        errors.push("Transport fixe : le coût mensuel est requis.".into());
                        TransportType::None
                    }
                }
            }
            "Daily" | "daily" => {
                let cost = input.transport_cost.unwrap_or(0.0);
                let days = input.transport_days.clone().unwrap_or_default();
                if cost <= 0.0 {
                    errors.push("Transport quotidien : le coût par jour est requis.".into());
                }
                if days.is_empty() {
                    errors.push("Transport quotidien : les jours de travail sont requis.".into());
                }
                TransportType::Daily { cost_per_day: cost, work_days: days }
            }
            other => {
                errors.push(format!("Type de transport inconnu: '{}'", other));
                TransportType::None
            }
        }
    }

    fn parse_account_type(s: &str) -> AccountType {
        match s.to_lowercase().as_str() {
            "cash"         => AccountType::Cash,
            "mobilemoney" | "mobile_money" | "momo" => AccountType::MobileMoney,
            "bank" | "banque" => AccountType::Bank,
            "savings" | "epargne" | "épargne" => AccountType::Savings,
            _              => AccountType::Cash,
        }
    }
}

// ─────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;

    // ── ChargeTracker ─────────────────────────────────────────
    fn make_charge(due_day: u8, amount: f64, paid: f64, status: ChargeStatus) -> RecurringCharge {
        RecurringCharge {
            id: "c1".into(), name: "Loyer".into(),
            amount, due_day, status, amount_paid: paid, is_active: true,
        }
    }

    #[test]
    fn test_fully_paid_no_alert() {
        let charges = vec![make_charge(15, 120_000.0, 120_000.0, ChargeStatus::Paid)];
        let r = ChargeTrackerEngine::track(&charges, &Date::new(2026, 3, 10));
        assert!(r[0].is_fully_paid);
        assert!(r[0].alert.is_none());
        assert_eq!(r[0].remaining, 0.0);
    }

    #[test]
    fn test_overdue_critical_alert() {
        let charges = vec![make_charge(5, 120_000.0, 0.0, ChargeStatus::Pending)];
        let r = ChargeTrackerEngine::track(&charges, &Date::new(2026, 3, 10));
        assert!(r[0].is_overdue);
        assert!(r[0].alert.as_ref().unwrap().level == AlertLevel::Critical);
    }

    #[test]
    fn test_due_today_critical() {
        let charges = vec![make_charge(15, 120_000.0, 0.0, ChargeStatus::Pending)];
        let r = ChargeTrackerEngine::track(&charges, &Date::new(2026, 3, 15));
        assert_eq!(r[0].days_until_due, 0);
        assert_eq!(r[0].alert.as_ref().unwrap().level, AlertLevel::Critical);
    }

    #[test]
    fn test_partial_payment_tracked() {
        let charges = vec![make_charge(25, 120_000.0, 50_000.0, ChargeStatus::Pending)];
        let r = ChargeTrackerEngine::track(&charges, &Date::new(2026, 3, 10));
        assert!((r[0].remaining - 70_000.0).abs() < 0.01);
        assert!((r[0].paid_amount - 50_000.0).abs() < 0.01);
    }

    #[test]
    fn test_inactive_charge_excluded() {
        let charges = vec![RecurringCharge {
            id: "c1".into(), name: "Test".into(), amount: 10_000.0,
            due_day: 15, status: ChargeStatus::Pending, amount_paid: 0.0,
            is_active: false, // inactif
        }];
        let r = ChargeTrackerEngine::track(&charges, &Date::new(2026, 3, 10));
        assert!(r.is_empty());
    }

    // ── DataIntegrity ─────────────────────────────────────────
    fn valid_input() -> EngineInput {
        EngineInput {
            today: Date::new(2026, 3, 15),
            accounts: vec![Account {
                id: "a1".into(), name: "MoMo".into(),
                account_type: AccountType::MobileMoney,
                balance: 200_000.0, is_active: true,
            }],
            charges: vec![], transactions: vec![],
            cycle: FinancialCycle {
                cycle_type: CycleType::Monthly,
                savings_goal: 0.0, transport: TransportType::None,
            },
        }
    }

    #[test]
    fn test_valid_input_clean_report() {
        let r = DataIntegrityEngine::check(&valid_input(), &[]);
        assert!(r.is_valid);
        assert!(r.errors.is_empty());
        assert_eq!(r.data_confidence, 100);
    }

    #[test]
    fn test_no_active_account_fatal() {
        let mut input = valid_input();
        input.accounts[0].is_active = false;
        let r = DataIntegrityEngine::check(&input, &[]);
        assert!(!r.is_valid);
        assert!(r.errors.iter().any(|e| e.fatal));
    }

    #[test]
    fn test_duplicate_tx_detected() {
        let mut input = valid_input();
        let tx = Transaction {
            id: "dup".into(), date: Date::new(2026, 3, 1),
            amount: 5000.0, tx_type: TransactionType::Expense,
            category: None, account_id: "a1".into(),
            description: None, sms_confidence: None,
        };
        input.transactions = vec![tx.clone(), tx];
        let r = DataIntegrityEngine::check(&input, &[]);
        assert!(r.errors.iter().any(|e| e.code.contains("DUPLICATE_TX")));
    }

    #[test]
    fn test_corrupted_history_auto_fixed() {
        let bad_record = CycleRecord {
            cycle_start: Date::new(2026, 3, 1),
            cycle_end:   Date::new(2026, 2, 28), // incohérent !
            ..CycleRecord::default()
        };
        let r = DataIntegrityEngine::check(&valid_input(), &[bad_record]);
        assert!(!r.auto_fixed.is_empty());
    }

    // ── Onboarding ────────────────────────────────────────────
    fn valid_onboarding() -> OnboardingInput {
        OnboardingInput {
            first_name: "Kofi".into(),
            currency: "FCFA".into(),
            cycle_type: CycleType::Monthly,
            accounts: vec![AccountOnboarding {
                name: "MTN MoMo".into(), account_type: "MobileMoney".into(),
                balance: 250_000.0, operator: Some("MTN".into()),
            }],
            charges: vec![ChargeOnboarding {
                name: "Loyer".into(), amount: 120_000.0, due_day: 5,
            }],
            transport_type: "None".into(),
            transport_cost: None, transport_days: None,
            savings_goal: 25_000.0,
            today: Date::new(2026, 3, 15),
        }
    }

    #[test]
    fn test_valid_onboarding_builds_engine_input() {
        let r = OnboardingEngine::build(&valid_onboarding());
        assert!(r.is_ready, "{:?}", r.validation_errors);
        assert!(r.engine_input.is_some());
        assert!(r.validation_errors.is_empty());
    }

    #[test]
    fn test_empty_name_fails() {
        let mut input = valid_onboarding();
        input.first_name = "".into();
        let r = OnboardingEngine::build(&input);
        assert!(!r.is_ready);
        assert!(r.validation_errors.iter().any(|e| e.contains("prénom")));
    }

    #[test]
    fn test_invalid_currency_fails() {
        let mut input = valid_onboarding();
        input.currency = "INVALID".into();
        let r = OnboardingEngine::build(&input);
        assert!(!r.is_ready);
        assert!(r.validation_errors.iter().any(|e| e.contains("Devise")));
    }

    #[test]
    fn test_no_accounts_fails() {
        let mut input = valid_onboarding();
        input.accounts = vec![];
        let r = OnboardingEngine::build(&input);
        assert!(!r.is_ready);
    }

    #[test]
    fn test_daily_transport_missing_cost_fails() {
        let mut input = valid_onboarding();
        input.transport_type = "Daily".into();
        input.transport_cost = None;
        input.transport_days = Some(vec![1, 2, 3, 4, 5]);
        let r = OnboardingEngine::build(&input);
        assert!(!r.is_ready);
        assert!(r.validation_errors.iter().any(|e| e.contains("Transport")));
    }

    #[test]
    fn test_onboarding_charges_initialized_as_pending() {
        let r = OnboardingEngine::build(&valid_onboarding());
        let input = r.engine_input.unwrap();
        assert_eq!(input.charges[0].status, ChargeStatus::Pending);
        assert_eq!(input.charges[0].amount_paid, 0.0);
    }
}
