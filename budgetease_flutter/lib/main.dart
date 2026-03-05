import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:ffi';
import 'package:sqlite3/open.dart';
import 'engine/zolt_engine.dart';
import 'config/theme.dart';
import 'presentation/providers/security_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/auth/lock_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/onboarding/calibration_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'data/database/app_database.dart';
import 'domain/services/notification_service.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'services/analytics_service.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize French locale for date formatting
  await initializeDateFormatting('fr_FR', null);

  // Override sqlite3 loading for Android (using sqlcipher)
  open.overrideFor(OperatingSystem.android, () {
    return DynamicLibrary.open('libsqlcipher.so');
  });

  // Initialiser le moteur Rust Zolt (silencieux si indisponible)
  ZoltEngine.initialize();

  // Check d'intégrité au démarrage (non-bloquant, résultat loggué)
  if (ZoltEngine.isAvailable) {
    try {
      final report = ZoltEngine.integrity(engineInput: const {
        'today': {'year': 0, 'month': 1, 'day': 1},
        'accounts': [],
        'charges': [],
        'transactions': [],
        'cycle': {'cycle_type': 'Monthly', 'savings_goal': 0.0, 'transport': 'None'},
      });
      if (report['is_valid'] == false) {
        debugPrint('[Zolt] Integrity check: données invalides — ${report['errors']}');
      } else {
        debugPrint('[Zolt] Integrity check OK — confidence: ${report['data_confidence']}%');
      }
    } catch (_) {
      // zolt_integrity optionnel, échec silencieux
    }
  }

  // Initialiser la base de données (singleton)
  AppDatabase();

  // Initialiser PostHog Analytics
  final config = PostHogConfig(
    'phc_kfOGYe0g12XISJvJK2mne0srlSweSH3vgQPdWqhpkwj',
  );
  config.host = 'https://eu.i.posthog.com';
  config.captureApplicationLifecycleEvents = true;
  config.debug = true;
  config.flushAt = 1;
  config.flushInterval = const Duration(seconds: 5);
  config.personProfiles = PostHogPersonProfiles.always;
  await Posthog().setup(config);

  runApp(
    const ProviderScope(
      overrides: [
        // Ajouter les overrides si nécessaire
      ],
      child: BudgetEaseApp(),
    ),
  );
}

class BudgetEaseApp extends ConsumerWidget {
  const BudgetEaseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProviderProvider);

    return MaterialApp(
      title: 'Zolt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode.when(
        data: (mode) => mode,
        loading: () => ThemeMode.system,
        error: (e, s) => ThemeMode.system,
      ),
      navigatorObservers: [
        PosthogObserver(),
      ],
      home: const AppInitializer(),
    );
  }
}

/// Widget d'initialisation de l'application
class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({super.key});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    // 1. Charger les données de calibrage (userName, currency) depuis la DB
    await _loadCalibrationFromDb();

    // 2. Initialiser les notifications
    final notifService = NotificationService();
    await notifService.initialize();

    // 3. Demander les permissions de notification (Android 13+)
    await notifService.requestPermissions();

    // 4. Track App Open
    ref.read(analyticsServiceProvider).capture('app_opened');
  }

  /// Charge les données de calibrage depuis la base de données
  /// pour initialiser le calibrationDataProvider au démarrage
  Future<void> _loadCalibrationFromDb() async {
    try {
      final database = AppDatabase();
      final settings = await database.select(database.settings).getSingleOrNull();
      if (settings != null) {
        ref.read(calibrationDataProvider.notifier).state = CalibrationData(
          currency: settings.currency,
          userName: settings.userName,
        );
      }
    } catch (e) {
      debugPrint('DEBUG: Error loading calibration from DB: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final securityService = ref.watch(securityServiceProvider);

    return authState.when(
      data: (isAuthenticated) {
        if (isAuthenticated) {
          // Utilisateur authentifié, vérifier si l'onboarding est complété
          return FutureBuilder<bool>(
            future: _isOnboardingCompleted(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingScreen();
              }

              if (snapshot.data == true) {
                // Onboarding complété, aller au home
                return const MainScreen();
              } else {
                // Onboarding non complété
                return const OnboardingScreen();
              }
            },
          );
        } else {
          // Utilisateur non authentifié, afficher l'écran de verrouillage
          return FutureBuilder<bool>(
            future: securityService.isSecurityConfigured(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingScreen();
              }

              if (snapshot.data == true) {
                // Sécurité configurée, afficher le lock screen
                return LockScreen(
                  securityService: securityService,
                  onUnlocked: () {
                    ref.read(authProvider.notifier).markAsAuthenticated();
                  },
                );
              } else {
                // Sécurité non configurée, aller à l'onboarding
                return const OnboardingScreen();
              }
            },
          );
        }
      },
      loading: () => const _LoadingScreen(),
      error: (error, stack) => _ErrorScreen(error: error.toString()),
    );
  }

  Future<bool> _isOnboardingCompleted() async {
    print('DEBUG: Checking onboarding status...');
    final database = AppDatabase();
    try {
      final settings = await (database.select(database.settings)..limit(1)).getSingleOrNull();
      print('DEBUG: Settings found: ${settings != null}, Onboarding Completed: ${settings?.onboardingCompleted}');
      return settings?.onboardingCompleted ?? false;
    } catch (e) {
      print('DEBUG: Error checking onboarding: $e');
      return false;
    } 
    // removed finally -> await database.close() because it's a singleton now!
  }
}

/// Écran de chargement
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Écran d'erreur
class _ErrorScreen extends StatelessWidget {
  final String error;

  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Erreur: $error'),
          ],
        ),
      ),
    );
  }
}
