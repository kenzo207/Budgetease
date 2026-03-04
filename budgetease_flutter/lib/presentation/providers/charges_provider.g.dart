// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'charges_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mostUrgentChargeHash() => r'f5e99e44afc65da1697d0fc42a2b8fddab1a4ec9';

/// Provider — charge la plus urgente (pour HomeScreen widget)
///
/// Copied from [mostUrgentCharge].
@ProviderFor(mostUrgentCharge)
final mostUrgentChargeProvider =
    AutoDisposeFutureProvider<RecurringCharge?>.internal(
  mostUrgentCharge,
  name: r'mostUrgentChargeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mostUrgentChargeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MostUrgentChargeRef = AutoDisposeFutureProviderRef<RecurringCharge?>;
String _$dailyChargeReserveHash() =>
    r'396c1dd9e5cf1044c7ca06f28a9c6de583345bce';

/// Provider — réserve journalière totale des charges
///
/// Copied from [dailyChargeReserve].
@ProviderFor(dailyChargeReserve)
final dailyChargeReserveProvider = AutoDisposeFutureProvider<double>.internal(
  dailyChargeReserve,
  name: r'dailyChargeReserveProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dailyChargeReserveHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DailyChargeReserveRef = AutoDisposeFutureProviderRef<double>;
String _$chargesNotifierHash() => r'a7b8f83def37821c4013e3441063ff4c63651f71';

/// Provider — liste des charges actives
///
/// Copied from [ChargesNotifier].
@ProviderFor(ChargesNotifier)
final chargesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ChargesNotifier, List<RecurringCharge>>.internal(
  ChargesNotifier.new,
  name: r'chargesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chargesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChargesNotifier = AutoDisposeAsyncNotifier<List<RecurringCharge>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
