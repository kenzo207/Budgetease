// ============================================================
//  MODULE CLASSIFIER — Classification automatique des transactions
//  Remplace la logique de catégorisation côté Flutter.
//  Basé sur patterns de noms connus (West Africa Mobile Money).
// ============================================================

use crate::types::*;

pub struct TransactionClassifier;

impl TransactionClassifier {
    /// Classifie une transaction brute (depuis SMS ou saisie manuelle).
    pub fn classify(raw: &RawTransaction) -> ClassificationResult {
        // Détermine d'abord le type (entrée ou sortie)
        let (tx_type, type_confidence) = Self::detect_type(raw);

        // Puis la catégorie selon le type
        let (category, cat_confidence) = if tx_type.is_outflow() {
            Self::classify_expense(raw)
        } else {
            Self::classify_income(raw)
        };

        let confidence = (type_confidence * 0.4 + cat_confidence * 0.6).min(1.0);
        let reason     = Self::build_reason(&tx_type, &category, raw);

        ClassificationResult { tx_type, category, confidence, reason }
    }

    // ── Détection du type (inflow/outflow) ───────────────────────
    fn detect_type(raw: &RawTransaction) -> (TransactionType, f64) {
        let text = Self::normalize(
            &[raw.description.as_deref(), raw.sms_text.as_deref(), raw.counterpart.as_deref()]
        );

        // Patterns de réception (revenu)
        let income_signals = [
            "reçu", "received", "crédité", "credited", "envoi reçu",
            "payment received", "vous avez reçu", "credit",
            "salaire", "salary", "virement reçu", "remboursement",
        ];
        // Patterns de paiement (dépense)
        let expense_signals = [
            "payé", "paid", "débité", "debited", "paiement effectué",
            "achat", "purchase", "retrait", "withdrawal", "transfert envoyé",
            "vous avez envoyé", "debit", "facture", "abonnement",
        ];

        let income_score:  f64 = income_signals.iter()
            .filter(|&&s| text.contains(s))
            .count() as f64;
        let expense_score: f64 = expense_signals.iter()
            .filter(|&&s| text.contains(s))
            .count() as f64;

        if income_score > expense_score {
            let conf = (0.5 + income_score * 0.15).min(0.95);
            (TransactionType::Income, conf)
        } else if expense_score > 0.0 {
            let conf = (0.5 + expense_score * 0.15).min(0.95);
            (TransactionType::Expense, conf)
        } else {
            // Par défaut : dépense avec faible confiance
            (TransactionType::Expense, 0.4)
        }
    }

