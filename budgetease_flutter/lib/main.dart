import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';
import 'dart:ffi';
import 'package:sqlite3/open.dart';
import 'config/theme.dart';
import 'presentation/providers/security_provider.dart';
import 'presentation/screens/auth/lock_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'data/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize French locale for date formatting
  await initializeDateFormatting('fr_FR', null);

  // Override sqlite3 loading for Android (using sqlcipher)
  open.overrideFor(OperatingSystem.android, () {
    return DynamicLibrary.open('libsqlcipher.so');
  });
  
  // Initialiser la base de données
  final database = AppDatabase();
  
  runApp(
    ProviderScope(
      overrides: [
        // Ajouter les overrides si nécessaire
      ],
      child: const BudgetEaseApp(),
    ),
  );
}

class BudgetEaseApp extends ConsumerWidget {
  const BudgetEaseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Zolt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
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
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erreur: $error'),
          ],
        ),
      ),
    );
  }
}
