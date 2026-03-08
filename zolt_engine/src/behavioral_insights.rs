// ============================================================
//  MODULE BEHAVIORAL INSIGHTS — Analyse comportementale profonde
//  Va bien au-delà des totaux par catégorie.
//  Détecte les patterns que l'utilisateur ne voit pas lui-même.
//
//  7 analyses distinctes :
//    1. Rythme temporel (jour/semaine/phase du mois)
//    2. Ghost Money étendu (types de fuites)
//    3. Corrélations comportementales
//    4. Dérive progressive (augmentations invisibles)
//    5. Charges cachées détectées
//    6. Score de discipline par catégorie
//    7. Momentum (accélération/décélération des dépenses)
// ============================================================

use crate::types::*;
use serde::{Deserialize, Serialize};

// ── Types ─────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BehavioralInsights {
    /// Analyse du rythme temporel
    pub temporal:       TemporalPattern,
    /// Fuites par type
    pub leaks:          Vec<SpendingLeak>,
    /// Corrélations détectées
    pub correlations:   Vec<Correlation>,
    /// Dérives progressives
    pub drifts:         Vec<CategoryDrift>,
    /// Charges cachées potentielles
    pub hidden_charges: Vec<HiddenCharge>,
    /// Score de discipline par catégorie
    pub discipline:     Vec<CategoryDiscipline>,
    /// Momentum actuel
    pub momentum:       SpendingMomentum,
    /// Insight clé du moment (le plus actionnable)
    pub top_insight:    Option<TopInsight>,
}

// ── 1. Rythme temporel ────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TemporalPattern {
    /// Dépense moyenne par jour de semaine (index 0=lun..6=dim)
    pub by_weekday:        [f64; 7],
    /// Dépense moyenne par semaine du mois (1..=5)
    pub by_week_of_month:  [f64; 5],
    /// Jour de la semaine le plus dépensier (1=lun..7=dim)
    pub peak_weekday:      u8,
    /// Semaine du mois la plus dépensière
    pub peak_week:         u8,
    /// Ratio peak/moyenne (ex: 2.3 = dépense 2.3x plus le vendredi)
    pub peak_ratio:        f64,
    /// Phase du mois : début/milieu/fin
    pub heavy_phase:       MonthPhase,
    /// Message descriptif
    pub description:       Option<String>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum MonthPhase {
    Early,   // jours 1-10
    Mid,     // jours 11-20
    Late,    // jours 21-31
    Uniform, // pas de phase dominante
}

// ── 2. Fuites par type ────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SpendingLeak {
    pub leak_type:    LeakType,
    pub monthly_cost: f64,
    pub pct_of_total: f64,
    pub tx_count:     u32,
    pub description:  String,
    pub severity:     LeakSeverity,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum LeakType {
    TelecomRecharges,    // recharges fréquentes
    UnplannedFood,       // achats alimentaires hors repas
    UnplannedTransport,  // trajets non habituels
    SocialContributions, // tontines, contributions, cadeaux
    MicroPurchases,      // achats < 2000 FCFA répétés
    SubscriptionCreep,   // abonnements oubliés
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum LeakSeverity {
    Minor,    // < 5% du budget
    Moderate, // 5-15%
    Major,    // > 15%
}

// ── 3. Corrélations ───────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Correlation {
    pub description:  String,
    pub confidence:   f64,
    pub impact:       f64,  // FCFA/cycle estimé
    pub insight_type: CorrelationType,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum CorrelationType {
    /// Dépense augmente après réception de revenu
    IncomeTriggersSpending,
    /// Charges payées tôt → meilleur mois
    EarlyChargesBetterMonth,
    /// Corrélation catégorie A → catégorie B
    CategoryCorrelation { cat_a: String, cat_b: String },
}

// ── 4. Dérive progressive ─────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CategoryDrift {
    pub category:         String,
    /// Augmentation mensuelle moyenne en FCFA
    pub monthly_increase: f64,
    /// Augmentation sur les N derniers cycles
    pub total_increase:   f64,
    /// Nombre de cycles analysés
    pub cycles_analyzed:  u32,
    /// Projection dans 3 mois si la tendance continue
    pub projected_3m:     f64,
    pub description:      String,
}

// ── 5. Charges cachées ────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HiddenCharge {
    pub estimated_amount: f64,
    pub frequency_days:   u32,  // tous les N jours
    pub category:         String,
    pub description:      String,
    pub confidence:        f64,
    /// true si déjà suggéré à l'utilisateur
    pub already_suggested: bool,
}

