// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_parser_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$smsParserServiceHash() => r'7c0c02448c5ad0e47253dc8b02a20b522182923f';

/// Provider du service de parsing SMS
///
/// Copied from [smsParserService].
@ProviderFor(smsParserService)
final smsParserServiceProvider = AutoDisposeProvider<SmsParserService>.internal(
  smsParserService,
  name: r'smsParserServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$smsParserServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SmsParserServiceRef = AutoDisposeProviderRef<SmsParserService>;
String _$pendingTransactionsCountHash() =>
    r'93e4d2f9b16f6448867e20b99fbccacf32d3604f';

/// Provider du nombre de transactions en attente
///
/// Copied from [pendingTransactionsCount].
@ProviderFor(pendingTransactionsCount)
final pendingTransactionsCountProvider =
    AutoDisposeFutureProvider<int>.internal(
      pendingTransactionsCount,
      name: r'pendingTransactionsCountProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingTransactionsCountHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingTransactionsCountRef = AutoDisposeFutureProviderRef<int>;
String _$pendingTransactionsHash() =>
    r'765bdddea96b3cfa928e7939fe2c13350ce753fc';

/// Provider des transactions en attente
///
/// Copied from [PendingTransactions].
@ProviderFor(PendingTransactions)
final pendingTransactionsProvider =
    AutoDisposeAsyncNotifierProvider<
      PendingTransactions,
      List<PendingTransaction>
    >.internal(
      PendingTransactions.new,
      name: r'pendingTransactionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingTransactionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PendingTransactions =
    AutoDisposeAsyncNotifier<List<PendingTransaction>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
