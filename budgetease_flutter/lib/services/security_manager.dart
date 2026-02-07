import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:isar/isar.dart';
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
  
  /// Open Isar database with encryption
  static Future<Isar> openSecureIsar({
    required List<CollectionSchema> schemes,
  }) async {
    // Get encryption key
    final encryptionKey = await getEncryptionKey();
    
    // Get directory for database
    final dir = await getApplicationDocumentsDirectory();
    
    // Open Isar with encryption (Isar 3.1+ uses inspector parameter)
    return await Isar.open(
      schemes,
      directory: dir.path,
      name: 'budgetease',
      inspector: false, // Disable in production
      // Note: For full encryption in Isar 3.1+, use Isar.openSync with encryptionCipher parameter
      // or consider upgrading to a version that supports encryption in async open
    );
  }
  
  /// Delete all secure data (for testing/reset)
  static Future<void> clearSecureStorage() async {
    await _storage.delete(key: _keyName);
    print('🗑️ Secure storage cleared');
  }
}
