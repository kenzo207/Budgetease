// ============================================================
//  FFI — BRIDGE FLUTTER
//  Interface C-compatible pour appel depuis Flutter via dart:ffi.
//  Règles strictes :
//    - Toutes les fonctions exportées sont #[no_mangle] extern "C"
//    - Pas de types Rust dans la signature (seulement primitives C)
//    - La mémoire allouée par Rust est libérée par Rust (zolt_free)
//    - Les strings passent en JSON UTF-8 null-terminé
//
//  Utilisation depuis Flutter :
//    1. Sérialise EngineInput en JSON (dart:convert)
//    2. Appelle zolt_run(json_ptr, json_len) → ptr vers JSON résultat
//    3. Lit le JSON résultat
//    4. Appelle zolt_free(ptr) pour libérer la mémoire
// ============================================================

use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int};

use crate::types::{EngineInput, ZoltEngineOutput};
use crate::adaptive::CycleRecord;
use crate::deterministic::DeterministicEngine;
use crate::adaptive::AdaptiveEngine;
use crate::surface::SurfaceEngine;

/// Point d'entrée principal.
/// 
/// # Arguments
/// * `input_json`   — Pointeur vers JSON UTF-8 null-terminé contenant `EngineInput`
/// * `history_json` — Pointeur vers JSON UTF-8 null-terminé contenant `Vec<CycleRecord>`
///
/// # Retour
/// Pointeur vers JSON UTF-8 null-terminé contenant `ZoltEngineOutput`.
/// **Doit être libéré avec `zolt_free`.**
/// Retourne un JSON d'erreur si le parsing échoue.
#[no_mangle]
pub extern "C" fn zolt_run(
    input_json:   *const c_char,
    history_json: *const c_char,
) -> *mut c_char {
    // Sécurité : vérifie les pointeurs null
    if input_json.is_null() || history_json.is_null() {
        return error_json("null pointer");
    }

    let input_str = match unsafe { CStr::from_ptr(input_json) }.to_str() {
        Ok(s)  => s,
        Err(_) => return error_json("invalid UTF-8 in input"),
    };

    let history_str = match unsafe { CStr::from_ptr(history_json) }.to_str() {
        Ok(s)  => s,
        Err(_) => return error_json("invalid UTF-8 in history"),
    };

    // Désérialise les entrées
    let input: EngineInput = match serde_json::from_str(input_str) {
        Ok(v)  => v,
        Err(e) => return error_json(&format!("input parse error: {}", e)),
    };

    let history: Vec<CycleRecord> = match serde_json::from_str(history_str) {
        Ok(v)  => v,
        Err(e) => return error_json(&format!("history parse error: {}", e)),
    };

    // ── Exécute les 3 couches ──
    let det      = DeterministicEngine::compute(&input);
    let adaptive = AdaptiveEngine::run(&input, &history, &det);
    let messages = SurfaceEngine::generate(&det, &adaptive, &input.today);

    let output = ZoltEngineOutput {
        deterministic: det,
        profile:       adaptive.profile,
        prediction:    adaptive.prediction,
        anomalies:     adaptive.anomalies,
        messages,
        suggestions:   adaptive.suggestions,
    };

    // Sérialise la sortie
    match serde_json::to_string(&output) {
        Ok(json) => match CString::new(json) {
            Ok(c)  => c.into_raw(),
            Err(_) => error_json("output serialization error"),
        },
        Err(e) => error_json(&format!("serialization error: {}", e)),
    }
}

/// Libère la mémoire allouée par `zolt_run`.
/// **Doit être appelé exactement une fois par pointeur retourné par `zolt_run`.**
#[no_mangle]
pub extern "C" fn zolt_free(ptr: *mut c_char) {
    if ptr.is_null() { return; }
    unsafe { drop(CString::from_raw(ptr)); }
}

/// Retourne la version du moteur sous forme de chaîne JSON.
/// Format : `{"version":"1.0.0","build":"2026-03-04"}`
#[no_mangle]
pub extern "C" fn zolt_version() -> *mut c_char {
    let v = r#"{"version":"1.0.0","build":"2026-03-04"}"#;
    CString::new(v).unwrap().into_raw()
}

// ── Utilitaire interne ───────────────────────────────────────
fn error_json(msg: &str) -> *mut c_char {
    let json = format!(r#"{{"error":"{}"}}"#, msg.replace('"', "'"));
    CString::new(json).unwrap_or_else(|_| CString::new("{}").unwrap()).into_raw()
}

// ────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;
    use std::ffi::CString;

    fn make_minimal_input_json() -> CString {
        CString::new(r#"{
            "today": {"year": 2026, "month": 3, "day": 15},
            "accounts": [{
                "id": "a1", "name": "MoMo",
                "account_type": "MobileMoney",
                "balance": 250000.0, "is_active": true
            }],
            "charges": [],
            "transactions": [],
            "cycle": {
                "cycle_type": "Monthly",
                "savings_goal": 25000.0,
                "transport": "None"
            }
        }"#).unwrap()
    }

    #[test]
    fn test_ffi_round_trip() {
        let input   = make_minimal_input_json();
        let history = CString::new("[]").unwrap();

        let result_ptr = zolt_run(input.as_ptr(), history.as_ptr());
        assert!(!result_ptr.is_null());

        let result_str = unsafe { CStr::from_ptr(result_ptr) }.to_str().unwrap();
        assert!(result_str.contains("daily_budget"));
        assert!(!result_str.contains("\"error\""));

        zolt_free(result_ptr);
    }

    #[test]
    fn test_ffi_null_input_returns_error() {
        let result_ptr = zolt_run(std::ptr::null(), std::ptr::null());
        assert!(!result_ptr.is_null());
        let result_str = unsafe { CStr::from_ptr(result_ptr) }.to_str().unwrap();
        assert!(result_str.contains("error"));
        zolt_free(result_ptr);
    }

    #[test]
    fn test_ffi_invalid_json_returns_error() {
        let bad   = CString::new("not valid json{{").unwrap();
        let empty = CString::new("[]").unwrap();
        let ptr   = zolt_run(bad.as_ptr(), empty.as_ptr());
        let s     = unsafe { CStr::from_ptr(ptr) }.to_str().unwrap();
        assert!(s.contains("error"));
        zolt_free(ptr);
    }
}
