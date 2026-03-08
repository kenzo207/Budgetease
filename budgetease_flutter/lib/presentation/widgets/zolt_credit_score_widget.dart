import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../engine/zolt_engine.dart';
import '../../engine/engine_input_builder.dart';
import '../providers/engine_provider.dart';

class ZoltCreditScoreWidget extends ConsumerStatefulWidget {
  const ZoltCreditScoreWidget({super.key});

  @override
  ConsumerState<ZoltCreditScoreWidget> createState() => _ZoltCreditScoreWidgetState();
}

class _ZoltCreditScoreWidgetState extends ConsumerState<ZoltCreditScoreWidget> {
  bool _isLoading = true;
  Map<String, dynamic>? _scoreData;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadScore();
  }

  Future<void> _loadScore() async {
    if (!ZoltEngine.isAvailable) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Moteur Zolt indisponible';
        });
      }
      return;
    }

    try {
      final rawInput = await ref.read(engineRawInputProvider.future);
      final inputJson = rawInput['input'];
      final historyJson = rawInput['history'];
      
      final creditInput = {
        'history': historyJson,
        'current': inputJson,
        'first_name': 'Kenzo', // Default or from prefs
      };

      final result = ZoltEngine.creditScore(input: creditInput);
      
      if (mounted) {
        setState(() {
          _scoreData = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Impossible de calculer le score';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onErrorContainer),
              const SizedBox(width: 12),
              Expanded(child: Text(_error, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer))),
            ],
          ),
        ),
      );
    }

    if (_scoreData == null) return const SizedBox.shrink();

    final scoreStr = _scoreData!['score'] ?? '0';
    final score = double.tryParse(scoreStr.toString()) ?? 0.0;
    final int scoreInt = score.round();
    final tier = _scoreData!['tier'] as String? ?? 'Inconnu';
    final summary = _scoreData!['summary'] as String? ?? 'Score calculé par Zolt.';

    Color scoreColor = Colors.grey;
    if (tier.startsWith('A')) scoreColor = Colors.green;
    else if (tier.startsWith('B')) scoreColor = Colors.teal;
    else if (tier.startsWith('C')) scoreColor = Colors.orange;
    else if (tier.startsWith('D')) scoreColor = Colors.deepOrange;
    else if (tier.startsWith('F')) scoreColor = Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scoreColor.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    tier,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zolt Credit Score',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        summary,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$scoreInt',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 8,
                backgroundColor: scoreColor.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
