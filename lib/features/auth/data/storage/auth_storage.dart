import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/auth_session.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final authStorageProvider = Provider<AuthStorage>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthStorage(storage);
});

class AuthStorage {
  static const _sessionKey = 'dishmade_auth_session';

  final FlutterSecureStorage _storage;

  const AuthStorage(this._storage);

  Future<void> saveSession(AuthSession session) async {
    await _storage.write(key: _sessionKey, value: jsonEncode(session.toJson()));
  }

  Future<AuthSession?> getSession() async {
    final value = await _storage.read(key: _sessionKey);

    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(value) as Map<String, dynamic>;
      final session = AuthSession.fromJson(json);

      if (!session.isValid) {
        await clear();
        return null;
      }

      return session;
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    final session = await getSession();
    return session?.accessToken;
  }

  Future<void> clear() async {
    await _storage.delete(key: _sessionKey);
  }
}
