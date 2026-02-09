import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/settings.dart';
import '../models/fixed_charge.dart';
import '../models/behavioral_profile.dart';
import '../models/income_pattern.dart';
import '../models/ghost_money_insight.dart';
import '../models/category.dart' as models;

class DatabaseService {
  static const String transactionsBox = 'transactions';
  static const String budgetsBox = 'budgets';
  static const String settingsBox = 'settings';
  static const String fixedChargesBox = 'fixed_charges';
  static const String behavioralProfilesBox = 'behavioral_profiles';
  static const String incomePatternsBox = 'income_patterns';
  static const String ghostMoneyInsightsBox = 'ghost_money_insights';
  static const String categoriesBox = 'categories';

  static late Box<Transaction> transactions;
  static late Box<Budget> budgets;
  static late Box<Settings> settings;
  static late Box<FixedCharge> fixedCharges;
  static late Box<BehavioralProfile> behavioralProfiles;
  static late Box<IncomePattern> incomePatterns;
  static late Box<GhostMoneyInsight> ghostMoneyInsights;
  static late Box<models.Category> categories;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);

    // Register adapters
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(BudgetAdapter());
    Hive.registerAdapter(SettingsAdapter());
    Hive.registerAdapter(FixedChargeAdapter());
    Hive.registerAdapter(BehavioralProfileAdapter());
    Hive.registerAdapter(IncomePatternAdapter());
    Hive.registerAdapter(GhostMoneyInsightAdapter());
    Hive.registerAdapter(models.CategoryAdapter());

    // Open boxes
    // Open boxes with safe recovery
    transactions = await _openBoxSafely<Transaction>(transactionsBox);
    budgets = await _openBoxSafely<Budget>(budgetsBox);
    settings = await _openBoxSafely<Settings>(settingsBox);
    fixedCharges = await _openBoxSafely<FixedCharge>(fixedChargesBox);
    behavioralProfiles = await _openBoxSafely<BehavioralProfile>(behavioralProfilesBox);
    incomePatterns = await _openBoxSafely<IncomePattern>(incomePatternsBox);
    ghostMoneyInsights = await _openBoxSafely<GhostMoneyInsight>(ghostMoneyInsightsBox);
    categories = await _openBoxSafely<models.Category>(categoriesBox);

    // Initialize defaults
    await initializeDefaults();
  }

  static Future<void> initializeDefaults() async {
    final settingsBox = Hive.box<Settings>(DatabaseService.settingsBox);

    if (settingsBox.isEmpty) {
      await settingsBox.add(Settings());
    }

    // Initialize default categories if empty
    final categoriesBox = Hive.box<models.Category>(DatabaseService.categoriesBox);
    if (categoriesBox.isEmpty) {
      final defaultCategories = models.getDefaultCategories();
      for (final category in defaultCategories) {
        await categoriesBox.add(category);
      }
    }
  }

  static Future<void> resetAll() async {
    await transactions.clear();
    await budgets.clear();
    await settings.clear();
    await initializeDefaults();
  }
  static Future<Box<T>> _openBoxSafely<T>(String boxName) async {
    try {
      return await Hive.openBox<T>(boxName);
    } catch (e) {
      debugPrint('Error opening $boxName box: $e. Resetting box.');
      await Hive.deleteBoxFromDisk(boxName);
      return await Hive.openBox<T>(boxName);
    }
  }
}
