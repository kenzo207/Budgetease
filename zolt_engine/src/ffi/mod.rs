// ============================================================
//  FFI — BRIDGE FLUTTER v1.2.0
//  Interface C-compatible pour appel depuis Flutter via dart:ffi.
//
//  Fonctions exportées :
//    zolt_run            → moteur complet (budget + adaptatif + notifs)
//    zolt_free           → libère la mémoire allouée par Rust
//    zolt_version        → version du moteur
//    zolt_validate       → valide l'input sans exécuter le moteur
//    zolt_analytics      → statistiques du cycle courant
//    zolt_close_cycle    → clôture d'un cycle financier
//    zolt_classify       → classification d'une transaction SMS
//    zolt_predict_income → prédiction du prochain revenu
// ============================================================

use std::ffi::{CStr, CString};
use std::os::raw::c_char;

use crate::types::*;
use crate::deterministic::DeterministicEngine;
use crate::adaptive::AdaptiveEngine;
use crate::surface::SurfaceEngine;
use crate::analytics::AnalyticsEngine;
use crate::cycle_close::CycleCloseEngine;
use crate::classifier::TransactionClassifier;
use crate::income_predictor::IncomePredictorEngine;
use crate::notifications::NotificationsEngine;

// ─────────────────────────────────────────────────────────────
//  MOTEUR COMPLET
// ─────────────────────────────────────────────────────────────

/// Exécute le moteur complet.
/// Input  : `input_json`   = EngineInput JSON
///          `history_json` = Vec<CycleRecord> JSON
/// Output : ZoltEngineOutputV2 JSON  — libérer avec zolt_free()
#[no_mangle]
pub extern "C" fn zolt_run(
    input_json:   *const c_char,
    history_json: *const c_char,
) -> *mut c_char {
    if input_json.is_null() || history_json.is_null() {
        return error_json("pointeur null reçu");
    }
    let input: EngineInput = match parse_json(input_json, "engine_input") {
        Ok(v) => v, Err(e) => return e,
    };
    let history: Vec<CycleRecord> = match parse_json(history_json, "history") {
        Ok(v) => v, Err(e) => return e,
    };

    let det = match DeterministicEngine::compute(&input) {
        Ok(d)  => d,
        Err(e) => return error_json(&format!("erreur deterministe: {}", e)),
    };
    let adaptive      = AdaptiveEngine::run(&input, &history, &det);
    let income_pred   = IncomePredictorEngine::predict(&history, &input.today);
    let notifications = NotificationsEngine::compute(&det, &adaptive, &input, income_pred.as_ref());
    let messages      = SurfaceEngine::generate(&det, &adaptive, &input.today);

    let output = ZoltEngineOutputV2 {
        deterministic:     det,
        profile:           adaptive.profile,
        prediction:        adaptive.prediction,
        income_prediction: income_pred,
        anomalies:         adaptive.anomalies,
        messages,
        suggestions:       adaptive.suggestions,
        notifications,
    };
    to_json_ptr(&output)
}

// ─────────────────────────────────────────────────────────────
//  ANALYTICS
// ─────────────────────────────────────────────────────────────

/// Calcule les statistiques du cycle courant.
/// Input  : AnalyticsInput JSON
/// Output : AnalyticsResult JSON
#[no_mangle]
pub extern "C" fn zolt_analytics(input_json: *const c_char) -> *mut c_char {
    let input: AnalyticsInput = match parse_json(input_json, "analytics") {
        Ok(v) => v, Err(e) => return e,
    };
    to_json_ptr(&AnalyticsEngine::compute(&input))
}

// ─────────────────────────────────────────────────────────────
//  CLÔTURE DE CYCLE
// ─────────────────────────────────────────────────────────────

/// Clôture un cycle et retourne le CycleRecord complet + message bilan.
/// Input  : CycleCloseInput JSON
/// Output : CycleCloseResult JSON
#[no_mangle]
pub extern "C" fn zolt_close_cycle(input_json: *const c_char) -> *mut c_char {
    let input: CycleCloseInput = match parse_json(input_json, "cycle_close") {
        Ok(v) => v, Err(e) => return e,
    };
    match CycleCloseEngine::close(&input) {
        Ok(r)  => to_json_ptr(&r),
        Err(e) => error_json(&e.to_string()),
    }
}

