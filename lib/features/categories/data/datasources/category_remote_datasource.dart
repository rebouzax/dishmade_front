import 'package:dio/dio.dart';
import 'package:dishmade_front/core/errors/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/pagination/paginated_response.dart';
import '../dtos/category_dto.dart';
import '../dtos/create_category_request.dart';

final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return CategoryRemoteDataSourceImpl(dio);
});

abstract interface class CategoryRemoteDataSource {
  Future<PaginatedResponse<CategoryDto>> getCategories({
    String? search,
    bool? isActive,
    int pageNumber = 1,
    int pageSize = 20,
  });

  Future<String> createCategory(CreateCategoryRequest request);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final Dio _dio;

  const CategoryRemoteDataSourceImpl(this._dio);

  @override
  Future<PaginatedResponse<CategoryDto>> getCategories({
    String? search,
    bool? isActive,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.categories,
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
        CategoryDto.fromJson,
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<String> createCategory(CreateCategoryRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.categories,
        data: request.toJson(),
      );

      return response.data?['id']?.toString() ?? '';
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
