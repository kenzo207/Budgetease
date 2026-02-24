// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transactionsProviderHash() =>
    r'd9a6d52ec510585ba1ae2fcf006596a616aa9949';

/// Provider des transactions
///
/// Copied from [TransactionsProvider].
@ProviderFor(TransactionsProvider)
final transactionsProviderProvider = AutoDisposeAsyncNotifierProvider<
    TransactionsProvider, List<Transaction>>.internal(
  TransactionsProvider.new,
  name: r'transactionsProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionsProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TransactionsProvider = AutoDisposeAsyncNotifier<List<Transaction>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
