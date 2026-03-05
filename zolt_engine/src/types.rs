// ============================================================
//  TYPES PARTAGÉS — Structures de données communes
//  Toutes les couches importent depuis ce module.
//  Serde utilisé pour la sérialisation JSON (SQLite ↔ Rust ↔ Flutter)
// ============================================================

use serde::{Deserialize, Serialize};
use std::fmt;

// ── Erreurs domaine ──────────────────────────────────────────

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum ZoltError {
    /// Données d'entrée invalides
    InvalidInput(String),
    /// Calcul impossible (ex: division par zéro, données corrompues)
    ComputationError(String),
    /// Historique corrompu ou incohérent
    HistoryCorrupted(String),
}

impl fmt::Display for ZoltError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            ZoltError::InvalidInput(msg)       => write!(f, "input invalide: {}", msg),
            ZoltError::ComputationError(msg)   => write!(f, "erreur de calcul: {}", msg),
            ZoltError::HistoryCorrupted(msg)   => write!(f, "historique corrompu: {}", msg),
        }
    }
}

pub type ZoltResult<T> = Result<T, ZoltError>;

// ── Dates légères (sans chrono — on-device, minimaliste) ────

/// Représentation d'une date sans dépendance externe.
/// Invariants : year ∈ [2000, 2100], month ∈ [1,12], day ∈ [1,31]
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Serialize, Deserialize)]
pub struct Date {
    pub year:  u16,
    pub month: u8,  // 1..=12
    pub day:   u8,  // 1..=31
}

impl Date {
    pub fn new(year: u16, month: u8, day: u8) -> Self {
        Self { year, month, day }
    }

    /// Construit et valide une date. Retourne une erreur si invalide.
    pub fn try_new(year: u16, month: u8, day: u8) -> ZoltResult<Self> {
        if !(1..=12).contains(&month) {
            return Err(ZoltError::InvalidInput(
                format!("mois invalide: {} (attendu 1-12)", month)
            ));
        }
        if year < 2000 || year > 2100 {
            return Err(ZoltError::InvalidInput(
                format!("année invalide: {} (attendu 2000-2100)", year)
            ));
        }
        let max_day = Self::last_day_of_month_static(year, month);
        if day < 1 || day > max_day {
            return Err(ZoltError::InvalidInput(
                format!("jour invalide: {} pour {}/{} (max {})", day, month, year, max_day)
            ));
        }
        Ok(Self { year, month, day })
    }

    /// Nombre de jours entre deux dates (self → other, positif si other > self).
    pub fn days_until(&self, other: &Date) -> i32 {
        let a = self.to_days_since_epoch();
        let b = other.to_days_since_epoch();
        b as i32 - a as i32
    }

    /// Jour de la semaine : 1 = lundi … 7 = dimanche (ISO 8601)
    pub fn weekday(&self) -> u8 {
        let days = self.to_days_since_epoch();
        ((days + 3) % 7 + 1) as u8
    }

    /// Conversion en jours depuis époque (2000-01-01 offset arbitraire)
    pub fn to_days_since_epoch(&self) -> u32 {
        let y = self.year as u32;
        let m = self.month as u32;
        let d = self.day as u32;
        let y_adj = if m <= 2 { y - 1 } else { y };
        let era = y_adj / 400;
        let yoe = y_adj - era * 400;
        let doy = (153 * (m + if m > 2 { 0 } else { 9 } - 3) + 2) / 5 + d - 1;
        let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy;
        era * 146097 + doe
    }

    pub fn from_days_since_epoch(days: u32) -> Self {
        let z   = days + 719_468;
        let era = z / 146_097;
        let doe = z - era * 146_097;
        let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146_096) / 365;
        let y   = yoe + era * 400;
        let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
        let mp  = (5 * doy + 2) / 153;
        let d   = doy - (153 * mp + 2) / 5 + 1;
        let m   = if mp < 10 { mp + 3 } else { mp - 9 };
        let y   = if m <= 2 { y + 1 } else { y };
        Date::new(y as u16, m as u8, d as u8)
    }

    pub fn within(&self, start: Date, end: Date) -> bool {
        *self >= start && *self <= end
    }

    #[inline]
    pub fn last_day_of_month_static(year: u16, month: u8) -> u8 {
        match month {
            1 | 3 | 5 | 7 | 8 | 10 | 12 => 31,
            4 | 6 | 9 | 11              => 30,
            2 => {
                let y = year as u32;
                if y % 400 == 0 || (y % 4 == 0 && y % 100 != 0) { 29 } else { 28 }
            }
            _ => 30,
        }
    }
}

