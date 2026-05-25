import 'package:dishmade_front/features/sales_history/domain/usescases/get_sales_history_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/sales_history_repository_impl.dart';
import 'sales_history_state.dart';

final getSalesHistoryUseCaseProvider = Provider<GetSalesHistoryUseCase>((ref) {
  final repository = ref.watch(salesHistoryRepositoryProvider);
  return GetSalesHistoryUseCase(repository);
});

final salesHistoryViewModelProvider =
    NotifierProvider.autoDispose<SalesHistoryViewModel, SalesHistoryState>(
      SalesHistoryViewModel.new,
    );

class SalesHistoryViewModel extends Notifier<SalesHistoryState> {
  late final GetSalesHistoryUseCase _getSalesHistoryUseCase;

  @override
  SalesHistoryState build() {
    _getSalesHistoryUseCase = ref.watch(getSalesHistoryUseCaseProvider);

    Future.microtask(loadInitial);

    return const SalesHistoryState();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      pageNumber: 1,
      hasNextPage: false,
    );

    try {
      final response = await _getSalesHistoryUseCase(
        startDate: state.startDate,
        endDate: state.endDate,
        pageNumber: 1,
        pageSize: state.pageSize,
      );

      if (!ref.mounted) return;

      state = state.copyWith(
        sales: response.items,
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
      final response = await _getSalesHistoryUseCase(
        startDate: state.startDate,
        endDate: state.endDate,
        pageNumber: nextPage,
        pageSize: state.pageSize,
      );

      if (!ref.mounted) return;

      state = state.copyWith(
        sales: [...state.sales, ...response.items],
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

  String _mapError(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Não foi possível carregar o histórico de vendas.';
  }
}
