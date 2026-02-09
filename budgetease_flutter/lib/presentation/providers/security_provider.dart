import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/services/security_service.dart';

part 'security_provider.g.dart';

/// Provider du service de sécurité
@riverpod
SecurityService securityService(SecurityServiceRef ref) {
  return SecurityService();
}

/// Provider de l'état d'authentification
@riverpod
class Auth extends _$Auth {
  @override
  Future<bool> build() async {
    final securityService = ref.read(securityServiceProvider);
    
    // Vérifier si l'utilisateur est authentifié
    final shouldLock = await securityService.shouldLock();
    return !shouldLock;
  }

  /// Authentifier l'utilisateur
  Future<bool> authenticate() async {
    final securityService = ref.read(securityServiceProvider);
    
    // Essayer la biométrie d'abord
    final biometricEnabled = await securityService.isBiometricEnabled();
    final biometricAvailable = await securityService.isBiometricAvailable();
    
    if (biometricEnabled && biometricAvailable) {
      final authenticated = await securityService.authenticateWithBiometric();
      if (authenticated) {
        state = const AsyncValue.data(true);
        return true;
      }
    }
    
    // Sinon, demander le PIN (géré par l'UI)
    return false;
  }

  /// Déconnecter l'utilisateur
  Future<void> logout() async {
    final securityService = ref.read(securityServiceProvider);
    await securityService.logout();
    state = const AsyncValue.data(false);
  }

  /// Marquer comme authentifié (après vérification du PIN)
  void markAsAuthenticated() {
    state = const AsyncValue.data(true);
  }

  /// Vérifier si une méthode de sécurité est configurée
  Future<bool> isSecurityConfigured() async {
    final securityService = ref.read(securityServiceProvider);
    return await securityService.isSecurityConfigured();
  }
}

/// Provider pour vérifier si la biométrie est disponible
@riverpod
Future<bool> isBiometricAvailable(IsBiometricAvailableRef ref) async {
  final securityService = ref.read(securityServiceProvider);
  return await securityService.isBiometricAvailable();
}

/// Provider pour vérifier si la biométrie est activée
@riverpod
Future<bool> isBiometricEnabled(IsBiometricEnabledRef ref) async {
  final securityService = ref.read(securityServiceProvider);
  return await securityService.isBiometricEnabled();
}

/// Provider pour vérifier si le PIN est activé
@riverpod
Future<bool> isPinEnabled(IsPinEnabledRef ref) async {
  final securityService = ref.read(securityServiceProvider);
  return await securityService.isPinEnabled();
}