    // ── Classification des dépenses ───────────────────────────────
    fn classify_expense(raw: &RawTransaction) -> (String, f64) {
        let text = Self::normalize(
            &[raw.description.as_deref(), raw.counterpart.as_deref(), raw.sms_text.as_deref()]
        );

        let rules: &[(&[&str], &str, f64)] = &[
            // Nourriture / Restaurant
            (&["restaurant", "maquis", "boulangerie", "pâtisserie", "fast food",
               "alimentat", "épicerie", "supermarché", "marché", "food", "jumia food",
               "glovo", "yassir food", "hunger", "pizza", "burger", "snack"], "nourriture", 0.85),

            // Transport
            (&["taxi", "moto", "zem", "bensikin", "uber", "bolt", "yassir",
               "inDriver", "transport", "carburant", "essence", "station",
               "total", "shell", "oryx", "parking", "péage"], "transport", 0.85),

            // Recharge téléphone / Internet
            (&["recharge", "airtime", "credit telephone", "data", "internet",
               "forfait", "bundle", "mtn", "moov", "orange", "wave", "telecel",
               "flooz", "t-money"], "recharge_telecom", 0.90),

            // Loyer / Logement
            (&["loyer", "rent", "bail", "location", "propriétaire", "immeuble",
               "appartement", "maison", "logement", "résidence"], "loyer", 0.90),

            // Santé
            (&["pharmacie", "médecin", "docteur", "clinique", "hôpital", "santé",
               "médicament", "consultation", "laboratoire", "analyse"], "santé", 0.90),

            // Éducation / École
            (&["école", "frais scolaire", "université", "formation", "cours",
               "inscription", "scolarité", "éducation", "livre", "fourniture"], "éducation", 0.85),

            // Shopping / Vêtements
            (&["jumia", "amazon", "aliexpress", "boutique", "vêtement",
               "habit", "chaussure", "mode", "shopping", "store", "market"], "shopping", 0.80),

            // Services publics / Factures
            (&["sbee", "soneb", "electric", "eau", "facture", "bill",
               "eneo", "senelec", "cie", "sodeci", "fsp", "canal+",
               "abonnement", "dstv", "netflix", "spotify"], "factures", 0.88),

            // Banque / Frais
            (&["frais", "commission", "fee", "retrait", "atm", "guichet",
               "virement", "transfert", "bank", "banque", "microfinance",
               "uba", "sgb", "bceao", "nsia", "orabank"], "banque_frais", 0.82),

            // Famille / Aide
            (&["famille", "maman", "papa", "frère", "sœur", "tonton",
               "aide", "soutien", "envoi", "contribution"], "famille", 0.75),

            // Divertissement / Loisirs
            (&["cinéma", "concert", "bar", "boîte", "sortie", "sport",
               "gym", "match", "jeu", "entertainment", "loisir"], "loisirs", 0.80),
        ];

        Self::match_rules(&text, raw.amount, rules)
    }

    // ── Classification des revenus ────────────────────────────────
    fn classify_income(raw: &RawTransaction) -> (String, f64) {
        let text = Self::normalize(
            &[raw.description.as_deref(), raw.counterpart.as_deref(), raw.sms_text.as_deref()]
        );

        let rules: &[(&[&str], &str, f64)] = &[
            (&["salaire", "salary", "paie", "wage", "employeur",
               "entreprise", "société", "virement employeur"], "salaire", 0.90),
            (&["freelance", "prestation", "mission", "facture", "client",
               "honoraire", "consultation", "service rendu"], "freelance", 0.82),
            (&["remboursement", "rembours", "retour", "refund"], "remboursement", 0.85),
            (&["aide", "envoi", "famille", "parent", "don", "gift",
               "contribution", "tontine", "nath"], "aide_famille", 0.75),
            (&["intérêt", "dividende", "épargne", "placement",
               "rendement", "investissement"], "intérêts", 0.85),
        ];

        Self::match_rules(&text, raw.amount, rules)
    }

    // ── Moteur de règles ──────────────────────────────────────────
    fn match_rules(text: &str, amount: f64, rules: &[(&[&str], &str, f64)]) -> (String, f64) {
        let mut best_cat   = "autre";
        let mut best_score = 0.0f64;
        let mut best_conf  = 0.35f64;

        for (keywords, category, base_conf) in rules {
            let matches = keywords.iter().filter(|&&kw| text.contains(kw)).count();
            if matches == 0 { continue; }
            let score = matches as f64 * base_conf;
            if score > best_score {
                best_score = score;
                best_cat   = category;
                best_conf  = (base_conf + (matches as f64 - 1.0) * 0.05).min(0.97);
            }
        }

        // Heuristique montant : gros montants ronds = souvent loyer/salaire
        if best_cat == "autre" && amount >= 50_000.0 && amount % 5_000.0 == 0.0 {
            best_conf = 0.30; // très faible confiance sur heuristique seule
        }

        (best_cat.to_string(), best_conf)
    }

    // ── Normalise et concatène plusieurs champs texte ─────────────
    fn normalize(parts: &[Option<&str>]) -> String {
        parts.iter()
            .filter_map(|&p| p)
            .map(|s| s.to_lowercase())
            .collect::<Vec<_>>()
            .join(" ")
    }

