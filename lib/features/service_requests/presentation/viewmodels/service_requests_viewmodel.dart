import 'package:dishmade_front/core/errors/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/service_request_repository_impl.dart';
import '../../domain/entities/service_request.dart';
import '../../domain/enums/service_request_status.dart';
import '../../domain/enums/service_request_type.dart';
import '../../domain/usecases/cancel_service_request_usecase.dart';
import '../../domain/usecases/get_service_requests_usecase.dart';
import '../../domain/usecases/resolve_service_request_usecase.dart';
import '../../domain/usecases/start_service_request_usecase.dart';
import 'service_requests_state.dart';

final getServiceRequestsUseCaseProvider = Provider<GetServiceRequestsUseCase>((
  ref,
) {
  final repository = ref.watch(serviceRequestRepositoryProvider);
  return GetServiceRequestsUseCase(repository);
});

final startServiceRequestUseCaseProvider = Provider<StartServiceRequestUseCase>(
  (ref) {
    final repository = ref.watch(serviceRequestRepositoryProvider);
    return StartServiceRequestUseCase(repository);
  },
);

final resolveServiceRequestUseCaseProvider =
    Provider<ResolveServiceRequestUseCase>((ref) {
      final repository = ref.watch(serviceRequestRepositoryProvider);
      return ResolveServiceRequestUseCase(repository);
    });

final cancelServiceRequestUseCaseProvider =
    Provider<CancelServiceRequestUseCase>((ref) {
      final repository = ref.watch(serviceRequestRepositoryProvider);
      return CancelServiceRequestUseCase(repository);
    });

final serviceRequestsViewModelProvider =
    NotifierProvider.autoDispose<
      ServiceRequestsViewModel,
      ServiceRequestsState
    >(ServiceRequestsViewModel.new);

class ServiceRequestsViewModel extends Notifier<ServiceRequestsState> {
  late final GetServiceRequestsUseCase _getUseCase;
  late final StartServiceRequestUseCase _startUseCase;
  late final ResolveServiceRequestUseCase _resolveUseCase;
  late final CancelServiceRequestUseCase _cancelUseCase;

  @override
  ServiceRequestsState build() {
    _getUseCase = ref.watch(getServiceRequestsUseCaseProvider);
    _startUseCase = ref.watch(startServiceRequestUseCaseProvider);
    _resolveUseCase = ref.watch(resolveServiceRequestUseCaseProvider);
    _cancelUseCase = ref.watch(cancelServiceRequestUseCaseProvider);

    return const ServiceRequestsState();
  }

  Future<void> loadInitial() {
    state = state.copyWith(pageNumber: 1);
    return _load(append: false);
  }

  Future<void> loadNextPage() async {
    if (!state.hasNextPage || state.isLoading) return;

    state = state.copyWith(pageNumber: state.pageNumber + 1);
    await _load(append: true);
  }

  Future<void> setStatusFilter(ServiceRequestStatus? status) async {
    state = state.copyWith(statusFilter: status, pageNumber: 1);

    await _load(append: false);
  }

  Future<void> setTypeFilter(ServiceRequestType? type) async {
    state = state.copyWith(typeFilter: type, pageNumber: 1);

    await _load(append: false);
  }

  Future<void> _load({required bool append}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final page = await _getUseCase(
        status: state.statusFilter,
        type: state.typeFilter,
        pageNumber: state.pageNumber,
        pageSize: state.pageSize,
      );

      if (!ref.mounted) return;

      state = state.copyWith(
        requests: append ? [...state.requests, ...page.items] : page.items,
        totalCount: page.totalCount,
        isLoading: false,
      );
    } catch (error) {
      if (!ref.mounted) return;

      state = state.copyWith(isLoading: false, errorMessage: _mapError(error));
    }
  }

  Future<bool> start(String id) {
    return _changeStatus(() => _startUseCase(id: id));
  }

  Future<bool> resolve(String id) {
    return _changeStatus(() => _resolveUseCase(id: id));
  }

  Future<bool> cancel(String id) {
    return _changeStatus(() => _cancelUseCase(id: id));
  }

  Future<bool> _changeStatus(Future<ServiceRequest> Function() action) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await action();

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
      return error.message;
    }

    return 'Não foi possível carregar as solicitações.';
  }
}
