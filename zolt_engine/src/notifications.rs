// ============================================================
//  MODULE NOTIFICATIONS — Décisions de notification
//  Le moteur décide QUOI et QUAND notifier.
//  Flutter déclenche juste ce qu'on lui demande.
//  Toute la logique métier "doit-on notifier ?" est ici.
// ============================================================

use crate::types::*;
use crate::adaptive::AdaptiveOutput;

pub struct NotificationsEngine;

impl NotificationsEngine {
    pub fn compute(
        det:          &DeterministicResult,
        adaptive:     &AdaptiveOutput,
        input:        &EngineInput,
        income_pred:  Option<&IncomePrediction>,
    ) -> Vec<NotificationTrigger> {
        let mut notifs: Vec<NotificationTrigger> = Vec::new();

        // ── 1. Alerte dépassement de budget ──────────────────────
        if let Some(n) = Self::budget_alert(det, &input.today) {
            notifs.push(n);
        }

        // ── 2. Rappel budget quotidien (1x/jour à déclencher au matin) ──
        if let Some(n) = Self::daily_reminder(det, &input.today) {
            notifs.push(n);
        }

        // ── 3. Charges imminentes ────────────────────────────────
        notifs.extend(Self::upcoming_charges(&input.charges, &input.today));

        // ── 4. Alerte prédiction critique ────────────────────────
        if let Some(n) = Self::prediction_alert(&adaptive.prediction, det) {
            notifs.push(n);
        }

        // ── 5. Anomalie Ghost Money ───────────────────────────────
        if let Some(n) = Self::ghost_money_alert(&adaptive.anomalies) {
            notifs.push(n);
        }

        // ── 6. Revenu attendu ────────────────────────────────────
        if let Some(n) = Self::income_reminder(income_pred, &input.today) {
            notifs.push(n);
        }

        // Déduplique par dedup_key (garde le premier)
        Self::deduplicate(notifs)
    }

    // ── Budget dépassé ────────────────────────────────────────────
    fn budget_alert(det: &DeterministicResult, today: &Date) -> Option<NotificationTrigger> {
        if !det.is_over_budget() { return None; }
        let overage = det.spent_today - det.daily_budget;
        Some(NotificationTrigger {
            channel:    NotificationChannel::BudgetAlerts,
            priority:   NotificationPriority::High,
            title:      "Budget dépassé aujourd'hui".into(),
            body:       format!(
                "Tu as dépassé ton budget de {:.0} FCFA. Évite de dépenser jusqu'à demain.",
                overage
            ),
            delay_secs: 0,
            dedup_key:  format!("budget_alert_{}_{}_{}", today.year, today.month, today.day),
        })
    }

    // ── Rappel matinal ────────────────────────────────────────────
    fn daily_reminder(det: &DeterministicResult, today: &Date) -> Option<NotificationTrigger> {
        if det.daily_budget <= 0.0 { return None; }
        Some(NotificationTrigger {
            channel:    NotificationChannel::Reminders,
            priority:   NotificationPriority::Normal,
            title:      "Ton budget du jour".into(),
            body:       format!(
                "Tu as {:.0} FCFA disponibles aujourd'hui. Bonne journée !",
                det.daily_budget
            ),
            delay_secs: 0, // Flutter planifie à l'heure souhaitée
            dedup_key:  format!("daily_reminder_{}_{}_{}", today.year, today.month, today.day),
        })
    }

    // ── Charges imminentes (dans les 3 jours) ─────────────────────
    fn upcoming_charges(charges: &[RecurringCharge], today: &Date) -> Vec<NotificationTrigger> {
        charges.iter()
            .filter(|c| c.is_active && c.status != ChargeStatus::Paid)
            .filter_map(|charge| {
                let max_day = Date::last_day_of_month_static(today.year, today.month);
                let effective_day = charge.due_day.min(max_day);
                let due_date = Date::new(today.year, today.month, effective_day);
                let days_until = today.days_until(&due_date);

                // Notifie à J-3, J-1 et J0
                if !(0..=3).contains(&days_until) { return None; }

                let (title, body, priority) = if days_until == 0 {
                    (
                        format!("Charge due aujourd'hui : {}", charge.name),
                        format!("{:.0} FCFA à payer aujourd'hui.", charge.remaining_amount()),
                        NotificationPriority::High,
                    )
                } else if days_until == 1 {
                    (
                        format!("Demain : {}", charge.name),
                        format!("{:.0} FCFA à payer demain. Assure-toi d'avoir les fonds.", charge.remaining_amount()),
                        NotificationPriority::High,
                    )
                } else {
                    (
                        format!("Dans {} jours : {}", days_until, charge.name),
                        format!("{:.0} FCFA à payer dans {} jours.", charge.remaining_amount(), days_until),
                        NotificationPriority::Normal,
                    )
                };

                Some(NotificationTrigger {
                    channel: NotificationChannel::RecurringCharges,
                    priority,
                    title,
                    body,
                    delay_secs: 0,
                    dedup_key: format!("charge_{}_{}_{}_{}",
                        charge.id, today.year, today.month, days_until),
                })
            })
            .collect()
    }

