import '../../domain/entities/restaurant_table.dart';

const _unset = Object();

class TablesState {
  final List<RestaurantTable> tables;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSaving;
  final String? errorMessage;

  final int? number;
  final bool? isOccupied;

  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;

  const TablesState({
    this.tables = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSaving = false,
    this.errorMessage,
    this.number,
    this.isOccupied,
    this.pageNumber = 1,
    this.pageSize = 20,
    this.totalCount = 0,
    this.totalPages = 0,
    this.hasNextPage = false,
  });

  TablesState copyWith({
    List<RestaurantTable>? tables,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSaving,
    Object? errorMessage = _unset,
    Object? number = _unset,
    Object? isOccupied = _unset,
    int? pageNumber,
    int? pageSize,
    int? totalCount,
    int? totalPages,
    bool? hasNextPage,
  }) {
    return TablesState(
      tables: tables ?? this.tables,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      number: number == _unset ? this.number : number as int?,
      isOccupied: isOccupied == _unset ? this.isOccupied : isOccupied as bool?,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}
