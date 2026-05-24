import 'package:dishmade_front/core/errors/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/dish_repository_impl.dart';
import '../../domain/usecases/get_dishes_usecase.dart';
import 'dishes_state.dart';

final getDishesUseCaseProvider = Provider<GetDishesUseCase>((ref) {
  final repository = ref.watch(dishRepositoryProvider);
  return GetDishesUseCase(repository);
});

final dishesViewModelProvider =
    NotifierProvider.autoDispose<DishesViewModel, DishesState>(
      DishesViewModel.new,
    );

class DishesViewModel extends Notifier<DishesState> {
  late final GetDishesUseCase _getDishesUseCase;

  @override
  DishesState build() {
    _getDishesUseCase = ref.watch(getDishesUseCaseProvider);

    Future.microtask(loadInitial);

    return const DishesState();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      pageNumber: 1,
      hasNextPage: false,
    );

    try {
      final response = await _getDishesUseCase(
        search: state.search,
        categoryId: state.categoryId,
        isAvailable: state.isAvailable,
        pageNumber: 1,
        pageSize: state.pageSize,
      );

      if (!ref.mounted) return;

      state = state.copyWith(
        dishes: response.items,
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
      final response = await _getDishesUseCase(
        search: state.search,
        categoryId: state.categoryId,
        isAvailable: state.isAvailable,
        pageNumber: nextPage,
        pageSize: state.pageSize,
      );

      if (!ref.mounted) return;

      state = state.copyWith(
        dishes: [...state.dishes, ...response.items],
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

  Future<void> setCategory(String? categoryId) async {
    state = state.copyWith(categoryId: categoryId);
    await loadInitial();
  }

  Future<void> setAvailability(bool? isAvailable) async {
    state = state.copyWith(isAvailable: isAvailable);
    await loadInitial();
  }

  String _mapError(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Não foi possível carregar os pratos.';
  }
}