    // ── Alerte prédiction déficit ─────────────────────────────────
    fn prediction_alert(
        pred: &Option<EndOfCyclePrediction>,
        det:  &DeterministicResult,
    ) -> Option<NotificationTrigger> {
        let pred = pred.as_ref()?;
        if pred.confidence < 0.4 { return None; }
        if pred.projected_deficit <= 0.0 { return None; }
        if pred.alert_level != AlertLevel::Critical { return None; }

        let reduction = pred.projected_deficit / det.days_remaining.max(1) as f64;
        Some(NotificationTrigger {
            channel:    NotificationChannel::BudgetAlerts,
            priority:   NotificationPriority::High,
            title:      "Fin de mois difficile en vue".into(),
            body:       format!(
                "À ce rythme, il te manquera {:.0} FCFA. \
                 Réduis de {:.0} FCFA/jour pour éviter le déficit.",
                pred.projected_deficit, reduction
            ),
            delay_secs: 0,
            dedup_key:  "prediction_deficit".into(),
        })
    }

    // ── Ghost Money ───────────────────────────────────────────────
    fn ghost_money_alert(anomalies: &[Anomaly]) -> Option<NotificationTrigger> {
        let ghost = anomalies.iter().find(|a| {
            !a.dismissed && matches!(a.anomaly_type, AnomalyType::GhostMoney { .. })
        })?;

        if let AnomalyType::GhostMoney { total, transaction_count, .. } = &ghost.anomaly_type {
            return Some(NotificationTrigger {
                channel:    NotificationChannel::BudgetAlerts,
                priority:   NotificationPriority::Normal,
                title:      "💸 Argent fantôme détecté".into(),
                body:       format!(
                    "{} petites dépenses = {:.0} FCFA cette semaine. Ça s'accumule !",
                    transaction_count, total
                ),
                delay_secs: 0,
                dedup_key:  format!("ghost_money_{}_{}", ghost.detected_on.year, ghost.detected_on.month),
            });
        }
        None
    }

    // ── Revenu attendu ─────────────────────────────────────────────
    fn income_reminder(pred: Option<&IncomePrediction>, today: &Date) -> Option<NotificationTrigger> {
        let pred = pred?;
        if pred.confidence < 0.6 { return None; }

        let due_date = pred.predicted_date?;
        let days_until = today.days_until(&due_date);

        // Notifie la veille et le jour J
        if !(0..=1).contains(&days_until) { return None; }

        let body = if days_until == 0 {
            format!("Ton revenu de {:.0} FCFA devrait arriver aujourd'hui.", pred.predicted_amount)
        } else {
            format!("Ton revenu de {:.0} FCFA est attendu demain.", pred.predicted_amount)
        };

        Some(NotificationTrigger {
            channel:    NotificationChannel::Reminders,
            priority:   NotificationPriority::Normal,
            title:      "💰 Revenu attendu".into(),
            body,
            delay_secs: 0,
            dedup_key:  format!("income_pred_{}_{}_{}", due_date.year, due_date.month, due_date.day),
        })
    }