// ─────────────────────────────────────────────────────────────
//  CLASSIFICATION DE TRANSACTION
// ─────────────────────────────────────────────────────────────

/// Classifie automatiquement une transaction brute (SMS ou saisie).
/// Input  : RawTransaction JSON
/// Output : ClassificationResult JSON
#[no_mangle]
pub extern "C" fn zolt_classify(input_json: *const c_char) -> *mut c_char {
    let raw: RawTransaction = match parse_json(input_json, "raw_transaction") {
        Ok(v) => v, Err(e) => return e,
    };
    to_json_ptr(&TransactionClassifier::classify(&raw))
}

// ─────────────────────────────────────────────────────────────
//  PRÉDICTION DE REVENU
// ─────────────────────────────────────────────────────────────

/// Prédit le prochain revenu basé sur l'historique.
/// Input  : { "history": [CycleRecord], "today": Date } JSON
/// Output : IncomePrediction JSON  ou  "null"
#[no_mangle]
pub extern "C" fn zolt_predict_income(input_json: *const c_char) -> *mut c_char {
    #[derive(serde::Deserialize)]
    struct In { history: Vec<CycleRecord>, today: Date }

    let input: In = match parse_json(input_json, "income_pred") {
        Ok(v) => v, Err(e) => return e,
    };
    match IncomePredictorEngine::predict(&input.history, &input.today) {
        Some(p) => to_json_ptr(&p),
        None    => string_to_ptr("null"),
    }
}

// ─────────────────────────────────────────────────────────────
//  UTILITAIRES
// ─────────────────────────────────────────────────────────────

/// Libère la mémoire allouée par toute fonction zolt_*. null → no-op.
#[no_mangle]
pub extern "C" fn zolt_free(ptr: *mut c_char) {
    if ptr.is_null() { return; }
    unsafe { drop(CString::from_raw(ptr)); }
}

