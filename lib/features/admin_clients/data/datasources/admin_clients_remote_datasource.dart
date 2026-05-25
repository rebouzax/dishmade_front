import 'package:dio/dio.dart';
import 'package:dishmade_front/core/errors/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/pagination/paginated_response.dart';
import '../dtos/admin_client_dto.dart';
import '../dtos/create_admin_client_request.dart';

final adminClientsRemoteDataSourceProvider =
    Provider<AdminClientsRemoteDataSource>((ref) {
      final dio = ref.watch(dioProvider);
      return AdminClientsRemoteDataSourceImpl(dio);
    });

abstract interface class AdminClientsRemoteDataSource {
  Future<PaginatedResponse<AdminClientDto>> getClients({
    String? search,
    bool? isActive,
    int pageNumber = 1,
    int pageSize = 20,
  });

  Future<String> createClient(CreateAdminClientRequest request);
}

class AdminClientsRemoteDataSourceImpl implements AdminClientsRemoteDataSource {
  final Dio _dio;

  const AdminClientsRemoteDataSourceImpl(this._dio);

  @override
  Future<PaginatedResponse<AdminClientDto>> getClients({
    String? search,
    bool? isActive,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.adminClients,
        queryParameters: {
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
          if (isActive != null) 'isActive': isActive,
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      return PaginatedResponse.fromJson(
        response.data ?? <String, dynamic>{},
        AdminClientDto.fromJson,
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<String> createClient(CreateAdminClientRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.adminClients,
        data: request.toJson(),
      );

      return response.data?['id']?.toString() ?? '';
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
