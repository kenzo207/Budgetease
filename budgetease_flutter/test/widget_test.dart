import 'package:flutter_test/flutter_test.dart';
import 'package:budgetease_v4/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: BudgetEaseApp(),
      ),
    );

    // Verify that the app builds without crashing
    expect(find.byType(BudgetEaseApp), findsOneWidget);
  });
}
