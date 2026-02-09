import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/common/custom_widgets.dart';
import '../../widgets/insights/ghost_money_card.dart';
import '../../services/insights_service.dart';
import '../../models/ghost_money_insight.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  GhostMoneyInsight? _ghostMoneyInsight;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() => _isLoading = true);
    
    // Détecter ou récupérer l'insight
    final insight = InsightsService.getOrCreateInsight();
    
    setState(() {
      _ghostMoneyInsight = insight;
      _isLoading = false;
    });
  }

  Future<void> _dismissInsight(GhostMoneyInsight insight) async {
    await InsightsService.dismissInsight(insight);
    setState(() {
      _ghostMoneyInsight = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Ajustements'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInsights,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadInsights,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // En-tête
                  const Text(
                    'Analyse de vos dépenses',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Identifiez les patterns qui impactent votre budget.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Insight Argent Fantôme
                  if (_ghostMoneyInsight != null)
                    GhostMoneyCard(
                      insight: _ghostMoneyInsight!,
                      onDismiss: () => _dismissInsight(_ghostMoneyInsight!),
                    )
                  else
                    EmptyState(
                      icon: Icons.insights_outlined,
                      title: 'Aucun pattern détecté',
                      subtitle: 'Continuez à enregistrer vos dépenses pour obtenir des insights.',
                    ),

                  const SizedBox(height: 24),

                  // Section informative
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.lightbulb_outline, size: 20, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'Comment ça marche ?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Les petites dépenses répétées peuvent représenter une part importante de votre budget sans que vous vous en rendiez compte. '
                          'Cette analyse vous aide à identifier ces patterns pour mieux ajuster vos habitudes.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.gray600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
