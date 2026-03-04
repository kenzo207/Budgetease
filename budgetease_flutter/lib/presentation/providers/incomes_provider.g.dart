// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incomes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$incomesDaoHash() => r'1481ffc611ea9652a24842a90df19d9cb6a7cf77';

/// Provider pour accéder au DAO des revenus réguliers
///
/// Copied from [incomesDao].
@ProviderFor(incomesDao)
final incomesDaoProvider = AutoDisposeProvider<RecurringIncomesDao>.internal(
  incomesDao,
  name: r'incomesDaoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$incomesDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IncomesDaoRef = AutoDisposeProviderRef<RecurringIncomesDao>;
String _$nextPendingIncomeHash() => r'b562377beedce729021c0b15afd879e2506d462b';

/// Provider dérivé pour récupérer uniquement le prochain revenu en attente (urgent)
///
/// Copied from [nextPendingIncome].
@ProviderFor(nextPendingIncome)
final nextPendingIncomeProvider =
    AutoDisposeFutureProvider<RecurringIncome?>.internal(
  nextPendingIncome,
  name: r'nextPendingIncomeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nextPendingIncomeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NextPendingIncomeRef = AutoDisposeFutureProviderRef<RecurringIncome?>;
String _$incomesNotifierHash() => r'527ef94065d255923d6428c948d12025eae13ff5';

/// Notifier pour gérer l'état de la liste des revenus réguliers (CRUD)
///
/// Copied from [IncomesNotifier].
@ProviderFor(IncomesNotifier)
final incomesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    IncomesNotifier, List<RecurringIncome>>.internal(
  IncomesNotifier.new,
  name: r'incomesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$incomesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$IncomesNotifier = AutoDisposeAsyncNotifier<List<RecurringIncome>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
