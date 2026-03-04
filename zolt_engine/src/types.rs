// ============================================================
//  TYPES PARTAGÉS — Structures de données communes
//  Toutes les couches importent depuis ce module.
//  Serde est utilisé pour la sérialisation JSON (SQLite ↔ Rust)
// ============================================================

use serde::{Deserialize, Serialize};

// ── Dates légères (pas de chrono — on-device, minimaliste) ──

/// Représentation d'une date sans dépendance externe.
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

    /// Nombre de jours entre deux dates (self → other, positif si other > self).
    pub fn days_until(&self, other: &Date) -> i32 {
        let a = self.to_days_since_epoch();
        let b = other.to_days_since_epoch();
        b as i32 - a as i32
    }

    /// Jour de la semaine : 1 = lundi … 7 = dimanche (ISO 8601)
    pub fn weekday(&self) -> u8 {
        let days = self.to_days_since_epoch();
        // Algorithme de Tomohiko Sakamoto
        ((days + 3) % 7 + 1) as u8
    }

    /// Conversion en jours depuis une époque arbitraire (2000-01-01)
    pub fn to_days_since_epoch(&self) -> u32 {
        let y = self.year as u32;
        let m = self.month as u32;
        let d = self.day as u32;
        let y = if m <= 2 { y - 1 } else { y };
        let era = y / 400;
        let yoe = y - era * 400;
        let doy = (153 * (m + if m > 2 { 0 } else { 9 } - 3) + 2) / 5 + d - 1;
        let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy;
        era * 146097 + doe
    }
}

// ── Comptes ──

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

// ── Transactions ──

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
    /// Retourne true si la transaction réduit le solde disponible
    pub fn is_outflow(&self) -> bool {
        matches!(self, Self::Expense | Self::TransferOut | Self::Withdrawal)
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Transaction {
    pub id:           String,
    pub date:         Date,
    pub amount:       f64,
    pub tx_type:      TransactionType,
    pub category:     Option<String>,
    pub account_id:   String,
    pub description:  Option<String>,
    /// Score de confiance SMS (0.0..=1.0). None si saisie manuelle.
    pub sms_confidence: Option<f64>,
}

// ── Charges fixes ──

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
    pub due_day:       u8,   // jour du mois (1..=31)
    pub status:        ChargeStatus,
    pub amount_paid:   f64,  // pour paiement partiel
    pub is_active:     bool,
}

impl RecurringCharge {
    pub fn remaining_amount(&self) -> f64 {
        (self.amount - self.amount_paid).max(0.0)
    }

    /// Réserve journalière nécessaire pour cette charge à partir d'aujourd'hui.
    /// Retourne 0.0 si la charge est déjà payée.
    pub fn daily_reserve(&self, today: &Date) -> f64 {
        if self.status == ChargeStatus::Paid {
            return 0.0;
        }
        let due_date = Date::new(today.year, today.month, self.due_day);
        let days_until = today.days_until(&due_date);

        if days_until < 0 {
            // Charge en retard → réserve immédiate du montant total restant
            self.remaining_amount()
        } else if days_until == 0 {
            // Échéance aujourd'hui
            self.remaining_amount()
        } else {
            self.remaining_amount() / days_until as f64
        }
    }

    /// Réinitialise la charge pour un nouveau cycle.
    pub fn reset_for_new_cycle(&self) -> Self {
        Self {
            status:      ChargeStatus::Pending,
            amount_paid: 0.0,
            ..self.clone()
        }
    }
}

// ── Transport ──

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum TransportType {
    /// Coût par jour de travail effectif
    Daily { cost_per_day: f64, work_days: Vec<u8> }, // work_days: 1=lun..7=dim
    /// Abonnement mensuel → traité comme charge fixe
    Subscription,
    /// Pas de transport configuré
    None,
}

// ── Cycle financier ──

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
    pub savings_goal:  f64,  // montant absolu à préserver
    pub transport:     TransportType,
}

// ── Snapshot d'état complet (entrée principale du moteur) ──

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EngineInput {
    pub today:       Date,
    pub accounts:    Vec<Account>,
    pub charges:     Vec<RecurringCharge>,
    pub cycle:       FinancialCycle,
    /// Transactions du cycle en cours uniquement
    pub transactions: Vec<Transaction>,
}

// ── Résultat du moteur déterministe ──

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeterministicResult {
    pub total_balance:       f64,
    pub committed_mass:      f64,   // épargne + transport + charges
    pub free_mass:           f64,   // ce qui est réellement libre
    pub days_remaining:      u32,
    pub daily_budget:        f64,   // B_j
    pub spent_today:         f64,
    pub remaining_today:     f64,   // B_j - dépenses du jour
    pub transport_reserve:   f64,
    pub charges_reserve:     f64,   // Σ charges non payées
}

// ── Profil comportemental (sortie du module A) ──

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

// ── Prédiction de fin de cycle (sortie module B) ──

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EndOfCyclePrediction {
    pub projected_final_balance: f64,
    pub projected_deficit:       f64,  // 0.0 si pas de déficit
    pub confidence:              f64,  // 0.0..=1.0 (faible si peu d'historique)
    pub alert_level:             AlertLevel,
}

// ── Anomalies (sortie module C) ──

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum AnomalyType {
    UnusualAmount { category: String, amount: f64, historical_avg: f64 },
    GhostMoney    { transaction_count: u32, total: f64, impact_pct: f64 },
    UnusualTiming { category: String, typical_week: u8, actual_week: u8 },
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Anomaly {
    pub anomaly_type: AnomalyType,
    pub detected_on:  Date,
    pub expires_on:   Date,
    pub dismissed:    bool,
}

// ── Niveaux d'alerte ──

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Serialize, Deserialize)]
pub enum AlertLevel {
    Info,       // bleu  — insight neutre
    Warning,    // orange — action recommandée
    Critical,   // rouge  — action urgente
    Positive,   // vert   — encouragement
}

// ── Message conversationnel (sortie couche 3) ──

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ConversationalMessage {
    pub level:   AlertLevel,
    pub title:   String,
    pub body:    String,
    /// Durée d'affichage en jours (None = permanent jusqu'à action)
    pub ttl_days: Option<u32>,
}

// ── Résultat complet du moteur (toutes couches) ──

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ZoltEngineOutput {
    pub deterministic:  DeterministicResult,
    pub profile:        BehavioralProfile,
    pub prediction:     Option<EndOfCyclePrediction>,
    pub anomalies:      Vec<Anomaly>,
    pub messages:       Vec<ConversationalMessage>,
    pub suggestions:    Vec<AdaptiveSuggestion>,
}

// ── Suggestions adaptatives (sortie module D) ──

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum AdaptiveSuggestion {
    ReviseSavingsGoal   { current: f64, suggested: f64, reason: String },
    AddHiddenCharge     { estimated_amount: f64, pattern_description: String },
    AdjustSafetyMargin  { new_margin_pct: f64 },
}
