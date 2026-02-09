import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Security Manager for encryption and secure storage
class SecurityManager {
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'budgetease_encryption_key_v4';
  
  /// Initialize encryption on first launch
  static Future<void> initializeEncryption() async {
    String? existingKey = await _storage.read(key: _keyName);
    
    if (existingKey == null) {
      // Generate AES-256 random key
      final key = encrypt.Key.fromSecureRandom(32); // 256 bits
      await _storage.write(key: _keyName, value: key.base64);
      print('🔐 Encryption key generated and stored in Keychain/Keystore');
    } else {
      print('🔐 Encryption key already exists');
    }
  }
  
  /// Get encryption key from secure storage
  static Future<List<int>> getEncryptionKey() async {
    final keyString = await _storage.read(key: _keyName);
    if (keyString == null) {
      throw Exception('Encryption key not found. Call initializeEncryption() first.');
    }
    return encrypt.Key.fromBase64(keyString).bytes;
  }
  
  /// Open Hive box with encryption
  static Future<Box<E>> openSecureBox<E>(String boxName) async {
    // Get encryption key
    final encryptionKey = await getEncryptionKey();
    
    // Open Hive box with encryption
    return await Hive.openBox<E>(
      boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }
  
  /// Delete all secure data (for testing/reset)
  static Future<void> clearSecureStorage() async {
    await _storage.delete(key: _keyName);
    print('🗑️ Secure storage cleared');
  }
}
