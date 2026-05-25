import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/dish_category.dart';
import '../../domain/usecases/get_categories_usecase.dart';

final activeCategoriesProvider = FutureProvider.autoDispose<List<DishCategory>>(
  (ref) async {
    final repository = ref.watch(categoryRepositoryProvider);
    final response = await GetCategoriesUseCase(repository)(
      isActive: true,
      pageNumber: 1,
      pageSize: 100,
    );

    return response.items;
  },
);

const _unset = Object();

class CategoriesState {
  final List<DishCategory> categories;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSaving;
  final String? errorMessage;

  final String search;
  final bool? isActive;

  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;

  const CategoriesState({
    this.categories = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSaving = false,
    this.errorMessage,
    this.search = '',
    this.isActive = true,
    this.pageNumber = 1,
    this.pageSize = 20,
    this.totalCount = 0,
    this.totalPages = 0,
    this.hasNextPage = false,
  });

  CategoriesState copyWith({
    List<DishCategory>? categories,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSaving,
    Object? errorMessage = _unset,
    String? search,
    Object? isActive = _unset,
    int? pageNumber,
    int? pageSize,
    int? totalCount,
    int? totalPages,
    bool? hasNextPage,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      search: search ?? this.search,
      isActive: isActive == _unset ? this.isActive : isActive as bool?,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}
