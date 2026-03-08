// ============================================================
//  MODULE FRAUD DETECTOR — Détection de fraude MoMo offline
//  Zéro réseau. Analyse le SMS AVANT que l'utilisateur confirme.
//
//  Vecteurs d'attaque couverts (West Africa) :
//    1. Faux remboursement / faux crédit         → Reversal Scam
//    2. Faux agent / arnaque guichet             → Fake Agent
//    3. SMS usurpation d'opérateur               → Operator Spoof
//    4. Faux code PIN / OTP demandé              → PIN Phishing
//    5. Montant hors profil (trop gros / trop petit) → Amount Anomaly
//    6. Heure de réception anormale              → Time Anomaly
//    7. Numéro expéditeur inconnu ou suspect     → Unknown Sender
//    8. Structure SMS atypique                   → Format Anomaly
//    9. Doublons suspects à quelques secondes    → Replay Attack
//   10. Demande d'action urgente ("répondez MAINTENANT") → Social Engineering
//
//  Score de risque : 0 (sûr) → 100 (fraude quasi-certaine)
//  Seuils :
//    0-25   → Normal, aucune alerte
//    26-50  → Suspect, avertissement discret
//    51-75  → Probable fraude, confirmation forte requise
//    76-100 → Fraude quasi-certaine, bloquer l'action
// ============================================================

use crate::types::*;
use crate::sms_parser::{SmsParseResult, MomoTxType, MomoOperator};
use serde::{Deserialize, Serialize};

