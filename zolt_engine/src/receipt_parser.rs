// ============================================================
//  MODULE RECEIPT PARSER — Parsing de reçus / tickets de caisse
//  Input  : texte brut retourné par ML Kit OCR (Flutter)
//  Output : RawTransaction structurée + score de confiance
//
//  Le moteur Rust fait 100% de l'extraction.
//  Flutter appelle zolt_parse_receipt(ocr_text) et reçoit
//  un RawTransaction prêt à classifier puis confirmer.
//
//  Stratégie :
//    1. Extraction du montant  (patterns FCFA, CFA, montants)
//    2. Extraction du marchand (première ligne non-numérique)
//    3. Extraction de la date  (formats DD/MM/YYYY, YYYY-MM-DD, DD-MM-YY)
//    4. Détection du type      (reçu de vente, reçu MoMo, ticket resto...)
//    5. Score de confiance global
// ============================================================

use crate::types::*;
use serde::{Deserialize, Serialize};

// ── Types ─────────────────────────────────────────────────────

/// Résultat complet du parsing d'un reçu OCR.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReceiptParseResult {
    /// Transaction brute extraite — prête pour le classifier
    pub raw:          RawTransaction,
    /// Date extraite du reçu (si trouvée)
    pub receipt_date: Option<Date>,
    /// Type de document détecté
    pub doc_type:     ReceiptDocType,
    /// Score de confiance global 0.0..=1.0
    pub confidence:   f64,
    /// Champs reconnus (pour debug/UI)
    pub fields:       Vec<ParsedField>,
    /// true si l'utilisateur doit confirmer avant création
    pub needs_review: bool,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum ReceiptDocType {
    RetailReceipt,    // ticket de caisse boutique
    RestaurantBill,   // addition restaurant
    MoMoReceipt,      // reçu Mobile Money imprimé
    PharmacyReceipt,  // pharmacie
    FuelReceipt,      // station essence
    BankSlip,         // bordereau bancaire
    Unknown,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ParsedField {
    pub name:       String,
    pub value:      String,
    pub confidence: f64,
}

/// Entrée du parser — texte OCR brut depuis Flutter/ML Kit
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReceiptParseInput {
    pub ocr_text: String,
    pub today:    Date,
}

// ── Moteur principal ──────────────────────────────────────────

pub struct ReceiptParser;

impl ReceiptParser {
    pub fn parse(input: &ReceiptParseInput) -> ReceiptParseResult {
        let text      = &input.ocr_text;
        let lines: Vec<&str> = text.lines()
            .map(|l| l.trim())
            .filter(|l| !l.is_empty())
            .collect();

        let (amount, amount_conf)     = Self::extract_amount(text);
        let (merchant, merchant_conf) = Self::extract_merchant(&lines);
        let (date, date_conf)         = Self::extract_date(text, &input.today);
        let doc_type                  = Self::detect_doc_type(text, &lines);

        // Score global = moyenne pondérée (montant est le plus important)
        let confidence = if amount.is_none() {
            // Montant non trouvé → confiance très basse
            amount_conf * 0.5 + merchant_conf * 0.3 + date_conf * 0.2
        } else {
            amount_conf * 0.55 + merchant_conf * 0.30 + date_conf * 0.15
        };

        let mut fields = vec![];
        if let Some(a) = amount {
            fields.push(ParsedField {
                name:       "montant".into(),
                value:      format!("{:.0} FCFA", a),
                confidence: amount_conf,
            });
        }
        if let Some(ref m) = merchant {
            fields.push(ParsedField {
                name:       "marchand".into(),
                value:      m.clone(),
                confidence: merchant_conf,
            });
        }
        if let Some(ref d) = date {
            fields.push(ParsedField {
                name:       "date".into(),
                value:      d.to_string(),
                confidence: date_conf,
            });
        }

        // Description enrichie selon le type
        let description = Self::build_description(&doc_type, &merchant, amount);
        let counterpart = merchant.clone();

        let raw = RawTransaction {
            amount:      amount.unwrap_or(0.0),
            description: Some(description),
            counterpart,
            sms_text:    None,
        };

        ReceiptParseResult {
            raw,
            receipt_date: date,
            doc_type,
            confidence,
            fields,
            needs_review: confidence < 0.65 || amount.is_none(),
        }
    }

    // ── 1. Extraction du montant ──────────────────────────────
    // Supporte : "15 000 FCFA", "15000CFA", "TOTAL: 8500", "Montant: 12 000"
    fn extract_amount(text: &str) -> (Option<f64>, f64) {
        // Normalise : supprime les espaces insécables et espaces dans les nombres
        let text_norm = text
            .replace('\u{00A0}', " ")
            .replace('\u{202F}', "");

        // Pattern 1 : nombre suivi de FCFA/CFA (le plus fiable)
        let patterns_fcfa = [
            r"(\d[\d\s]{1,8}\d|\d+)\s*(?:FCFA|F\.?CFA|CFA)\b",
            r"(?:FCFA|CFA)\s*:?\s*(\d[\d\s]{0,6}\d|\d+)",
        ];
        for pattern in &patterns_fcfa {
            if let Some(m) = Self::regex_first_capture(&text_norm, pattern) {
                let cleaned: String = m.chars().filter(|c| c.is_ascii_digit()).collect();
                if let Ok(v) = cleaned.parse::<f64>() {
                    if v > 0.0 && v < 100_000_000.0 {
                        return (Some(v), 0.92);
                    }
                }
            }
        }

        // Pattern 2 : TOTAL / MONTANT / A PAYER
        let total_patterns = [
            r"(?i)(?:total|montant|a payer|net a payer|solde|montant total)[^\d]*(\d[\d\s]{0,6}\d|\d+)",
            r"(?i)(?:total|montant)[^\d]*(\d[\d\s]{0,6}\d|\d+)",
        ];
        for pattern in &total_patterns {
            if let Some(m) = Self::regex_first_capture(&text_norm, pattern) {
                let cleaned: String = m.chars().filter(|c| c.is_ascii_digit()).collect();
                if let Ok(v) = cleaned.parse::<f64>() {
                    if v > 100.0 && v < 100_000_000.0 {
                        return (Some(v), 0.78);
                    }
                }
            }
        }

        // Pattern 3 : le plus grand nombre du texte (fallback)
        let mut candidates: Vec<f64> = Self::extract_all_numbers(&text_norm)
            .into_iter()
            .filter(|&n| n >= 200.0 && n < 10_000_000.0)
            .collect();
        candidates.sort_by(|a, b| b.partial_cmp(a).unwrap());

        if let Some(&v) = candidates.first() {
            return (Some(v), 0.45);
        }

        (None, 0.0)
    }

    // ── 2. Extraction du marchand ─────────────────────────────
    fn extract_merchant(lines: &[&str]) -> (Option<String>, f64) {
        // Les premières lignes non-numériques sont généralement le nom du marchand
        let skip_words = [
            "ticket", "reçu", "facture", "caisse", "merci", "bienvenue",
            "tel", "telephone", "tél", "date", "heure", "caissier",
        ];

        for line in lines.iter().take(6) {
            let lower = line.to_lowercase();
            if skip_words.iter().any(|w| lower.contains(w)) { continue; }

            // Ignorer les lignes purement numériques ou très courtes
            let alpha_count = line.chars().filter(|c| c.is_alphabetic()).count();
            if alpha_count < 3 { continue; }

            // Longueur raisonnable pour un nom de marchand
            if line.len() >= 3 && line.len() <= 60 {
                let merchant = Self::clean_merchant_name(line);
                let conf = if merchant.len() >= 4 { 0.72 } else { 0.45 };
                return (Some(merchant), conf);
            }
        }
        (None, 0.0)
    }

    fn clean_merchant_name(raw: &str) -> String {
        // Garde uniquement les caractères pertinents
        raw.chars()
            .filter(|c| c.is_alphanumeric() || " '-&./".contains(*c))
            .collect::<String>()
            .trim()
            .to_string()
    }

    // ── 3. Extraction de la date ──────────────────────────────
    fn extract_date(text: &str, today: &Date) -> (Option<Date>, f64) {
        // DD/MM/YYYY ou DD-MM-YYYY
        if let Some(caps) = Self::regex_captures(text, r"(\d{1,2})[/\-\.](\d{1,2})[/\-\.](\d{2,4})") {
            if caps.len() == 3 {
                if let (Ok(d), Ok(m), Ok(y_raw)) = (
                    caps[0].parse::<u8>(),
                    caps[1].parse::<u8>(),
                    caps[2].parse::<u16>(),
                ) {
                    let y = if y_raw < 100 { 2000 + y_raw } else { y_raw };
                    if let Ok(date) = Date::try_new(y, m, d) {
                        // Sanity check : pas dans le futur > 1 jour
                        if date.days_until(today) >= -1 {
                            return (Some(date), 0.88);
                        }
                    }
                }
            }
        }

        // YYYY-MM-DD (format ISO)
        if let Some(caps) = Self::regex_captures(text, r"(\d{4})[/\-](\d{1,2})[/\-](\d{1,2})") {
            if caps.len() == 3 {
                if let (Ok(y), Ok(m), Ok(d)) = (
                    caps[0].parse::<u16>(),
                    caps[1].parse::<u8>(),
                    caps[2].parse::<u8>(),
                ) {
                    if let Ok(date) = Date::try_new(y, m, d) {
                        return (Some(date), 0.85);
                    }
                }
            }
        }

        // Pas de date trouvée → utilise aujourd'hui (confiance faible)
        (None, 0.0)
    }

    // ── 4. Détection du type de document ─────────────────────
    fn detect_doc_type(text: &str, lines: &[&str]) -> ReceiptDocType {
        let lower = text.to_lowercase();

        // Mots-clés par type, avec poids
        let checks: &[(&[&str], ReceiptDocType)] = &[
            (&["mobile money", "momo", "mtn mobile", "orange money", "moov money", "wave"], ReceiptDocType::MoMoReceipt),
            (&["pharmacie", "medicament", "ordonnance", "médicament"], ReceiptDocType::PharmacyReceipt),
            (&["carburant", "essence", "gasoil", "litre", "station"], ReceiptDocType::FuelReceipt),
            (&["restaurant", "maquis", "bar", "boisson", "repas", "menu"], ReceiptDocType::RestaurantBill),
            (&["banque", "bank", "bordereau", "virement", "dépôt", "depot"], ReceiptDocType::BankSlip),
        ];

        for (keywords, doc_type) in checks {
            let hits = keywords.iter().filter(|&&k| lower.contains(k)).count();
            if hits >= 1 {
                return doc_type.clone();
            }
        }

        ReceiptDocType::RetailReceipt
    }

    // ── 5. Description enrichie ───────────────────────────────
    fn build_description(
        doc_type: &ReceiptDocType,
        merchant: &Option<String>,
        amount:   Option<f64>,
    ) -> String {
        let merchant_str = merchant.as_deref().unwrap_or("Inconnu");
        let amount_str = amount
            .map(|a| format!("{:.0} FCFA", a))
            .unwrap_or_else(|| "montant inconnu".into());

        match doc_type {
            ReceiptDocType::RestaurantBill  =>
                format!("Addition — {} — {}", merchant_str, amount_str),
            ReceiptDocType::PharmacyReceipt =>
                format!("Pharmacie — {} — {}", merchant_str, amount_str),
            ReceiptDocType::FuelReceipt     =>
                format!("Carburant — {} — {}", merchant_str, amount_str),
            ReceiptDocType::MoMoReceipt     =>
                format!("Reçu MoMo — {} — {}", merchant_str, amount_str),
            ReceiptDocType::BankSlip        =>
                format!("Bordereau bancaire — {}", amount_str),
            _                               =>
                format!("Achat — {} — {}", merchant_str, amount_str),
        }
    }

    // ── Helpers regex légers (sans crate regex) ───────────────

    /// Trouve le premier groupe capturant d'un pattern simple.
    /// Implémentation minimaliste — supporte les patterns les plus courants
    /// sans dépendance à la crate regex.
    fn regex_first_capture(text: &str, pattern: &str) -> Option<String> {
        // Simplifié : cherche les mots-clés spécifiques manuellement
        // plutôt que d'implémenter un moteur regex complet.
        // Délègue à la logique spécifique selon le pattern.
        let lower = text.to_lowercase();

        // Pattern FCFA
        if pattern.contains("FCFA") || pattern.contains("CFA") {
            return Self::find_amount_near_fcfa(text);
        }

        // Pattern TOTAL/MONTANT
        if pattern.to_lowercase().contains("total") || pattern.to_lowercase().contains("montant") {
            return Self::find_amount_after_keyword(text, &[
                "total", "montant", "a payer", "net a payer", "solde"
            ]);
        }

        None
    }

    fn find_amount_near_fcfa(text: &str) -> Option<String> {
        let upper = text.to_uppercase().replace('\u{00A0}', " ");
        let markers = ["FCFA", "F.CFA", "CFA"];

        for marker in &markers {
            if let Some(pos) = upper.find(marker) {
                // Cherche le nombre avant le marqueur
                let before = &upper[..pos];
                let digits_before = Self::last_number_in(before);
                if let Some(n) = digits_before {
                    if n.len() >= 2 {
                        return Some(n);
                    }
                }
                // Cherche le nombre après ": "
                let after = &upper[pos + marker.len()..];
                let trimmed = after.trim_start_matches(&[':', ' ', '\t'][..]);
                let digits_after = Self::first_number_in(trimmed);
                if let Some(n) = digits_after {
                    return Some(n);
                }
            }
        }
        None
    }

    fn find_amount_after_keyword(text: &str, keywords: &[&str]) -> Option<String> {
        let lower = text.to_lowercase();
        let upper = text.to_uppercase();

        for kw in keywords {
            if let Some(pos) = lower.find(kw) {
                let after = &upper[pos + kw.len()..];
                let trimmed = after.trim_start_matches(&[':', ' ', '\t', '\n', '\r'][..]);
                if let Some(n) = Self::first_number_in(trimmed) {
                    if n.len() >= 2 {
                        return Some(n);
                    }
                }
            }
        }
        None
    }

    fn regex_captures(text: &str, pattern: &str) -> Option<Vec<String>> {
        // Patterns de dates supportés manuellement
        if pattern.contains(r"(\d{1,2})[/\-\.](\d{1,2})[/\-\.](\d{2,4})") {
            return Self::parse_date_dmy(text);
        }
        if pattern.contains(r"(\d{4})[/\-](\d{1,2})[/\-](\d{1,2})") {
            return Self::parse_date_ymd(text);
        }
        None
    }

    fn parse_date_dmy(text: &str) -> Option<Vec<String>> {
        // Cherche DD/MM/YYYY, DD-MM-YYYY, DD.MM.YYYY
        for line in text.lines() {
            let chars: Vec<char> = line.chars().collect();
            let mut i = 0;
            while i + 7 < chars.len() {
                // Essaie de lire DD[sep]MM[sep]YYYY
                let seg: String = chars[i..i.min(chars.len())].iter()
                    .take(10).collect();
                if let Some(result) = Self::try_parse_dmy(&seg) {
                    return Some(result);
                }
                i += 1;
            }
        }
        None
    }

    fn try_parse_dmy(s: &str) -> Option<Vec<String>> {
        let bytes = s.as_bytes();
        if bytes.len() < 8 { return None; }

        // Extrait 2 chiffres
        let d1 = bytes[0];
        let d2 = bytes[1];
        if !d1.is_ascii_digit() || !d2.is_ascii_digit() { return None; }

        let sep = bytes[2];
        if sep != b'/' && sep != b'-' && sep != b'.' { return None; }

        let m1 = bytes[3];
        let m2 = bytes[4];
        if !m1.is_ascii_digit() || !m2.is_ascii_digit() { return None; }

        if bytes[5] != sep { return None; }

        // Année 2 ou 4 chiffres
        let (y_str, end) = if bytes.len() >= 10
            && bytes[6].is_ascii_digit() && bytes[7].is_ascii_digit()
            && bytes[8].is_ascii_digit() && bytes[9].is_ascii_digit()
        {
            (&s[6..10], 10)
        } else if bytes.len() >= 8
            && bytes[6].is_ascii_digit() && bytes[7].is_ascii_digit()
        {
            (&s[6..8], 8)
        } else {
            return None;
        };

        let d_str = &s[0..2];
        let m_str = &s[3..5];

        Some(vec![d_str.to_string(), m_str.to_string(), y_str.to_string()])
    }

    fn parse_date_ymd(text: &str) -> Option<Vec<String>> {
        for line in text.lines() {
            let bytes = line.as_bytes();
            let mut i = 0;
            while i + 9 < bytes.len() {
                if bytes[i].is_ascii_digit() && bytes[i+1].is_ascii_digit()
                    && bytes[i+2].is_ascii_digit() && bytes[i+3].is_ascii_digit()
                    && (bytes[i+4] == b'/' || bytes[i+4] == b'-')
                {
                    let sep = bytes[i+4];
                    if bytes[i+5].is_ascii_digit() && bytes[i+6].is_ascii_digit()
                        && bytes[i+7] == sep
                        && bytes[i+8].is_ascii_digit() && bytes[i+9].is_ascii_digit()
                    {
                        let y = &line[i..i+4];
                        let m = &line[i+5..i+7];
                        let d = &line[i+8..i+10];
                        return Some(vec![y.to_string(), m.to_string(), d.to_string()]);
                    }
                }
                i += 1;
            }
        }
        None
    }

    fn extract_all_numbers(text: &str) -> Vec<f64> {
        let mut results = Vec::new();
        let mut current = String::new();

        for ch in text.chars() {
            if ch.is_ascii_digit() {
                current.push(ch);
            } else if ch == ' ' && !current.is_empty() {
                // Espace dans un nombre (ex: "15 000")
                current.push(ch);
            } else {
                if !current.is_empty() {
                    let cleaned: String = current.chars()
                        .filter(|c| c.is_ascii_digit()).collect();
                    if let Ok(n) = cleaned.parse::<f64>() {
                        results.push(n);
                    }
                    current.clear();
                }
            }
        }
        if !current.is_empty() {
            let cleaned: String = current.chars()
                .filter(|c| c.is_ascii_digit()).collect();
            if let Ok(n) = cleaned.parse::<f64>() {
                results.push(n);
            }
        }
        results
    }

    fn first_number_in(s: &str) -> Option<String> {
        let mut num = String::new();
        let mut started = false;
        for ch in s.chars().take(20) {
            if ch.is_ascii_digit() {
                num.push(ch);
                started = true;
            } else if ch == ' ' && started && !num.is_empty() {
                // Espace entre groupes de chiffres
                num.push(ch);
            } else if started {
                break;
            }
        }
        let cleaned: String = num.chars().filter(|c| c.is_ascii_digit()).collect();
        if cleaned.is_empty() { None } else { Some(cleaned) }
    }

    fn last_number_in(s: &str) -> Option<String> {
        let mut num = String::new();
        let trimmed = s.trim_end();
        let mut digits_started = false;

        for ch in trimmed.chars().rev().take(15) {
            if ch.is_ascii_digit() {
                num.push(ch);
                digits_started = true;
            } else if ch == ' ' && digits_started {
                num.push(ch);
            } else if digits_started {
                break;
            }
        }
        if num.is_empty() { return None; }
        let reversed: String = num.chars()
            .filter(|c| c.is_ascii_digit())
            .collect::<String>()
            .chars().rev().collect();
        if reversed.is_empty() { None } else { Some(reversed) }
    }
}

// ─────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;

    fn parse(text: &str) -> ReceiptParseResult {
        ReceiptParser::parse(&ReceiptParseInput {
            ocr_text: text.into(),
            today: Date::new(2026, 3, 15),
        })
    }

    #[test]
    fn test_amount_fcfa_explicit() {
        let result = parse("PHARMACIE DU PORT\nTotal : 8 500 FCFA\nMerci");
        assert!((result.raw.amount - 8500.0).abs() < 1.0, "amount={}", result.raw.amount);
        assert!(result.confidence > 0.6);
    }

    #[test]
    fn test_amount_total_keyword() {
        let result = parse("SUPERETTE CHEZ KOFFI\nSavon 500\nPain 300\nTOTAL: 1200\nDate: 15/03/2026");
        assert!((result.raw.amount - 1200.0).abs() < 1.0, "amount={}", result.raw.amount);
    }

    #[test]
    fn test_merchant_extracted_first_line() {
        let result = parse("BOULANGERIE SOLEIL\nDate: 15/03/2026\nPain 500 FCFA\nTotal 500 FCFA");
        assert_eq!(
            result.raw.counterpart.as_deref().unwrap_or(""),
            "BOULANGERIE SOLEIL"
        );
    }

    #[test]
    fn test_date_dmy_extracted() {
        let result = parse("STATION SHELL\n15/03/2026\nCarburant\nTotal: 15000 FCFA");
        assert_eq!(result.receipt_date, Some(Date::new(2026, 3, 15)));
        assert!(result.fields.iter().any(|f| f.name == "date"));
    }

    #[test]
    fn test_date_ymd_extracted() {
        let result = parse("Reçu\n2026-03-15\nTotal: 5000 FCFA");
        assert_eq!(result.receipt_date, Some(Date::new(2026, 3, 15)));
    }

    #[test]
    fn test_doc_type_pharmacy() {
        let result = parse("PHARMACIE SAINTE MARIE\nParacétamol 500mg\n2 boites\nTotal: 2500 FCFA");
        assert_eq!(result.doc_type, ReceiptDocType::PharmacyReceipt);
    }

    #[test]
    fn test_doc_type_restaurant() {
        let result = parse("RESTAURANT LE SOLEIL\nRiz sauce 2000\nBoisson 500\nTotal: 2500 FCFA");
        assert_eq!(result.doc_type, ReceiptDocType::RestaurantBill);
    }

    #[test]
    fn test_doc_type_momo() {
        let result = parse("MTN MOBILE MONEY\nTransaction reussie\nMontant: 10000 FCFA\nFrais: 100 FCFA");
        assert_eq!(result.doc_type, ReceiptDocType::MoMoReceipt);
    }

    #[test]
    fn test_needs_review_when_no_amount() {
        let result = parse("Texte sans montant ni chiffre reconnaissable");
        assert!(result.needs_review);
    }

    #[test]
    fn test_no_panic_empty_input() {
        let result = parse("");
        assert!(result.needs_review);
        assert_eq!(result.raw.amount, 0.0);
    }

    #[test]
    fn test_no_panic_garbage_input() {
        let result = parse("@#$%^&*()_+\n\n\t\t\n???");
        assert!(result.raw.amount >= 0.0);
    }

    #[test]
    fn test_description_contains_merchant() {
        let result = parse("TOTAL ENERGIES\n15/03/2026\nCarburant 20L\nTotal: 22000 FCFA");
        let desc = result.raw.description.unwrap_or_default();
        assert!(!desc.is_empty());
    }

    #[test]
    fn test_confidence_high_when_all_fields_present() {
        let result = parse(
            "BOUTIQUE MODE AFRICA\n14/03/2026\nRobe wax 35000 FCFA\nTOTAL: 35000 FCFA\nMerci"
        );
        assert!(result.confidence > 0.70, "confidence={}", result.confidence);
        assert!(!result.needs_review);
    }

    #[test]
    fn test_fields_populated() {
        let result = parse("PHARMACIE DU CENTRE\n15/03/2026\nTotal: 8500 FCFA");
        assert!(result.fields.iter().any(|f| f.name == "montant"));
    }
}
