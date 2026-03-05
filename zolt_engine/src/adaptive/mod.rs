// ============================================================
//  COUCHE 2 — MOTEUR ADAPTATIF
//  Note : CycleRecord est maintenant dans types.rs
// ============================================================

pub mod profile;
pub mod prediction;
pub mod anomaly;
pub mod adjustment;
pub mod memory;

use crate::types::*;
pub use crate::types::CycleRecord;

pub struct AdaptiveEngine;

impl AdaptiveEngine {
    pub fn run(
        input:   &EngineInput,
        history: &[CycleRecord],
        det:     &DeterministicResult,
    ) -> AdaptiveOutput {
        let valid_history: Vec<CycleRecord> = history.iter()
            .filter(|r| r.validate().is_ok())
            .cloned()
            .collect();

        let profile     = profile::ProfileModule::compute(&valid_history);
        let prediction  = prediction::PredictionModule::compute(input, det, &valid_history, &profile);
        let anomalies   = anomaly::AnomalyModule::detect(input, &valid_history, &profile, det);
        let suggestions = adjustment::AdjustmentModule::suggest(&valid_history, &profile, det);
        let episodes    = memory::MemoryModule::relevant_episodes(input, &valid_history);

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