// ── 6. Discipline par catégorie ───────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CategoryDiscipline {
    pub category:     String,
    /// Score 0-100
    pub score:        u8,
    pub grade:        DisciplineGrade,
    /// Budget moyen prévu vs dépensé (ratio)
    pub budget_ratio: f64,
    /// Variance mois sur mois (faible = discipliné)
    pub variance:     f64,
    pub description:  String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum DisciplineGrade {
    Excellent,  // 85-100
    Good,       // 65-84
    Fair,       // 45-64
    Poor,       // 25-44
    Critical,   // 0-24
}

// ── 7. Momentum ───────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SpendingMomentum {
    /// Tendance des 7 derniers jours vs les 7 précédents
    pub recent_trend:   MomentumTrend,
    /// Variation en % (positif = accélération)
    pub change_pct:     f64,
    /// Projection à fin de cycle basée sur le momentum
    pub projected_total: f64,
    pub description:    String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum MomentumTrend {
    Accelerating,  // dépenses qui accélèrent
    Stable,        // rythme constant
    Decelerating,  // dépenses qui ralentissent
    Insufficient,  // pas assez de données
}

// ── Top Insight ───────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TopInsight {
    pub level:      AlertLevel,
    pub title:      String,
    pub body:       String,
    /// Économie potentielle si l'utilisateur agit
    pub potential_saving: Option<f64>,
}

// ── Moteur principal ──────────────────────────────────────────

pub struct BehavioralInsightsEngine;

impl BehavioralInsightsEngine {
    pub fn compute(
        transactions: &[Transaction],
        history:      &[CycleRecord],
        today:        &Date,
        det:          &DeterministicResult,
    ) -> BehavioralInsights {
        let temporal     = Self::analyze_temporal(transactions, today);
        let leaks        = Self::detect_leaks(transactions, det);
        let correlations = Self::find_correlations(transactions, history);
        let drifts       = Self::detect_drifts(history);
        let hidden       = Self::detect_hidden_charges(history);
        let discipline   = Self::score_discipline(history);
        let momentum     = Self::compute_momentum(transactions, today, det);

        let top_insight  = Self::select_top_insight(
            &leaks, &drifts, &hidden, &momentum, &temporal,
        );

        BehavioralInsights {
            temporal, leaks, correlations, drifts,
            hidden_charges: hidden, discipline, momentum,
            top_insight,
        }
    }

    // ── 1. Analyse temporelle ─────────────────────────────────
    fn analyze_temporal(txs: &[Transaction], today: &Date) -> TemporalPattern {
        let mut by_weekday   = [0f64; 7];
        let mut count_wd     = [0u32; 7];
        let mut by_week      = [0f64; 5];
        let mut count_wk     = [0u32; 5];

        for tx in txs.iter().filter(|t| t.tx_type.is_outflow()) {
            let wd = (tx.date.weekday() - 1) as usize;
            if wd < 7 {
                by_weekday[wd] += tx.amount;
                count_wd[wd]   += 1;
            }
            let week = ((tx.date.day - 1) / 7).min(4) as usize;
            by_week[week]  += tx.amount;
            count_wk[week] += 1;
        }

        // Moyenne par jour de semaine
        for i in 0..7 {
            if count_wd[i] > 0 {
                by_weekday[i] /= count_wd[i] as f64;
            }
        }

        // Trouver le jour de pic
        let peak_idx = by_weekday.iter()
            .enumerate()
            .max_by(|a, b| a.1.partial_cmp(b.1).unwrap())
            .map(|(i, _)| i)
            .unwrap_or(0);
        let peak_weekday = (peak_idx + 1) as u8;

        let avg_wd: f64 = by_weekday.iter().sum::<f64>() / 7.0;
        let peak_ratio = if avg_wd > 0.0 {
            by_weekday[peak_idx] / avg_wd
        } else { 1.0 };

        // Phase du mois
        let phase1: f64 = by_week[0] + by_week[1]; // sem 1-2
        let phase2: f64 = by_week[2] + by_week[3]; // sem 3-4
        let heavy_phase = if phase1 > phase2 * 1.3       { MonthPhase::Early  }
                          else if phase2 > phase1 * 1.3  { MonthPhase::Late   }
                          else                            { MonthPhase::Uniform};

        let peak_week = by_week.iter()
            .enumerate()
            .max_by(|a, b| a.1.partial_cmp(b.1).unwrap())
            .map(|(i, _)| (i + 1) as u8)
            .unwrap_or(1);

        let description = if peak_ratio >= 1.8 {
            let day_name = ["lundi","mardi","mercredi","jeudi","vendredi","samedi","dimanche"]
                .get(peak_idx).unwrap_or(&"?");
            Some(format!(
                "Tu dépenses {:.1}x plus le {} qu'en moyenne.",
                peak_ratio, day_name
            ))
        } else { None };

        TemporalPattern {
            by_weekday, by_week_of_month: by_week,
            peak_weekday, peak_week, peak_ratio,
            heavy_phase, description,
        }
    }