    // ── Déduplication ─────────────────────────────────────────────
    fn deduplicate(notifs: Vec<NotificationTrigger>) -> Vec<NotificationTrigger> {
        let mut seen  = std::collections::HashSet::new();
        let mut result = Vec::new();
        for n in notifs {
            if seen.insert(n.dedup_key.clone()) {
                result.push(n);
            }
        }
        result
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
            profile:     BehavioralProfile::default(),
            prediction:  None, anomalies: vec![],
            suggestions: vec![], episodes: vec![],
        }
    }

    fn base_det() -> DeterministicResult {
        DeterministicResult {
            total_balance: 200_000.0, committed_mass: 50_000.0,
            free_mass: 150_000.0, days_remaining: 15,
            daily_budget: 10_000.0, spent_today: 3_000.0,
            remaining_today: 7_000.0,
            transport_reserve: 0.0, charges_reserve: 50_000.0,
        }
    }

    fn base_input() -> EngineInput {
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
    fn test_no_notifications_when_healthy() {
        let det   = base_det();
        let input = base_input();
        let notifs = NotificationsEngine::compute(&det, &empty_adaptive(), &input, None);
        // Seul le rappel quotidien est attendu
        let non_reminder: Vec<_> = notifs.iter()
            .filter(|n| n.channel != NotificationChannel::Reminders)
            .collect();
        assert!(non_reminder.is_empty());
    }

    #[test]
    fn test_budget_alert_when_over_budget() {
        let mut det = base_det();
        det.spent_today     = 15_000.0;
        det.remaining_today = -5_000.0;
        let input  = base_input();
        let notifs = NotificationsEngine::compute(&det, &empty_adaptive(), &input, None);
        assert!(notifs.iter().any(|n| n.channel == NotificationChannel::BudgetAlerts
            && n.priority == NotificationPriority::High
            && n.title.contains("dépassé")));
    }

    #[test]
    fn test_charge_due_today_notified() {
        let det   = base_det();
        let mut input = base_input();
        input.today = Date::new(2026, 3, 15);
        input.charges = vec![RecurringCharge {
            id: "c1".into(), name: "Loyer".into(),
            amount: 120_000.0, due_day: 15, // aujourd'hui
            status: ChargeStatus::Pending, amount_paid: 0.0, is_active: true,
        }];
        let notifs = NotificationsEngine::compute(&det, &empty_adaptive(), &input, None);
        let charge_notif = notifs.iter().find(|n| n.channel == NotificationChannel::RecurringCharges);
        assert!(charge_notif.is_some());
        assert_eq!(charge_notif.unwrap().priority, NotificationPriority::High);
    }

    #[test]
    fn test_paid_charge_not_notified() {
        let det   = base_det();
        let mut input = base_input();
        input.charges = vec![RecurringCharge {
            id: "c1".into(), name: "Loyer".into(),
            amount: 120_000.0, due_day: 15,
            status: ChargeStatus::Paid, // déjà payée
            amount_paid: 120_000.0, is_active: true,
        }];
        let notifs = NotificationsEngine::compute(&det, &empty_adaptive(), &input, None);
        assert!(!notifs.iter().any(|n| n.channel == NotificationChannel::RecurringCharges));
    }

    #[test]
    fn test_ghost_money_notification() {
        let det   = base_det();
        let mut adaptive = empty_adaptive();
        adaptive.anomalies.push(Anomaly {
            anomaly_type: AnomalyType::GhostMoney {
                transaction_count: 7, total: 2_800.0, impact_pct: 0.08,
            },
            detected_on: Date::new(2026, 3, 14),
            expires_on:  Date::new(2026, 3, 21),
            dismissed:   false,
        });
        let notifs = NotificationsEngine::compute(&det, &adaptive, &base_input(), None);
        assert!(notifs.iter().any(|n| n.title.contains("fantôme")));
    }

    #[test]
    fn test_dismissed_anomaly_no_notification() {
        let det   = base_det();
        let mut adaptive = empty_adaptive();
        adaptive.anomalies.push(Anomaly {
            anomaly_type: AnomalyType::GhostMoney {
                transaction_count: 7, total: 2_800.0, impact_pct: 0.08,
            },
            detected_on: Date::new(2026, 3, 14),
            expires_on:  Date::new(2026, 3, 21),
            dismissed:   true, // rejeté
        });
        let notifs = NotificationsEngine::compute(&det, &adaptive, &base_input(), None);
        assert!(!notifs.iter().any(|n| n.title.contains("fantôme")));
    }

    #[test]
    fn test_dedup_key_prevents_duplicates() {
        let det   = base_det();
        let mut input = base_input();
        // Deux charges dues le même jour
        input.charges = vec![
            RecurringCharge {
                id: "c1".into(), name: "Loyer".into(),
                amount: 120_000.0, due_day: 15,
                status: ChargeStatus::Pending, amount_paid: 0.0, is_active: true,
            },
            RecurringCharge {
                id: "c1".into(), name: "Loyer".into(), // même id
                amount: 120_000.0, due_day: 15,
                status: ChargeStatus::Pending, amount_paid: 0.0, is_active: true,
            },
        ];
        let notifs = NotificationsEngine::compute(&det, &empty_adaptive(), &input, None);
        let charge_notifs: Vec<_> = notifs.iter()
            .filter(|n| n.channel == NotificationChannel::RecurringCharges)
            .collect();
        assert_eq!(charge_notifs.len(), 1, "doublon non dédupliqué");
    }

    #[test]
    fn test_daily_reminder_not_shown_when_zero_budget() {
        let mut det = base_det();
        det.daily_budget = 0.0;
        let notifs = NotificationsEngine::compute(&det, &empty_adaptive(), &base_input(), None);
        assert!(!notifs.iter().any(|n| n.channel == NotificationChannel::Reminders
            && n.title.contains("budget du jour")));
    }
}
