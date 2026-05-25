import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/usecases/get_dashboard_usecase.dart';
import 'dashboard_state.dart';

final getDashboardUseCaseProvider = Provider<GetDashboardUseCase>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return GetDashboardUseCase(repository);
});

final dashboardViewModelProvider =
    NotifierProvider.autoDispose<DashboardViewModel, DashboardState>(
      DashboardViewModel.new,
    );

class DashboardViewModel extends Notifier<DashboardState> {
  late final GetDashboardUseCase _getDashboardUseCase;

  @override
  DashboardState build() {
    _getDashboardUseCase = ref.watch(getDashboardUseCaseProvider);

    final now = DateTime.now();
    final initialState = DashboardState(
      startDate: DateTime(now.year, now.month, 1),
      endDate: now,
    );

    Future.microtask(loadInitial);

    return initialState;
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _getDashboardUseCase(
        startDate: state.startDate,
        endDate: state.endDate,
      );

      if (!ref.mounted) return;

      state = state.copyWith(
        summary: response,
        isLoading: false,
        lastUpdatedAt: DateTime.now(),
      );
    } catch (error) {
      if (!ref.mounted) return;

      state = state.copyWith(isLoading: false, errorMessage: _mapError(error));
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  Future<void> setDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = state.copyWith(startDate: startDate, endDate: endDate);

    await loadInitial();
  }

  Future<void> clearDateRange() async {
    state = state.copyWith(startDate: null, endDate: null);

    await loadInitial();
  }

  Future<void> setCurrentMonth() async {
    final now = DateTime.now();

    state = state.copyWith(
      startDate: DateTime(now.year, now.month, 1),
      endDate: now,
    );

    await loadInitial();
  }

  String _mapError(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Não foi possível carregar o dashboard.';
  }
}