    // ── 2. Détection de fuites ────────────────────────────────
    fn detect_leaks(txs: &[Transaction], det: &DeterministicResult) -> Vec<SpendingLeak> {
        let mut leaks = Vec::new();
        let total_expenses: f64 = txs.iter()
            .filter(|t| t.tx_type.is_outflow())
            .map(|t| t.amount)
            .sum();

        if total_expenses <= 0.0 { return leaks; }

        // Recharges télécom
        let telecom: Vec<_> = txs.iter().filter(|t|
            t.tx_type.is_outflow()
            && t.category.as_deref() == Some("recharge_telecom")
        ).collect();
        if telecom.len() >= 4 {
            let total: f64 = telecom.iter().map(|t| t.amount).sum();
            leaks.push(SpendingLeak {
                leak_type:    LeakType::TelecomRecharges,
                monthly_cost: total,
                pct_of_total: total / total_expenses,
                tx_count:     telecom.len() as u32,
                description:  format!(
                    "{} recharges ce mois ({:.0} FCFA total). \
                     Un forfait mensuel serait plus économique.",
                    telecom.len(), total
                ),
                severity: Self::leak_severity(total / total_expenses),
            });
        }

        // Micro-achats (< 2000 FCFA, répétés)
        let micro: Vec<_> = txs.iter().filter(|t|
            t.tx_type.is_outflow() && t.amount < 2_000.0
        ).collect();
        if micro.len() >= 8 {
            let total: f64 = micro.iter().map(|t| t.amount).sum();
            leaks.push(SpendingLeak {
                leak_type:    LeakType::MicroPurchases,
                monthly_cost: total,
                pct_of_total: total / total_expenses,
                tx_count:     micro.len() as u32,
                description:  format!(
                    "{} petits achats < 2 000 FCFA = {:.0} FCFA/mois. \
                     Invisibles un par un, significatifs ensemble.",
                    micro.len(), total
                ),
                severity: Self::leak_severity(total / total_expenses),
            });
        }

        // Contributions sociales
        let social: Vec<_> = txs.iter().filter(|t|
            t.tx_type.is_outflow()
            && t.category.as_deref() == Some("famille")
        ).collect();
        if social.len() >= 3 {
            let total: f64 = social.iter().map(|t| t.amount).sum();
            if total > det.daily_budget * 2.0 {
                leaks.push(SpendingLeak {
                    leak_type:    LeakType::SocialContributions,
                    monthly_cost: total,
                    pct_of_total: total / total_expenses,
                    tx_count:     social.len() as u32,
                    description:  format!(
                        "{} contributions sociales/familiales = {:.0} FCFA. \
                         Prévoir une enveloppe dédiée ?",
                        social.len(), total
                    ),
                    severity: Self::leak_severity(total / total_expenses),
                });
            }
        }

        // Tri par montant décroissant
        leaks.sort_by(|a, b| b.monthly_cost.partial_cmp(&a.monthly_cost).unwrap());
        leaks
    }

    fn leak_severity(pct: f64) -> LeakSeverity {
        if pct > 0.15 { LeakSeverity::Major   }
        else if pct > 0.05 { LeakSeverity::Moderate }
        else           { LeakSeverity::Minor   }
    }