    fn build_reason(tx_type: &TransactionType, category: &str, raw: &RawTransaction) -> String {
        let type_label = match tx_type {
            TransactionType::Income => "revenu",
            TransactionType::Expense => "dépense",
            _ => "transaction",
        };
        match &raw.counterpart {
            Some(cp) if !cp.is_empty() =>
                format!("Classifié comme {} / {} (contrepartie: {})", type_label, category, cp),
            _ =>
                format!("Classifié comme {} / {} par analyse textuelle", type_label, category),
        }
    }
}

// ─────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;

    fn raw(desc: &str, amount: f64) -> RawTransaction {
        RawTransaction {
            amount,
            description: Some(desc.into()),
            counterpart: None,
            sms_text:    None,
        }
    }

    fn raw_sms(sms: &str, amount: f64) -> RawTransaction {
        RawTransaction {
            amount,
            description: None,
            counterpart: None,
            sms_text:    Some(sms.into()),
        }
    }

    #[test]
    fn test_classify_mtn_recharge() {
        let r = TransactionClassifier::classify(&raw("Recharge MTN 1000 FCFA", 1_000.0));
        assert_eq!(r.category, "recharge_telecom");
        assert!(r.confidence > 0.7);
    }

    #[test]
    fn test_classify_loyer() {
        let r = TransactionClassifier::classify(&raw("Paiement loyer mensuel", 120_000.0));
        assert_eq!(r.tx_type, TransactionType::Expense);
        assert_eq!(r.category, "loyer");
        assert!(r.confidence > 0.8);
    }

    #[test]
    fn test_classify_salaire_inflow() {
        let r = TransactionClassifier::classify(&raw_sms(
            "Vous avez reçu 250000 FCFA de SOCIETE XYZ - salaire Mars", 250_000.0
        ));
        assert!(r.tx_type.is_inflow());
        assert_eq!(r.category, "salaire");
        assert!(r.confidence > 0.7);
    }

    #[test]
    fn test_classify_restaurant() {
        let r = TransactionClassifier::classify(&raw("Maquis La Belle Vue", 8_500.0));
        assert_eq!(r.category, "nourriture");
    }

    #[test]
    fn test_classify_transport_taxi() {
        let r = TransactionClassifier::classify(&raw("Taxi aéroport", 15_000.0));
        assert_eq!(r.category, "transport");
    }

    #[test]
    fn test_classify_pharmacie() {
        let r = TransactionClassifier::classify(&raw("Pharmacie du Centre - médicaments", 12_000.0));
        assert_eq!(r.category, "santé");
    }

    #[test]
    fn test_classify_unknown_returns_autre() {
        let r = TransactionClassifier::classify(&RawTransaction {
            amount: 5_000.0,
            description: None, counterpart: None, sms_text: None,
        });
        assert_eq!(r.category, "autre");
        assert!(r.confidence < 0.5);
    }

    #[test]
    fn test_classify_jumia_shopping() {
        let r = TransactionClassifier::classify(&raw("Achat Jumia - commande #12345", 35_000.0));
        assert_eq!(r.category, "shopping");
    }

    #[test]
    fn test_classify_sbee_facture() {
        let r = TransactionClassifier::classify(&raw("Paiement facture SBEE électricité", 25_000.0));
        assert_eq!(r.category, "factures");
    }

    #[test]
    fn test_classify_remboursement() {
        let r = TransactionClassifier::classify(&raw_sms(
            "Vous avez reçu 15000 FCFA de Jean - remboursement", 15_000.0
        ));
        assert!(r.tx_type.is_inflow());
        assert_eq!(r.category, "remboursement");
    }

    #[test]
    fn test_confidence_range() {
        let cases = [
            RawTransaction { amount: 1000.0, description: Some("recharge orange".into()), counterpart: None, sms_text: None },
            RawTransaction { amount: 5000.0, description: None, counterpart: None, sms_text: None },
        ];
        for raw in &cases {
            let r = TransactionClassifier::classify(raw);
            assert!((0.0..=1.0).contains(&r.confidence),
                "confidence hors [0,1]: {}", r.confidence);
        }
    }
}
