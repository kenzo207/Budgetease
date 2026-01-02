import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../models/transaction.dart';
import '../common/custom_widgets.dart';

class RoundUpSheet extends StatefulWidget {
  final double originalAmount;
  final double roundedAmount;
  final String currency;

  const RoundUpSheet({
    super.key,
    required this.originalAmount,
    required this.roundedAmount,
    required this.currency,
  });

  @override
  State<RoundUpSheet> createState() => _RoundUpSheetState();
}

class _RoundUpSheetState extends State<RoundUpSheet> {
  double get _savings => widget.roundedAmount - widget.originalAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Icon(
            Icons.savings_outlined,
            size: 48,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Arrondir pour épargner ?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.gray600,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'Notez une dépense de '),
                TextSpan(
                  text: '${widget.roundedAmount.toStringAsFixed(0)} ${widget.currency}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                const TextSpan(text: '\net épargnez discrètement '),
                TextSpan(
                  text: '${_savings.toStringAsFixed(0)} ${widget.currency}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Non, garder ${widget.originalAmount.toStringAsFixed(0)}',
                  isOutlined: true,
                  onPressed: () => Navigator.pop(context, false),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Oui, arrondir',
                  onPressed: () => Navigator.pop(context, true),
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
