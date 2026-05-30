import '../../domain/entities/dish.dart';

const _unset = Object();

class DishesState {
  final List<Dish> dishes;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSaving;
  final String? errorMessage;

  final String search;
  final String? categoryId;
  final bool? isAvailable;

  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;

  const DishesState({
    this.dishes = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.search = '',
    this.categoryId,
    this.isAvailable = true,
    this.pageNumber = 1,
    this.pageSize = 20,
    this.totalCount = 0,
    this.totalPages = 0,
    this.hasNextPage = false,
    this.isSaving = false,
  });

  DishesState copyWith({
    List<Dish>? dishes,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSaving,
    Object? errorMessage = _unset,
    String? search,
    Object? categoryId = _unset,
    Object? isAvailable = _unset,
    int? pageNumber,
    int? pageSize,
    int? totalCount,
    int? totalPages,
    bool? hasNextPage,
  }) {
    return DishesState(
      dishes: dishes ?? this.dishes,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      search: search ?? this.search,
      categoryId: categoryId == _unset
          ? this.categoryId
          : categoryId as String?,
      isAvailable: isAvailable == _unset
          ? this.isAvailable
          : isAvailable as bool?,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
