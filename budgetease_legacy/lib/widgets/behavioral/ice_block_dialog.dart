import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../common/custom_widgets.dart';

class IceBlockDialog extends StatefulWidget {
  const IceBlockDialog({super.key});

  @override
  State<IceBlockDialog> createState() => _IceBlockDialogState();
}

class _IceBlockDialogState extends State<IceBlockDialog> {
  int _secondsRemaining = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.ac_unit,
              size: 48,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Pause Fraîcheur ❄️',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Cette dépense n\'est pas essentielle et votre score de risque est élevé.\n\nEn avez-vous vraiment besoin maintenant ?',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.gray600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: _secondsRemaining > 0
                    ? 'Attendez ${_secondsRemaining}s...'
                    : 'Oui, je confirme',
                onPressed: _secondsRemaining > 0
                    ? null
                    : () => Navigator.pop(context, true),
                backgroundColor: _secondsRemaining > 0
                    ? AppColors.gray200
                    : AppColors.primary,
                textColor: _secondsRemaining > 0
                    ? AppColors.gray600
                    : Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Non, j\'annule',
                style: TextStyle(
                  color: AppColors.gray600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
