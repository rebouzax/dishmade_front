import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/public_order_session.dart';

final publicOrderSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final publicOrderStorageProvider = Provider<PublicOrderStorage>((ref) {
  final storage = ref.watch(publicOrderSecureStorageProvider);
  return PublicOrderStorage(storage);
});

class PublicOrderStorage {
  final FlutterSecureStorage _storage;

  const PublicOrderStorage(this._storage);

  String _key(String slug) => 'dishmade_public_order_$slug';

  Future<void> saveSession(PublicOrderSession session) async {
    await _storage.write(
      key: _key(session.restaurantSlug),
      value: jsonEncode(session.toJson()),
    );
  }

  Future<PublicOrderSession?> getSession(String slug) async {
    final value = await _storage.read(key: _key(slug));

    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(value) as Map<String, dynamic>;
      return PublicOrderSession.fromJson(json);
    } catch (_) {
      await clearSession(slug);
      return null;
    }
  }

  Future<void> clearSession(String slug) async {
    await _storage.delete(key: _key(slug));
  }
}
