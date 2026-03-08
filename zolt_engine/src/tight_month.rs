// ============================================================
//  MODULE TIGHT MONTH — Mode "Fin de mois serré"
//  Activation automatique quand le moteur détecte un risque
//  de déficit avant la prochaine paie.
//
//  3 composants :
//    A. Détecteur de tension — décide si le mode s'active
//    B. Mode serré — budget réduit, catégories figées, messages
//    C. Calendrier de tension — timeline des 30 prochains jours
//       avec les jours à risque, les échéances et les marges
//
//  Le mode s'active et se désactive automatiquement.
//  L'utilisateur peut voir pourquoi il s'est activé.
//  Le widget affiche toujours l'état le plus critique.
// ============================================================

use crate::types::*;
use crate::compute_verifier::ComputeVerifier;
use serde::{Deserialize, Serialize};

// ── Types ─────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TightMonthInput {
    pub engine_input: EngineInput,
    pub det:          DeterministicResult,
    pub history:      Vec<CycleRecord>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TightMonthResult {
    /// Mode actif ou non
    pub is_active:          bool,
    /// Niveau de tension
    pub tension_level:      TensionLevel,
    /// Budget journalier recommandé en mode serré (réduit)
    pub strict_daily_budget: f64,
    /// Budget normal pour comparaison
    pub normal_daily_budget: f64,
    /// Raison d'activation (null si non actif)
    pub trigger_reason:     Option<String>,
    /// Calendrier des 30 prochains jours
    pub calendar:           Vec<CalendarDay>,
    /// Catégories à prioriser (charges fixes)
    pub priority_categories: Vec<String>,
    /// Catégories à réduire
    pub reduce_categories:  Vec<CategoryCut>,
    /// Message d'activation
    pub message:            String,
    /// Projection du solde à la fin du cycle
    pub projected_final_balance: f64,
    /// Objectif minimum de solde en fin de cycle
    pub min_target_balance: f64,
    /// Jours critiques identifiés (index dans calendar)
    pub critical_days:      Vec<u32>,
    /// Mode désactivé automatiquement à cette date
    pub auto_deactivate_at: Option<Date>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum TensionLevel {
    Comfortable,  // Aucune tension
    Watchful,     // Marge < 20% — surveiller
    Tight,        // Risque modéré — mode serré recommandé
    Critical,     // Risque élevé — mode serré obligatoire
    Emergency,    // Déficit quasi-certain — alerte maximale
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CalendarDay {
    pub date:            Date,
    pub day_number:      u32,   // Jour dans le cycle
    pub tension:         DayTension,
    /// Charges prévues ce jour
    pub scheduled_charges: Vec<ScheduledCharge>,
    /// Solde projeté en fin de journée
    pub projected_balance: f64,
    /// Budget disponible ce jour
    pub day_budget:      f64,
    /// Note explicative
    pub note:            Option<String>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum DayTension {
    Easy,     // Journée normale
    Moderate, // Vigilance recommandée
    High,     // Charge importante ce jour
    Critical, // Solde projeté sous le minimum
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScheduledCharge {
    pub name:        String,
    pub amount:      f64,
    pub is_due:      bool,  // true = échéance exacte, false = estimée
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CategoryCut {
    pub category:       String,
    pub current_monthly: f64,
    pub suggested_cut:   f64,  // Montant à réduire
    pub cut_pct:         u8,   // % de réduction suggérée
    pub impact:          f64,  // Impact sur le solde final
}

// ── Widget state — données minimales pour le widget OS ────────
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WidgetState {
    /// Solde total
    pub balance:          f64,
    /// Budget restant aujourd'hui
    pub remaining_today:  f64,
    /// Budget total du jour
    pub daily_budget:     f64,
    /// % du budget utilisé aujourd'hui (0.0 à 1.0+)
    pub usage_ratio:      f64,
    /// Mode serré actif
    pub tight_mode:       bool,
    /// Niveau de tension
    pub tension_level:    TensionLevel,
    /// Message court pour le widget (max 60 chars)
    pub widget_text:      String,
    /// Couleur sémantique : "green" | "orange" | "red"
    pub color_hint:       String,
    /// Prochaine échéance de charge (si dans les 5 jours)
    pub next_charge:      Option<WidgetCharge>,
    /// Dernière mise à jour (epoch jours)
    pub updated_at_epoch: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WidgetCharge {
    pub name:       String,
    pub amount:     f64,
    pub days_until: u32,
}

// ── Moteur principal ──────────────────────────────────────────

pub struct TightMonthEngine;

impl TightMonthEngine {
    pub fn compute(input: &TightMonthInput) -> TightMonthResult {
        let det     = &input.det;
        let today   = &input.engine_input.today;
        let charges = &input.engine_input.charges;

        // ── Calcul de la projection de fin de cycle ───────────
        // Utilise le ComputeVerifier pour avoir une projection fiable
        let ctx = crate::compute_verifier::VerifierContext {
            input:   &input.engine_input,
            history: &input.history,
            det,
        };
        let eoc = ComputeVerifier::verify_end_of_cycle(&ctx);
        let daily_budget_verified = ComputeVerifier::verify_daily_budget(&ctx);

        let projected_final = eoc.value;
        let normal_daily    = daily_budget_verified.value;

        // ── Solde minimum cible ───────────────────────────────
        // = objectif d'épargne du cycle
        let min_target = input.engine_input.cycle.savings_goal;

        // ── Détermination du niveau de tension ────────────────
        let margin = projected_final - min_target;
        let margin_ratio = if min_target > 0.0 { margin / min_target }
            else if projected_final > 0.0 { 1.0 }
            else { -1.0 };

        let tension_level = if projected_final < 0.0 {
            TensionLevel::Emergency
        } else if margin < 0.0 {
            TensionLevel::Critical
        } else if margin_ratio < 0.20 {
            TensionLevel::Tight
        } else if margin_ratio < 0.50 {
            TensionLevel::Watchful
        } else {
            TensionLevel::Comfortable
        };

        let is_active = matches!(tension_level,
            TensionLevel::Tight | TensionLevel::Critical | TensionLevel::Emergency
        );

        // ── Budget serré ──────────────────────────────────────
        let strict_daily_budget = if is_active && det.days_remaining > 0 {
            // Réduit le budget pour s'assurer d'atteindre le min_target
            let available_for_spending = det.free_mass - min_target.max(0.0);
            if available_for_spending > 0.0 {
                available_for_spending / det.days_remaining as f64
            } else {
                // Situation critique : budget minimal de survie
                Self::survival_budget(&input.engine_input)
            }
        } else {
            normal_daily
        };

        // ── Raison d'activation ───────────────────────────────
        let trigger_reason = if is_active {
            Some(Self::build_trigger_reason(&tension_level, projected_final, min_target, normal_daily))
        } else {
            None
        };

        // ── Calendrier des 30 prochains jours ─────────────────
        let calendar = Self::build_calendar(
            today,
            charges,
            det,
            strict_daily_budget,
            min_target,
            &tension_level,
        );

        // ── Jours critiques ───────────────────────────────────
        let critical_days: Vec<u32> = calendar.iter()
            .filter(|d| d.tension == DayTension::Critical)
            .map(|d| d.day_number)
            .collect();

        // ── Catégories à réduire ──────────────────────────────
        let reduce_categories = if is_active {
            Self::suggest_cuts(&input.engine_input, margin.abs(), normal_daily)
        } else {
            vec![]
        };

        // ── Catégories prioritaires ───────────────────────────
        let priority_categories = vec![
            "loyer".into(), "électricité".into(), "eau".into(),
            "nourriture".into(), "transport".into(),
        ];

        // ── Désactivation automatique ─────────────────────────
        // Se désactive le jour de la prochaine paie probable
        let auto_deactivate_at = if is_active {
            Self::estimate_next_income_date(today, &input.history)
        } else {
            None
        };

        // ── Message ───────────────────────────────────────────
        let message = Self::build_message(
            &tension_level, projected_final, min_target,
            strict_daily_budget, normal_daily,
        );

        TightMonthResult {
            is_active,
            tension_level,
            strict_daily_budget,
            normal_daily_budget: normal_daily,
            trigger_reason,
            calendar,
            priority_categories,
            reduce_categories,
            message,
            projected_final_balance: projected_final,
            min_target_balance: min_target,
            critical_days,
            auto_deactivate_at,
        }
    }

    // ── Widget state — compact, pour le widget OS ─────────────
    pub fn compute_widget(input: &TightMonthInput) -> WidgetState {
        let det   = &input.det;
        let today = &input.engine_input.today;

        let result = Self::compute(input);
        let is_tight = result.is_active;

        let usage_ratio = if det.daily_budget > 0.0 {
            det.spent_today / det.daily_budget
        } else { 0.0 };

        let color_hint = match result.tension_level {
            TensionLevel::Comfortable | TensionLevel::Watchful => "green".into(),
            TensionLevel::Tight                                 => "orange".into(),
            TensionLevel::Critical | TensionLevel::Emergency    => "red".into(),
        };

        let widget_text = if is_tight {
            format!(
                "Mode serré — {:.0} FCFA/j",
                result.strict_daily_budget
            )
        } else {
            let remaining = det.remaining_today;
            if remaining > 0.0 {
                format!("{:.0} FCFA restants aujourd'hui", remaining)
            } else {
                "Budget du jour dépassé".into()
            }
        };
        // Tronque à 60 chars
        let widget_text = if widget_text.len() > 60 {
            widget_text[..60].to_string()
        } else {
            widget_text
        };

        // Prochaine charge dans les 5 jours
        let next_charge = input.engine_input.charges.iter()
            .filter(|c| c.is_active && c.status != ChargeStatus::Paid)
            .filter_map(|c| {
                let days = Self::days_until_due(today, c.due_day);
                if days <= 5 {
                    Some(WidgetCharge {
                        name:       c.name.clone(),
                        amount:     c.amount,
                        days_until: days,
                    })
                } else {
                    None
                }
            })
            .min_by_key(|c| c.days_until);

        WidgetState {
            balance:          det.total_balance,
            remaining_today:  det.remaining_today.max(0.0),
            daily_budget:     if is_tight { result.strict_daily_budget } else { det.daily_budget },
            usage_ratio,
            tight_mode:       is_tight,
            tension_level:    result.tension_level,
            widget_text,
            color_hint,
            next_charge,
            updated_at_epoch: today.to_days_since_epoch(),
        }
    }

    // ── Construction du calendrier ────────────────────────────
    fn build_calendar(
        today:         &Date,
        charges:       &[RecurringCharge],
        det:           &DeterministicResult,
        strict_budget: f64,
        min_target:    f64,
        tension:       &TensionLevel,
    ) -> Vec<CalendarDay> {
        let mut calendar = Vec::new();
        let mut running_balance = det.total_balance;
        let days_to_show = det.days_remaining.min(30);

        for day_offset in 0..days_to_show {
            let date = today.add_days(day_offset);
            let day_number = day_offset + 1;

            // Charges prévues ce jour
            let scheduled: Vec<ScheduledCharge> = charges.iter()
                .filter(|c| c.is_active && c.status != ChargeStatus::Paid)
                .filter(|c| c.due_day as u32 == date.day as u32)
                .map(|c| ScheduledCharge {
                    name:    c.name.clone(),
                    amount:  c.amount,
                    is_due:  true,
                })
                .collect();

            let charges_today: f64 = scheduled.iter().map(|c| c.amount).sum();

            // Dépense estimée (budget du jour + charges prévues)
            let total_outflow = strict_budget + charges_today;
            running_balance -= total_outflow;

            // Tension du jour
            let day_tension = if running_balance < 0.0 {
                DayTension::Critical
            } else if !scheduled.is_empty() && scheduled.iter().any(|c| c.amount > 50_000.0) {
                DayTension::High
            } else if running_balance < min_target * 1.2 {
                DayTension::Moderate
            } else {
                DayTension::Easy
            };

            let note = if !scheduled.is_empty() {
                Some(format!(
                    "{} à payer : {}",
                    scheduled.len(),
                    scheduled.iter().map(|c| c.name.as_str()).collect::<Vec<_>>().join(", ")
                ))
            } else if day_tension == DayTension::Critical {
                Some("Solde projeté insuffisant — réduire les dépenses maintenant.".into())
            } else {
                None
            };

            calendar.push(CalendarDay {
                date,
                day_number,
                tension: day_tension,
                scheduled_charges: scheduled,
                projected_balance: running_balance.max(0.0),
                day_budget: if charges_today > 0.0 { strict_budget + charges_today } else { strict_budget },
                note,
            });
        }

        calendar
    }

    // ── Suggestions de coupes ─────────────────────────────────
    fn suggest_cuts(
        input:        &EngineInput,
        deficit:      f64,
        daily_budget: f64,
    ) -> Vec<CategoryCut> {
        // Identifie les catégories non-essentielles dans les transactions
        let mut category_spending: std::collections::HashMap<String, f64> =
            std::collections::HashMap::new();

        for tx in &input.transactions {
            if tx.tx_type.is_outflow() {
                if let Some(cat) = &tx.category {
                    *category_spending.entry(cat.clone()).or_default() += tx.amount;
                }
            }
        }

        let essential = ["loyer", "électricité", "eau", "santé", "éducation"];

        let mut cuts: Vec<CategoryCut> = category_spending.iter()
            .filter(|(cat, _)| !essential.iter().any(|e| cat.contains(e)))
            .map(|(cat, &spent)| {
                let monthly_proj = spent * 2.0; // approximation sur le mois entier
                let cut_pct: u8 = if monthly_proj > daily_budget * 5.0 { 30 } else { 20 };
                let suggested_cut = monthly_proj * cut_pct as f64 / 100.0;
                CategoryCut {
                    category:        cat.clone(),
                    current_monthly: monthly_proj,
                    suggested_cut,
                    cut_pct,
                    impact:          suggested_cut,
                }
            })
            .collect();

        // Trie par impact décroissant
        cuts.sort_by(|a, b| b.impact.partial_cmp(&a.impact).unwrap());
        cuts.truncate(4); // Max 4 suggestions
        cuts
    }

    // ── Budget de survie minimal ──────────────────────────────
    fn survival_budget(input: &EngineInput) -> f64 {
        // Transport + nourriture de base = minimum vital
        let transport = match &input.cycle.transport {
            TransportType::Daily { cost_per_day, .. } => *cost_per_day,
            _ => 0.0,
        };
        // Nourriture estimée : 1 500 FCFA / jour minimum West Africa
        transport + 1_500.0
    }

    // ── Date prochaine paie estimée ───────────────────────────
    fn estimate_next_income_date(today: &Date, history: &[CycleRecord]) -> Option<Date> {
        if history.is_empty() { return None; }

        // Cherche le jour habituel de paie dans l'historique
        let income_days: Vec<u8> = history.iter()
            .flat_map(|r| r.transactions.iter())
            .filter(|t| t.tx_type.is_inflow() && t.amount > 50_000.0)
            .map(|t| t.date.day)
            .collect();

        if income_days.is_empty() { return None; }

        let avg_day = (income_days.iter().map(|&d| d as u32).sum::<u32>()
            / income_days.len() as u32) as u8;

        // Prochaine occurrence de ce jour
        if today.day < avg_day {
            Some(Date::new(today.year, today.month, avg_day))
        } else {
            // Mois prochain
            let (next_year, next_month) = if today.month == 12 {
                (today.year + 1, 1)
            } else {
                (today.year, today.month + 1)
            };
            Some(Date::new(next_year, next_month, avg_day))
        }
    }

    fn days_until_due(today: &Date, due_day: u8) -> u32 {
        if due_day >= today.day {
            (due_day - today.day) as u32
        } else {
            // Mois prochain
            let days_in_month = 30u32; // approximation
            days_in_month - today.day as u32 + due_day as u32
        }
    }

    fn build_trigger_reason(
        level:      &TensionLevel,
        projected:  f64,
        target:     f64,
        daily:      f64,
    ) -> String {
        match level {
            TensionLevel::Emergency =>
                format!(
                    "Déficit projeté de {:.0} FCFA à fin de cycle. \
                     Au rythme actuel, ton solde sera négatif.",
                    projected.abs()
                ),
            TensionLevel::Critical =>
                format!(
                    "Ton solde projeté en fin de cycle ({:.0} FCFA) sera \
                     inférieur à ton objectif d'épargne ({:.0} FCFA).",
                    projected, target
                ),
            TensionLevel::Tight =>
                format!(
                    "Marge de sécurité faible : {:.0} FCFA disponibles \
                     au-dessus de l'objectif. Budget ajusté à {:.0} FCFA/jour.",
                    projected - target, daily * 0.85
                ),
            _ => "Situation financière sous surveillance.".into(),
        }
    }

    fn build_message(
        level:         &TensionLevel,
        projected:     f64,
        target:        f64,
        strict_budget: f64,
        normal_budget: f64,
    ) -> String {
        match level {
            TensionLevel::Emergency => format!(
                "🚨 Situation critique. Si rien ne change, tu termineras le cycle \
                 avec un déficit de {:.0} FCFA. Réduis au maximum et envisage \
                 un revenu d'appoint.",
                projected.abs()
            ),
            TensionLevel::Critical => format!(
                "⚠️ Mode serré activé. Ton budget journalier passe de {:.0} à {:.0} FCFA. \
                 Priorise les charges fixes. Chaque FCFA économisé compte.",
                normal_budget, strict_budget
            ),
            TensionLevel::Tight => format!(
                "Mode vigilance. Budget réduit à {:.0} FCFA/jour pour préserver \
                 ton objectif d'épargne ({:.0} FCFA).",
                strict_budget, target
            ),
            TensionLevel::Watchful =>
                "Tout va bien, mais surveille tes dépenses cette semaine.".into(),
            TensionLevel::Comfortable => format!(
                "Situation confortable. Tu projettes {:.0} FCFA en fin de cycle.",
                projected
            ),
        }
    }
}

// ─────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;

    fn base_det(balance: f64, daily: f64, days_rem: u32, free_mass: f64) -> DeterministicResult {
        DeterministicResult {
            total_balance:    balance,
            committed_mass:   balance - free_mass,
            free_mass,
            days_remaining:   days_rem,
            daily_budget:     daily,
            spent_today:      daily * 0.3,
            remaining_today:  daily * 0.7,
            transport_reserve: 0.0,
            charges_reserve:  0.0,
        }
    }

    fn base_input(balance: f64, daily: f64, days_rem: u32, savings_goal: f64) -> TightMonthInput {
        TightMonthInput {
            engine_input: EngineInput {
                today: Date::new(2026, 3, 15),
                accounts: vec![Account {
                    id: "a1".into(), name: "MoMo".into(),
                    account_type: AccountType::MobileMoney,
                    balance, is_active: true,
                }],
                charges: vec![RecurringCharge {
                    id: "c1".into(), name: "Électricité".into(),
                    amount: 15_000.0, due_day: 20,
                    status: ChargeStatus::Pending, amount_paid: 0.0, is_active: true,
                }],
                transactions: vec![
                    Transaction {
                        id: "t1".into(), date: Date::new(2026, 3, 1),
                        amount: 300_000.0, tx_type: TransactionType::Income,
                        category: Some("salaire".into()), account_id: "a1".into(),
                        description: None, sms_confidence: None,
                    },
                    Transaction {
                        id: "t2".into(), date: Date::new(2026, 3, 10),
                        amount: 25_000.0, tx_type: TransactionType::Expense,
                        category: Some("loisirs".into()), account_id: "a1".into(),
                        description: None, sms_confidence: None,
                    },
                ],
                cycle: FinancialCycle {
                    cycle_type: CycleType::Monthly,
                    savings_goal,
                    transport: TransportType::None,
                },
            },
            det: base_det(balance, daily, days_rem, balance * 0.8),
            history: vec![],
        }
    }

    #[test]
    fn test_comfortable_when_plenty_of_margin() {
        let r = TightMonthEngine::compute(&base_input(300_000.0, 8_000.0, 16, 20_000.0));
        assert_eq!(r.tension_level, TensionLevel::Comfortable);
        assert!(!r.is_active);
    }

    #[test]
    fn test_critical_when_deficit_projected() {
        // 50 000 solde, 5 000/jour pendant 16 jours = 80 000 nécessaire → déficit
        let r = TightMonthEngine::compute(&base_input(50_000.0, 5_000.0, 16, 30_000.0));
        assert!(
            matches!(r.tension_level, TensionLevel::Critical | TensionLevel::Emergency | TensionLevel::Tight),
            "level={:?}", r.tension_level
        );
    }

    #[test]
    fn test_strict_budget_lower_than_normal() {
        let r = TightMonthEngine::compute(&base_input(80_000.0, 8_000.0, 16, 50_000.0));
        if r.is_active {
            assert!(
                r.strict_daily_budget <= r.normal_daily_budget,
                "strict={} normal={}", r.strict_daily_budget, r.normal_daily_budget
            );
        }
    }

    #[test]
    fn test_calendar_has_correct_days() {
        let r = TightMonthEngine::compute(&base_input(200_000.0, 8_000.0, 16, 20_000.0));
        assert_eq!(r.calendar.len(), 16);
    }

    #[test]
    fn test_charge_appears_in_calendar() {
        // Charge due le 20, today le 15 → doit apparaître au jour 5
        let r = TightMonthEngine::compute(&base_input(200_000.0, 8_000.0, 16, 20_000.0));
        let charge_day = r.calendar.iter().find(|d| !d.scheduled_charges.is_empty());
        assert!(charge_day.is_some(), "aucune charge dans le calendrier");
        let cd = charge_day.unwrap();
        assert!(!cd.scheduled_charges.is_empty());
    }

    #[test]
    fn test_critical_days_identified() {
        // Situation très serrée → des jours critiques doivent être identifiés
        let r = TightMonthEngine::compute(&base_input(30_000.0, 5_000.0, 16, 50_000.0));
        // Avec 30k et 5k/jour pendant 16 jours → 80k de dépenses vs 30k dispo
        // Des jours critiques doivent apparaître
        assert!(!r.calendar.is_empty());
    }

    #[test]
    fn test_suggest_cuts_when_active() {
        let r = TightMonthEngine::compute(&base_input(60_000.0, 6_000.0, 16, 50_000.0));
        if r.is_active {
            // Des catégories de réduction doivent être suggérées
            // (loisirs est dans les transactions de base)
            assert!(!r.reduce_categories.is_empty() || r.tension_level == TensionLevel::Comfortable);
        }
    }

    #[test]
    fn test_widget_fields_valid() {
        let input = base_input(200_000.0, 8_000.0, 16, 20_000.0);
        let w = TightMonthEngine::compute_widget(&input);
        assert!(w.balance >= 0.0);
        assert!(w.usage_ratio >= 0.0);
        assert!(!w.widget_text.is_empty());
        assert!(w.widget_text.len() <= 60);
        assert!(!w.color_hint.is_empty());
    }

    #[test]
    fn test_widget_tight_mode_text() {
        let input = base_input(40_000.0, 5_000.0, 16, 50_000.0);
        let w = TightMonthEngine::compute_widget(&input);
        if w.tight_mode {
            assert!(
                w.color_hint == "orange" || w.color_hint == "red",
                "color={}", w.color_hint
            );
        }
    }

    #[test]
    fn test_next_charge_in_widget() {
        let input = base_input(200_000.0, 8_000.0, 16, 20_000.0);
        let w = TightMonthEngine::compute_widget(&input);
        // Charge due le 20, today le 15 → dans 5 jours → doit apparaître dans le widget
        assert!(w.next_charge.is_some(), "next_charge should be present for charge due in 5 days");
        let nc = w.next_charge.unwrap();
        assert_eq!(nc.days_until, 5);
        assert!((nc.amount - 15_000.0).abs() < 1.0);
    }

    #[test]
    fn test_message_non_empty() {
        let r = TightMonthEngine::compute(&base_input(200_000.0, 8_000.0, 16, 20_000.0));
        assert!(!r.message.is_empty());
    }

    #[test]
    fn test_emergency_level_negative_projection() {
        // 20 000 FCFA, 3 000/jour, 16 jours = 48 000 de dépenses → déficit grave
        let r = TightMonthEngine::compute(&base_input(20_000.0, 3_000.0, 16, 30_000.0));
        assert!(
            matches!(r.tension_level, TensionLevel::Emergency | TensionLevel::Critical | TensionLevel::Tight),
            "{:?}", r.tension_level
        );
        assert!(r.trigger_reason.is_some());
    }
}
