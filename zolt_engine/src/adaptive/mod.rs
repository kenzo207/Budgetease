// ============================================================
//  COUCHE 2 — MOTEUR ADAPTATIF
//  5 modules indépendants qui apprennent des comportements.
//  Nécessite un historique de cycles passés pour être fiable.
//  Pendant les 3 premiers cycles → mode observation uniquement.
// ============================================================

pub mod profile;    // Module A — Profil comportemental
pub mod prediction; // Module B — Prédiction fin de cycle
pub mod anomaly;    // Module C — Détection d'anomalies
pub mod adjustment; // Module D — Ajustements adaptatifs
pub mod memory;     // Module E — Mémoire épisodique

use crate::types::*;

/// Historique d'un cycle terminé, stocké localement (SQLite).
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct CycleRecord {
    pub cycle_start:         Date,
    pub cycle_end:           Date,
    pub opening_balance:     f64,
    pub closing_balance:     f64,
    pub total_income:        f64,
    pub total_expenses:      f64,
    pub savings_goal:        f64,
    pub savings_achieved:    f64,
    /// Dépenses par jour du cycle (index 0 = jour 1)
    pub daily_expenses:      Vec<f64>,
    /// Dépenses par catégorie : (catégorie, total)
    pub category_totals:     Vec<(String, f64)>,
    pub transactions:        Vec<Transaction>,
}

impl CycleRecord {
    pub fn cycle_length(&self) -> u32 {
        (self.cycle_start.days_until(&self.cycle_end) + 1).max(1) as u32
    }
}

/// Façade : orchestre tous les modules adaptatifs.
pub struct AdaptiveEngine;

impl AdaptiveEngine {
    pub fn run(
        input:   &EngineInput,
        history: &[CycleRecord],
        det:     &DeterministicResult,
    ) -> AdaptiveOutput {
        let profile    = profile::ProfileModule::compute(history);
        let prediction = prediction::PredictionModule::compute(input, det, history, &profile);
        let anomalies  = anomaly::AnomalyModule::detect(input, history, &profile, det);
        let suggestions = adjustment::AdjustmentModule::suggest(history, &profile, det);
        let episodes   = memory::MemoryModule::relevant_episodes(input, history);

        AdaptiveOutput { profile, prediction, anomalies, suggestions, episodes }
    }
}

#[derive(Debug, Clone)]
pub struct AdaptiveOutput {
    pub profile:     BehavioralProfile,
    pub prediction:  Option<EndOfCyclePrediction>,
    pub anomalies:   Vec<Anomaly>,
    pub suggestions: Vec<AdaptiveSuggestion>,
    pub episodes:    Vec<memory::Episode>,
}
