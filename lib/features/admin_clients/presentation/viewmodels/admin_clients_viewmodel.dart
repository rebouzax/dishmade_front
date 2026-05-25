import 'package:dishmade_front/core/errors/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/admin_clients_repository_impl.dart';
import '../../domain/usecases/create_admin_client_usecase.dart';
import '../../domain/usecases/get_admin_clients_usecase.dart';
import 'admin_clients_state.dart';

final getAdminClientsUseCaseProvider = Provider<GetAdminClientsUseCase>((ref) {
  final repository = ref.watch(adminClientsRepositoryProvider);
  return GetAdminClientsUseCase(repository);
});

final createAdminClientUseCaseProvider = Provider<CreateAdminClientUseCase>((
  ref,
) {
  final repository = ref.watch(adminClientsRepositoryProvider);
  return CreateAdminClientUseCase(repository);
});

final adminClientsViewModelProvider =
    NotifierProvider.autoDispose<AdminClientsViewModel, AdminClientsState>(
      AdminClientsViewModel.new,
    );

class AdminClientsViewModel extends Notifier<AdminClientsState> {
  late final GetAdminClientsUseCase _getClientsUseCase;
  late final CreateAdminClientUseCase _createClientUseCase;

  @override
  AdminClientsState build() {
    _getClientsUseCase = ref.watch(getAdminClientsUseCaseProvider);
    _createClientUseCase = ref.watch(createAdminClientUseCaseProvider);

    Future.microtask(loadInitial);

    return const AdminClientsState();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      pageNumber: 1,
      hasNextPage: false,
    );

    try {
      final response = await _getClientsUseCase(
        search: state.search,
        isActive: state.isActive,
        pageNumber: 1,
        pageSize: state.pageSize,
      );

      if (!ref.mounted) return;

      state = state.copyWith(
        clients: response.items,
        isLoading: false,
        pageNumber: response.pageNumber,
        totalCount: response.totalCount,
        totalPages: response.totalPages,
        hasNextPage: response.hasNextPage,
      );
    } catch (error) {
      if (!ref.mounted) return;

      state = state.copyWith(isLoading: false, errorMessage: _mapError(error));
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasNextPage) {
      return;
    }

    final nextPage = state.pageNumber + 1;

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      final response = await _getClientsUseCase(
        search: state.search,
        isActive: state.isActive,
        pageNumber: nextPage,
        pageSize: state.pageSize,
      );

      if (!ref.mounted) return;

      state = state.copyWith(
        clients: [...state.clients, ...response.items],
        isLoadingMore: false,
        pageNumber: response.pageNumber,
        totalCount: response.totalCount,
        totalPages: response.totalPages,
        hasNextPage: response.hasNextPage,
      );
    } catch (error) {
      if (!ref.mounted) return;

      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: _mapError(error),
      );
    }
  }

  Future<void> setSearch(String value) async {
    state = state.copyWith(search: value.trim());
    await loadInitial();
  }

  Future<void> setActiveFilter(bool? value) async {
    state = state.copyWith(isActive: value);
    await loadInitial();
  }

  Future<bool> createClient({
    required String restaurantName,
    String? restaurantDocument,
    required String userName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _createClientUseCase(
        restaurantName: restaurantName.trim(),
        restaurantDocument: restaurantDocument?.trim(),
        userName: userName.trim(),
        email: email.trim(),
        password: password,
      );

      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false);
      await loadInitial();

      return true;
    } catch (error) {
      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false, errorMessage: _mapError(error));

      return false;
    }
  }

  String _mapError(Object error) {
    if (error is ApiException) {
      if (error.statusCode == 403) {
        return 'Você não tem permissão para acessar este recurso.';
      }

      return error.message;
    }

    return 'Não foi possível processar os clientes.';
  }
}
