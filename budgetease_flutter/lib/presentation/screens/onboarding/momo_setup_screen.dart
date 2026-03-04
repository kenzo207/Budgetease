import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/database/tables/accounts_table.dart';
import '../../../domain/services/sms_parser_service.dart';
import '../../providers/sms_parser_provider.dart';
import 'onboarding_screen.dart';
import 'accounts_inventory_screen.dart';
import 'calibration_screen.dart';

// ═══════════════════════════════════════════════════════
// MODÈLE
// ═══════════════════════════════════════════════════════

class DetectedMomoAccount {
  final String operator;
  double balance;
  bool included;
  final bool fromSms; // true = détecté auto, false = ajouté manuellement

  DetectedMomoAccount({
    required this.operator,
    required this.balance,
    this.included = true,
    this.fromSms = true,
  });
}

// ═══════════════════════════════════════════════════════
// ÉCRAN
// ═══════════════════════════════════════════════════════

/// Écran 4b : Détection automatique des comptes Mobile Money
class MomoSetupScreen extends ConsumerStatefulWidget {
  const MomoSetupScreen({super.key});

  @override
  ConsumerState<MomoSetupScreen> createState() => _MomoSetupScreenState();
}

enum _MomoSetupPhase { question, scanning, results }

class _MomoSetupScreenState extends ConsumerState<MomoSetupScreen> {
  _MomoSetupPhase _phase = _MomoSetupPhase.question;
  List<DetectedMomoAccount> _detected = [];
  bool _permissionDenied = false;
  String _scanStatus = 'Lecture des SMS...';

  // ── Question initiale ───────────────────────────────

  Future<void> _onYes() async {
    final status = await Permission.sms.request();

    if (!mounted) return;

    if (status.isGranted) {
      setState(() {
        _phase = _MomoSetupPhase.scanning;
        _permissionDenied = false;
      });
      await _scanSms();
    } else {
      setState(() {
        _permissionDenied = true;
      });
    }
  }

  void _onNo() {
    // Pas de compte MoMo → passe directement à l'étape suivante
    ref.read(onboardingControllerProvider.notifier).nextStep();
  }

  // ── Scan des SMS ─────────────────────────────────────