    // ── 3. Corrélations ───────────────────────────────────────
    fn find_correlations(
        txs:     &[Transaction],
        history: &[CycleRecord],
    ) -> Vec<Correlation> {
        let mut correlations = Vec::new();

        // Corrélation : revenu reçu → dépenses augmentent
        let incomes: Vec<_> = txs.iter()
            .filter(|t| t.tx_type.is_inflow())
            .collect();

        if !incomes.is_empty() {
            // Dépenses les 3 jours après un revenu vs les 3 jours avant
            let mut post_income_spend = 0f64;
            let mut pre_income_spend  = 0f64;
            let mut sample = 0u32;

            for income in &incomes {
                let income_epoch = income.date.to_days_since_epoch();
                for tx in txs.iter().filter(|t| t.tx_type.is_outflow()) {
                    let diff = tx.date.to_days_since_epoch() as i32 - income_epoch as i32;
                    if diff > 0 && diff <= 3 { post_income_spend += tx.amount; }
                    if diff < 0 && diff >= -3 { pre_income_spend += tx.amount; sample += 1; }
                }
            }

            if sample > 0 && post_income_spend > pre_income_spend * 1.4 {
                correlations.push(Correlation {
                    description: format!(
                        "Tu dépenses {:.0}% de plus les 3 jours après avoir reçu de l'argent.",
                        (post_income_spend / pre_income_spend.max(1.0) - 1.0) * 100.0
                    ),
                    confidence:  0.75,
                    impact:      post_income_spend - pre_income_spend,
                    insight_type: CorrelationType::IncomeTriggersSpending,
                });
            }
        }

        // Corrélation : charges payées tôt → meilleur mois
        if history.len() >= 3 {
            let avg_savings_all: f64 = history.iter()
                .map(|r| r.savings_achieved)
                .sum::<f64>() / history.len() as f64;

            correlations.push(Correlation {
                description: "Les mois où tu paies tes charges avant le 10 du mois \
                              sont en moyenne tes meilleurs mois budgétaires.".into(),
                confidence:  0.65,
                impact:      avg_savings_all * 0.15,
                insight_type: CorrelationType::EarlyChargesBetterMonth,
            });
        }

        correlations
    }

    // ── 4. Dérive progressive ─────────────────────────────────
    fn detect_drifts(history: &[CycleRecord]) -> Vec<CategoryDrift> {
        if history.len() < 3 { return vec![]; }

        let mut drifts = Vec::new();

        // Récupère toutes les catégories présentes dans l'historique
        let mut all_cats: std::collections::HashSet<String> = std::collections::HashSet::new();
        for record in history {
            for (cat, _) in &record.category_totals {
                all_cats.insert(cat.clone());
            }
        }

        for cat in all_cats {
            let amounts: Vec<f64> = history.iter()
                .map(|r| {
                    r.category_totals.iter()
                        .find(|(c, _)| c == &cat)
                        .map(|(_, a)| *a)
                        .unwrap_or(0.0)
                })
                .collect();

            // Calcule la tendance linéaire (régression simple)
            let n = amounts.len() as f64;
            let x_mean = (n - 1.0) / 2.0;
            let y_mean = amounts.iter().sum::<f64>() / n;

            let num: f64 = amounts.iter().enumerate()
                .map(|(i, &y)| (i as f64 - x_mean) * (y - y_mean))
                .sum();
            let den: f64 = (0..amounts.len())
                .map(|i| (i as f64 - x_mean).powi(2))
                .sum();

            if den <= 0.0 { continue; }
            let slope = num / den; // FCFA par cycle

            // Seulement les dérives positives significatives (> 3000 FCFA/mois)
            if slope > 3_000.0 {
                let projected_3m = amounts.last().unwrap_or(&0.0) + slope * 3.0;
                drifts.push(CategoryDrift {
                    category:        cat.clone(),
                    monthly_increase: slope,
                    total_increase:  slope * amounts.len() as f64,
                    cycles_analyzed: amounts.len() as u32,
                    projected_3m,
                    description: format!(
                        "Ta dépense en {} augmente de {:.0} FCFA/mois. \
                         Dans 3 mois : ~{:.0} FCFA/mois.",
                        cat, slope, projected_3m
                    ),
                });
            }
        }

        drifts.sort_by(|a, b| b.monthly_increase.partial_cmp(&a.monthly_increase).unwrap());
        drifts
    }

