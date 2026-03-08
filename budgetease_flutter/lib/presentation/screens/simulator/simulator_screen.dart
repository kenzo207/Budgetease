import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../engine/zolt_engine.dart';
import '../../../engine/engine_input_builder.dart';
import '../../providers/engine_provider.dart';
import '../../../core/utils/formatters.dart';

class SimulatorScreen extends ConsumerStatefulWidget {
  const SimulatorScreen({super.key});

  @override
  ConsumerState<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends ConsumerState<SimulatorScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _error;

  int _selectedScenarioIndex = 0; // 0: AddCharge, 1: ReduceCategory
  
  // Scénario: AddCharge
  final _chargeNameCtrl = TextEditingController(text: 'Abonnement');
  final _chargeAmountCtrl = TextEditingController(text: '15000');

  // Scénario: ReduceCategory
  final _categoryNameCtrl = TextEditingController(text: 'loisirs');
  final _reducePctCtrl = TextEditingController(text: '20');

  @override
  void dispose() {
    _chargeNameCtrl.dispose();
    _chargeAmountCtrl.dispose();
    _categoryNameCtrl.dispose();
    _reducePctCtrl.dispose();
    super.dispose();
  }

  Future<void> _runSimulation() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      if (!ZoltEngine.isAvailable) throw Exception('Moteur Zolt non disponible');

      // 1. Get raw history JSON
      final rawInput = await ref.read(engineRawInputProvider.future);
      final historyJson = rawInput['history'] as List<dynamic>;
      
      // 2. Get deterministic state
      final engineOutput = ref.read(zoltEngineProviderProvider).valueOrNull?.engine;
      if (engineOutput == null) throw Exception('Données du moteur indisponibles');
      final detJson = engineOutput.deterministic.toJson();

      // 3. Build request
      Map<String, dynamic> requestJson;
      if (_selectedScenarioIndex == 0) {
        requestJson = {
          'AddCharge': {
            'name': _chargeNameCtrl.text,
            'amount': double.tryParse(_chargeAmountCtrl.text) ?? 0.0,
          }
        };
      } else {
        requestJson = {
          'ReduceCategory': {
            'category': _categoryNameCtrl.text,
            'reduce_by_pct': (double.tryParse(_reducePctCtrl.text) ?? 20.0) / 100.0,
          }
        };
      }

      final now = DateTime.now();
      final contextJson = {
        'det': detJson,
        'history': historyJson,
        'today': {'year': now.year, 'month': now.month, 'day': now.day},
        'first_name': 'Kofi', // Ou depuis préférences
      };

      final simulateInput = {
        'request': requestJson,
        'context': contextJson,
      };

      // 4. Run FFI
      final result = ZoltEngine.simulate(input: simulateInput);

      setState(() {
        _result = result;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulateur Financier'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Explore tes scénarios futurs',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Découvre instantanément l\'impact de tes décisions financières sur ton budget journalier.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            
            // Toggle Scenario Type
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Ajouter Charge')),
                ButtonSegment(value: 1, label: Text('Réduire Catégorie')),
              ],
              selected: {_selectedScenarioIndex},
              onSelectionChanged: (set) {
                setState(() {
                  _selectedScenarioIndex = set.first;
                });
              },
            ),
            const SizedBox(height: 24),

            // Scenario Form
            if (_selectedScenarioIndex == 0) ...[
              TextField(
                controller: _chargeNameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nom de la nouvelle charge',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _chargeAmountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant par mois (FCFA)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ] else ...[
              TextField(
                controller: _categoryNameCtrl,
                decoration: InputDecoration(
                  labelText: 'Catégorie à réduire (ex: loisirs)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _reducePctCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Pourcentage de réduction (%)',
                  suffixText: '%',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _runSimulation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Lancer la simulation Zolt'),
            ),

            const SizedBox(height: 32),

            // Results Section
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
              ),

            if (_result != null) _buildResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final headline = _result!['headline'] as String? ?? '';
    final feasibility = (_result!['feasibility'] as num?)?.toDouble() ?? 0.0;
    
    // Convert logic colors
    Color feasiColor = Colors.orange;
    if (feasibility >= 0.7) feasiColor = Colors.green;
    else if (feasibility < 0.3) feasiColor = Colors.red;

    final details = (_result!['details'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final actionPlan = (_result!['action_plan'] as List?)?.cast<String>() ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: feasiColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: feasiColor.withValues(alpha: 0.2))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.auto_graph, color: feasiColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Faisabilité : ${(feasibility * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: feasiColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Impact Détaillé', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...details.map((d) {
                  final valStr = d['value'] as String? ?? '';
                  final delta = (d['delta'] as num?)?.toDouble() ?? 0.0;
                  final color = delta > 0 ? Colors.green : (delta < 0 ? Colors.red : Theme.of(context).colorScheme.onSurface);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(d['label'] as String? ?? ''),
                        Text(
                          valStr,
                          style: TextStyle(fontWeight: FontWeight.bold, color: color),
                        ),
                      ],
                    ),
                  );
                }),

                const Divider(height: 32),
                Text('Plan d\'action recommandé', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...actionPlan.map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, size: 18, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(step)),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
