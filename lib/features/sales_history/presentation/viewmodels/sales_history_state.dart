import '../../domain/entities/sale_history.dart';

const _unset = Object();

class SalesHistoryState {
  final List<SaleHistory> sales;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  final DateTime? startDate;
  final DateTime? endDate;

  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;

  const SalesHistoryState({
    this.sales = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.startDate,
    this.endDate,
    this.pageNumber = 1,
    this.pageSize = 20,
    this.totalCount = 0,
    this.totalPages = 0,
    this.hasNextPage = false,
  });

  double get loadedRevenue {
    return sales.fold<double>(0, (sum, sale) => sum + sale.total);
  }

  int get loadedItemsSold {
    return sales.fold<int>(0, (sum, sale) => sum + sale.totalItems);
  }

  double get loadedAverageTicket {
    if (sales.isEmpty) return 0;
    return loadedRevenue / sales.length;
  }

  SalesHistoryState copyWith({
    List<SaleHistory>? sales,
    bool? isLoading,
    bool? isLoadingMore,
    Object? errorMessage = _unset,
    Object? startDate = _unset,
    Object? endDate = _unset,
    int? pageNumber,
    int? pageSize,
    int? totalCount,
    int? totalPages,
    bool? hasNextPage,
  }) {
    return SalesHistoryState(
      sales: sales ?? this.sales,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      startDate: startDate == _unset ? this.startDate : startDate as DateTime?,
      endDate: endDate == _unset ? this.endDate : endDate as DateTime?,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}
