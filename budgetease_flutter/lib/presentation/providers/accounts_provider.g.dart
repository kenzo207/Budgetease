// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$accountsProviderHash() => r'c796c2e6236ae1e03d966d45090863ae118766df';

/// Provider des comptes
///
/// Copied from [AccountsProvider].
@ProviderFor(AccountsProvider)
final accountsProviderProvider =
    AutoDisposeAsyncNotifierProvider<AccountsProvider, List<Account>>.internal(
  AccountsProvider.new,
  name: r'accountsProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$accountsProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AccountsProvider = AutoDisposeAsyncNotifier<List<Account>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