impl fmt::Display for Date {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{:04}-{:02}-{:02}", self.year, self.month, self.day)
    }
}

// ── Comptes ──────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum AccountType {
    MobileMoney,  // MTN / Moov / Orange / Wave
    Cash,
    Bank,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Account {
    pub id:           String,
    pub name:         String,
    pub account_type: AccountType,
    pub balance:      f64,   // FCFA, toujours ≥ 0
    pub is_active:    bool,
}

impl Account {
    pub fn validate(&self) -> ZoltResult<()> {
        if self.id.is_empty() {
            return Err(ZoltError::InvalidInput("compte: id vide".into()));
        }
        if self.balance < 0.0 {
            return Err(ZoltError::InvalidInput(
                format!("compte '{}': solde négatif ({:.2})", self.name, self.balance)
            ));
        }
        if !self.balance.is_finite() {
            return Err(ZoltError::InvalidInput(
                format!("compte '{}': solde non-fini (NaN/inf)", self.name)
            ));
        }
        Ok(())
    }
}

// ── Transactions ─────────────────────────────────────────────

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum TransactionType {
    Expense,
    Income,
    TransferOut,
    TransferIn,
    Withdrawal,
    Deposit,
}

impl TransactionType {
    #[inline]
    pub fn is_outflow(&self) -> bool {
        matches!(self, Self::Expense | Self::TransferOut | Self::Withdrawal)
    }

