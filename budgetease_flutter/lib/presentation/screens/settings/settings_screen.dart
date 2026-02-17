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
      // backgroundColor: AppColors.backgroundColor, // Removed to use theme
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
                    const SizedBox(height: 8),
                    Text(
                      'Bonjour, ${calibrationData.userName} 👋',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            // color: AppColors.textSecondary, // Removed to use theme
                          ),
                    ),
                  ],
                ),
              ),

              // Profile Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Profil',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              
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
                onTap: () => _showThemePicker(context, ref),
              ),

              const SizedBox(height: 24),

              // App Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Application',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              
              _buildSettingCard(
                context,
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Gérer les notifications',
                onTap: () => _showNotificationsDialog(context),
              ),
              
              _buildSettingCard(
                context,
                icon: Icons.category_outlined,
                title: 'Catégories',
                subtitle: 'Gérer les catégories de transactions',
                onTap: () {
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
                    setState(() => _smsEnabled = value);
                    // TODO: Persist preference
                    if (value) {
                      try {
                         await ref.read(pendingTransactionsProvider.notifier).scan();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur: $e')),
                          );
                          setState(() => _smsEnabled = false);
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

              const SizedBox(height: 24),

              // Data Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Données',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              
              _buildSettingCard(
                context,
                icon: Icons.backup_outlined,
                title: 'Sauvegarde',
                subtitle: 'Exporter vos données',
                onTap: () => _exportData(context),
              ),
              
              _buildSettingCard(
                context,
                icon: Icons.restore_outlined,
                title: 'Restaurer',
                subtitle: 'Importer des données',
                onTap: () => _importData(context),
              ),
              
              _buildSettingCard(
                context,
                icon: Icons.refresh_outlined,
                title: 'Réinitialiser l\'application',
                subtitle: 'Supprimer toutes les données',
                iconColor: AppColors.errorColor,
                onTap: () => _showResetDialog(context),
              ),

              const SizedBox(height: 24),

              // About Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'À propos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              
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
                  showLicensePage(
                    context: context,
                    applicationName: 'Zolt',
                    applicationVersion: '4.0.0',
                  );
                },
              ),
              
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Signé par Kenzo O\'Bryan',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),

              const SizedBox(height: 32),
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
            color: (iconColor ?? AppColors.primaryColor).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppColors.primaryColor,
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
                ? const Icon(Icons.chevron_right, color: AppColors.textSecondary)
                : null),
        onTap: onTap,
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser l\'application ?'),
        content: const Text(
          'Cette action supprimera toutes vos données (comptes, transactions, paramètres). '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetApp(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorColor,
            ),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetApp(BuildContext context) async {
    try {
      final database = AppDatabase();
      
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
          const SnackBar(
            content: Text('Application réinitialisée'),
            backgroundColor: AppColors.accentColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.errorColor,
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
        title: const Text('Modifier le nom'),
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
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await _updateUserName(context, ref, newName);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Enregistrer'),
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
        title: const Text('Choisir la devise'),
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
            child: const Text('Annuler'),
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
        
        // Refresh provider
        ref.invalidate(calibrationDataProvider);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nom mis à jour'),
              backgroundColor: AppColors.accentColor,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.errorColor,
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
        
        // Refresh provider
        ref.invalidate(calibrationDataProvider);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Devise mise à jour'),
              backgroundColor: AppColors.accentColor,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.errorColor,
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
              backgroundColor: AppColors.accentColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.errorColor,
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
      final settings = await database.select(database.settings).getSingleOrNull();
      
      final exportCount = accounts.length + transactions.length + categories.length;
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sauvegarde créée: $exportCount éléments\n(Fonctionnalité d\'export fichier à venir)'),
            backgroundColor: AppColors.accentColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: AppColors.errorColor,
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
        title: const Text('Restaurer les données'),
        content: const Text(
          'Cette fonctionnalité permet d\'importer des données depuis une sauvegarde.\n\n'
          'L\'import de fichiers sera disponible dans une prochaine version.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configurez vos préférences de notifications',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            
            // Budget alerts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alertes budget',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Recevoir une alerte quand le budget est dépassé',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
            
            const Divider(),
            
            // Daily check-in
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check-in Quotidien',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Petit rappel le soir pour noter vos dépenses',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
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
        title: const Text('Couleur des bordures'),
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
            child: const Text('Annuler'),
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
            const SnackBar(
              content: Text('Couleur mise à jour instantanément !'),
              backgroundColor: AppColors.accentColor,
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
            backgroundColor: AppColors.errorColor,
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
        title: const Text('Choisir le thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Système'),
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
              title: const Text('Clair'),
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
              title: const Text('Sombre'),
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
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}
