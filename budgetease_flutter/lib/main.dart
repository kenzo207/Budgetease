import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:budgetease_flutter/database/app_database.dart';
import 'package:budgetease_flutter/providers/privacy_mode_provider.dart';
import 'package:budgetease_flutter/services/wallet_service.dart';
import 'package:budgetease_flutter/services/shield_service.dart';
import 'package:budgetease_flutter/services/daily_cap_calculator.dart';
import 'package:budgetease_flutter/services/daily_snapshots_service.dart';
import 'package:budgetease_flutter/screens/vertical_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF121212),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Drift database
  final database = AppDatabase();
  
  // Initialize services
  final walletService = WalletService(database);
  final shieldService = ShieldService(database);
  final dailyCapCalculator = DailyCapCalculator(database, shieldService, walletService);
  final snapshotsService = DailySnapshotsService(database);
  
  // Initialize default wallets if needed
  await walletService.initializeDefaultWallets();

  runApp(BudgetEaseApp(
    database: database,
    walletService: walletService,
    shieldService: shieldService,
    dailyCapCalculator: dailyCapCalculator,
    snapshotsService: snapshotsService,
  ));
}

class BudgetEaseApp extends StatelessWidget {
  final AppDatabase database;
  final WalletService walletService;
  final ShieldService shieldService;
  final DailyCapCalculator dailyCapCalculator;
  final DailySnapshotsService snapshotsService;

  const BudgetEaseApp({
    super.key,
    required this.database,
    required this.walletService,
    required this.shieldService,
    required this.dailyCapCalculator,
    required this.snapshotsService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PrivacyModeProvider()),
        Provider<AppDatabase>.value(value: database),
        Provider<WalletService>.value(value: walletService),
        Provider<ShieldService>.value(value: shieldService),
        Provider<DailyCapCalculator>.value(value: dailyCapCalculator),
        Provider<DailySnapshotsService>.value(value: snapshotsService),
      ],
      child: MaterialApp(
        title: 'BudgetEase - Flow & Shield',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF121212),
          primaryColor: const Color(0xFF6C63FF),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6C63FF),
            secondary: Color(0xFF03DAC6),
            surface: Color(0xFF1E1E1E),
            background: Color(0xFF121212),
            error: Color(0xFFF44336),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF1E1E1E),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
            ),
          ),
        ),
        home: const VerticalHomeScreen(),
      ),
    );
  }
}