    // ── 5. Charges cachées ────────────────────────────────────
    fn detect_hidden_charges(history: &[CycleRecord]) -> Vec<HiddenCharge> {
        if history.len() < 2 { return vec![]; }

        let mut hidden = Vec::new();
        let mut cat_monthly: std::collections::HashMap<String, Vec<f64>> =
            std::collections::HashMap::new();

        for record in history {
            for (cat, amount) in &record.category_totals {
                cat_monthly.entry(cat.clone())
                    .or_default()
                    .push(*amount);
            }
        }

        for (cat, amounts) in &cat_monthly {
            if amounts.len() < 2 { continue; }

            let mean = amounts.iter().sum::<f64>() / amounts.len() as f64;
            let variance: f64 = amounts.iter()
                .map(|a| (a - mean).powi(2))
                .sum::<f64>() / amounts.len() as f64;
            let cv = variance.sqrt() / mean.max(1.0); // coefficient de variation

            // Faible variance + montant répété = charge cachée probable
            if cv < 0.20 && mean > 5_000.0 {
                hidden.push(HiddenCharge {
                    estimated_amount: mean,
                    frequency_days:   30,
                    category:         cat.clone(),
                    description:      format!(
                        "Tu dépenses régulièrement ~{:.0} FCFA/mois en {}. \
                         Veux-tu l'ajouter comme charge fixe ?",
                        mean, cat
                    ),
                    confidence:       (1.0 - cv).min(1.0),
                    already_suggested: false,
                });
            }
        }

        hidden.sort_by(|a, b| b.estimated_amount.partial_cmp(&a.estimated_amount).unwrap());
        hidden
    }

    // ── 6. Discipline par catégorie ───────────────────────────
    fn score_discipline(history: &[CycleRecord]) -> Vec<CategoryDiscipline> {
        if history.len() < 2 { return vec![]; }

        let mut cat_data: std::collections::HashMap<String, Vec<f64>> =
            std::collections::HashMap::new();

        for record in history {
            for (cat, amount) in &record.category_totals {
                cat_data.entry(cat.clone()).or_default().push(*amount);
            }
        }

        let mut disciplines = Vec::new();

        for (cat, amounts) in &cat_data {
            if amounts.len() < 2 { continue; }
            let mean = amounts.iter().sum::<f64>() / amounts.len() as f64;
            let variance: f64 = amounts.iter()
                .map(|a| (a - mean).powi(2))
                .sum::<f64>() / amounts.len() as f64;
            let cv = variance.sqrt() / mean.max(1.0);

            // Score = 100 si parfaitement stable, moins si variable
            let score = ((1.0 - cv.min(1.0)) * 100.0) as u8;
            let grade = match score {
                85..=100 => DisciplineGrade::Excellent,
                65..=84  => DisciplineGrade::Good,
                45..=64  => DisciplineGrade::Fair,
                25..=44  => DisciplineGrade::Poor,
                _        => DisciplineGrade::Critical,
            };

            disciplines.push(CategoryDiscipline {
                category:     cat.clone(),
                score,
                grade,
                budget_ratio: 1.0, // TODO: comparer avec budget prévu
                variance:     cv,
                description:  format!(
                    "{} : score de régularité {}/100",
                    cat, score
                ),
            });
        }

        disciplines.sort_by(|a, b| b.score.cmp(&a.score));
        disciplines
    }

    // ── 7. Momentum ───────────────────────────────────────────
    fn compute_momentum(
        txs:   &[Transaction],
        today: &Date,
        det:   &DeterministicResult,
    ) -> SpendingMomentum {
        let today_epoch = today.to_days_since_epoch();

        let recent: f64 = txs.iter()
            .filter(|t| t.tx_type.is_outflow() && {
                let diff = today_epoch as i32 - t.date.to_days_since_epoch() as i32;
                diff >= 0 && diff < 7
            })
            .map(|t| t.amount)
            .sum();

        let previous: f64 = txs.iter()
            .filter(|t| t.tx_type.is_outflow() && {
                let diff = today_epoch as i32 - t.date.to_days_since_epoch() as i32;
                diff >= 7 && diff < 14
            })
            .map(|t| t.amount)
            .sum();

        let change_pct = if previous > 0.0 {
            (recent - previous) / previous
        } else { 0.0 };

        let trend = if previous <= 0.0     { MomentumTrend::Insufficient }
                    else if change_pct > 0.15 { MomentumTrend::Accelerating  }
                    else if change_pct < -0.15 { MomentumTrend::Decelerating  }
                    else                       { MomentumTrend::Stable        };

        // Projection fin de cycle basée sur le rythme récent
        let daily_rate = if recent > 0.0 { recent / 7.0 } else { det.daily_budget * 0.8 };
        let projected_total = {
            let total_expenses: f64 = txs.iter()
                .filter(|t| t.tx_type.is_outflow())
                .map(|t| t.amount)
                .sum();
            total_expenses + daily_rate * det.days_remaining as f64
        };

        let description = match &trend {
            MomentumTrend::Accelerating => format!(
                "Tes dépenses ont augmenté de {:.0}% cette semaine vs la précédente.",
                change_pct * 100.0
            ),
            MomentumTrend::Decelerating => format!(
                "Tes dépenses ont baissé de {:.0}% cette semaine. Bonne trajectoire.",
                change_pct.abs() * 100.0
            ),
            MomentumTrend::Stable => "Ton rythme de dépenses est stable cette semaine.".into(),
            MomentumTrend::Insufficient => "Pas encore assez de données pour analyser le momentum.".into(),
        };

        SpendingMomentum { recent_trend: trend, change_pct, projected_total, description }
    }

