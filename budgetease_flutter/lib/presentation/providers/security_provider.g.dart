// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$securityServiceHash() => r'2716294b27b6071e49dd98156e33a308b0526806';

/// Provider du service de sécurité
///
/// Copied from [securityService].
@ProviderFor(securityService)
final securityServiceProvider = AutoDisposeProvider<SecurityService>.internal(
  securityService,
  name: r'securityServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$securityServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SecurityServiceRef = AutoDisposeProviderRef<SecurityService>;
String _$isBiometricAvailableHash() =>
    r'b885969dfcaa9d751b9c6f3e519b3aeb7e6cc940';

/// Provider pour vérifier si la biométrie est disponible
///
/// Copied from [isBiometricAvailable].
@ProviderFor(isBiometricAvailable)
final isBiometricAvailableProvider = AutoDisposeFutureProvider<bool>.internal(
  isBiometricAvailable,
  name: r'isBiometricAvailableProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isBiometricAvailableHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsBiometricAvailableRef = AutoDisposeFutureProviderRef<bool>;
String _$isBiometricEnabledHash() =>
    r'37b1c1b2f3ac7441d831c89f311dd72f05bfdbb3';

/// Provider pour vérifier si la biométrie est activée
///
/// Copied from [isBiometricEnabled].
@ProviderFor(isBiometricEnabled)
final isBiometricEnabledProvider = AutoDisposeFutureProvider<bool>.internal(
  isBiometricEnabled,
  name: r'isBiometricEnabledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isBiometricEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsBiometricEnabledRef = AutoDisposeFutureProviderRef<bool>;
String _$isPinEnabledHash() => r'b599665961e70be8d3a61dfbc5ea0ac95fc2160c';

/// Provider pour vérifier si le PIN est activé
///
/// Copied from [isPinEnabled].
@ProviderFor(isPinEnabled)
final isPinEnabledProvider = AutoDisposeFutureProvider<bool>.internal(
  isPinEnabled,
  name: r'isPinEnabledProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isPinEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsPinEnabledRef = AutoDisposeFutureProviderRef<bool>;
String _$authHash() => r'aa86370bc195062ee57dbc22cf53e629a4963b3c';

/// Provider de l'état d'authentification
///
/// Copied from [Auth].
@ProviderFor(Auth)
final authProvider = AutoDisposeAsyncNotifierProvider<Auth, bool>.internal(
  Auth.new,
  name: r'authProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Auth = AutoDisposeAsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
