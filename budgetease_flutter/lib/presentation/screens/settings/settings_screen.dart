import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/utils/zolt_colors.dart';
import '../../widgets/zolt_card.dart';
import '../onboarding/onboarding_screen.dart';
import '../transactions/pending_transactions_screen.dart';
import 'categories_management_screen.dart';
import '../../providers/border_color_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/sms_parser_provider.dart';
import '../../../services/analytics_service.dart';
import '../simulator/simulator_screen.dart';
import '../charges/charges_screen.dart';
import '../incomes/incomes_screen.dart';
import '../onboarding/calibration_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).screen('Settings');
      _loadSmsSettings();
    });
  }

  Future<void> _loadSmsSettings() async {
    final database = ref.read(databaseProvider);
    final settings = await database.select(database.settings).getSingleOrNull();
    if (settings != null && mounted) {
      setState(() => _smsEnabled = settings.smsParsingEnabled);
    }
  }

  @override
  Widget build(BuildContext context) {
    final calibrationData = ref.watch(calibrationDataProvider);
    final themeMode = ref.watch(themeProviderProvider).valueOrNull;
    final zolt = context.zolt;

    return Scaffold(
      backgroundColor: zolt.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                child: Text(
                  'Paramètres',
                  style: TextStyle(
                    fontFamily: 'CabinetGrotesk',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: zolt.textPrimary,
                  ),
                ),
              ),

              // Profil Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ZoltCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: ZoltTokens.brand,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _getInitials(calibrationData.userName),
                              style: const TextStyle(
                                fontFamily: 'CabinetGrotesk',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  calibrationData.userName,
                                  style: TextStyle(
                                    fontFamily: 'CabinetGrotesk',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: zolt.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Compte gratuit',
                                  style: TextStyle(
                                    fontFamily: 'CabinetGrotesk',
                                    fontSize: 12,
                                    color: zolt.text2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 42,
                        decoration: BoxDecoration(
                          color: ZoltTokens.goldMuted,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.lock, size: 16, color: ZoltTokens.gold),
                            const SizedBox(width: 8),
                            const Text(
                              'Passer à Premium',
                              style: TextStyle(
                                fontFamily: 'CabinetGrotesk',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ZoltTokens.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // SECTION 1 : MON COMPTE
              _buildSectionTitle('MON COMPTE', zolt),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ZoltCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildListItem(LucideIcons.user, 'Prénom et préférences', zolt, onTap: () => _showEditNameDialog(context, ref, calibrationData.userName)),
                      Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: zolt.border),
                      _buildListItem(LucideIcons.smartphone, 'Mes comptes MoMo', zolt, onTap: () {}), // Implement accounts later
                      Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: zolt.border),
                      _buildListItem(LucideIcons.repeat, 'Charges & Revenus', zolt, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChargesScreen()))),
                      Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: zolt.border),
                      _buildListItem(LucideIcons.download, 'Données & Export', zolt, onTap: () => _exportData(context)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // SECTION 2 : APPARENCE & APP
              _buildSectionTitle('APPARENCE & APP', zolt),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ZoltCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildListItem(LucideIcons.sunMedium, 'Thème', zolt, trailing: Text(_getThemeName(themeMode), style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 14, color: zolt.text3)), onTap: () => _showThemePicker(context, ref)),
                      Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: zolt.border),
                      _buildListItem(LucideIcons.globe, 'Langue', zolt, trailing: Text('Français', style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 14, color: zolt.text3))),
                      Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: zolt.border),
                      _buildListItem(LucideIcons.bell, 'Notifications', zolt, onTap: () => _showNotificationsDialog(context)),
                      Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: zolt.border),
                      _buildListItem(LucideIcons.layoutGrid, 'Widget écran d\'accueil', zolt),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // SECTION 3 : AIDE
              _buildSectionTitle('AIDE', zolt),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ZoltCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildListItem(LucideIcons.compass, 'Revoir la visite guidée', zolt, onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('has_seen_tutorial', false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tutoriel réinitialisé.')));
                        }
                      }),
                      Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: zolt.border),
                      _buildListItem(LucideIcons.info, 'Comment fonctionne Zolt?', zolt, onTap: () {}),
                      Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: zolt.border),
                      _buildListItem(LucideIcons.mail, 'Nous contacter', zolt, onTap: () {}),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // FOOTER
              Center(
                child: Text(
                  'Version 1.5.0 · Zolt\nMade with ♥ in Bénin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'CabinetGrotesk',
                    fontSize: 11,
                    color: zolt.text3,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // DESTRUCTIVE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  onTap: () => _showResetDialog(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.trash2, size: 18, color: ZoltTokens.critical),
                        const SizedBox(width: 8),
                        const Text(
                          'Supprimer mon compte',
                          style: TextStyle(
                            fontFamily: 'CabinetGrotesk',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ZoltTokens.critical,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length > 1 ? 2 : 1).toUpperCase();
  }

  Widget _buildSectionTitle(String title, ZoltColors zolt) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'CabinetGrotesk',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.4,
          color: zolt.text3,
        ),
      ),
    );
  }

  Widget _buildListItem(IconData icon, String title, ZoltColors zolt, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, size: 20, color: zolt.textPrimary),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'CabinetGrotesk',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: zolt.textPrimary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) trailing,
          if (trailing != null) const SizedBox(width: 8),
          Icon(LucideIcons.chevronRight, size: 16, color: zolt.text3),
        ],
      ),
      onTap: onTap,
    );
  }

  String _getThemeName(ThemeMode? mode) {
    if (mode == null || mode == ThemeMode.system) return 'Auto';
    if (mode == ThemeMode.light) return 'Clair';
    return 'Sombre';
  }

  // --- Logic Methods Start ---

  void _showResetDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final zolt = context.zolt;
        return Container(
          decoration: BoxDecoration(
            color: zolt.isDark ? ZoltTokens.darkSurface3 : ZoltTokens.lightSurface3,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.alertTriangle, size: 28, color: ZoltTokens.critical),
              const SizedBox(height: 16),
              Text(
                'Supprimer mon compte ?',
                style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 18, fontWeight: FontWeight.w700, color: zolt.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Cette action est irréversible. Toutes tes données seront effacées.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 14, color: zolt.text2),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  await _resetApp(context);
                },
                child: Container(
                  height: 48,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ZoltTokens.critical,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: Alignment.center,
                  child: const Text('Supprimer définitivement', style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler', style: TextStyle(fontFamily: 'CabinetGrotesk', fontSize: 14, color: zolt.text2)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _resetApp(BuildContext context) async {
    try {
      final database = ref.read(databaseProvider);
      ref.read(analyticsServiceProvider).capture('app_reset_confirmed');

      await database.delete(database.transactions).go();
      await database.delete(database.accounts).go();
      await database.delete(database.recurringCharges).go();
      await database.delete(database.categories).go();
      await database.delete(database.settings).go();
      
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (route) => false,
        );
      }
    } catch (e) {}
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le nom'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                final db = ref.read(databaseProvider);
                final s = await db.select(db.settings).getSingleOrNull();
                if (s != null) {
                  await db.update(db.settings).replace(s.copyWith(userName: newName));
                  final current = ref.read(calibrationDataProvider);
                  ref.read(calibrationDataProvider.notifier).state = current.copyWith(userName: newName);
                }
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
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
            RadioListTile<ThemeMode>(title: const Text('Système / Auto'), value: ThemeMode.system, groupValue: currentmode, onChanged: (v) { ref.read(themeProviderProvider.notifier).setThemeMode(v!); Navigator.pop(context); }),
            RadioListTile<ThemeMode>(title: const Text('Clair'), value: ThemeMode.light, groupValue: currentmode, onChanged: (v) { ref.read(themeProviderProvider.notifier).setThemeMode(v!); Navigator.pop(context); }),
            RadioListTile<ThemeMode>(title: const Text('Sombre'), value: ThemeMode.dark, groupValue: currentmode, onChanged: (v) { ref.read(themeProviderProvider.notifier).setThemeMode(v!); Navigator.pop(context); }),
          ],
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Notifications'), content: const Text('En développement...')));
  }

  Future<void> _exportData(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export bientôt disponible')));
  }
}
