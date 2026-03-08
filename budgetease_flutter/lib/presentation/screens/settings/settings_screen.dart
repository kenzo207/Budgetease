import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/constants/app_constants.dart';
import '../../../data/database/app_database.dart';
import '../onboarding/onboarding_screen.dart';
import '../onboarding/calibration_screen.dart';
import '../transactions/pending_transactions_screen.dart';
import 'categories_management_screen.dart';
import '../../providers/border_color_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/sms_parser_provider.dart';
import '../../../services/analytics_service.dart';
import '../../widgets/zolt_credit_score_widget.dart';
import '../simulator/simulator_screen.dart';
import '../charges/charges_screen.dart';
import '../incomes/incomes_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Écran des paramètres
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _smsEnabled = false;

  @override
  void initState() {
    super.initState();
    // Track screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).screen('Settings');
    });
    // Load SMS settings after first frame to avoid null errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSmsSettings();
    });
  }

  Future<void> _loadSmsSettings() async {
    final database = AppDatabase();
    final settings = await database.select(database.settings).getSingleOrNull();
    if (settings != null && mounted) {
      setState(() {
        _smsEnabled = settings.smsParsingEnabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final calibrationData = ref.watch(calibrationDataProvider);

    return Scaffold(
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Removed to use theme
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paramètres',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Bonjour, ${calibrationData.userName} ',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                // color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), // Removed to use theme
                              ),
                        ),
                        Icon(Icons.waving_hand, size: 18, color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                  ],
                ),
              ),

              const ZoltCreditScoreWidget(),
              SizedBox(height: 12),

              // Profile Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Profil',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                ),
              ),
              SizedBox(height: 12),
              
              _buildSettingCard(
                context,
                icon: Icons.person_outline,
                title: 'Nom d\'utilisateur',
                subtitle: calibrationData.userName,
                onTap: () => _showEditNameDialog(context, ref, calibrationData.userName),
              ),
              
              _buildSettingCard(
                context,
                icon: Icons.attach_money,
                title: 'Devise',
                subtitle: calibrationData.currency,
                onTap: () => _showEditCurrencyDialog(context, ref, calibrationData.currency),
              ),
              
              _buildSettingCard(
                context,
                icon: Icons.border_color,
                title: 'Couleur des bordures',
                subtitle: 'Personnaliser l\'apparence',
                onTap: () => _showBorderColorPicker(context, ref),
              ),

              _buildSettingCard(
                context,
                icon: Icons.brightness_6_outlined,
                title: 'Thème',
                subtitle: _getThemeName(ref.watch(themeProviderProvider).valueOrNull),
                onTap: () {
                  ref.read(analyticsServiceProvider).capture('settings_theme_picker_opened');
                  _showThemePicker(context, ref);
                },
              ),

              _buildSettingCard(
                context,
                icon: Icons.auto_graph_outlined,
                title: 'Simulateur Financier',
                subtitle: 'Simuler l\'impact d\'une grosse dépense',
                iconColor: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimulatorScreen(),
                    ),
                  );
                },
              ),

              SizedBox(height: 24),

              // App Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Application',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                ),
              ),
              SizedBox(height: 12),
              
              _buildSettingCard(
                context,
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Gérer les notifications',
                onTap: () => _showNotificationsDialog(context),
              ),
              
              _buildSettingCard(
                context,
                icon: Icons.receipt_long_outlined,
                title: 'Mes charges fixes',
                subtitle: 'Loyer, factures, abonnements · Réserve journalière',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChargesScreen()),
                ),
              ),

              _buildSettingCard(
                context,
                icon: Icons.inventory_2_outlined,
                title: 'Mes rentrées régulières',
                subtitle: 'Argent de poche, salaire, paie de chantier',
                iconColor: Theme.of(context).colorScheme.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IncomesScreen()),
                ),
              ),

              _buildSettingCard(
                context,
                icon: Icons.category_outlined,
                title: 'Catégories',
                subtitle: 'Gérer les catégories de transactions',
                onTap: () {
                  ref.read(analyticsServiceProvider).capture(
                    'screen_viewed',
                    properties: {'screen': 'Categories', 'source': 'settings'},
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoriesManagementScreen(),
                    ),
                  );
                },
              ),
              
              _buildSettingCard(
                context,
                icon: Icons.sms_outlined,
                title: 'Analyse SMS',
                subtitle: 'Détection automatique des transactions',
                trailing: Switch(
                  value: _smsEnabled,
                  onChanged: (value) async {
                    await _toggleSms(value);
                    // Analytics
                    ref.read(analyticsServiceProvider).capture(
                      'sms_scanning_toggled',
                      properties: {'enabled': value},
                    );
                    if (value) {
                      try {
                         await ref.read(pendingTransactionsProvider.notifier).scan();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur: $e')),
                          );
                          await _toggleSms(false);
                        }
                      }
                    }
                  },
                ),
              ),

              if (_smsEnabled)
                _buildSettingCard(
                  context,
                  icon: Icons.mark_email_unread_outlined,
                  title: 'Transactions détectées',
                  subtitle: 'Valider les transactions SMS',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PendingTransactionsScreen(),
                      ),
                    );
                  },
                ),

              SizedBox(height: 24),

              // Données Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Données',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                ),
              ),
              SizedBox(height: 12),
              
              _buildSettingCard(
                context,
                icon: Icons.backup_outlined,
                title: 'Sauvegarde',
                subtitle: 'Export de données — prochainement',
                iconColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
              ),
              
              _buildSettingCard(
                context,
                icon: Icons.restore_outlined,
                title: 'Restaurer',
                subtitle: 'Import de données — prochainement',
                iconColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
              ),

              SizedBox(height: 24),

              // ⚠️ Zone dangereuse — isolée visuellement
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zone dangereuse',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _buildSettingCard(
                        context,
                        icon: Icons.delete_forever_outlined,
                        title: 'Réinitialiser l\'application',
                        subtitle: 'Supprime toutes les données — action irréversible',
                        iconColor: Theme.of(context).colorScheme.primary,
                        onTap: () => _showResetDialog(context),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // About Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'À propos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                ),
              ),
              SizedBox(height: 12),
              
              _buildSettingCard(
                context,
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: 'Zolt v4.0.0',
              ),
              
              _buildSettingCard(
                context,
                icon: Icons.description_outlined,
                title: 'Licences',
                subtitle: 'Licences open source',
                onTap: () {
                  ref.read(analyticsServiceProvider).capture('licenses_viewed');
                  showLicensePage(
                    context: context,
                    applicationName: 'Zolt',
                    applicationVersion: '4.0.0',
                  );
                },
              ),
              
              SizedBox(height: 24),
              Center(
                child: Text(
                  'Signé par Kenzo O\'Bryan',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),

              SizedBox(height: 32),

              // Divers Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Aide & Tutoriel',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                ),
              ),
              SizedBox(height: 12),

              _buildSettingCard(
                context,
                icon: Icons.lightbulb_outline,
                title: 'Revoir le tutoriel',
                subtitle: 'Relancer le guide visuel de l\'écran d\'accueil',
                iconColor: Theme.of(context).colorScheme.primary,
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('has_seen_tutorial', false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tutoriel réinitialisé ! Retournez à l\'accueil pour le voir.')),
                    );
                    Navigator.of(context).pop(); // Retourne de force à l'accueil
                  }
                },
              ),

              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? Theme.of(context).colorScheme.primary).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        trailing: trailing ??
            (onTap != null
                ? Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))
                : null),
        onTap: onTap,
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Réinitialiser l\'application ?'),
        content: Text(
          'Cette action supprimera toutes vos données (comptes, transactions, paramètres). '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetApp(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetApp(BuildContext context) async {
    try {
      final database = AppDatabase();
      
      // Analytics — fire before wiping DB
      ref.read(analyticsServiceProvider).capture('app_reset_confirmed');

      // Delete all data
      await database.delete(database.transactions).go();
      await database.delete(database.accounts).go();
      await database.delete(database.recurringCharges).go();
      await database.delete(database.categories).go();
      await database.delete(database.settings).go();
      
      if (context.mounted) {
        // Navigate to onboarding
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (route) => false,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Application réinitialisée'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier le nom'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nom d\'utilisateur',
            hintText: 'Entrez votre nom',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await _updateUserName(context, ref, newName);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showEditCurrencyDialog(BuildContext context, WidgetRef ref, String currentCurrency) {
    final currencies = ['FCFA', 'EUR', 'USD', 'GBP', 'CAD'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choisir la devise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((currency) {
            return RadioListTile<String>(
              title: Text(currency),
              value: currency,
              groupValue: currentCurrency,
              onChanged: (value) async {
                if (value != null) {
                  await _updateCurrency(context, ref, value);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserName(BuildContext context, WidgetRef ref, String newName) async {
    try {
      final database = AppDatabase();
      final settings = await database.select(database.settings).getSingleOrNull();
      
      if (settings != null) {
        await database.update(database.settings).replace(
          settings.copyWith(userName: newName),
        );
        
        // Mettre à jour le provider directement avec la nouvelle valeur
        final current = ref.read(calibrationDataProvider);
        ref.read(calibrationDataProvider.notifier).state = current.copyWith(userName: newName);

        // Analytics
        ref.read(analyticsServiceProvider).capture(
          'username_updated',
          properties: {'new_length': newName.length},
        );
        // Mettre à jour le nom dans PostHog
        ref.read(analyticsServiceProvider).identifyWithName(newName);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Nom mis à jour'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  Future<void> _updateCurrency(BuildContext context, WidgetRef ref, String newCurrency) async {
    try {
      final database = AppDatabase();
      final settings = await database.select(database.settings).getSingleOrNull();
      
      if (settings != null) {
        await database.update(database.settings).replace(
          settings.copyWith(currency: newCurrency),
        );
        
        // Mettre à jour le provider directement avec la nouvelle valeur
        final current = ref.read(calibrationDataProvider);
        ref.read(calibrationDataProvider.notifier).state = current.copyWith(currency: newCurrency);

        // Analytics
        ref.read(analyticsServiceProvider).capture(
          'currency_changed',
          properties: {'to': newCurrency},
        );
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Devise mise à jour'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  Future<void> _toggleSms(bool value) async {
    try {
      final database = AppDatabase();
      final settings = await database.select(database.settings).getSingleOrNull();
      
      if (settings != null) {
        await database.update(database.settings).replace(
          settings.copyWith(smsParsingEnabled: value),
        );
        
        setState(() {
          _smsEnabled = value;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(value ? 'Analyse SMS activée' : 'Analyse SMS désactivée'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final database = AppDatabase();
      
      // Get all data
      final accounts = await database.select(database.accounts).get();
      final transactions = await database.select(database.transactions).get();
      final categories = await database.select(database.categories).get();
      
      final exportCount = accounts.length + transactions.length + categories.length;
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sauvegarde créée: $exportCount éléments\n(Fonctionnalité d\'export fichier à venir)'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    // Show dialog explaining the feature
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restaurer les données'),
        content: Text(
          'Cette fonctionnalité permet d\'importer des données depuis une sauvegarde.\n\n'
          'L\'import de fichiers sera disponible dans une prochaine version.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configurez vos préférences de notifications',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            
            // Budget alerts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alertes budget',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Recevoir une alerte quand le budget est dépassé',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final settings = ref.watch(notificationSettingsProvider).valueOrNull ?? {};
                    final enabled = settings['budget'] ?? true;
                    return Switch(
                      value: enabled,
                      onChanged: (value) {
                         ref.read(notificationSettingsProvider.notifier).toggleBudgetAlerts(value);
                      },
                    );
                  }
                ),
              ],
            ),
            
            Divider(),
            
            // Daily check-in
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check-in Quotidien',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Petit rappel le soir pour noter vos dépenses',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final settings = ref.watch(notificationSettingsProvider).valueOrNull ?? {};
                    final enabled = settings['daily'] ?? false;
                    return Switch(
                      value: enabled,
                      onChanged: (value) {
                         ref.read(notificationSettingsProvider.notifier).toggleDailyReminders(value);
                      },
                    );
                  }
                ),
              ],
            ),

            SizedBox(height: 16),
            
            // Test notification button
            SizedBox(
              width: double.infinity,
              child: Consumer(
                builder: (context, ref, child) {
                  return OutlinedButton.icon(
                    icon: Icon(Icons.notifications_active_outlined, size: 18),
                    label: Text('Tester les notifications'),
                    onPressed: () async {
                      final service = ref.read(notificationServiceProvider);
                      await service.showTestNotification();
                    },
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showBorderColorPicker(BuildContext context, WidgetRef ref) {
    final colors = {
      'Vert': '#4CAF50',
      'Bleu': '#2196F3',
      'Violet': '#9C27B0',
      'Orange': '#FF9800',
      'Rouge': '#F44336',
      'Rose': '#E91E63',
      'Cyan': '#00BCD4',
      'Jaune': '#FFC107',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Couleur des bordures'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: colors.entries.map((entry) {
            final color = Color(int.parse(entry.value.substring(1), radix: 16) + 0xFF000000);
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              title: Text(entry.key),
              onTap: () async {
                await _updateBorderColor(context, ref, entry.value);
                if (context.mounted) Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateBorderColor(
    BuildContext context,
    WidgetRef ref,
    String colorHex,
  ) async {
    try {
      final database = AppDatabase();
      final settings = await database.select(database.settings).getSingleOrNull();
      
      if (settings != null) {
        await database.update(database.settings).replace(
          settings.copyWith(borderColor: drift.Value(colorHex)),
        );
        
        // Invalidate border color provider for instant refresh
        ref.invalidate(borderColorProvider);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Couleur mise à jour instantanément !'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  String _getThemeName(ThemeMode? mode) {
    if (mode == null) return 'Système';
    switch (mode) {
      case ThemeMode.system:
        return 'Système';
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
    }
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    final currentmode = ref.read(themeProviderProvider).valueOrNull ?? ThemeMode.system;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choisir le thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text('Système'),
              value: ThemeMode.system,
              groupValue: currentmode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProviderProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text('Clair'),
              value: ThemeMode.light,
              groupValue: currentmode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProviderProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text('Sombre'),
              value: ThemeMode.dark,
              groupValue: currentmode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProviderProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
        ],
      ),
    );
  }
}
