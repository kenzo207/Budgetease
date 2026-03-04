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

// Types partagés entre toutes les couches
pub mod types;
