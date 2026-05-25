import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../dtos/login_request_dto.dart';
import '../storage/auth_storage.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final authStorage = ref.watch(authStorageProvider);

  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    authStorage: authStorage,
  );
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthStorage _authStorage;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthStorage authStorage,
  }) : _remoteDataSource = remoteDataSource,
       _authStorage = authStorage;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(
      LoginRequestDto(email: email, password: password),
    );

    final session = response.toEntity();

    await _authStorage.saveSession(session);

    return session;
  }

  @override
  Future<AuthSession?> restoreSession() {
    return _authStorage.getSession();
  }

  @override
  Future<void> logout() {
    return _authStorage.clear();
  }
}