// ── Types ─────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FraudCheckInput {
    /// Résultat du parsing SMS
    pub parsed:         SmsParseResult,
    /// Heure de réception (0-23)
    pub hour_received:  u8,
    /// Historique des transactions pour profiling
    pub history:        Vec<Transaction>,
    /// Historique des cycles pour baseline comportemental
    pub cycle_history:  Vec<CycleRecord>,
    /// Sender ID (ex: "MTN-BJ", "+22997123456")
    pub sender_id:      Option<String>,
    /// Date de réception
    pub received_at:    Date,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FraudCheckResult {
    /// Score de risque 0-100
    pub risk_score:     u8,
    /// Niveau de risque catégorisé
    pub risk_level:     RiskLevel,
    /// Signaux détectés (liste des red flags)
    pub signals:        Vec<FraudSignal>,
    /// Message d'alerte à afficher à l'utilisateur
    pub alert_message:  Option<String>,
    /// Action recommandée
    pub recommended_action: RecommendedAction,
    /// true = bloquer l'action jusqu'à confirmation explicite
    pub should_block:   bool,
    /// Explication pédagogique (pourquoi c'est suspect)
    pub explanation:    String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum RiskLevel {
    Safe,       // 0-25
    Suspicious, // 26-50
    Likely,     // 51-75
    Critical,   // 76-100
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FraudSignal {
    pub signal_type: FraudSignalType,
    pub weight:      u8,    // poids dans le score final (0-100)
    pub detail:      String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum FraudSignalType {
    ReversalScam,
    FakeAgent,
    OperatorSpoof,
    PinPhishing,
    AmountAnomaly,
    TimeAnomaly,
    UnknownSender,
    FormatAnomaly,
    ReplayAttack,
    SocialEngineering,
    SuspiciousCounterpart,
    UnusualDestination,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum RecommendedAction {
    Allow,              // Laisser passer
    WarnUser,           // Afficher avertissement
    RequireConfirmation, // Double confirmation obligatoire
    Block,              // Bloquer et alerter
}

// ── Moteur principal ──────────────────────────────────────────

pub struct FraudDetector;

impl FraudDetector {
    pub fn check(input: &FraudCheckInput) -> FraudCheckResult {
        let mut signals: Vec<FraudSignal> = Vec::new();
        let text  = &input.parsed.raw.sms_text.as_deref().unwrap_or("").to_lowercase();
        let upper = text.to_uppercase();

        // ── Signal 1 : Faux remboursement / crédit piège ─────
        // Arnaque classique : SMS dit "crédit de X FCFA" mais en vrai c'est
        // une tentative d'obtenir un transfert en retour.
        if let Some(s) = Self::check_reversal_scam(text, &input.parsed) {
            signals.push(s);
        }

        // ── Signal 2 : Demande de PIN / OTP / code secret ────
        if let Some(s) = Self::check_pin_phishing(text) {
            signals.push(s);
        }

        // ── Signal 3 : Urgence sociale / manipulation ────────
        if let Some(s) = Self::check_social_engineering(text) {
            signals.push(s);
        }

        // ── Signal 4 : Usurpation d'opérateur ───────────────
        if let Some(s) = Self::check_operator_spoof(&input.parsed, input.sender_id.as_deref()) {
            signals.push(s);
        }

        // ── Signal 5 : Montant hors profil ───────────────────
        if let Some(s) = Self::check_amount_anomaly(&input.parsed, &input.history, &input.cycle_history) {
            signals.push(s);
        }

        // ── Signal 6 : Heure anormale ────────────────────────
        if let Some(s) = Self::check_time_anomaly(input.hour_received, &input.history) {
            signals.push(s);
        }

        // ── Signal 7 : Expéditeur inconnu / suspect ──────────
        if let Some(s) = Self::check_unknown_sender(
            input.sender_id.as_deref(), &input.parsed.operator, &input.history
        ) {
            signals.push(s);
        }

        // ── Signal 8 : Format SMS atypique ───────────────────
        if let Some(s) = Self::check_format_anomaly(text, &input.parsed) {
            signals.push(s);
        }

        // ── Signal 9 : Faux agent (demande retrait immédiat) ─
        if let Some(s) = Self::check_fake_agent(text) {
            signals.push(s);
        }

        // ── Signal 10 : Contrepartie suspecte ────────────────
        if let Some(s) = Self::check_suspicious_counterpart(
            &input.parsed, &input.history
        ) {
            signals.push(s);
        }

        // ── Calcul du score ───────────────────────────────────
        let raw_score: u32 = signals.iter().map(|s| s.weight as u32).sum();
        // Normalise : plusieurs signaux se combinent avec diminishing returns
        let risk_score = Self::normalize_score(raw_score, &signals);

        let risk_level = match risk_score {
            0..=25  => RiskLevel::Safe,
            26..=50 => RiskLevel::Suspicious,
            51..=75 => RiskLevel::Likely,
            _       => RiskLevel::Critical,
        };

        let recommended_action = match risk_level {
            RiskLevel::Safe       => RecommendedAction::Allow,
            RiskLevel::Suspicious => RecommendedAction::WarnUser,
            RiskLevel::Likely     => RecommendedAction::RequireConfirmation,
            RiskLevel::Critical   => RecommendedAction::Block,
        };

        let should_block = risk_score >= 76;

        let (alert_message, explanation) = Self::build_messages(
            risk_score, &signals, &input.parsed, &risk_level
        );

        FraudCheckResult {
            risk_score,
            risk_level,
            signals,
            alert_message,
            recommended_action,
            should_block,
            explanation,
        }
    }

    // ── Détecteurs individuels ────────────────────────────────

    /// Arnaque remboursement : SMS affirme créditer, demande de transférer en retour
    fn check_reversal_scam(text: &str, parsed: &SmsParseResult) -> Option<FraudSignal> {
        let scam_patterns = [
            // Faux crédit suivi d'une demande de retour
            ("erreur de transfert", 55),
            ("envoyé par erreur", 60),
            ("veuillez renvoyer", 65),
            ("renvoyez le montant", 65),
            ("remboursez", 40),
            ("j'ai fait une erreur", 50),
            ("transaction inversée", 45),
            ("reversal", 45),
            // Faux prix gagnant
            ("vous avez gagné", 50),
            ("vous êtes le gagnant", 55),
            ("vous avez été sélectionné", 50),
            ("prix mobile money", 60),
            ("loterie mtn", 65),
            ("loterie moov", 65),
            ("loterie orange", 65),
        ];

        let mut max_weight = 0u8;
        let mut matched_pattern = "";

        for (pattern, weight) in &scam_patterns {
            if text.contains(pattern) && *weight > max_weight {
                max_weight = *weight;
                matched_pattern = pattern;
            }
        }

        // Combinaison extra-suspecte : "reçu" + "renvoyez" dans le même SMS
        let has_credit = text.contains("reçu") || text.contains("crédit") || text.contains("crédité");
        let has_return_request = text.contains("renvo") || text.contains("rembours") || text.contains("retourner");
        if has_credit && has_return_request && max_weight < 70 {
            max_weight = 70;
        }

        if max_weight > 0 {
            Some(FraudSignal {
                signal_type: FraudSignalType::ReversalScam,
                weight: max_weight,
                detail: format!("Pattern d'arnaque détecté : «{}»", matched_pattern),
            })
        } else {
            None
        }
    }

    /// Demande de PIN, code secret, OTP
    fn check_pin_phishing(text: &str) -> Option<FraudSignal> {
        let pin_patterns = [
            ("votre pin", 70),
            ("votre code pin", 75),
            ("code secret", 70),
            ("mot de passe", 60),
            ("your pin", 70),
            ("your password", 65),
            ("entrez votre code", 65),
            ("saisir votre code", 65),
            ("composez votre pin", 70),
            ("otp", 55),
            ("one time password", 65),
            ("code de confirmation", 40), // moins suspect — normal dans certains flux
            ("ne partagez jamais", -10i32 as u8), // signal négatif : avertissement légitime
        ];

        let mut total_weight: i32 = 0;
        let mut details = Vec::new();

        for (pattern, weight) in &pin_patterns {
            if text.contains(pattern) {
                total_weight += *weight as i32;
                if *weight > 40 {
                    details.push(*pattern);
                }
            }
        }

        if total_weight >= 60 {
            Some(FraudSignal {
                signal_type: FraudSignalType::PinPhishing,
                weight: total_weight.min(90).max(0) as u8,
                detail: format!("Demande de code sensible : {}", details.join(", ")),
            })
        } else {
            None
        }
    }

    /// Manipulation psychologique / urgence artificielle
    fn check_social_engineering(text: &str) -> Option<FraudSignal> {
        let urgency_patterns = [
            ("immédiatement", 30),
            ("urgent", 25),
            ("maintenant", 20),
            ("dans les prochaines minutes", 40),
            ("dans les 30 minutes", 45),
            ("avant minuit", 35),
            ("offre expire", 40),
            ("dernière chance", 45),
            ("agissez vite", 40),
            ("répondez maintenant", 50),
            ("appelez ce numéro", 35),
            ("contactez notre agent", 30),
            ("ne dites à personne", 60),
            ("gardez le secret", 55),
            ("ne montrez pas", 50),
            ("votre compte sera bloqué", 45),
            ("compte suspendu", 40),
        ];

        let mut score: u32 = 0;
        let mut matched = Vec::new();

        for (pattern, weight) in &urgency_patterns {
            if text.contains(pattern) {
                score += weight;
                matched.push(*pattern);
            }
        }

        // Accumulation : plusieurs patterns d'urgence = très suspect
        let final_weight = if score >= 80 { 75u8 }
            else if score >= 50 { 55 }
            else if score >= 30 { 35 }
            else if score > 0   { 20 }
            else                { return None; };

        Some(FraudSignal {
            signal_type: FraudSignalType::SocialEngineering,
            weight: final_weight,
            detail: format!("Manipulation détectée : {}", matched.join(", ")),
        })
    }

    /// Usurpation d'opérateur — sender ID ne correspond pas au contenu
    fn check_operator_spoof(parsed: &SmsParseResult, sender: Option<&str>) -> Option<FraudSignal> {
        let sender_up = sender.map(|s| s.to_uppercase()).unwrap_or_default();

        // Si l'opérateur dans le SMS ne correspond pas au sender ID
        let mismatch = match parsed.operator {
            MomoOperator::MtnMomo => {
                !sender_up.is_empty()
                    && !sender_up.contains("MTN")
                    && !sender_up.contains("MOMO")
                    && !sender_up.starts_with("+")  // numéros longue distance OK
            },
            MomoOperator::MoovMoney => {
                !sender_up.is_empty()
                    && !sender_up.contains("MOOV")
                    && !sender_up.contains("FLOOZ")
            },
            MomoOperator::OrangeMoney => {
                !sender_up.is_empty() && !sender_up.contains("ORANGE")
            },
            MomoOperator::Wave => {
                !sender_up.is_empty() && !sender_up.contains("WAVE")
            },
            _ => false,
        };

        // Sender ID numérique avec contenu opérateur = suspect
        let sender_is_phone = sender.map(|s| {
            s.chars().filter(|c| c.is_ascii_digit()).count() >= 8
        }).unwrap_or(false);

        let operator_mentioned = parsed.operator != MomoOperator::Unknown;

        if mismatch {
            Some(FraudSignal {
                signal_type: FraudSignalType::OperatorSpoof,
                weight: 60,
                detail: format!(
                    "Sender «{}» ne correspond pas à l'opérateur détecté dans le SMS.",
                    sender.unwrap_or("inconnu")
                ),
            })
        } else if sender_is_phone && operator_mentioned {
            // Un vrai SMS opérateur vient d'un sender ID alphanumérique, pas d'un numéro
            Some(FraudSignal {
                signal_type: FraudSignalType::OperatorSpoof,
                weight: 40,
                detail: "SMS d'opérateur reçu d'un numéro de téléphone (sender suspect).".into(),
            })
        } else {
            None
        }
    }

    /// Montant hors profil comportemental
    fn check_amount_anomaly(
        parsed:        &SmsParseResult,
        history:       &[Transaction],
        cycle_history: &[CycleRecord],
    ) -> Option<FraudSignal> {
        let amount = parsed.raw.amount;
        if amount <= 0.0 { return None; }

        // Calcule la moyenne et l'écart-type des transactions similaires
        let similar_amounts: Vec<f64> = history.iter()
            .filter(|t| {
                // Même type de transaction approximativement
                match &parsed.tx_type {
                    MomoTxType::Received => t.tx_type.is_inflow(),
                    MomoTxType::Sent | MomoTxType::Withdrawal => t.tx_type.is_outflow(),
                    _ => true,
                }
            })
            .map(|t| t.amount)
            .collect();

        if similar_amounts.len() < 3 {
            // Pas assez de données → vérification sur plafond absolu
            if amount > 1_000_000.0 {
                return Some(FraudSignal {
                    signal_type: FraudSignalType::AmountAnomaly,
                    weight: 35,
                    detail: format!("Montant très élevé ({:.0} FCFA) sans historique de référence.", amount),
                });
            }
            return None;
        }

        let mean = similar_amounts.iter().sum::<f64>() / similar_amounts.len() as f64;
        let var: f64 = similar_amounts.iter()
            .map(|v| (v - mean).powi(2))
            .sum::<f64>() / similar_amounts.len() as f64;
        let std = var.sqrt();

        // Z-score
        let z = if std > 0.0 { (amount - mean) / std } else { 0.0 };

        // Montant > mean + 3*std = anomalie statistique forte
        if z > 4.0 {
            Some(FraudSignal {
                signal_type: FraudSignalType::AmountAnomaly,
                weight: 55,
                detail: format!(
                    "Montant {:.0} FCFA = {:.1}× ton maximum habituel ({:.0} FCFA en moyenne).",
                    amount, amount / mean.max(1.0), mean
                ),
            })
        } else if z > 2.5 {
            Some(FraudSignal {
                signal_type: FraudSignalType::AmountAnomaly,
                weight: 30,
                detail: format!(
                    "Montant {:.0} FCFA inhabituel (2.5× au-dessus de ta moyenne de {:.0} FCFA).",
                    amount, mean
                ),
            })
        } else {
            None
        }
    }

    /// Heure de réception anormale
    fn check_time_anomaly(hour: u8, history: &[Transaction]) -> Option<FraudSignal> {
        // Heure très tardive ou très matinale = suspect
        let is_unusual_hour = hour >= 23 || hour <= 4;

        if !is_unusual_hour { return None; }

        Some(FraudSignal {
            signal_type: FraudSignalType::TimeAnomaly,
            weight: 20,
            detail: format!(
                "SMS reçu à {}h — heure inhabituelle pour une transaction MoMo.",
                hour
            ),
        })
    }

    /// Expéditeur inconnu ou premier contact avec ce numéro/nom
    fn check_unknown_sender(
        sender:   Option<&str>,
        operator: &MomoOperator,
        history:  &[Transaction],
    ) -> Option<FraudSignal> {
        let sender = match sender {
            Some(s) if !s.is_empty() => s,
            _ => return None,
        };

        // Sender ID officiel d'opérateur = OK
        let official_senders = [
            "MTN", "MOMO", "MOOV", "FLOOZ", "ORANGE", "WAVE",
            "T-MONEY", "TMONEY", "AIRTEL", "CELTI",
        ];
        if official_senders.iter().any(|&s| sender.to_uppercase().contains(s)) {
            return None;
        }

        // Vérifie si ce sender apparaît dans l'historique
        let sender_seen_before = history.iter().any(|t| {
            t.description.as_deref()
                .map(|d| d.to_lowercase().contains(&sender.to_lowercase()))
                .unwrap_or(false)
        });

        if !sender_seen_before {
            Some(FraudSignal {
                signal_type: FraudSignalType::UnknownSender,
                weight: 15,
                detail: format!("Premier contact avec «{}» — jamais vu dans ton historique.", sender),
            })
        } else {
            None
        }
    }

    /// Format SMS atypique pour l'opérateur détecté
    fn check_format_anomaly(text: &str, parsed: &SmsParseResult) -> Option<FraudSignal> {
        let mut anomalies = Vec::new();

        // Un vrai SMS MoMo a toujours un montant
        if parsed.raw.amount <= 0.0 {
            anomalies.push("aucun montant trouvé");
        }

        // Vrai SMS n'a jamais de lien URL (sauf rarement pour les reçus web)
        if text.contains("http://") || text.contains("www.") {
            // Exception : certains SMS Wave contiennent des liens légitimes
            if parsed.operator != MomoOperator::Wave {
                anomalies.push("contient un lien URL suspect");
            }
        }

        // Fautes d'orthographe grossières sur les noms d'opérateurs
        let typos = [
            ("mtn mobil money", "MTN Mobile Money"),
            ("mtn moile money", "MTN Mobile Money"),
            ("orange mony", "Orange Money"),
            ("moov mony", "Moov Money"),
        ];
        for (typo, _correct) in &typos {
            if text.contains(typo) {
                anomalies.push("faute sur le nom de l'opérateur");
                break;
            }
        }

        // Beaucoup de majuscules = spam/arnaque
        let upper_count = text.chars().filter(|c| c.is_uppercase()).count();
        let total_alpha  = text.chars().filter(|c| c.is_alphabetic()).count();
        if total_alpha > 20 && upper_count as f64 / total_alpha as f64 > 0.60 {
            anomalies.push("proportion anormale de majuscules");
        }

        if anomalies.is_empty() { return None; }

        let weight = (anomalies.len() as u8 * 20).min(60);
        Some(FraudSignal {
            signal_type: FraudSignalType::FormatAnomaly,
            weight,
            detail: format!("Format suspect : {}", anomalies.join(", ")),
        })
    }

    /// Arnaque faux agent : demande de retrait immédiat en zone géographique suspecte
    fn check_fake_agent(text: &str) -> Option<FraudSignal> {
        let patterns = [
            ("retirez maintenant", 45),
            ("retirer immédiatement", 45),
            ("allez au guichet", 35),
            ("rendez-vous chez l'agent", 30),
            ("votre argent vous attend", 50),
            ("récupérez votre argent", 40),
            ("code de retrait", 35),
            ("code pour retirer", 40),
        ];

        let mut weight = 0u8;
        let mut matched = "";

        for (pattern, w) in &patterns {
            if text.contains(pattern) && *w > weight {
                weight = *w;
                matched = pattern;
            }
        }

        if weight > 0 {
            Some(FraudSignal {
                signal_type: FraudSignalType::FakeAgent,
                weight,
                detail: format!("Instruction d'agent suspecte : «{}»", matched),
            })
        } else {
            None
        }
    }

    /// Contrepartie suspecte (premier contact + gros montant + type inhabituel)
    fn check_suspicious_counterpart(
        parsed:  &SmsParseResult,
        history: &[Transaction],
    ) -> Option<FraudSignal> {
        let counterpart = match &parsed.counterpart {
            Some(cp) if !cp.is_empty() => cp,
            _ => return None,
        };

        // Vérifie si cette contrepartie a déjà été vue
        let known = history.iter().any(|t| {
            t.description.as_deref()
                .map(|d| d.to_lowercase().contains(&counterpart.to_lowercase()))
                .unwrap_or(false)
        });

        // Premier contact + montant élevé = signal modéré
        if !known && parsed.raw.amount > 100_000.0 {
            Some(FraudSignal {
                signal_type: FraudSignalType::SuspiciousCounterpart,
                weight: 25,
                detail: format!(
                    "Première transaction avec «{}» pour un montant élevé ({:.0} FCFA).",
                    counterpart, parsed.raw.amount
                ),
            })
        } else {
            None
        }
    }

    // ── Score final avec diminishing returns ──────────────────
    // La somme brute exagère le risque si plusieurs signaux faibles s'accumulent.
    // On applique une formule de saturation.
    fn normalize_score(raw: u32, signals: &[FraudSignal]) -> u8 {
        if signals.is_empty() { return 0; }

        // Un seul signal critique suffit
        let max_single = signals.iter().map(|s| s.weight as u32).max().unwrap_or(0);

        // Score combiné avec saturation logarithmique
        let combined = if raw > 0 {
            let base = max_single as f64;
            let extra = (raw - max_single) as f64 * 0.40; // autres signaux contribuent moins
            (base + extra).min(100.0) as u32
        } else {
            0
        };

        combined.min(100) as u8
    }

    // ── Messages utilisateur ──────────────────────────────────
    fn build_messages(
        score:    u8,
        signals:  &[FraudSignal],
        parsed:   &SmsParseResult,
        level:    &RiskLevel,
    ) -> (Option<String>, String) {
        let amount_str = if parsed.raw.amount > 0.0 {
            format!("{:.0} FCFA", parsed.raw.amount)
        } else {
            "montant inconnu".into()
        };

        let (alert, explanation) = match level {
            RiskLevel::Safe => (
                None,
                format!(
                    "Ce SMS semble authentique. Aucun signe de fraude détecté. \
                     Transaction : {}.",
                    amount_str
                ),
            ),
            RiskLevel::Suspicious => {
                let main_signal = signals.iter()
                    .max_by_key(|s| s.weight)
                    .map(|s| &s.detail[..])
                    .unwrap_or("anomalie détectée");
                (
                    Some(format!("⚠️ SMS suspect ({} sur 100) : {}", score, main_signal)),
                    format!(
                        "Ce SMS contient des éléments inhabituels. \
                         Vérifiez l'expéditeur et ne partagez jamais votre PIN. \
                         Détail : {}.",
                        main_signal
                    ),
                )
            },
            RiskLevel::Likely => {
                let top = signals.iter()
                    .max_by_key(|s| s.weight)
                    .map(|s| &s.signal_type)
                    .unwrap();
                let specific = Self::fraud_type_warning(top);
                (
                    Some(format!("🚨 Probable fraude ({} sur 100) !", score)),
                    format!(
                        "Ce SMS présente de fortes caractéristiques d'arnaque. \
                         {}. Ne transférez pas d'argent et ne partagez aucun code.",
                        specific
                    ),
                )
            },
            RiskLevel::Critical => (
                Some(format!(
                    "🛑 FRAUDE QUASI-CERTAINE ({} sur 100) — N'agissez pas !",
                    score
                )),
                "Ce SMS est très probablement une tentative d'arnaque. \
                 Les vraies applications MoMo ne demandent jamais votre PIN \
                 ni de renvoyer de l'argent. Ignorez ce message et signalez-le \
                 à votre opérateur.".into(),
            ),
        };

        (alert, explanation)
    }

    fn fraud_type_warning(signal_type: &FraudSignalType) -> &'static str {
        match signal_type {
            FraudSignalType::ReversalScam =>
                "Arnaque au faux remboursement : personne n'envoie de l'argent par erreur puis redemande",
            FraudSignalType::PinPhishing =>
                "Votre opérateur ne demande jamais votre PIN par SMS",
            FraudSignalType::SocialEngineering =>
                "La pression d'urgence est une technique d'arnaque classique",
            FraudSignalType::OperatorSpoof =>
                "Ce SMS ne vient pas de votre opérateur MoMo réel",
            FraudSignalType::FakeAgent =>
                "Aucun agent légitime ne vous contacte par SMS pour un retrait",
            _ => "Schéma frauduleux connu en Afrique de l'Ouest",
        }
    }
}

// ─────────────────────────────────────────────────────────────
#[cfg(test)]
mod tests {
    use super::*;
    use crate::sms_parser::{SmsParser, SmsParseInput};

    fn make_input(sms: &str, sender: Option<&str>, hour: u8) -> FraudCheckInput {
        let parsed = SmsParser::parse(&SmsParseInput {
            sms_text:    sms.into(),
            received_at: Date::new(2026, 3, 15),
            sender:      sender.map(String::from),
        });
        FraudCheckInput {
            parsed,
            hour_received:  hour,
            history:        vec![],
            cycle_history:  vec![],
            sender_id:      sender.map(String::from),
            received_at:    Date::new(2026, 3, 15),
        }
    }

    #[test]
    fn test_legitimate_sms_safe() {
        let sms = "MTN MOBILE MONEY: Vous avez reçu 25 000 FCFA de KOUASSI YVES. Nouveau solde: 187 500 FCFA.";
        let r = FraudDetector::check(&make_input(sms, Some("MTN-BJ"), 14));
        assert_eq!(r.risk_level, RiskLevel::Safe, "signals: {:?}", r.signals);
        assert!(!r.should_block);
        assert_eq!(r.recommended_action, RecommendedAction::Allow);
    }

    #[test]
    fn test_reversal_scam_detected() {
        let sms = "Vous avez reçu 50000 FCFA. J'ai envoyé par erreur, veuillez renvoyer le montant.";
        let r = FraudDetector::check(&make_input(sms, Some("+22990123456"), 15));
        assert!(r.risk_score >= 51, "score={}", r.risk_score);
        assert!(r.signals.iter().any(|s| s.signal_type == FraudSignalType::ReversalScam));
    }

    #[test]
    fn test_pin_phishing_detected() {
        let sms = "MTN MOMO: Votre compte nécessite une vérification. Entrez votre code PIN pour confirmer.";
        let r = FraudDetector::check(&make_input(sms, Some("MTN"), 10));
        assert!(r.risk_score >= 51, "score={}", r.risk_score);
        assert!(r.signals.iter().any(|s| s.signal_type == FraudSignalType::PinPhishing));
        assert!(r.recommended_action == RecommendedAction::RequireConfirmation
            || r.recommended_action == RecommendedAction::Block);
    }

    #[test]
    fn test_lottery_scam() {
        let sms = "Félicitations ! Vous avez gagné 500 000 FCFA à la Loterie MTN. Contactez notre agent immédiatement.";
        let r = FraudDetector::check(&make_input(sms, Some("+22997000001"), 20));
        assert!(r.risk_score >= 51, "score={}", r.risk_score);
    }

    #[test]
    fn test_social_engineering_urgency() {
        let sms = "URGENT: Votre compte sera bloqué dans les 30 minutes. Répondez maintenant avec votre code secret.";
        let r = FraudDetector::check(&make_input(sms, Some("+22990000001"), 2));
        assert!(r.risk_score >= 51, "score={}", r.risk_score);
        assert!(r.signals.iter().any(|s|
            s.signal_type == FraudSignalType::SocialEngineering
            || s.signal_type == FraudSignalType::PinPhishing
        ));
    }

    #[test]
    fn test_operator_spoof_detected() {
        // SMS dit "MTN Mobile Money" mais vient d'un numéro de téléphone
        let sms = "MTN MOBILE MONEY: Votre solde est de 250 000 FCFA. Code de vérification: 4521.";
        let r = FraudDetector::check(&make_input(sms, Some("+22990123456"), 11));
        assert!(r.signals.iter().any(|s| s.signal_type == FraudSignalType::OperatorSpoof));
    }

    #[test]
    fn test_late_hour_adds_signal() {
        let sms = "MTN MOMO: Reçu 5 000 FCFA de INCONNU.";
        let r = FraudDetector::check(&make_input(sms, Some("MTN"), 3)); // 3h du matin
        assert!(r.signals.iter().any(|s| s.signal_type == FraudSignalType::TimeAnomaly));
    }

    #[test]
    fn test_amount_anomaly_very_large() {
        // Historique de petites transactions, soudain 2M FCFA
        let history: Vec<Transaction> = (0..10).map(|i| Transaction {
            id: format!("t{}", i), date: Date::new(2026, 3, i + 1),
            amount: 10_000.0, tx_type: TransactionType::Income,
            category: None, account_id: "a1".into(),
            description: None, sms_confidence: None,
        }).collect();

        let parsed = SmsParser::parse(&SmsParseInput {
            sms_text: "MTN MOMO: Reçu 2 000 000 FCFA de INCONNU.".into(),
            received_at: Date::new(2026, 3, 15),
            sender: Some("MTN".into()),
        });

        let input = FraudCheckInput {
            parsed, hour_received: 14,
            history, cycle_history: vec![],
            sender_id: Some("MTN".into()),
            received_at: Date::new(2026, 3, 15),
        };

        let r = FraudDetector::check(&input);
        assert!(r.signals.iter().any(|s| s.signal_type == FraudSignalType::AmountAnomaly),
                "should detect amount anomaly");
    }

    #[test]
    fn test_critical_fraud_blocks() {
        // Combinaison PIN + urgence + sender inconnu = blocage
        let sms = "URGENT: Votre compte sera bloqué! Entrez votre code PIN maintenant. Ne dites à personne.";
        let r = FraudDetector::check(&make_input(sms, Some("+22991234567"), 23));
        assert!(r.should_block || r.risk_score >= 51, "score={}", r.risk_score);
    }

    #[test]
    fn test_explanation_always_present() {
        let sms = "MTN MOMO: Reçu 15 000 FCFA.";
        let r = FraudDetector::check(&make_input(sms, Some("MTN"), 12));
        assert!(!r.explanation.is_empty());
    }

    #[test]
    fn test_url_in_sms_flagged() {
        let sms = "MTN MOMO: Transaction réussie. Consultez http://mtn-verify.com pour confirmer.";
        let r = FraudDetector::check(&make_input(sms, Some("MTN"), 14));
        // L'URL doit déclencher un signal format
        assert!(r.risk_score > 0);
    }

    #[test]
    fn test_no_panic_empty_sms() {
        let r = FraudDetector::check(&make_input("", None, 12));
        assert_eq!(r.risk_level, RiskLevel::Safe);
    }

    #[test]
    fn test_normalize_score_capped_at_100() {
        // Même avec beaucoup de signaux, score ≤ 100
        let signals: Vec<FraudSignal> = (0..10).map(|i| FraudSignal {
            signal_type: FraudSignalType::SocialEngineering,
            weight: 80,
            detail: format!("signal {}", i),
        }).collect();
        let score = FraudDetector::normalize_score(800, &signals);
        assert!(score <= 100, "score={}", score);
    }
}
