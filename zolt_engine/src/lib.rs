// ============================================================
//  ZOLT ENGINE — Moteur IA financier on-device
//  Architecture : 3 couches indépendantes
//    1. deterministic  → calculs exacts, budget journalier
//    2. adaptive       → 5 modules d'apprentissage comportemental
//    3. surface        → templates conversationnels contextuels
//  Compatible Flutter via FFI (crate-type = cdylib)
// ============================================================

pub mod deterministic;
pub mod adaptive;
pub mod surface;
pub mod ffi;
pub mod types;

// Modules étendus v1.2.0
pub mod analytics;
pub mod cycle_close;
pub mod classifier;
pub mod income_predictor;
pub mod notifications;

// Modules v1.3.0
pub mod health_score;
pub mod triage_scorer;
pub mod cycle_detector;
pub mod ops;
pub mod session;

// Modules v1.4.0 — Conseiller financier embarqué
pub mod cash_tracker;
pub mod behavioral_insights;
pub mod scenario_engine;
pub mod narrative_engine;
pub mod receipt_parser;
pub mod session_v2;

// Modules v1.4.0 — Fiabilité & SMS
pub mod sms_parser;
pub mod compute_verifier;

// Modules v1.5.0 — Fraude, Score, Mode serré
pub mod fraud_detector;
pub mod credit_score;
pub mod tight_month;