    #[inline]
    pub fn is_inflow(&self) -> bool {
        matches!(self, Self::Income | Self::TransferIn | Self::Deposit)
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Transaction {
    pub id:             String,
    pub date:           Date,
    pub amount:         f64,
    pub tx_type:        TransactionType,
    pub category:       Option<String>,
    pub account_id:     String,
    pub description:    Option<String>,
    /// Score de confiance SMS (0.0..=1.0). None si saisie manuelle.
    pub sms_confidence: Option<f64>,
}

impl Transaction {
    pub fn validate(&self) -> ZoltResult<()> {
        if self.amount <= 0.0 {
            return Err(ZoltError::InvalidInput(
                format!("transaction '{}': montant invalide ({:.2})", self.id, self.amount)
            ));
        }
        if !self.amount.is_finite() {
            return Err(ZoltError::InvalidInput(
                format!("transaction '{}': montant non-fini", self.id)
            ));
        }
        if let Some(conf) = self.sms_confidence {
            if !(0.0..=1.0).contains(&conf) {
                return Err(ZoltError::InvalidInput(
                    format!("transaction '{}': sms_confidence hors [0,1]: {:.3}", self.id, conf)
                ));
            }
        }
        Ok(())
    }
}

// ── Charges fixes ─────────────────────────────────────────────

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum ChargeStatus {
    Pending,
    Paid,
    Overdue,
    PartiallyPaid,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RecurringCharge {
    pub id:            String,
    pub name:          String,
    pub amount:        f64,
    pub due_day:       u8,   // 1..=31
    pub status:        ChargeStatus,
    pub amount_paid:   f64,
    pub is_active:     bool,
}

impl RecurringCharge {
    pub fn validate(&self) -> ZoltResult<()> {
        if self.amount <= 0.0 || !self.amount.is_finite() {
            return Err(ZoltError::InvalidInput(
                format!("charge '{}': montant invalide ({:.2})", self.name, self.amount)
            ));
        }
        if !(1..=31).contains(&self.due_day) {
            return Err(ZoltError::InvalidInput(
                format!("charge '{}': due_day invalide ({})", self.name, self.due_day)
            ));
        }
        if self.amount_paid < 0.0 || self.amount_paid > self.amount {
            return Err(ZoltError::InvalidInput(
                format!(
                    "charge '{}': amount_paid ({:.2}) hors [0, amount ({:.2})]",
                    self.name, self.amount_paid, self.amount
                )
            ));
        }
        Ok(())
    }

    #[inline]
    pub fn remaining_amount(&self) -> f64 {
        (self.amount - self.amount_paid).max(0.0)
    }

    /// Réserve journalière pour cette charge à partir d'aujourd'hui.
    pub fn daily_reserve(&self, today: &Date) -> f64 {
        if self.status == ChargeStatus::Paid {
            return 0.0;
        }
        // Gestion du due_day au-delà du dernier jour du mois (ex: 31 en février)
        let max_day = Date::last_day_of_month_static(today.year, today.month);
        let effective_day = self.due_day.min(max_day);
        let due_date = Date::new(today.year, today.month, effective_day);
        let days_until = today.days_until(&due_date);

        if days_until <= 0 {
            // Déjà dû ou en retard → montant entier immédiatement
            self.remaining_amount()
        } else {
            self.remaining_amount() / days_until as f64
        }
    }

    pub fn reset_for_new_cycle(&self) -> Self {
        Self {
            status:      ChargeStatus::Pending,
            amount_paid: 0.0,
            ..self.clone()
        }
    }
}

// ── Transport ─────────────────────────────────────────────────

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum TransportType {
    /// Coût par jour de travail effectif
    Daily { cost_per_day: f64, work_days: Vec<u8> },  // work_days: 1=lun..7=dim
    /// Abonnement mensuel → traité comme charge fixe
    Subscription,
    /// Pas de transport configuré
    None,
}

impl TransportType {
    pub fn validate(&self) -> ZoltResult<()> {
        if let TransportType::Daily { cost_per_day, work_days } = self {
            if *cost_per_day <= 0.0 || !cost_per_day.is_finite() {
                return Err(ZoltError::InvalidInput(
                    format!("transport: cost_per_day invalide ({:.2})", cost_per_day)
                ));
            }
            if work_days.is_empty() {
                return Err(ZoltError::InvalidInput(
                    "transport daily: work_days vide".into()
                ));
            }
            for &d in work_days {
                if !(1..=7).contains(&d) {
                    return Err(ZoltError::InvalidInput(
                        format!("transport: work_day invalide ({}), attendu 1-7", d)
                    ));
                }
            }
        }
        Ok(())
    }
}

// ── Cycle financier ───────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum CycleType {
    Monthly,
    Weekly,
    Daily,
    /// Début = dernier revenu, fin = date estimée prochain revenu
    Irregular { cycle_start: Date, cycle_end: Date },
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FinancialCycle {
    pub cycle_type:    CycleType,
    pub savings_goal:  f64,  // montant absolu à préserver (≥ 0)
    pub transport:     TransportType,
}

impl FinancialCycle {
    pub fn validate(&self) -> ZoltResult<()> {
        if self.savings_goal < 0.0 || !self.savings_goal.is_finite() {
            return Err(ZoltError::InvalidInput(
                format!("savings_goal invalide ({:.2})", self.savings_goal)
            ));
        }
        self.transport.validate()?;
        if let CycleType::Irregular { cycle_start, cycle_end } = &self.cycle_type {
            if cycle_start >= cycle_end {
                return Err(ZoltError::InvalidInput(
                    format!(
                        "cycle irrégulier: cycle_start ({}) >= cycle_end ({})",
                        cycle_start, cycle_end
                    )
                ));
            }
        }
        Ok(())
    }
}

// ── EngineInput ───────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EngineInput {
    pub today:        Date,
    pub accounts:     Vec<Account>,
    pub charges:      Vec<RecurringCharge>,
    pub cycle:        FinancialCycle,
    /// Transactions du cycle en cours uniquement
    pub transactions: Vec<Transaction>,
}

impl EngineInput {
    /// Validation complète des données d'entrée.
    pub fn validate(&self) -> ZoltResult<()> {
        // Date valide
        Date::try_new(self.today.year, self.today.month, self.today.day)?;

        // Au moins un compte actif
        if self.accounts.is_empty() {
            return Err(ZoltError::InvalidInput("aucun compte fourni".into()));
        }
        let has_active = self.accounts.iter().any(|a| a.is_active);
        if !has_active {
            return Err(ZoltError::InvalidInput("aucun compte actif".into()));
        }

        // Validation de chaque compte
        for account in &self.accounts {
            account.validate()?;
        }

        // Validation des charges
        for charge in &self.charges {
            charge.validate()?;
        }

        // Validation du cycle
        self.cycle.validate()?;

        // Validation des transactions
        for tx in &self.transactions {
            tx.validate()?;
        }

        // Vérification cohérence cycle irrégulier : today doit être dans la fenêtre
        if let CycleType::Irregular { cycle_start, cycle_end } = &self.cycle.cycle_type {
            if self.today < *cycle_start || self.today > *cycle_end {
                return Err(ZoltError::InvalidInput(
                    format!(
                        "today ({}) hors du cycle irrégulier [{}, {}]",
                        self.today, cycle_start, cycle_end
                    )
                ));
            }
        }

        Ok(())
    }
}

// ── DeterministicResult ───────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeterministicResult {
    pub total_balance:       f64,
    pub committed_mass:      f64,   // épargne + transport + charges
    pub free_mass:           f64,   // ce qui est réellement libre (≥ 0)
    pub days_remaining:      u32,   // ≥ 1
    pub daily_budget:        f64,   // B_j (≥ 0)
    pub spent_today:         f64,
    pub remaining_today:     f64,   // peut être négatif si dépassement
    pub transport_reserve:   f64,
    pub charges_reserve:     f64,
}

impl DeterministicResult {
    /// Vrai si le budget du jour est épuisé ou dépassé.
    pub fn is_over_budget(&self) -> bool {
        self.remaining_today < 0.0
    }

