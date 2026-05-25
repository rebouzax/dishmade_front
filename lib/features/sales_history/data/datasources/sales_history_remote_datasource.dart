import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/pagination/paginated_response.dart';
import '../dtos/sale_history_dto.dart';

final salesHistoryRemoteDataSourceProvider =
    Provider<SalesHistoryRemoteDataSource>((ref) {
      final dio = ref.watch(dioProvider);
      return SalesHistoryRemoteDataSourceImpl(dio);
    });

abstract interface class SalesHistoryRemoteDataSource {
  Future<PaginatedResponse<SaleHistoryDto>> getSalesHistory({
    DateTime? startDate,
    DateTime? endDate,
    int pageNumber = 1,
    int pageSize = 20,
  });
}

class SalesHistoryRemoteDataSourceImpl implements SalesHistoryRemoteDataSource {
  final Dio _dio;

  const SalesHistoryRemoteDataSourceImpl(this._dio);

  @override
  Future<PaginatedResponse<SaleHistoryDto>> getSalesHistory({
    DateTime? startDate,
    DateTime? endDate,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.salesHistory,
        queryParameters: {
          if (startDate != null) 'startDate': _formatDate(startDate),
          if (endDate != null) 'endDate': _formatDate(endDate),
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      return PaginatedResponse.fromJson(
        response.data ?? <String, dynamic>{},
        SaleHistoryDto.fromJson,
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
