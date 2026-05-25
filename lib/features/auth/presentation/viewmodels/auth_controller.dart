import 'package:dishmade_front/core/errors/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/restore_session_usecase.dart';
import 'auth_state.dart';

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final restoreSessionUseCaseProvider = Provider<RestoreSessionUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RestoreSessionUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  late final LoginUseCase _loginUseCase;
  late final RestoreSessionUseCase _restoreSessionUseCase;
  late final LogoutUseCase _logoutUseCase;

  @override
  AuthState build() {
    _loginUseCase = ref.watch(loginUseCaseProvider);
    _restoreSessionUseCase = ref.watch(restoreSessionUseCaseProvider);
    _logoutUseCase = ref.watch(logoutUseCaseProvider);

    Future.microtask(restoreSession);

    return const AuthState(isLoading: true);
  }

  Future<void> restoreSession() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = await _restoreSessionUseCase();

      if (!ref.mounted) return;

      state = AuthState(session: session, isLoading: false);
    } catch (_) {
      if (!ref.mounted) return;

      state = const AuthState(session: null, isLoading: false);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = await _loginUseCase(
        email: email.trim(),
        password: password,
      );

      if (!ref.mounted) return false;

      state = AuthState(session: session, isLoading: false);

      return true;
    } catch (error) {
      if (!ref.mounted) return false;

      state = AuthState(
        session: null,
        isLoading: false,
        errorMessage: _mapError(error),
      );

      return false;
    }
  }

  Future<void> logout() async {
    await _logoutUseCase();

    if (!ref.mounted) return;

    state = const AuthState(session: null, isLoading: false);
  }

  String _mapError(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Não foi possível realizar login.';
  }
}