    /// Vrai si les engagements dépassent le solde total.
    pub fn is_insolvent(&self) -> bool {
        self.free_mass == 0.0 && self.committed_mass > self.total_balance
    }
}

// ── Profil comportemental ─────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum SpendingRhythm {
    Linear,   // dépenses régulières tout le mois
    Frontal,  // beaucoup en début de mois
    Terminal, // concentration en fin de mois
    Erratic,  // pas de pattern clair
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BehavioralProfile {
    pub rhythm:                SpendingRhythm,
    /// 0.0 (très stable) → 1.0 (très volatile)
    pub volatility_score:      f64,
    /// Ratio moyen d'atteinte de l'objectif d'épargne (0.0..=1.0)
    pub savings_achievement:   f64,
    /// Nombre de cycles observés (fiabilité du profil)
    pub cycles_observed:       u32,
    /// Charges informelles détectées (montant estimé/mois)
    pub hidden_charges_total:  f64,
}

impl Default for BehavioralProfile {
    fn default() -> Self {
        Self {
            rhythm:               SpendingRhythm::Linear,
            volatility_score:     0.0,
            savings_achievement:  1.0,
            cycles_observed:      0,
            hidden_charges_total: 0.0,
        }
    }
}

// ── Prédiction fin de cycle ───────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EndOfCyclePrediction {
    pub projected_final_balance: f64,
    pub projected_deficit:       f64,  // 0.0 si pas de déficit
    pub confidence:              f64,  // 0.0..=1.0
    pub alert_level:             AlertLevel,
}

// ── Anomalies ─────────────────────────────────────────────────

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum AnomalyType {
    UnusualAmount   { category: String, amount: f64, historical_avg: f64 },
    GhostMoney      { transaction_count: u32, total: f64, impact_pct: f64 },
    UnusualTiming   { category: String, typical_week: u8, actual_week: u8 },
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Anomaly {
    pub anomaly_type: AnomalyType,
    pub detected_on:  Date,
    pub expires_on:   Date,
    pub dismissed:    bool,
}

// ── Niveaux d'alerte ──────────────────────────────────────────

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Serialize, Deserialize)]
pub enum AlertLevel {
    Info,       // bleu  — insight neutre
    Warning,    // orange — action recommandée
    Critical,   // rouge  — action urgente
    Positive,   // vert   — encouragement
}

