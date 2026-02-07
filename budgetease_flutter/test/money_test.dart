import 'package:flutter_test/flutter_test.dart';
import 'package:budgetease_flutter/utils/money.dart';

void main() {
  group('Money Type Tests', () {
    test('Create money from double', () {
      final money = Money(100.50, 'FCFA');
      expect(money.amount, 100.50);
      expect(money.cents, 10050);
      expect(money.currency, 'FCFA');
    });

    test('Create money from cents', () {
      final money = Money.fromCents(10050, 'FCFA');
      expect(money.amount, 100.50);
      expect(money.cents, 10050);
    });

    test('Addition works correctly', () {
      final a = Money(100.0, 'FCFA');
      final b = Money(50.0, 'FCFA');
      final result = a + b;

      expect(result.amount, 150.0);
    });

    test('Subtraction works correctly', () {
      final a = Money(100.0, 'FCFA');
      final b = Money(30.0, 'FCFA');
      final result = a - b;

      expect(result.amount, 70.0);
    });

    test('Multiplication works correctly', () {
      final money = Money(10.0, 'FCFA');
      final result = money * 2.5;

      expect(result.amount, 25.0);
    });

    test('Division works correctly', () {
      final money = Money(100.0, 'FCFA');
      final result = money / 4;

      expect(result.amount, 25.0);
    });

    test('Comparison operators work', () {
      final a = Money(100.0, 'FCFA');
      final b = Money(50.0, 'FCFA');

      expect(a > b, true);
      expect(b < a, true);
      expect(a >= b, true);
      expect(b <= a, true);
    });

    test('Equality works', () {
      final a = Money(100.0, 'FCFA');
      final b = Money(100.0, 'FCFA');
      final c = Money(100.0, 'NGN');

      expect(a == b, true);
      expect(a == c, false); // Different currency
    });

    test('Different currencies throw error', () {
      final fcfa = Money(100.0, 'FCFA');
      final ngn = Money(100.0, 'NGN');

      expect(() => fcfa + ngn, throwsArgumentError);
    });

    test('No floating point errors with many additions', () {
      // Classic floating point problem: 0.1 + 0.2 != 0.3
      Money sum = Money.zero('FCFA');

      for (int i = 0; i < 1000; i++) {
        sum = sum + Money(0.1, 'FCFA');
      }

      expect(sum.amount, 100.0); // Should be exactly 100.0
    });

    test('List sum works', () {
      final amounts = [
        Money(10.0, 'FCFA'),
        Money(20.0, 'FCFA'),
        Money(30.0, 'FCFA'),
      ];

      final total = amounts.sum();
      expect(total.amount, 60.0);
    });

    test('List average works', () {
      final amounts = [
        Money(10.0, 'FCFA'),
        Money(20.0, 'FCFA'),
        Money(30.0, 'FCFA'),
      ];

      final avg = amounts.average();
      expect(avg.amount, 20.0);
    });

    test('List max/min works', () {
      final amounts = [
        Money(10.0, 'FCFA'),
        Money(100.0, 'FCFA'),
        Money(5.0, 'FCFA'),
      ];

      expect(amounts.max().amount, 100.0);
      expect(amounts.min().amount, 5.0);
    });

    test('Absolute value works', () {
      final negative = Money(-50.0, 'FCFA');
      expect(negative.abs().amount, 50.0);
    });

    test('Clamp works', () {
      final money = Money(100.0, 'FCFA');
      final min = Money(20.0, 'FCFA');
      final max = Money(80.0, 'FCFA');

      final clamped = money.clamp(min, max);
      expect(clamped.amount, 80.0);
    });

    test('Zero checks work', () {
      final zero = Money.zero('FCFA');
      final positive = Money(10.0, 'FCFA');
      final negative = Money(-10.0, 'FCFA');

      expect(zero.isZero, true);
      expect(positive.isPositive, true);
      expect(negative.isNegative, true);
    });

    test('toString formats correctly', () {
      final money = Money(1500.0, 'FCFA');
      expect(money.toString(), '1500.0 FCFA');
    });

    test('Safe operations work', () {
      final a = Money(100.0, 'FCFA');
      final b = Money(50.0, 'FCFA');

      final addResult = SafeMoney.add(a, b);
      expect(addResult.isRight(), true);
      expect(addResult.getOrThrow().amount, 150.0);

      final divByZero = SafeMoney.divide(a, 0);
      expect(divByZero.isLeft(), true);
    });
  });
}
