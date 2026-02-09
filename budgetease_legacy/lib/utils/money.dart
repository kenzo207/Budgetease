import 'package:fpdart/fpdart.dart';

/// Immutable Money type using FPdart for precise financial calculations
/// Stores amounts as cents (smallest unit) to avoid floating-point errors
class Money {
  final int _cents; // Stored in cents (or smallest currency unit)
  final String currency;

  /// Create Money from double amount
  Money(double amount, this.currency)
      : _cents = (amount * 100).round();

  /// Create Money from cents directly
  Money.fromCents(this._cents, this.currency);

  /// Create zero money
  Money.zero(String currency) : this(0.0, currency);

  /// Get amount as double
  double get amount => _cents / 100.0;

  /// Get cents value
  int get cents => _cents;

  // ========== Arithmetic Operations ==========

  /// Add two Money values (same currency required)
  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money.fromCents(_cents + other._cents, currency);
  }

  /// Subtract Money (same currency required)
  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money.fromCents(_cents - other._cents, currency);
  }

  /// Multiply by a factor
  Money operator *(double multiplier) {
    return Money.fromCents((_cents * multiplier).round(), currency);
  }

  /// Divide by a factor
  Money operator /(double divisor) {
    if (divisor == 0) throw ArgumentError('Cannot divide by zero');
    return Money.fromCents((_cents / divisor).round(), currency);
  }

  /// Negate
  Money operator -() {
    return Money.fromCents(-_cents, currency);
  }

  // ========== Comparison Operations ==========

  bool operator >(Money other) {
    _assertSameCurrency(other);
    return _cents > other._cents;
  }

  bool operator <(Money other) {
    _assertSameCurrency(other);
    return _cents < other._cents;
  }

  bool operator >=(Money other) {
    _assertSameCurrency(other);
    return _cents >= other._cents;
  }

  bool operator <=(Money other) {
    _assertSameCurrency(other);
    return _cents <= other._cents;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Money &&
        other._cents == _cents &&
        other.currency == currency;
  }

  @override
  int get hashCode => _cents.hashCode ^ currency.hashCode;

  // ========== Utility Methods ==========

  /// Check if amount is positive
  bool get isPositive => _cents > 0;

  /// Check if amount is negative
  bool get isNegative => _cents < 0;

  /// Check if amount is zero
  bool get isZero => _cents == 0;

  /// Get absolute value
  Money abs() {
    return Money.fromCents(_cents.abs(), currency);
  }

  /// Clamp between min and max
  Money clamp(Money min, Money max) {
    _assertSameCurrency(min);
    _assertSameCurrency(max);
    return Money.fromCents(_cents.clamp(min._cents, max._cents), currency);
  }

  /// Convert to another representation (for display)
  String toStringWithSymbol() {
    return formatCurrency(amount, currency);
  }

  @override
  String toString() => '$amount $currency';

  // ========== Private Helpers ==========

  void _assertSameCurrency(Money other) {
    if (currency != other.currency) {
      throw ArgumentError(
        'Cannot perform operation on different currencies: $currency vs ${other.currency}',
      );
    }
  }

  /// Format currency (simplified, will use full formatter in production)
  static String formatCurrency(double amount, String currency) {
    switch (currency) {
      case 'FCFA':
        return '${amount.toStringAsFixed(0)} FCFA';
      case 'NGN':
        return '₦${amount.toStringAsFixed(2)}';
      case 'GHS':
        return 'GH₵${amount.toStringAsFixed(2)}';
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'EUR':
        return '€${amount.toStringAsFixed(2)}';
      default:
        return '${amount.toStringAsFixed(2)} $currency';
    }
  }
}

// ========== FPdart Extensions (Optional) ==========

/// Extension to work with Either for error handling
extension MoneyEither on Either<String, Money> {
  /// Get Money or throw error
  Money getOrThrow() {
    return fold(
      (error) => throw Exception(error),
      (money) => money,
    );
  }

  /// Get Money or return zero
  Money getOrZero(String currency) {
    return fold(
      (_) => Money.zero(currency),
      (money) => money,
    );
  }
}

/// Safe Money operations returning Either for error handling
class SafeMoney {
  /// Safe add with error handling
  static Either<String, Money> add(Money a, Money b) {
    return Either.tryCatch(
      () => a + b,
      (error, _) => 'Addition failed: ${error.toString()}',
    );
  }

  /// Safe subtract with error handling
  static Either<String, Money> subtract(Money a, Money b) {
    return Either.tryCatch(
      () => a - b,
      (error, _) => 'Subtraction failed: ${error.toString()}',
    );
  }

  /// Safe multiply with validation
  static Either<String, Money> multiply(Money money, double factor) {
    if (factor.isNaN || factor.isInfinite) {
      return Either.left('Invalid multiplier: $factor');
    }
    return Either.tryCatch(
      () => money * factor,
      (error, _) => 'Multiplication failed: ${error.toString()}',
    );
  }

  /// Safe divide with zero check
  static Either<String, Money> divide(Money money, double divisor) {
    if (divisor == 0) {
      return Either.left('Cannot divide by zero');
    }
    return Either.tryCatch(
      () => money / divisor,
      (error, _) => 'Division failed: ${error.toString()}',
    );
  }
}

// ========== List Extensions ==========

extension MoneyList on List<Money> {
  /// Sum all money in list
  Money sum() {
    if (isEmpty) throw StateError('Cannot sum empty list');
    
    return reduce((a, b) => a + b);
  }

  /// Sum with default if empty
  Money sumOr(Money defaultValue) {
    if (isEmpty) return defaultValue;
    return sum();
  }

  /// Average
  Money average() {
    if (isEmpty) throw StateError('Cannot average empty list');
    return sum() / length.toDouble();
  }

  /// Maximum
  Money max() {
    if (isEmpty) throw StateError('Cannot get max of empty list');
    return reduce((a, b) => a > b ? a : b);
  }

  /// Minimum
  Money min() {
    if (isEmpty) throw StateError('Cannot get min of empty list');
    return reduce((a, b) => a < b ? a : b);
  }
}