// ── Messages conversationnels ─────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ConversationalMessage {
    pub level:    AlertLevel,
    pub title:    String,
    pub body:     String,
    /// Durée d'affichage en jours (None = permanent jusqu'à action)
    pub ttl_days: Option<u32>,
}

// ── Suggestions adaptatives ───────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum AdaptiveSuggestion {
    ReviseSavingsGoal  { current: f64, suggested: f64, reason: String },
    AddHiddenCharge    { estimated_amount: f64, pattern_description: String },
    AdjustSafetyMargin { new_margin_pct: f64 },
}

// ── Sortie complète ───────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ZoltEngineOutput {
    pub deterministic:  DeterministicResult,
    pub profile:        BehavioralProfile,
    pub prediction:     Option<EndOfCyclePrediction>,
    pub anomalies:      Vec<Anomaly>,
    pub messages:       Vec<ConversationalMessage>,
    pub suggestions:    Vec<AdaptiveSuggestion>,
}

// ── Cycle Record (défini ici pour éviter les imports circulaires) ─

/// Snapshot d'un cycle financier terminé.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CycleRecord {
    pub cycle_start:         Date,
    pub cycle_end:           Date,
    pub opening_balance:     f64,
    pub closing_balance:     f64,
    pub total_income:        f64,
    pub total_expenses:      f64,
    pub savings_goal:        f64,
    pub savings_achieved:    f64,
    pub daily_expenses:      Vec<f64>,
    pub category_totals:     Vec<(String, f64)>,
    pub transactions:        Vec<Transaction>,
}

impl CycleRecord {
    #[inline]
    pub fn cycle_length(&self) -> u32 {
        (self.cycle_start.days_until(&self.cycle_end) + 1).max(1) as u32
    }

    pub fn validate(&self) -> ZoltResult<()> {
        if self.cycle_start >= self.cycle_end {
            return Err(ZoltError::HistoryCorrupted(format!(
                "cycle_start ({}) >= cycle_end ({})", self.cycle_start, self.cycle_end
            )));
        }
        if !self.total_income.is_finite() || self.total_income < 0.0 {
            return Err(ZoltError::HistoryCorrupted(format!(
                "total_income invalide: {}", self.total_income
            )));
        }
        if !self.total_expenses.is_finite() || self.total_expenses < 0.0 {
            return Err(ZoltError::HistoryCorrupted(format!(
                "total_expenses invalide: {}", self.total_expenses
            )));
        }
        Ok(())
    }
}

// ── Clôture de cycle ──────────────────────────────────────────

/// Données nécessaires pour clôturer un cycle.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CycleCloseInput {
    pub cycle_start:      Date,
    pub cycle_end:        Date,
    pub opening_balance:  f64,
    pub closing_balance:  f64,
    pub savings_goal:     f64,
    /// Transactions du cycle complet
    pub transactions:     Vec<Transaction>,
}

/// Résultat de la clôture — prêt à persister en SQLite.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CycleCloseResult {
    pub record:           CycleRecord,
    /// Résumé lisible pour l'utilisateur
    pub summary_message:  ConversationalMessage,
}

