import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_provider.dart';
import '../dtos/dashboard_summary_dto.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return DashboardRemoteDataSourceImpl(dio);
});

abstract interface class DashboardRemoteDataSource {
  Future<DashboardSummaryDto> getDashboard({
    DateTime? startDate,
    DateTime? endDate,
  });
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio _dio;

  const DashboardRemoteDataSourceImpl(this._dio);

  @override
  Future<DashboardSummaryDto> getDashboard({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.dashboard,
        queryParameters: {
          if (startDate != null) 'startDate': _formatDate(startDate),
          if (endDate != null) 'endDate': _formatDate(endDate),
        },
      );

      return DashboardSummaryDto.fromJson(response.data ?? <String, dynamic>{});
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
