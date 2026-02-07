import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgetease_flutter/services/shield_service.dart';

/// Shield Screen - Manage fixed charges, debts, and SOS
class ShieldScreen extends StatelessWidget {
  const ShieldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shieldService = Provider.of<ShieldService>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 36,
                        color: Color(0xFF6C63FF),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'The Shield',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Protected Budget',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<double>(
                    future: shieldService.calculateMonthlyShieldTotal(),
                    builder: (context, snapshot) {
                      final total = snapshot.data ?? 0.0;
                      return Text(
                        '${total.toStringAsFixed(0)} FCFA/mois',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C63FF),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Placeholder
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No shield items yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add fixed charges, debts, or SOS fund',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Add Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    //TODO: Add shield item
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Shield Item'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
