import 'package:drift/drift.dart';
import 'accounts_table.dart';

/// Types de transactions Mobile Money détectées par SMS
enum MomoTransactionType {
  transferOut,  // Transfert envoyé (dépense)
  transferIn,   // Transfert reçu (revenu)
  withdrawal,   // Retrait (dépense)
  payment,      // Paiement (dépense)
  deposit,      // Dépôt (revenu)
  unknown,      // Type inconnu
}

/// Table des transactions en attente (détectées par SMS)
@DataClassName('PendingTransaction')
class PendingTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get operator => text()(); // MTN, Moov, Orange, Wave

  // Champs de parsing enrichi
  IntColumn get momoType => intEnum<MomoTransactionType>().withDefault(Constant(MomoTransactionType.unknown.index))();
  RealColumn get fee => real().withDefault(const Constant(0.0))();
  RealColumn get balanceAfter => real().nullable()(); // Solde après la transaction
  TextColumn get counterpart => text().nullable()(); // Nom du destinataire/expéditeur
  TextColumn get counterpartPhone => text().nullable()(); // Téléphone
  TextColumn get momoRef => text().nullable()(); // Référence MoMo (ID)
  DateTimeColumn get transactionDate => dateTime().nullable()(); // Date extraite du SMS

  // Champs originaux
  TextColumn get rawSms => text()();
  DateTimeColumn get smsDate => dateTime()();
  TextColumn get transactionId => text().nullable()();
  BoolColumn get isProcessed => boolean().withDefault(const Constant(false))();
  BoolColumn get countsInBudget => boolean().withDefault(const Constant(true))(); // L'utilisateur décide
  IntColumn get suggestedAccountId => integer().nullable().references(Accounts, #id)();
  DateTimeColumn get createdAt => dateTime()();
}
