import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../onboarding/onboarding_screen.dart';

/// Provider pour stocker les données de calibrage
final calibrationDataProvider = StateProvider<CalibrationData>((ref) {
  return CalibrationData(currency: 'FCFA', userName: '');
});

class CalibrationData {
  final String currency;
  final String userName;

  CalibrationData({required this.currency, required this.userName});

  CalibrationData copyWith({String? currency, String? userName}) {
    return CalibrationData(
      currency: currency ?? this.currency,
      userName: userName ?? this.userName,
    );
  }
}

/// Écran 2 : Calibrage (Devise + Prénom)
class CalibrationScreen extends ConsumerStatefulWidget {
  const CalibrationScreen({super.key});

  @override
  ConsumerState<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends ConsumerState<CalibrationScreen> {
  final _nameController = TextEditingController();
  String _selectedCurrency = 'FCFA';

  @override
  void initState() {
    super.initState();
    final data = ref.read(calibrationDataProvider);
    _selectedCurrency = data.currency;
    _nameController.text = data.userName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canContinue => _nameController.text.trim().isNotEmpty;

  void _onContinue() {
    ref.read(calibrationDataProvider.notifier).state = CalibrationData(
      currency: _selectedCurrency,
      userName: _nameController.text.trim(),
    );
    ref.read(onboardingControllerProvider.notifier).nextStep();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bouton retour
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              ref.read(onboardingControllerProvider.notifier).previousStep();
            },
          ),
          
          const SizedBox(height: 24),
          
          // Question 1: Devise
          Text(
            'Quelle est votre devise principale ?',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _selectedCurrency,
            decoration: const InputDecoration(
              labelText: 'Devise',
              prefixIcon: Icon(Icons.attach_money),
            ),
            items: AppConstants.supportedCurrencies.map((currency) {
              return DropdownMenuItem(
                value: currency,
                child: Text(_getCurrencyName(currency)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCurrency = value!;
              });
            },
          ),
          
          const SizedBox(height: 32),
          
          // Question 2: Prénom
          Text(
            'Comment doit-on vous appeler ?',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          
          const SizedBox(height: 16),
          
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Prénom',
              prefixIcon: Icon(Icons.person),
              hintText: 'Ex: Jean',
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
          ),
          
          const Spacer(),
          
          // Bouton Continuer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canContinue ? _onContinue : null,
              child: const Text('Continuer'),
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrencyName(String code) {
    switch (code) {
      case 'FCFA':
        return 'Franc CFA (FCFA)';
      case 'EUR':
        return 'Euro (EUR)';
      case 'USD':
        return 'Dollar US (USD)';
      case 'GHS':
        return 'Cedi Ghanéen (GHS)';
      case 'NGN':
        return 'Naira Nigérian (NGN)';
      default:
        return code;
    }
  }
}