// ── Analytics ─────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AnalyticsInput {
    pub transactions: Vec<Transaction>,
    pub cycle_start:  Date,
    pub cycle_end:    Date,
    /// Cycles passés pour les comparaisons
    pub history:      Vec<CycleRecord>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CategoryStat {
    pub category:       String,
    pub total:          f64,
    pub pct_of_budget:  f64,  // % du total des dépenses
    pub tx_count:       u32,
    pub avg_per_tx:     f64,
    /// Comparaison avec la moyenne des cycles passés (+/- %)
    pub vs_history_pct: Option<f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PeriodComparison {
    pub current_expenses:  f64,
    pub previous_expenses: f64,
    pub delta_pct:         f64,  // positif = plus dépensé
    pub current_income:    f64,
    pub previous_income:   f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AnalyticsResult {
    pub total_expenses:       f64,
    pub total_income:         f64,
    pub net:                  f64,  // income - expenses
    pub by_category:          Vec<CategoryStat>,
    pub daily_average:        f64,
    pub peak_day:             Option<Date>,   // jour avec le plus de dépenses
    pub peak_day_amount:      f64,
    pub comparison:           Option<PeriodComparison>,
    pub savings_rate:         f64,  // (income - expenses) / income
}

// ── Classification de transaction ────────────────────────────

/// Données brutes d'une transaction SMS parsée.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RawTransaction {
    pub amount:      f64,
    pub description: Option<String>,
    pub counterpart: Option<String>,  // nom/numéro de la contrepartie
    pub sms_text:    Option<String>,
}

/// Résultat de la classification automatique.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClassificationResult {
    pub tx_type:     TransactionType,
    pub category:    String,
    pub confidence:  f64,   // 0.0..=1.0
    pub reason:      String,
}

// ── Prédiction de revenu ──────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IncomePrediction {
    pub predicted_amount:    f64,
    pub predicted_date:      Option<Date>,
    pub confidence:          f64,
    pub pattern_description: String,
    /// Nombre de cycles utilisés pour cette prédiction
    pub based_on_cycles:     u32,
}

// ── Notifications ─────────────────────────────────────────────

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum NotificationChannel {
    BudgetAlerts,
    Reminders,
    SmsParsing,
    RecurringCharges,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum NotificationPriority {
    High,
    Normal,
    Low,
}

/// Déclencheur de notification — Flutter l'affiche, le moteur décide quand.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NotificationTrigger {
    pub channel:   NotificationChannel,
    pub priority:  NotificationPriority,
    pub title:     String,
    pub body:      String,
    /// Délai en secondes avant d'afficher (0 = immédiat)
    pub delay_secs: u64,
    /// Identifiant stable pour éviter les doublons (ex: "charge_loyer_2026_03")
    pub dedup_key: String,
}

// ── Sortie étendue du moteur ──────────────────────────────────

/// Sortie complète v2 — remplace ZoltEngineOutput
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ZoltEngineOutputV2 {
    pub deterministic:          DeterministicResult,
    pub profile:                BehavioralProfile,
    pub prediction:             Option<EndOfCyclePrediction>,
    pub income_prediction:      Option<IncomePrediction>,
    pub anomalies:              Vec<Anomaly>,
    pub messages:               Vec<ConversationalMessage>,
    pub suggestions:            Vec<AdaptiveSuggestion>,
    pub notifications:          Vec<NotificationTrigger>,
}


impl Default for CycleRecord {
    fn default() -> Self {
        Self {
            cycle_start:      Date::new(2026, 1, 1),
            cycle_end:        Date::new(2026, 1, 31),
            opening_balance:  0.0,
            closing_balance:  0.0,
            total_income:     100_000.0,
            total_expenses:   80_000.0,
            savings_goal:     0.0,
            savings_achieved: 0.0,
            daily_expenses:   vec![0.0; 31],
            category_totals:  vec![],
            transactions:     vec![],
        }
    }
}

