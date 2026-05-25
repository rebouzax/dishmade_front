import 'package:dishmade_front/features/sales_history/data/repositories/sales_history_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/pagination/paginated_response.dart';
import '../../domain/entities/sale_history.dart';
import '../datasources/sales_history_remote_datasource.dart';

final salesHistoryRepositoryProvider = Provider<SalesHistoryRepository>((ref) {
  final remoteDataSource = ref.watch(salesHistoryRemoteDataSourceProvider);
  return SalesHistoryRepositoryImpl(remoteDataSource);
});

class SalesHistoryRepositoryImpl implements SalesHistoryRepository {
  final SalesHistoryRemoteDataSource _remoteDataSource;

  const SalesHistoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<PaginatedResponse<SaleHistory>> getSalesHistory({
    DateTime? startDate,
    DateTime? endDate,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final response = await _remoteDataSource.getSalesHistory(
      startDate: startDate,
      endDate: endDate,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    return PaginatedResponse<SaleHistory>(
      items: response.items.map((dto) => dto.toEntity()).toList(),
      pageNumber: response.pageNumber,
      pageSize: response.pageSize,
      totalCount: response.totalCount,
      totalPages: response.totalPages,
      hasPreviousPage: response.hasPreviousPage,
      hasNextPage: response.hasNextPage,
    );
  }
}