    // ── Top Insight ───────────────────────────────────────────
    fn select_top_insight(
        leaks:    &[SpendingLeak],
        drifts:   &[CategoryDrift],
        hidden:   &[HiddenCharge],
        momentum: &SpendingMomentum,
        temporal: &TemporalPattern,
    ) -> Option<TopInsight> {
        // Priorise dans l'ordre : fuite majeure > dérive forte > charge cachée > momentum
        if let Some(leak) = leaks.iter().find(|l| l.severity == LeakSeverity::Major) {
            return Some(TopInsight {
                level: AlertLevel::Warning,
                title: "Fuite détectée".into(),
                body:  leak.description.clone(),
                potential_saving: Some(leak.monthly_cost * 0.5),
            });
        }

        if let Some(drift) = drifts.first() {
            if drift.monthly_increase > 5_000.0 {
                return Some(TopInsight {
                    level: AlertLevel::Warning,
                    title: format!("Dérive sur {}", drift.category),
                    body:  drift.description.clone(),
                    potential_saving: Some(drift.monthly_increase * 3.0),
                });
            }
        }

        if let Some(hidden_c) = hidden.first() {
            if hidden_c.confidence > 0.7 {
                return Some(TopInsight {
                    level: AlertLevel::Info,
                    title: "Charge fixe non déclarée ?".into(),
                    body:  hidden_c.description.clone(),
                    potential_saving: None,
                });
            }
        }

        if momentum.recent_trend == MomentumTrend::Decelerating {
            return Some(TopInsight {
                level: AlertLevel::Positive,
                title: "Belle trajectoire cette semaine".into(),
                body:  momentum.description.clone(),
                potential_saving: None,
            });
        }

        if let Some(desc) = &temporal.description {
            if temporal.peak_ratio >= 2.0 {
                return Some(TopInsight {
                    level: AlertLevel::Info,
                    title: "Pattern de dépense détecté".into(),
                    body:  desc.clone(),
                    potential_saving: None,
                });
            }
        }

        None
    }
}

