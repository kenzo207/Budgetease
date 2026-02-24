import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

// Import tables
import 'tables/accounts_table.dart';
import 'tables/transactions_table.dart';
import 'tables/categories_table.dart';
import 'tables/recurring_charges_table.dart';
import 'tables/pending_transactions_table.dart';
import 'tables/settings_table.dart';
import 'tables/income_patterns_table.dart';
import 'tables/insights_table.dart';
import 'tables/behavioral_profiles_table.dart';

// Import DAOs
import 'daos/accounts_dao.dart';
import 'daos/transactions_dao.dart';
import 'daos/categories_dao.dart';
import 'daos/recurring_charges_dao.dart';

part 'app_database.g.dart';

/// Base de données principale de BudgetEase v4.0
/// Chiffrée avec SQLCipher pour une sécurité maximale
@DriftDatabase(
  tables: [
    Accounts,
    Transactions,
    Categories,
    RecurringCharges,
    PendingTransactions,
    Settings,
    IncomePatterns,
    Insights,
    BehavioralProfiles,
  ],
  daos: [
    AccountsDao,
    TransactionsDao,
    CategoriesDao,
    RecurringChargesDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  // Singleton pattern
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 6; // v6: Better category icons
  
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _seedDefaultData();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Migration de v1 à v2 : Ajout du champ borderColor
          if (from < 2) {
            try {
              await m.addColumn(settings, settings.borderColor);
              print('✅ Migration v1→v2: borderColor ajouté avec succès');
            } catch (e) {
              print('⚠️ Migration v1→v2: borderColor déjà existant ou erreur: $e');
            }
          }
          
          // Migration de v2 à v3 : Ajout des tables Phase 7
          if (from < 3) {
            try {
              await m.createTable(incomePatterns);
              await m.createTable(insights);
              await m.createTable(behavioralProfiles);
              print('✅ Migration v2→v3: Tables Phase 7 créées avec succès');
            } catch (e) {
              print('⚠️ Migration v2→v3: Erreur création tables: $e');
            }
          }

          // Migration de v3 à v4 : Ajout du thème
          if (from < 4) {
            try {
              await m.addColumn(settings, settings.themeMode);
              print('✅ Migration v3→v4: themeMode ajouté avec succès');
            } catch (e) {
              print('⚠️ Migration v3→v4: Erreur ajout themeMode: $e');
            }
          }

          // Migration de v4 à v5 : Parsing SMS enrichi
          if (from < 5) {
            try {
              // Drop et recréer la table pending_transactions (les pending sont temporaires)
              await m.deleteTable('pending_transactions');
              await m.createTable(pendingTransactions);
              print('✅ Migration v4→v5: Table pending_transactions recréée avec champs enrichis');
            } catch (e) {
              print('⚠️ Migration v4→v5: Erreur migration pending_transactions: $e');
            }
          }
          // Migration de v5 à v6 : Meilleures icônes pour les catégories
          if (from < 6) {
            try {
              // Mettre à jour les icônes des catégories de revenus
              final iconUpdates = {
                'payments': 'account_balance_wallet',  // Salaire
                'work': 'laptop_mac',                  // Freelance
                'store': 'storefront',                 // Business
                'attach_money': 'monetization_on',     // Autre revenu
              };
              for (final entry in iconUpdates.entries) {
                await customStatement(
                  'UPDATE categories SET icon = ? WHERE icon = ?',
                  [entry.value, entry.key],
                );
              }
              print('✅ Migration v5→v6: Icônes des catégories mises à jour');
            } catch (e) {
              print('⚠️ Migration v5→v6: Erreur mise à jour icônes: $e');
            }
          }
        },
        beforeOpen: (details) async {
          if (details.wasCreated) {
            print('🆕 Nouvelle base de données créée (v$schemaVersion)');
          } else if (details.hadUpgrade) {
            print('⬆️ Base de données mise à jour: v${details.versionBefore} → v${details.versionNow}');
          }
        },
      );

  /// Initialiser les données par défaut
  Future<void> _seedDefaultData() async {
    // Créer les catégories par défaut
    await _seedDefaultCategories();
    
    // Créer les paramètres par défaut
    await _seedDefaultSettings();
  }

  /// Créer les catégories de dépenses par défaut
  Future<void> _seedDefaultCategories() async {
    final expenseCategories = [
      ('Alimentation', 'restaurant', '#FF6B6B', CategoryType.expense),
      ('Transport', 'directions_car', '#4ECDC4', CategoryType.expense),
      ('Téléphone', 'phone_iphone', '#95E1D3', CategoryType.expense),
      ('Logement', 'home', '#F38181', CategoryType.expense),
      ('Santé', 'local_hospital', '#AA96DA', CategoryType.expense),
      ('Loisirs', 'sports_esports', '#FCBAD3', CategoryType.expense),
      ('Vêtements', 'checkroom', '#FFFFD2', CategoryType.expense),
      ('Éducation', 'school', '#A8D8EA', CategoryType.expense),
      ('Factures', 'lightbulb', '#FFD93D', CategoryType.expense),
      ('Autres', 'category', '#6C5CE7', CategoryType.expense),
    ];

    final incomeCategories = [
      ('Salaire', 'account_balance_wallet', '#00D2FF', CategoryType.income),
      ('Freelance', 'laptop_mac', '#3AA0FF', CategoryType.income),
      ('Business', 'storefront', '#4A69FF', CategoryType.income),
      ('Cadeau', 'card_giftcard', '#6C5CE7', CategoryType.income),
      ('Investissement', 'trending_up', '#A29BFE', CategoryType.income),
      ('Autre', 'monetization_on', '#74B9FF', CategoryType.income),
    ];

    for (final (name, icon, color, type) in expenseCategories) {
      await into(categories).insert(
        CategoriesCompanion.insert(
          name: name,
          icon: icon,
          color: color,
          type: type,
          isDefault: const Value(true),
          createdAt: DateTime.now(),
        ),
      );
    }

    for (final (name, icon, color, type) in incomeCategories) {
      await into(categories).insert(
        CategoriesCompanion.insert(
          name: name,
          icon: icon,
          color: color,
          type: type,
          isDefault: const Value(true),
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  /// Créer les paramètres par défaut
  Future<void> _seedDefaultSettings() async {
    await into(settings).insert(
      SettingsCompanion.insert(
        userName: 'Utilisateur',
        currency: const Value('FCFA'),
        financialCycle: FinancialCycle.monthly,
        transportMode: TransportMode.none,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Ouvrir la connexion à la base de données chiffrée
  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'budgetease_v4.db'));
      
      // Récupérer ou générer la clé de chiffrement
      final encryptionKey = await _getEncryptionKey();
      
      // Initialiser SQLCipher
      await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
      
      return NativeDatabase(
        file,
        setup: (rawDb) {
          // Activer le chiffrement avec la clé
          rawDb.execute("PRAGMA key = '$encryptionKey';");
          rawDb.execute('PRAGMA cipher_page_size = 4096;');
          rawDb.execute('PRAGMA kdf_iter = 64000;');
          rawDb.execute('PRAGMA cipher_hmac_algorithm = HMAC_SHA512;');
          rawDb.execute('PRAGMA cipher_kdf_algorithm = PBKDF2_HMAC_SHA512;');
          
          // Optimisations SQLite
          rawDb.execute('PRAGMA foreign_keys = ON;');
          rawDb.execute('PRAGMA journal_mode = WAL;');
        },
      );
    });
  }

  /// Récupérer ou générer la clé de chiffrement
  static Future<String> _getEncryptionKey() async {
    const storage = FlutterSecureStorage();
    const keyName = 'budgetease_v4_db_encryption_key';
    
    try {
      // Vérifier si une clé existe déjà
      String? existingKey = await storage.read(key: keyName);
      
      if (existingKey != null) {
        return existingKey;
      }
    } catch (e) {
      print('⚠️ Erreur de lecture de la clé de chiffrement: $e');
      print('🚨 Réinitialisation du stockage sécurisé et de la base de données...');
      
      // En cas d'erreur (ex: clé Android Keystore invalidée), on réinitialise tout
      await storage.deleteAll();
      
      // On supprime aussi la base de données qui ne pourra plus être déchiffrée
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'budgetease_v4.db'));
      if (await file.exists()) {
        await file.delete();
      }
    }
    
    // Générer une nouvelle clé sécurisée (256 bits)
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final newKey = base64Encode(bytes);
    
    // Stocker la clé dans le Keystore Android
    await storage.write(key: keyName, value: newKey);
    
    return newKey;
  }
}
