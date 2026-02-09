import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service de gestion de la sécurité et de l'authentification
class SecurityService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  static const String _pinKey = 'user_pin_hash';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _pinEnabledKey = 'pin_enabled';
  static const String _lastAuthKey = 'last_auth_timestamp';
  
  // Durée d'inactivité avant verrouillage (en secondes)
  static const int inactivityLockDuration = 60;

  // ========== Biométrie ==========

  /// Vérifier si la biométrie est disponible sur l'appareil
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Obtenir les types de biométrie disponibles
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authentifier avec la biométrie
  Future<bool> authenticateWithBiometric({
    String reason = 'Déverrouillez BudgetEase',
  }) async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      if (authenticated) {
        await _updateLastAuthTimestamp();
      }

      return authenticated;
    } catch (e) {
      return false;
    }
  }

  /// Activer la biométrie
  Future<void> enableBiometric() async {
    await _storage.write(key: _biometricEnabledKey, value: 'true');
  }

  /// Désactiver la biométrie
  Future<void> disableBiometric() async {
    await _storage.write(key: _biometricEnabledKey, value: 'false');
  }

  /// Vérifier si la biométrie est activée
  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  // ========== PIN ==========

  /// Définir un nouveau PIN
  Future<void> setPin(String pin) async {
    if (pin.length < 4 || pin.length > 6) {
      throw Exception('Le PIN doit contenir entre 4 et 6 chiffres');
    }

    final hashedPin = _hashPin(pin);
    await _storage.write(key: _pinKey, value: hashedPin);
    await _storage.write(key: _pinEnabledKey, value: 'true');
  }

  /// Vérifier un PIN
  Future<bool> verifyPin(String pin) async {
    final storedHash = await _storage.read(key: _pinKey);
    if (storedHash == null) return false;

    final hashedPin = _hashPin(pin);
    final isValid = hashedPin == storedHash;

    if (isValid) {
      await _updateLastAuthTimestamp();
    }

    return isValid;
  }

  /// Supprimer le PIN
  Future<void> removePin() async {
    await _storage.delete(key: _pinKey);
    await _storage.write(key: _pinEnabledKey, value: 'false');
  }

  /// Vérifier si un PIN est défini
  Future<bool> isPinSet() async {
    final pin = await _storage.read(key: _pinKey);
    return pin != null;
  }

  /// Vérifier si le PIN est activé
  Future<bool> isPinEnabled() async {
    final value = await _storage.read(key: _pinEnabledKey);
    return value == 'true';
  }

  /// Hasher le PIN avec SHA-256
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ========== Gestion des Sessions ==========

  /// Mettre à jour le timestamp de la dernière authentification
  Future<void> _updateLastAuthTimestamp() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.write(key: _lastAuthKey, value: timestamp);
  }

  /// Obtenir le timestamp de la dernière authentification
  Future<DateTime?> getLastAuthTimestamp() async {
    final value = await _storage.read(key: _lastAuthKey);
    if (value == null) return null;

    final timestamp = int.tryParse(value);
    if (timestamp == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Vérifier si l'application doit être verrouillée
  Future<bool> shouldLock() async {
    final lastAuth = await getLastAuthTimestamp();
    if (lastAuth == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastAuth).inSeconds;

    return difference > inactivityLockDuration;
  }

  /// Déconnecter (effacer le timestamp)
  Future<void> logout() async {
    await _storage.delete(key: _lastAuthKey);
  }

  // ========== Configuration Globale ==========

  /// Vérifier si une méthode de sécurité est configurée
  Future<bool> isSecurityConfigured() async {
    final biometricEnabled = await isBiometricEnabled();
    final pinEnabled = await isPinEnabled();
    return biometricEnabled || pinEnabled;
  }

  /// Obtenir la méthode de sécurité préférée
  Future<SecurityMethod> getPreferredSecurityMethod() async {
    final biometricEnabled = await isBiometricEnabled();
    final biometricAvailable = await isBiometricAvailable();

    if (biometricEnabled && biometricAvailable) {
      return SecurityMethod.biometric;
    }

    final pinEnabled = await isPinEnabled();
    if (pinEnabled) {
      return SecurityMethod.pin;
    }

    return SecurityMethod.none;
  }

  /// Authentifier avec la méthode préférée
  Future<bool> authenticate() async {
    final method = await getPreferredSecurityMethod();

    switch (method) {
      case SecurityMethod.biometric:
        return await authenticateWithBiometric();
      case SecurityMethod.pin:
        // Le PIN est géré par l'UI
        return false;
      case SecurityMethod.none:
        return true;
    }
  }
}

/// Méthodes de sécurité disponibles
enum SecurityMethod {
  biometric,
  pin,
  none,
}
