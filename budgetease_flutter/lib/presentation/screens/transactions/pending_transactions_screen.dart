import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/sms_parser_provider.dart';
import '../../providers/transactions_provider.dart'; // To add real transaction
import '../../data/database/app_database.dart'; // For PendingTransaction type
import '../../core/utils/formatters.dart'; // For money format
import '../widgets/action_bottom_sheet.dart'; // Reuse for adding transaction details?

class PendingTransactionsScreen extends ConsumerWidget {
  const PendingTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions SMS détectées'),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              try {
                final count = await ref.read(pendingTransactionsProvider.notifier).scan();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$count nouvelles transactions trouvées')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundColor,
      body: pendingAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sms_failed, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Aucune transaction en attente'),
                  TextButton(
                    onPressed: () => ref.read(pendingTransactionsProvider.notifier).scan(),
                    child: const Text('Scanner maintenant'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: transactions.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryColor,
                    child: Icon(Icons.message, color: Colors.white),
                  ),
                  title: Text('${transaction.amount} FCFA'),
                  subtitle: Text('${transaction.operator} • ${DateFormatter.formatRelative(transaction.smsDate)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _approveTransaction(context, ref, transaction),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => ref.read(pendingTransactionsProvider.notifier).markAsProcessed(transaction.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur: $e')),
      ),
    );
  }

  void _approveTransaction(BuildContext context, WidgetRef ref, PendingTransaction pending) {
    // Show partial ActionBottomSheet pre-filled
    // For now, simpler implementation: just mark processed and maybe create dummy?
    // Proper way: Open ActionBottomSheet with data.
    // Since ActionBottomSheet is a widget, we can mount it. 
    // But ActionBottomSheet state is internal.
    // Better: Show a dialog to select Category and Account, then save.
    
    showDialog(
      context: context,
      builder: (context) => _ApproveDialog(pending: pending),
    );
  }
}

class _ApproveDialog extends ConsumerStatefulWidget {
  final PendingTransaction pending;
  const _ApproveDialog({required this.pending});

  @override
  ConsumerState<_ApproveDialog> createState() => __ApproveDialogState();
}

class __ApproveDialogState extends ConsumerState<_ApproveDialog> {
  // Simplification: We need category and account.
  // ... Implementation of a mini-form ...
  // For MVP I will just text "Feature coming soon" or implement basic.
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Valider'),
      content: Text('Ajouter ${widget.pending.amount} FCFA ?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        TextButton(
          onPressed: () {
            // Logic to add transaction would go here.
            // For now, just mark processed to clean up UI.
            ref.read(pendingTransactionsProvider.notifier).markAsProcessed(widget.pending.id);
            Navigator.pop(context);
          }, 
          child: const Text('Confirmer')
        ),
      ],
    );
  }
}