/// Valide l'input sans exécuter le moteur.
/// Output : {"valid":true} | {"valid":false,"error":"..."}
#[no_mangle]
pub extern "C" fn zolt_validate(input_json: *const c_char) -> *mut c_char {
    if input_json.is_null() {
        return string_to_ptr(r#"{"valid":false,"error":"pointeur null"}"#);
    }
    let s = match unsafe { CStr::from_ptr(input_json) }.to_str() {
        Ok(s)  => s,
        Err(_) => return string_to_ptr(r#"{"valid":false,"error":"UTF-8 invalide"}"#),
    };
    let input: EngineInput = match serde_json::from_str(s) {
        Ok(v)  => v,
        Err(e) => {
            let msg = format!(r#"{{"valid":false,"error":"{}"}}"#, escape(&e.to_string()));
            return string_to_ptr(&msg);
        }
    };
    match input.validate() {
        Ok(())  => string_to_ptr(r#"{"valid":true}"#),
        Err(e)  => {
            let msg = format!(r#"{{"valid":false,"error":"{}"}}"#, escape(&e.to_string()));
            string_to_ptr(&msg)
        }
    }
}

/// Retourne la version du moteur.
#[no_mangle]
pub extern "C" fn zolt_version() -> *mut c_char {
    string_to_ptr(r#"{"version":"1.4.0","build":"2026-03-08"}"#)
}

// ── Helpers internes ──────────────────────────────────────────

fn parse_json<T: serde::de::DeserializeOwned>(
    ptr:     *const c_char,
    context: &str,
) -> Result<T, *mut c_char> {
    if ptr.is_null() {
        return Err(error_json(&format!("{}: pointeur null", context)));
    }
    let s = match unsafe { CStr::from_ptr(ptr) }.to_str() {
        Ok(s)  => s,
        Err(_) => return Err(error_json(&format!("{}: UTF-8 invalide", context))),
    };
    serde_json::from_str(s).map_err(|e| {
        error_json(&format!("{}: JSON invalide — {}", context, e))
    })
}

fn to_json_ptr<T: serde::Serialize>(v: &T) -> *mut c_char {
    match serde_json::to_string(v) {
        Ok(json) => string_to_ptr(&json),
        Err(e)   => error_json(&format!("serialisation: {}", e)),
    }
}

fn error_json(msg: &str) -> *mut c_char {
    string_to_ptr(&format!(r#"{{"error":"{}"}}"#, escape(msg)))
}

fn string_to_ptr(s: &str) -> *mut c_char {
    CString::new(s)
        .unwrap_or_else(|_| CString::new("{}").unwrap())
        .into_raw()
}

fn escape(s: &str) -> String {
    s.replace('\\', "\\\\").replace('"', "\\'").replace('\n', " ")
}

// ─────────────────────────────────────────────────────────────
//  TESTS FFI
// ─────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;
    use std::ffi::CString;

    fn ptr_to_str(ptr: *mut c_char) -> String {
        assert!(!ptr.is_null(), "ptr is null");
        let s = unsafe { CStr::from_ptr(ptr) }.to_str().unwrap().to_owned();
        zolt_free(ptr);
        s
    }

    fn minimal_input_json() -> CString {
        CString::new(r#"{
            "today":{"year":2026,"month":3,"day":15},
            "accounts":[{"id":"a1","name":"MoMo","account_type":"MobileMoney","balance":250000.0,"is_active":true}],
            "charges":[],"transactions":[],
            "cycle":{"cycle_type":"Monthly","savings_goal":25000.0,"transport":"None"}
        }"#).unwrap()
    }

    // ── zolt_run ──────────────────────────────────────────────
    #[test]
    fn test_run_success_has_all_fields() {
        let s = ptr_to_str(zolt_run(
            minimal_input_json().as_ptr(),
            CString::new("[]").unwrap().as_ptr(),
        ));
        assert!(!s.contains("\"error\""), "unexpected error: {}", s);
        assert!(s.contains("daily_budget"),      "missing daily_budget");
        assert!(s.contains("notifications"),     "missing notifications");
        assert!(s.contains("income_prediction"), "missing income_prediction");
        assert!(s.contains("messages"),          "missing messages");
    }

    #[test]
    fn test_run_null_input_returns_error() {
        let s = ptr_to_str(zolt_run(std::ptr::null(), std::ptr::null()));
        assert!(s.contains("error"), "{}", s);
    }

    #[test]
    fn test_run_bad_json_returns_error() {
        let bad = CString::new("{not json").unwrap();
        let s   = ptr_to_str(zolt_run(bad.as_ptr(), CString::new("[]").unwrap().as_ptr()));
        assert!(s.contains("error"), "{}", s);
    }

    #[test]
    fn test_run_with_charge_due_today_has_notification() {
        let json = CString::new(r#"{
            "today":{"year":2026,"month":3,"day":15},
            "accounts":[{"id":"a1","name":"MoMo","account_type":"MobileMoney","balance":300000.0,"is_active":true}],
            "charges":[{"id":"c1","name":"Loyer","amount":120000.0,"due_day":15,"status":"Pending","amount_paid":0.0,"is_active":true}],
            "transactions":[],
            "cycle":{"cycle_type":"Monthly","savings_goal":25000.0,"transport":"None"}
        }"#).unwrap();
        let s = ptr_to_str(zolt_run(json.as_ptr(), CString::new("[]").unwrap().as_ptr()));
        assert!(!s.contains("\"error\""), "{}", s);
        assert!(s.contains("RecurringCharges"), "{}", s);
    }

    // ── zolt_analytics ────────────────────────────────────────
    #[test]
    fn test_analytics_basic() {
        let json = CString::new(r#"{
            "transactions":[
                {"id":"t1","date":{"year":2026,"month":3,"day":5},"amount":10000.0,
                 "tx_type":"Expense","category":"nourriture","account_id":"a1",
                 "description":null,"sms_confidence":null}
            ],
            "cycle_start":{"year":2026,"month":3,"day":1},
            "cycle_end":{"year":2026,"month":3,"day":31},
            "history":[]
        }"#).unwrap();
        let s = ptr_to_str(zolt_analytics(json.as_ptr()));
        assert!(!s.contains("\"error\""),   "{}", s);
        assert!(s.contains("total_expenses"), "{}", s);
        assert!(s.contains("by_category"),   "{}", s);
    }

    #[test]
    fn test_analytics_null_returns_error() {
        let s = ptr_to_str(zolt_analytics(std::ptr::null()));
        assert!(s.contains("error"), "{}", s);
    }

    // ── zolt_close_cycle ──────────────────────────────────────
    #[test]
    fn test_close_cycle_success() {
        let json = CString::new(r#"{
            "cycle_start":{"year":2026,"month":3,"day":1},
            "cycle_end":{"year":2026,"month":3,"day":31},
            "opening_balance":300000.0,
            "closing_balance":80000.0,
            "savings_goal":30000.0,
            "transactions":[
                {"id":"t1","date":{"year":2026,"month":3,"day":1},"amount":200000.0,
                 "tx_type":"Income","category":"salaire","account_id":"a1",
                 "description":null,"sms_confidence":null},
                {"id":"t2","date":{"year":2026,"month":3,"day":10},"amount":50000.0,
                 "tx_type":"Expense","category":"loyer","account_id":"a1",
                 "description":null,"sms_confidence":null}
            ]
        }"#).unwrap();
        let s = ptr_to_str(zolt_close_cycle(json.as_ptr()));
        assert!(!s.contains("\"error\""),    "{}", s);
        assert!(s.contains("summary_message"), "{}", s);
        assert!(s.contains("cycle_start"),     "{}", s);
    }

    #[test]
    fn test_close_cycle_invalid_dates_error() {
        let json = CString::new(r#"{
            "cycle_start":{"year":2026,"month":3,"day":31},
            "cycle_end":{"year":2026,"month":3,"day":1},
            "opening_balance":100000.0,"closing_balance":100000.0,
            "savings_goal":0.0,"transactions":[]
        }"#).unwrap();
        let s = ptr_to_str(zolt_close_cycle(json.as_ptr()));
        assert!(s.contains("error"), "{}", s);
    }

    // ── zolt_classify ─────────────────────────────────────────
    #[test]
    fn test_classify_telecom() {
        let json = CString::new(r#"{"amount":1000.0,"description":"Recharge MTN 1000 FCFA","counterpart":null,"sms_text":null}"#).unwrap();
        let s = ptr_to_str(zolt_classify(json.as_ptr()));
        assert!(!s.contains("\"error\""),      "{}", s);
        assert!(s.contains("recharge_telecom"), "{}", s);
        assert!(s.contains("confidence"),       "{}", s);
    }

    #[test]
    fn test_classify_loyer() {
        let json = CString::new(r#"{"amount":120000.0,"description":"Paiement loyer mensuel","counterpart":null,"sms_text":null}"#).unwrap();
        let s = ptr_to_str(zolt_classify(json.as_ptr()));
        assert!(s.contains("loyer"), "{}", s);
    }

    #[test]
    fn test_classify_null_returns_error() {
        let s = ptr_to_str(zolt_classify(std::ptr::null()));
        assert!(s.contains("error"), "{}", s);
    }

    // ── zolt_predict_income ───────────────────────────────────
    #[test]
    fn test_predict_income_empty_history_returns_null() {
        let json = CString::new(r#"{"history":[],"today":{"year":2026,"month":3,"day":15}}"#).unwrap();
        let s = ptr_to_str(zolt_predict_income(json.as_ptr()));
        assert_eq!(s, "null");
    }

    #[test]
    fn test_predict_income_with_salary_history() {
        let json = CString::new(r#"{
            "today":{"year":2026,"month":3,"day":20},
            "history":[
                {
                    "cycle_start":{"year":2026,"month":1,"day":1},
                    "cycle_end":{"year":2026,"month":1,"day":31},
                    "opening_balance":50000.0,"closing_balance":80000.0,
                    "total_income":250000.0,"total_expenses":180000.0,
                    "savings_goal":30000.0,"savings_achieved":30000.0,
                    "daily_expenses":[],"category_totals":[],
                    "transactions":[{"id":"s1","date":{"year":2026,"month":1,"day":5},"amount":250000.0,
                     "tx_type":"Income","category":"salaire","account_id":"a1","description":null,"sms_confidence":null}]
                },
                {
                    "cycle_start":{"year":2026,"month":2,"day":1},
                    "cycle_end":{"year":2026,"month":2,"day":28},
                    "opening_balance":80000.0,"closing_balance":100000.0,
                    "total_income":250000.0,"total_expenses":170000.0,
                    "savings_goal":30000.0,"savings_achieved":30000.0,
                    "daily_expenses":[],"category_totals":[],
                    "transactions":[{"id":"s2","date":{"year":2026,"month":2,"day":5},"amount":250000.0,
                     "tx_type":"Income","category":"salaire","account_id":"a1","description":null,"sms_confidence":null}]
                }
            ]
        }"#).unwrap();
        let s = ptr_to_str(zolt_predict_income(json.as_ptr()));
        // Soit null (pas assez de confiance) soit un objet valide
        if s != "null" {
            assert!(s.contains("predicted_amount"), "{}", s);
            assert!(!s.contains("\"error\""),       "{}", s);
        }
    }

    // ── zolt_validate ─────────────────────────────────────────
    #[test]
    fn test_validate_valid_input() {
        let s = ptr_to_str(zolt_validate(minimal_input_json().as_ptr()));
        assert!(s.contains("\"valid\":true"), "{}", s);
    }

    #[test]
    fn test_validate_null_ptr() {
        let s = ptr_to_str(zolt_validate(std::ptr::null()));
        assert!(s.contains("false"), "{}", s);
    }

    #[test]
    fn test_validate_bad_json() {
        let bad = CString::new("{bad").unwrap();
        let s   = ptr_to_str(zolt_validate(bad.as_ptr()));
        assert!(s.contains("false"), "{}", s);
    }

    // ── zolt_free ─────────────────────────────────────────────
    #[test]
    fn test_free_null_noop() {
        zolt_free(std::ptr::null_mut()); // ne doit pas crasher
    }

    #[test]
    fn test_free_valid_ptr() {
        let ptr = string_to_ptr("test");
        zolt_free(ptr); // ne doit pas crasher
    }

    // ── zolt_version ──────────────────────────────────────────
    #[test]
    fn test_version_contains_semver() {
        let s = ptr_to_str(zolt_version());
        assert!(s.contains("1.2.0"), "{}", s);
        assert!(s.contains("build"),  "{}", s);
    }
}

// ─────────────────────────────────────────────────────────────
//  SESSION STATE — L'appel unique (v1.3.0)
// ─────────────────────────────────────────────────────────────

/// Calcule l'état complet de l'app en un seul appel.
/// Input  : SessionInput JSON
/// Output : SessionState JSON — libérer avec zolt_free()
#[no_mangle]
pub extern "C" fn zolt_session(input_json: *const c_char) -> *mut c_char {
    let input: crate::types::SessionInput = match parse_json(input_json, "session_input") {
        Ok(v) => v, Err(e) => return e,
    };
    to_json_ptr(&crate::session::SessionEngine::compute(&input))
}

/// Valide et construit un EngineInput depuis les données onboarding.
/// Input  : OnboardingInput JSON
/// Output : OnboardingResult JSON
#[no_mangle]
pub extern "C" fn zolt_onboarding(input_json: *const c_char) -> *mut c_char {
    let input: crate::types::OnboardingInput = match parse_json(input_json, "onboarding") {
        Ok(v) => v, Err(e) => return e,
    };
    to_json_ptr(&crate::ops::OnboardingEngine::build(&input))
}

/// Vérifie l'intégrité des données sans calcul.
/// Input  : { "engine_input": EngineInput, "history": [CycleRecord] } JSON
/// Output : IntegrityReport JSON
#[no_mangle]
pub extern "C" fn zolt_integrity(input_json: *const c_char) -> *mut c_char {
    #[derive(serde::Deserialize)]
    struct In { engine_input: crate::types::EngineInput, history: Vec<crate::types::CycleRecord> }
    let input: In = match parse_json(input_json, "integrity") {
        Ok(v) => v, Err(e) => return e,
    };
    to_json_ptr(&crate::ops::DataIntegrityEngine::check(&input.engine_input, &input.history))
}

// ─────────────────────────────────────────────────────────────
//  SESSION v1.4.0 — Appel unique avec cash + behavioral + narrative
// ─────────────────────────────────────────────────────────────

/// Session complète v1.4.0 — conseiller financier embarqué.
/// Input  : SessionInputV2 JSON
/// Output : SessionStateV2 JSON
#[no_mangle]
pub extern "C" fn zolt_session_v2(input_json: *const c_char) -> *mut c_char {
    if input_json.is_null() { return error_json("pointeur null reçu"); }
    let input: crate::session_v2::SessionInputV2 = match parse_json(input_json, "session_v2") {
        Ok(v) => v, Err(e) => return e,
    };
    to_json_ptr(&crate::session_v2::SessionEngineV2::compute(&input))
}

/// Parse le texte OCR d'un reçu et retourne un RawTransaction structuré.
/// Input  : ReceiptParseInput JSON { "ocr_text": "...", "today": Date }
/// Output : ReceiptParseResult JSON
#[no_mangle]
pub extern "C" fn zolt_parse_receipt(input_json: *const c_char) -> *mut c_char {
    if input_json.is_null() { return error_json("pointeur null reçu"); }
    let input: crate::receipt_parser::ReceiptParseInput = match parse_json(input_json, "receipt") {
        Ok(v) => v, Err(e) => return e,
    };
    to_json_ptr(&crate::receipt_parser::ReceiptParser::parse(&input))
}

/// Simule un scénario financier "what-if".
/// Input  : { "request": ScenarioRequest, "context": ScenarioContext } JSON
/// Output : ScenarioResult JSON
#[no_mangle]
pub extern "C" fn zolt_simulate(input_json: *const c_char) -> *mut c_char {
    if input_json.is_null() { return error_json("pointeur null reçu"); }

    #[derive(serde::Deserialize)]
    struct SimInput {
        request: crate::scenario_engine::ScenarioRequest,
        context: crate::scenario_engine::ScenarioContext,
    }

    let input: SimInput = match parse_json(input_json, "scenario") {
        Ok(v) => v, Err(e) => return e,
    };
    to_json_ptr(&crate::scenario_engine::ScenarioEngine::simulate(&input.request, &input.context))
}

/// Calcule les insights comportementaux depuis l'historique.
/// Input  : { "transactions": [...], "history": [...], "today": Date } JSON
/// Output : BehavioralInsights JSON
#[no_mangle]
pub extern "C" fn zolt_behavioral(input_json: *const c_char) -> *mut c_char {
    if input_json.is_null() { return error_json("pointeur null reçu"); }

    #[derive(serde::Deserialize)]
    struct BehInput {
        transactions: Vec<crate::types::Transaction>,
        history:      Vec<crate::types::CycleRecord>,
        today:        crate::types::Date,
    }

    let input: BehInput = match parse_json(input_json, "behavioral") {
        Ok(v) => v, Err(e) => return e,
    };

    // Besoin d'un DeterministicResult minimal pour le module
    // On calcule depuis les transactions si possible
    #[derive(serde::Deserialize)]
    struct MinDet {
        daily_budget:    Option<f64>,
        days_remaining:  Option<u32>,
    }

    // Crée un det minimal avec des valeurs par défaut raisonnables
    let det = crate::types::DeterministicResult {
        total_balance: 0.0, committed_mass: 0.0, free_mass: 0.0,
        days_remaining: 15, daily_budget: 10_000.0,
        spent_today: 0.0, remaining_today: 10_000.0,
        transport_reserve: 0.0, charges_reserve: 0.0,
    };

    to_json_ptr(&crate::behavioral_insights::BehavioralInsightsEngine::compute(
        &input.transactions, &input.history, &input.today, &det,
    ))
}

/// Vérifie un SMS parsé pour détecter une fraude MoMo.
/// Input  : FraudCheckInput JSON
/// Output : FraudCheckResult JSON
#[no_mangle]
pub extern "C" fn zolt_check_fraud(input_json: *const c_char) -> *mut c_char {
    if input_json.is_null() { return error_json("pointeur null reçu"); }
    let input: crate::fraud_detector::FraudCheckInput = match parse_json(input_json, "fraud") {
        Ok(v) => v, Err(e) => return e,
    };
    to_json_ptr(&crate::fraud_detector::FraudDetector::check(&input))
}

/// Calcule le score de crédit informel Zolt.
/// Input  : CreditScoreInput JSON { "history": [...], "current": EngineInput, "first_name": "..." }
/// Output : CreditScoreResult JSON
#[no_mangle]
pub extern "C" fn zolt_credit_score(input_json: *const c_char) -> *mut c_char {
    if input_json.is_null() { return error_json("pointeur null reçu"); }
    let input: crate::credit_score::CreditScoreInput = match parse_json(input_json, "credit") {
        Ok(v) => v, Err(e) => return e,
    };
    to_json_ptr(&crate::credit_score::CreditScoreEngine::compute(&input))
}

/// Mode fin de mois serré + calendrier de tension.
/// Input  : TightMonthInput JSON { "engine_input": EngineInput, "det": DeterministicResult, "history": [...] }
/// Output : TightMonthResult JSON
#[no_mangle]
pub extern "C" fn zolt_tight_month(input_json: *const c_char) -> *mut c_char {
    if input_json.is_null() { return error_json("pointeur null reçu"); }
    let input: crate::tight_month::TightMonthInput = match parse_json(input_json, "tight") {
        Ok(v) => v, Err(e) => return e,
    };
    to_json_ptr(&crate::tight_month::TightMonthEngine::compute(&input))
}

/// État compact pour le widget OS (mise à jour légère, sans recalcul complet).
/// Input  : TightMonthInput JSON
/// Output : WidgetState JSON
#[no_mangle]
pub extern "C" fn zolt_widget(input_json: *const c_char) -> *mut c_char {
    if input_json.is_null() { return error_json("pointeur null reçu"); }
    let input: crate::tight_month::TightMonthInput = match parse_json(input_json, "widget") {
        Ok(v) => v, Err(e) => return e,
    };
    to_json_ptr(&crate::tight_month::TightMonthEngine::compute_widget(&input))
}

/// Parse un SMS Mobile Money en arrière-plan.
/// Input  : SmsParseInput JSON { "sms_text": "...", "received_at": Date, "sender": "MTN-BJ" }
/// Output : SmsParseResult JSON
#[no_mangle]
pub extern "C" fn zolt_parse_sms(input_json: *const c_char) -> *mut c_char {
    if input_json.is_null() { return error_json("pointeur null reçu"); }
    let input: crate::sms_parser::SmsParseInput = match parse_json(input_json, "sms") {
        Ok(v) => v, Err(e) => return e,
    };
    to_json_ptr(&crate::sms_parser::SmsParser::parse(&input))
}

/// Traite un lot de SMS en une seule passe (arrière-plan).
/// Input  : { "inputs": [SmsParseInput], "existing_txs": [Transaction], "today": Date }
/// Output : BatchProcessResult JSON
#[no_mangle]
pub extern "C" fn zolt_parse_sms_batch(input_json: *const c_char) -> *mut c_char {
    if input_json.is_null() { return error_json("pointeur null reçu"); }

    #[derive(serde::Deserialize)]
    struct BatchIn {
        inputs:       Vec<crate::sms_parser::SmsParseInput>,
        existing_txs: Vec<crate::types::Transaction>,
        today:        crate::types::Date,
    }

    let input: BatchIn = match parse_json(input_json, "sms_batch") {
        Ok(v) => v, Err(e) => return e,
    };
    to_json_ptr(&crate::sms_parser::SmsBatchProcessor::process_batch(
        &input.inputs, &input.existing_txs, &input.today
    ))
}

/// Vérifie si un résultat parsé est un doublon.
/// Input  : DeduplicationInput JSON
/// Output : DeduplicationResult JSON
#[no_mangle]
pub extern "C" fn zolt_check_duplicate(input_json: *const c_char) -> *mut c_char {
    if input_json.is_null() { return error_json("pointeur null reçu"); }
    let input: crate::sms_parser::DeduplicationInput = match parse_json(input_json, "dedup") {
        Ok(v) => v, Err(e) => return e,
    };
    to_json_ptr(&crate::sms_parser::SmsParser::check_duplicate(&input))
}

/// Rapport de vérification multi-formules des calculs.
/// Input  : { "engine_input": EngineInput, "history": [CycleRecord] } JSON
/// Output : VerificationReport JSON
#[no_mangle]
pub extern "C" fn zolt_verify(input_json: *const c_char) -> *mut c_char {
    if input_json.is_null() { return error_json("pointeur null reçu"); }

    #[derive(serde::Deserialize)]
    struct VerIn {
        engine_input: crate::types::EngineInput,
        history:      Vec<crate::types::CycleRecord>,
    }

    let input: VerIn = match parse_json(input_json, "verify") {
        Ok(v) => v, Err(e) => return e,
    };

    let det = match crate::deterministic::DeterministicEngine::compute(&input.engine_input) {
        Ok(d)  => d,
        Err(e) => return error_json(&format!("calcul impossible: {}", e)),
    };

    to_json_ptr(&crate::compute_verifier::ComputeVerifier::verify_all(
        &crate::compute_verifier::VerifierContext {
            input:   &input.engine_input,
            history: &input.history,
            det:     &det,
        }
    ))
}

// ─────────────────────────────────────────────────────────────
//  TESTS SESSION (v1.3.0)
// ─────────────────────────────────────────────────────────────
#[cfg(test)]
mod session_tests {
    use super::*;
    use std::ffi::CString;

    fn ptr_to_str(ptr: *mut c_char) -> String {
        assert!(!ptr.is_null());
        let s = unsafe { std::ffi::CStr::from_ptr(ptr) }.to_str().unwrap().to_owned();
        zolt_free(ptr);
        s
    }

    fn session_json() -> CString {
        CString::new(r#"{
            "engine_input": {
                "today":{"year":2026,"month":3,"day":15},
                "accounts":[{"id":"a1","name":"MoMo","account_type":"MobileMoney","balance":350000.0,"is_active":true}],
                "charges":[{"id":"c1","name":"Loyer","amount":120000.0,"due_day":20,"status":"Pending","amount_paid":0.0,"is_active":true}],
                "transactions":[],
                "cycle":{"cycle_type":"Monthly","savings_goal":30000.0,"transport":"None"}
            },
            "history":[],
            "pending_sms":[]
        }"#).unwrap()
    }

    #[test]
    fn test_session_all_fields_present() {
        let s = ptr_to_str(zolt_session(session_json().as_ptr()));
        assert!(!s.contains("\"error\""),    "{}", s);
        assert!(s.contains("engine"),        "{}", s);
        assert!(s.contains("health"),        "{}", s);
        assert!(s.contains("cycle"),         "{}", s);
        assert!(s.contains("charge_tracking"), "{}", s);
        assert!(s.contains("integrity"),     "{}", s);
        assert!(s.contains("triage"),        "{}", s);
    }

    #[test]
    fn test_session_null_returns_error() {
        let s = ptr_to_str(zolt_session(std::ptr::null()));
        assert!(s.contains("error"), "{}", s);
    }

    #[test]
    fn test_onboarding_valid() {
        let json = CString::new(r#"{
            "first_name":"Kofi","currency":"FCFA","cycle_type":"Monthly",
            "accounts":[{"name":"MoMo","account_type":"MobileMoney","balance":250000.0,"operator":"MTN"}],
            "charges":[{"name":"Loyer","amount":120000.0,"due_day":5}],
            "transport_type":"None","transport_cost":null,"transport_days":null,
            "savings_goal":25000.0,
            "today":{"year":2026,"month":3,"day":15}
        }"#).unwrap();
        let s = ptr_to_str(zolt_onboarding(json.as_ptr()));
        assert!(s.contains("\"is_ready\":true"), "{}", s);
        assert!(s.contains("engine_input"), "{}", s);
    }

    #[test]
    fn test_onboarding_invalid_no_account() {
        let json = CString::new(r#"{
            "first_name":"Kofi","currency":"FCFA","cycle_type":"Monthly",
            "accounts":[],"charges":[],"transport_type":"None",
            "transport_cost":null,"transport_days":null,
            "savings_goal":0.0,"today":{"year":2026,"month":3,"day":15}
        }"#).unwrap();
        let s = ptr_to_str(zolt_onboarding(json.as_ptr()));
        assert!(s.contains("\"is_ready\":false"), "{}", s);
        assert!(s.contains("validation_errors"), "{}", s);
    }

    #[test]
    fn test_integrity_valid() {
        let json = CString::new(r#"{
            "engine_input":{
                "today":{"year":2026,"month":3,"day":15},
                "accounts":[{"id":"a1","name":"MoMo","account_type":"MobileMoney","balance":200000.0,"is_active":true}],
                "charges":[],"transactions":[],
                "cycle":{"cycle_type":"Monthly","savings_goal":0.0,"transport":"None"}
            },
            "history":[]
        }"#).unwrap();
        let s = ptr_to_str(zolt_integrity(json.as_ptr()));
        assert!(s.contains("\"is_valid\":true"), "{}", s);
        assert!(s.contains("data_confidence"), "{}", s);
    }
}
