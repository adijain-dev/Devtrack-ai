import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _tokenKey = 'jwt_token';

/// Provider exposing the [SecureStorageService].
final secureStorageProvider = Provider<SecureStorageService>((_) {
  return SecureStorageService(const FlutterSecureStorage());
});

/// Simple wrapper around [FlutterSecureStorage] for JWT persistence.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  const SecureStorageService(this._storage);

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);
}
