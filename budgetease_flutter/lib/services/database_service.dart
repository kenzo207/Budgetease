import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/settings.dart';
import '../models/fixed_charge.dart';

class DatabaseService {
  static const String transactionsBox = 'transactions';
  static const String budgetsBox = 'budgets';
  static const String settingsBox = 'settings';
  static const String fixedChargesBox = 'fixed_charges';

  static late Box<Transaction> transactions;
  static late Box<Budget> budgets;
  static late Box<Settings> settings;
  static late Box<FixedCharge> fixedCharges;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);

    // Register adapters
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(BudgetAdapter());
    Hive.registerAdapter(SettingsAdapter());
    Hive.registerAdapter(FixedChargeAdapter());

    // Open boxes
    await Hive.openBox<Transaction>(transactionsBox);
    await Hive.openBox<Budget>(budgetsBox);
    await Hive.openBox<Settings>(settingsBox);
    await Hive.openBox<FixedCharge>(fixedChargesBox);

    // Initialize defaults
    await initializeDefaults();
  }

  static Future<void> initializeDefaults() async {
    final settingsBox = Hive.box<Settings>(DatabaseService.settingsBox);

    if (settingsBox.isEmpty) {
      await settingsBox.add(Settings());
    }
  }

  static Box<Transaction> get transactions =>
      Hive.box<Transaction>(transactionsBox);

  static Box<Budget> get budgets => Hive.box<Budget>(budgetsBox);

  static Box<Settings> get settings => Hive.box<Settings>(settingsBox);

  static Future<void> resetAll() async {
    await transactions.clear();
    await budgets.clear();
    await settings.clear();
    await initializeDefaults();
  }
}
