import 'package:dishmade_front/core/errors/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/category_repository_impl.dart';
import '../../domain/usecases/create_category_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import 'categories_provider.dart';

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return GetCategoriesUseCase(repository);
});

final createCategoryUseCaseProvider = Provider<CreateCategoryUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return CreateCategoryUseCase(repository);
});

final categoriesViewModelProvider =
    NotifierProvider.autoDispose<CategoriesViewModel, CategoriesState>(
      CategoriesViewModel.new,
    );

class CategoriesViewModel extends Notifier<CategoriesState> {
  late final GetCategoriesUseCase _getCategoriesUseCase;
  late final CreateCategoryUseCase _createCategoryUseCase;

  @override
  CategoriesState build() {
    _getCategoriesUseCase = ref.watch(getCategoriesUseCaseProvider);
    _createCategoryUseCase = ref.watch(createCategoryUseCaseProvider);

    Future.microtask(loadInitial);

    return const CategoriesState();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      pageNumber: 1,
      hasNextPage: false,
    );

    try {
      final response = await _getCategoriesUseCase(
        search: state.search,
        isActive: state.isActive,
        pageNumber: 1,
        pageSize: state.pageSize,
      );

      if (!ref.mounted) return;

      state = state.copyWith(
        categories: response.items,
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
      final response = await _getCategoriesUseCase(
        search: state.search,
        isActive: state.isActive,
        pageNumber: nextPage,
        pageSize: state.pageSize,
      );

      if (!ref.mounted) return;

      state = state.copyWith(
        categories: [...state.categories, ...response.items],
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

  Future<bool> createCategory({
    required String name,
    String? description,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _createCategoryUseCase(
        name: name.trim(),
        description: description?.trim(),
      );

      if (!ref.mounted) return false;

      ref.invalidate(activeCategoriesProvider);

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

    return 'Não foi possível processar a categoria.';
  }
}
