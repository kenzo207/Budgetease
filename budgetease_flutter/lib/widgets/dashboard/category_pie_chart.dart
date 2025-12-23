import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/colors.dart';

class CategoryPieChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const CategoryPieChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Aucune donnée à afficher',
            style: TextStyle(color: AppColors.gray600),
          ),
        ),
      );
    }

    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.danger,
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
      const Color(0xFF84CC16),
      const Color(0xFFF59E0B),
    ];

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: data.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final percentage = item['percentage'] as double;

            return PieChartSectionData(
              value: percentage,
              title: '${percentage.toStringAsFixed(0)}%',
              color: colors[index % colors.length],
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

class CategoryLegend extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String currency;

  const CategoryLegend({
    super.key,
    required this.data,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.danger,
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
      const Color(0xFF84CC16),
      const Color(0xFFF59E0B),
    ];

    return Column(
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final category = item['category'] as String;
        final amount = item['amount'] as double;
        final percentage = item['percentage'] as double;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