  Future<void> _scanSms() async {
    setState(() => _scanStatus = 'Lecture des SMS en cours...');

    try {
      final query = SmsQuery();
      final messages = await query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 300,
      );

      setState(() => _scanStatus = 'Analyse des transactions...');

      final smsParser = ref.read(smsParserServiceProvider);

      // Groupe par opérateur : garde uniquement le solde du SMS le plus récent
      final Map<String, double> latestBalance = {};
      final Map<String, DateTime> latestDate = {};

      for (final msg in messages) {
        if (msg.body == null || msg.sender == null) continue;
        final date = msg.date ?? DateTime.now();
        final parsed = smsParser.parseMessage(msg.sender!, msg.body!, date);

        if (parsed != null && parsed.balanceAfter != null) {
          final op = parsed.operator;
          if (!latestDate.containsKey(op) || date.isAfter(latestDate[op]!)) {
            latestBalance[op] = parsed.balanceAfter!;
            latestDate[op] = date;
          }
        }
      }

      final detected = latestBalance.entries
          .map((e) => DetectedMomoAccount(
                operator: e.key,
                balance: e.value,
                included: true,
                fromSms: true,
              ))
          .toList();

      if (!mounted) return;
      setState(() {
        _detected = detected;
        _phase = _MomoSetupPhase.results;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _detected = [];
        _phase = _MomoSetupPhase.results;
      });
    }
  }

  // ── Ajout manuel ─────────────────────────────────────

  void _addManually() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMomoSheet(
        existingOperators: _detected.map((d) => d.operator).toSet(),
        currency: ref.read(calibrationDataProvider).currency,
        onAdd: (operator, balance) {
          setState(() {
            _detected.add(DetectedMomoAccount(
              operator: operator,
              balance: balance,
              included: true,
              fromSms: false,
            ));
          });
        },
      ),
    );
  }

  // ── Confirmation ─────────────────────────────────────

  void _confirm() {
    final included = _detected.where((d) => d.included).toList();

    // Ajoute les comptes MoMo à la liste partagée de l'onboarding
    final current = ref.read(accountsToCreateProvider);
    // On retire les éventuels MoMo déjà présents (re-entrée possible)
    final nonMomo = current
        .where((a) => a.type != AccountType.mobileMoney)
        .toList();

    final momoAccounts = included
        .map((d) => AccountToCreate(
              type: AccountType.mobileMoney,
              balance: d.balance,
              operator: d.operator,
            ))
        .toList();

    ref.read(accountsToCreateProvider.notifier).state = [
      ...nonMomo,
      ...momoAccounts,
    ];

    ref.read(onboardingControllerProvider.notifier).nextStep();
  }

  // ── Build ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _MomoSetupPhase.question => _buildQuestion(),
      _MomoSetupPhase.scanning => _buildScanning(),
      _MomoSetupPhase.results  => _buildResults(),
    };
  }

  // ─── Phase 1 : Question ──────────────────────────────

  Widget _buildQuestion() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () =>
                ref.read(onboardingControllerProvider.notifier).previousStep(),
          ),
          const Spacer(),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              ),
              child: Icon(
                Icons.phone_android_outlined,
                size: 52,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: 40),
          Text(
            'Avez-vous un compte Mobile Money ?',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            'MTN MoMo, Orange Money, Wave ou Moov Money',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            textAlign: TextAlign.center,
          ),
          if (_permissionDenied) ...[
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Permission SMS refusée. Vous pouvez configurer votre compte manuellement.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _onNo,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Theme.of(context).colorScheme.surface),
                    foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  child: Text('Non'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.sms_outlined),
                  label: Text('Oui, détecter'),
                  onPressed: _onYes,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Phase 2 : Scan ──────────────────────────────────

  Widget _buildScanning() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 3,
            ),
            SizedBox(height: 32),
            Text(
              'Recherche de vos comptes',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              _scanStatus,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Text(
              'Vos SMS ne quittent jamais cet appareil.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Phase 3 : Résultats ─────────────────────────────

  Widget _buildResults() {
    final currency = ref.watch(calibrationDataProvider).currency;
    final hasDetected = _detected.isNotEmpty;
    final anyIncluded = _detected.any((d) => d.included);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => setState(() => _phase = _MomoSetupPhase.question),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasDetected
                    ? '${_detected.length} compte${_detected.length > 1 ? 's' : ''} détecté${_detected.length > 1 ? 's' : ''}'
                    : 'Aucun compte détecté',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              SizedBox(height: 6),
              Text(
                hasDetected
                    ? 'Solde issu de votre dernier SMS. Modifiez si besoin.'
                    : 'Aucun SMS Mobile Money trouvé dans votre boîte. Ajoutez manuellement.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),

        // Liste des comptes détectés
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              ..._detected.asMap().entries.map((entry) {
                final i = entry.key;
                final account = entry.value;
                return _MomoAccountCard(
                  account: account,
                  currency: currency,
                  onToggle: (val) =>
                      setState(() => _detected[i].included = val),
                  onBalanceChanged: (val) =>
                      setState(() => _detected[i].balance = val),
                  onRemove: account.fromSms
                      ? null
                      : () => setState(() => _detected.removeAt(i)),
                );
              }),
              SizedBox(height: 8),
              // Bouton ajouter manuellement
              OutlinedButton.icon(
                onPressed: _addManually,
                icon: Icon(Icons.add, size: 20),
                label: Text('Ajouter un compte manuellement'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 80), // espace pour le footer
            ],
          ),
        ),

        // Footer
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (hasDetected && anyIncluded) || !hasDetected
                      ? _confirm
                      : null,
                  child: Text(anyIncluded ? 'Confirmer' : 'Passer'),
                ),
              ),
              if (hasDetected) ...[
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (final d in _detected) {
                        d.included = false;
                      }
                    });
                    _confirm();
                  },
                  child: Text('Passer sans compte MoMo'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// CARTE COMPTE DÉTECTÉ
// ═══════════════════════════════════════════════════════

class _MomoAccountCard extends StatefulWidget {
  final DetectedMomoAccount account;
  final String currency;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onBalanceChanged;
  final VoidCallback? onRemove;

  const _MomoAccountCard({
    required this.account,
    required this.currency,
    required this.onToggle,
    required this.onBalanceChanged,
    this.onRemove,
  });

  @override
  State<_MomoAccountCard> createState() => _MomoAccountCardState();
}

class _MomoAccountCardState extends State<_MomoAccountCard> {
  late TextEditingController _balanceController;

  @override
  void initState() {
    super.initState();
    _balanceController = TextEditingController(
      text: widget.account.balance.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIncluded = widget.account.included;

    return Card(
      color: isIncluded ? Theme.of(context).colorScheme.surfaceContainerHighest : Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isIncluded
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)
              : Theme.of(context).colorScheme.surface,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  ),
                  child: Icon(Icons.phone_android_outlined,
                      color: Theme.of(context).colorScheme.primary, size: 22),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.account.operator,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (widget.account.fromSms)
                        Row(
                          children: [
                            Icon(Icons.sms_outlined,
                                size: 11, color: Theme.of(context).colorScheme.primary),
                            SizedBox(width: 4),
                            Text(
                              'Détecté via SMS',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (widget.onRemove != null)
                  IconButton(
                    icon: Icon(Icons.close,
                        size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
                    onPressed: widget.onRemove,
                  )
                else
                  Switch(
                    value: isIncluded,
                    onChanged: widget.onToggle,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
            if (isIncluded) ...[
              SizedBox(height: 12),
              Divider(color: Theme.of(context).colorScheme.surface, height: 1),
              SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Solde actuel',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _balanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        suffixText: widget.currency,
                        suffixStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 0),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val);
                        if (parsed != null) widget.onBalanceChanged(parsed);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// BOTTOM SHEET : AJOUT MANUEL
// ═══════════════════════════════════════════════════════

class _AddMomoSheet extends ConsumerStatefulWidget {
  final Set<String> existingOperators;
  final String currency;
  final void Function(String operator, double balance) onAdd;

  const _AddMomoSheet({
    required this.existingOperators,
    required this.currency,
    required this.onAdd,
  });

  @override
  ConsumerState<_AddMomoSheet> createState() => _AddMomoSheetState();
}

class _AddMomoSheetState extends ConsumerState<_AddMomoSheet> {
  String? _selectedOperator;
  final _balanceController = TextEditingController();

  static const _operators = [
    'MTN MoMo',
    'Orange Money',
    'Wave',
    'Moov Money',
  ];

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  bool get _canAdd =>
      _selectedOperator != null && _balanceController.text.isNotEmpty;

  void _onAdd() {
    final balance = double.tryParse(_balanceController.text) ?? 0.0;
    widget.onAdd(_selectedOperator!, balance);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Ajouter un compte',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 20),
          // Sélection opérateur
          Text('Opérateur',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _operators
                .map((op) => ChoiceChip(
                      label: Text(op),
                      selected: _selectedOperator == op,
                      selectedColor:
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      labelStyle: TextStyle(
                        color: _selectedOperator == op
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: _selectedOperator == op
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: _selectedOperator == op
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surface,
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedOperator = op),
                    ))
                .toList(),
          ),
          SizedBox(height: 20),
          // Solde
          TextField(
            controller: _balanceController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Solde actuel',
              suffixText: widget.currency,
              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
            ),
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canAdd ? _onAdd : null,
              child: Text('Ajouter'),
            ),
          ),
        ],
      ),
    );
  }
}
