import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/pagination/paginated_response.dart';
import '../dtos/create_table_request.dart';
import '../dtos/restaurant_table_dto.dart';
import '../dtos/update_table_request.dart';

final tableRemoteDataSourceProvider = Provider<TableRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return TableRemoteDataSourceImpl(dio);
});

abstract interface class TableRemoteDataSource {
  Future<PaginatedResponse<RestaurantTableDto>> getTables({
    int? number,
    bool? isOccupied,
    int pageNumber = 1,
    int pageSize = 20,
  });

  Future<String> createTable(CreateTableRequest request);

  Future<void> updateTable({
    required String id,
    required UpdateTableRequest request,
  });

  Future<void> occupyTable({required String id});

  Future<void> releaseTable({required String id});

  Future<void> deleteTable({required String id});
}

class TableRemoteDataSourceImpl implements TableRemoteDataSource {
  final Dio _dio;

  const TableRemoteDataSourceImpl(this._dio);

  @override
  Future<PaginatedResponse<RestaurantTableDto>> getTables({
    int? number,
    bool? isOccupied,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.tables,
        queryParameters: {
          if (number != null) 'number': number,
          if (isOccupied != null) 'isOccupied': isOccupied,
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      return PaginatedResponse.fromJson(
        response.data ?? <String, dynamic>{},
        RestaurantTableDto.fromJson,
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<String> createTable(CreateTableRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.tables,
        data: request.toJson(),
      );

      return response.data?['id']?.toString() ?? '';
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<void> updateTable({
    required String id,
    required UpdateTableRequest request,
  }) async {
    try {
      await _dio.put<void>(ApiEndpoints.tableById(id), data: request.toJson());
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<void> occupyTable({required String id}) async {
    try {
      await _dio.patch<void>(ApiEndpoints.occupyTable(id));
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<void> releaseTable({required String id}) async {
    try {
      await _dio.patch<void>(ApiEndpoints.releaseTable(id));
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<void> deleteTable({required String id}) async {
    try {
      await _dio.delete<void>(ApiEndpoints.tableById(id));
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