// ── Tests ─────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_date_validation_valid() {
        assert!(Date::try_new(2026, 3, 15).is_ok());
        assert!(Date::try_new(2024, 2, 29).is_ok()); // année bissextile
        assert!(Date::try_new(2025, 2, 28).is_ok()); // non-bissextile
    }

    #[test]
    fn test_date_validation_invalid() {
        assert!(Date::try_new(2025, 2, 29).is_err()); // non-bissextile
        assert!(Date::try_new(2026, 0, 1).is_err());  // mois = 0
        assert!(Date::try_new(2026, 13, 1).is_err()); // mois = 13
        assert!(Date::try_new(2026, 4, 31).is_err()); // avril a 30 jours
        assert!(Date::try_new(1999, 1, 1).is_err());  // trop tôt
    }

    #[test]
    fn test_date_roundtrip() {
        let d = Date::new(2026, 3, 15);
        let epoch = d.to_days_since_epoch();
        let back = Date::from_days_since_epoch(epoch);
        assert_eq!(d, back);
    }

    #[test]
    fn test_date_weekday() {
        // 2026-03-09 = lundi
        assert_eq!(Date::new(2026, 3, 9).weekday(), 1);
        // 2026-03-15 = dimanche
        assert_eq!(Date::new(2026, 3, 15).weekday(), 7);
    }

    #[test]
    fn test_charge_due_day_clamped_short_month() {
        // Charge due le 31 en février → clampée au 28
        let charge = RecurringCharge {
            id: "c1".into(), name: "Loyer".into(),
            amount: 100_000.0, due_day: 31,
            status: ChargeStatus::Pending, amount_paid: 0.0, is_active: true,
        };
        // En février, ne doit pas paniquer
        let today = Date::new(2025, 2, 1);
        let reserve = charge.daily_reserve(&today);
        assert!(reserve > 0.0);
    }

    #[test]
    fn test_charge_validation_invalid() {
        let bad = RecurringCharge {
            id: "c1".into(), name: "Test".into(),
            amount: -500.0, due_day: 15,
            status: ChargeStatus::Pending, amount_paid: 0.0, is_active: true,
        };
        assert!(bad.validate().is_err());
    }

    #[test]
    fn test_engine_input_validation_no_active_account() {
        let input = EngineInput {
            today: Date::new(2026, 3, 10),
            accounts: vec![Account {
                id: "a1".into(), name: "Cash".into(),
                account_type: AccountType::Cash,
                balance: 100.0, is_active: false, // inactif
            }],
            charges: vec![], transactions: vec![],
            cycle: FinancialCycle {
                cycle_type:   CycleType::Monthly,
                savings_goal: 0.0,
                transport:    TransportType::None,
            },
        };
        assert!(input.validate().is_err());
    }

    #[test]
    fn test_transport_validation_empty_work_days() {
        let t = TransportType::Daily { cost_per_day: 500.0, work_days: vec![] };
        assert!(t.validate().is_err());
    }

    #[test]
    fn test_deterministic_result_helpers() {
        let det = DeterministicResult {
            total_balance: 50_000.0,
            committed_mass: 80_000.0,
            free_mass: 0.0, // clampé
            days_remaining: 5,
            daily_budget: 0.0,
            spent_today: 0.0,
            remaining_today: 0.0,
            transport_reserve: 0.0,
            charges_reserve: 80_000.0,
        };
        assert!(det.is_insolvent());
        assert!(!det.is_over_budget());
    }
}

// ── Types v1.3.0 — Session State, Health Score, Triage, Onboarding ──

/// Score de santé financière 0-100 avec détail par dimension.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HealthScore {
    /// Score global 0-100
    pub score:        u8,
    pub grade:        HealthGrade,
    /// Dimensions détaillées (chacune 0-100)
    pub budget:       u8,   // respect du budget journalier
    pub savings:      u8,   // progression vers l'objectif d'épargne
    pub stability:    u8,   // régularité des dépenses (faible volatilité = bien)
    pub prediction:   u8,   // trajectoire de fin de cycle
    pub trend:        i8,   // delta vs cycle précédent (-100..+100)
    pub message:      String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum HealthGrade {
    Excellent, // 80-100
    Good,      // 60-79
    Fair,      // 40-59
    Poor,      // 20-39
    Critical,  // 0-19
}

/// Transaction SMS en attente de triage, enrichie par le moteur.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PendingTransactionInput {
    pub id:          String,
    pub raw:         RawTransaction,
    /// Date de détection
    pub detected_at: Date,
}

/// Résultat du scoring pour une transaction en attente.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TriageResult {
    pub id:                String,
    pub classification:    ClassificationResult,
    /// true si le moteur recommande d'ignorer (doublon potentiel)
    pub suggest_ignore:    bool,
    pub ignore_reason:     Option<String>,
    /// Impact sur le budget si confirmé comme dépense
    pub budget_impact:     Option<BudgetImpact>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BudgetImpact {
    pub daily_budget_pct:   f64,  // % du budget journalier
    pub remaining_after:    f64,
    pub would_exceed_budget: bool,
}