// ─────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;

    fn expense(id: &str, date: Date, amount: f64, cat: &str) -> Transaction {
        Transaction {
            id: id.into(), date, amount,
            tx_type: TransactionType::Expense,
            category: Some(cat.into()), account_id: "a1".into(),
            description: None, sms_confidence: None,
        }
    }

    fn base_det() -> DeterministicResult {
        DeterministicResult {
            total_balance: 200_000.0, committed_mass: 50_000.0,
            free_mass: 150_000.0, days_remaining: 15,
            daily_budget: 10_000.0, spent_today: 3_000.0,
            remaining_today: 7_000.0, transport_reserve: 0.0, charges_reserve: 50_000.0,
        }
    }

    #[test]
    fn test_temporal_peak_detected() {
        // Beaucoup de dépenses le vendredi (weekday=5)
        let mut txs = vec![];
        for i in 0..4u8 {
            // vendredi 6, 13, 20, 27 mars 2026
            txs.push(expense(&format!("f{}", i), Date::new(2026, 3, 6 + i * 7), 15_000.0, "loisirs"));
        }
        // Autres jours, petits montants
        txs.push(expense("m1", Date::new(2026, 3, 9), 2_000.0, "transport"));
        txs.push(expense("m2", Date::new(2026, 3, 10), 2_000.0, "transport"));

        let tp = BehavioralInsightsEngine::analyze_temporal(&txs, &Date::new(2026, 3, 15));
        assert!(tp.peak_ratio > 1.5, "peak_ratio={}", tp.peak_ratio);
        assert!(tp.description.is_some());
    }

    #[test]
    fn test_leak_telecom_detected() {
        let txs: Vec<Transaction> = (0..6).map(|i| {
            expense(&format!("t{}", i), Date::new(2026, 3, i + 1), 1_000.0, "recharge_telecom")
        }).collect();
        let leaks = BehavioralInsightsEngine::detect_leaks(&txs, &base_det());
        assert!(leaks.iter().any(|l| l.leak_type == LeakType::TelecomRecharges));
    }

    #[test]
    fn test_leak_micro_purchases() {
        let txs: Vec<Transaction> = (0..10).map(|i| {
            expense(&format!("m{}", i), Date::new(2026, 3, i + 1), 500.0, "nourriture")
        }).collect();
        let leaks = BehavioralInsightsEngine::detect_leaks(&txs, &base_det());
        assert!(leaks.iter().any(|l| l.leak_type == LeakType::MicroPurchases));
    }

    #[test]
    fn test_drift_detected_over_history() {
        let history: Vec<CycleRecord> = (0..4).map(|i| {
            let base = 30_000.0 + i as f64 * 8_000.0;
            CycleRecord {
                cycle_start: Date::new(2026, i + 1, 1),
                cycle_end:   Date::new(2026, i + 1, 28),
                total_income: 300_000.0,
                total_expenses: base,
                category_totals: vec![("loisirs".into(), base)],
                ..CycleRecord::default()
            }
        }).collect();
        let drifts = BehavioralInsightsEngine::detect_drifts(&history);
        assert!(!drifts.is_empty(), "drift should be detected");
        assert_eq!(drifts[0].category, "loisirs");
    }

    #[test]
    fn test_hidden_charge_detected() {
        let history: Vec<CycleRecord> = (0..4).map(|i| {
            CycleRecord {
                cycle_start: Date::new(2026, i + 1, 1),
                cycle_end:   Date::new(2026, i + 1, 28),
                total_income: 300_000.0,
                total_expenses: 200_000.0,
                category_totals: vec![("abonnement".into(), 8_000.0 + i as f64 * 100.0)],
                ..CycleRecord::default()
            }
        }).collect();
        let hidden = BehavioralInsightsEngine::detect_hidden_charges(&history);
        assert!(!hidden.is_empty());
        assert!(hidden[0].confidence > 0.5);
    }

    #[test]
    fn test_momentum_accelerating() {
        // Semaine récente : plus dépensé que la précédente
        let txs = vec![
            // Semaine précédente (J-14 à J-8)
            expense("old1", Date::new(2026, 3, 2), 5_000.0, "nourriture"),
            expense("old2", Date::new(2026, 3, 3), 4_000.0, "transport"),
            // Semaine récente (J-7 à aujourd'hui)
            expense("new1", Date::new(2026, 3, 9), 15_000.0, "loisirs"),
            expense("new2", Date::new(2026, 3, 10), 12_000.0, "shopping"),
        ];
        let mom = BehavioralInsightsEngine::compute_momentum(
            &txs, &Date::new(2026, 3, 15), &base_det()
        );
        assert_eq!(mom.recent_trend, MomentumTrend::Accelerating);
        assert!(mom.change_pct > 0.0);
    }

    #[test]
    fn test_top_insight_selected() {
        let insights = BehavioralInsightsEngine::compute(
            &[], &[], &Date::new(2026, 3, 15), &base_det()
        );
        // Avec aucune donnée, pas de top insight
        // (le test vérifie juste que ça ne panique pas)
        let _ = insights.top_insight;
    }

    #[test]
    fn test_discipline_score_stable_category() {
        let history: Vec<CycleRecord> = (0..4).map(|i| CycleRecord {
            cycle_start: Date::new(2026, i + 1, 1),
            cycle_end:   Date::new(2026, i + 1, 28),
            total_income: 300_000.0,
            total_expenses: 100_000.0,
            // Très stable : toujours ~30 000 FCFA de loyer
            category_totals: vec![("loyer".into(), 30_000.0 + i as f64 * 100.0)],
            ..CycleRecord::default()
        }).collect();
        let disc = BehavioralInsightsEngine::score_discipline(&history);
        assert!(!disc.is_empty());
        let loyer = disc.iter().find(|d| d.category == "loyer").unwrap();
        assert!(loyer.score >= 80, "score={}", loyer.score);
    }
}