/// Entrée pour le scoring de triage batch.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TriageInput {
    pub pending:            Vec<PendingTransactionInput>,
    /// Transactions déjà confirmées du cycle (pour détecter doublons)
    pub existing:           Vec<Transaction>,
    pub det:                DeterministicResult,
}

/// État du cycle — détecté par le moteur.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum CycleStatus {
    /// Cycle en cours, tout va bien
    Active,
    /// Fin de cycle dans N jours
    EndingSoon { days_remaining: u32 },
    /// Cycle terminé — doit être clôturé
    ShouldClose,
    /// Nouveau cycle à initialiser
    ShouldInit,
}

/// Résultat de la détection de cycle.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CycleDetectionResult {
    pub status:             CycleStatus,
    pub current_day:        u32,
    pub total_days:         u32,
    pub pct_elapsed:        f64,
    /// Si ShouldInit : template du prochain EngineInput (charges reportées, etc.)
    pub next_input_template: Option<NextCycleTemplate>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NextCycleTemplate {
    /// Charges actives à reconduire (réinitialisées)
    pub charges:            Vec<RecurringCharge>,
    /// Transactions récurrentes à pré-renseigner
    pub suggested_opening_balance: f64,
}

/// Suivi d'une charge avec paiement partiel.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChargeTrackingResult {
    pub charge_id:          String,
    pub charge_name:        String,
    pub total_amount:       f64,
    pub paid_amount:        f64,
    pub remaining:          f64,
    pub is_fully_paid:      bool,
    pub is_overdue:         bool,
    pub days_until_due:     i32,  // négatif = en retard
    pub daily_reserve_needed: f64,
    pub alert:              Option<ConversationalMessage>,
}

/// Résultat de validation de l'intégrité des données.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IntegrityReport {
    pub is_valid:           bool,
    pub errors:             Vec<IntegrityError>,
    pub warnings:           Vec<String>,
    pub auto_fixed:         Vec<String>,
    /// Score de confiance dans les données 0-100
    pub data_confidence:    u8,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IntegrityError {
    pub code:    String,
    pub message: String,
    pub fatal:   bool,
}

/// Données brutes depuis l'onboarding Flutter.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OnboardingInput {
    pub first_name:         String,
    pub currency:           String,
    pub cycle_type:         CycleType,
    pub accounts:           Vec<AccountOnboarding>,
    pub charges:            Vec<ChargeOnboarding>,
    pub transport_type:     String,
    pub transport_cost:     Option<f64>,
    pub transport_days:     Option<Vec<u8>>,
    pub savings_goal:       f64,
    pub today:              Date,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AccountOnboarding {
    pub name:           String,
    pub account_type:   String,
    pub balance:        f64,
    pub operator:       Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChargeOnboarding {
    pub name:       String,
    pub amount:     f64,
    pub due_day:    u8,
}

/// Sortie de l'onboarding : EngineInput prêt à l'emploi + erreurs.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OnboardingResult {
    pub engine_input:       Option<EngineInput>,
    pub validation_errors:  Vec<String>,
    pub is_ready:           bool,
}

/// SESSION STATE — l'appel unique que Flutter fait à chaque ouverture.
/// Retourne tout ce dont l'app a besoin pour afficher l'écran d'accueil.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SessionState {
    /// Tout le moteur principal
    pub engine:             ZoltEngineOutputV2,
    /// Score de santé
    pub health:             HealthScore,
    /// État du cycle
    pub cycle:              CycleDetectionResult,
    /// Suivi des charges
    pub charge_tracking:    Vec<ChargeTrackingResult>,
    /// Transactions SMS à trier (avec scoring)
    pub triage:             Vec<TriageResult>,
    /// Rapport d'intégrité (silencieux si OK)
    pub integrity:          IntegrityReport,
    /// Timestamp de calcul (epoch jours)
    pub computed_at_epoch:  u32,
}

/// Entrée pour le calcul de session complète.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SessionInput {
    pub engine_input:       EngineInput,
    pub history:            Vec<CycleRecord>,
    pub pending_sms:        Vec<PendingTransactionInput>,
}
