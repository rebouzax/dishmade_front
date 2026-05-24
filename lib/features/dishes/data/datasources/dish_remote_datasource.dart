import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/pagination/paginated_response.dart';
import '../dtos/create_dish_request.dart';
import '../dtos/dish_dto.dart';
import '../dtos/update_dish_request.dart';

final dishRemoteDataSourceProvider = Provider<DishRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return DishRemoteDataSourceImpl(dio);
});

abstract interface class DishRemoteDataSource {
  Future<PaginatedResponse<DishDto>> getDishes({
    String? search,
    String? categoryId,
    bool? isAvailable,
    int pageNumber = 1,
    int pageSize = 20,
  });

  Future<String> createDish(CreateDishRequest request);

  Future<void> updateDish({
    required String id,
    required UpdateDishRequest request,
  });
}

class DishRemoteDataSourceImpl implements DishRemoteDataSource {
  final Dio _dio;

  const DishRemoteDataSourceImpl(this._dio);

  @override
  Future<PaginatedResponse<DishDto>> getDishes({
    String? search,
    String? categoryId,
    bool? isAvailable,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.dishes,
        queryParameters: {
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
          if (categoryId != null && categoryId.trim().isNotEmpty)
            'categoryId': categoryId,
          if (isAvailable != null) 'isAvailable': isAvailable,
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      return PaginatedResponse.fromJson(
        response.data ?? <String, dynamic>{},
        DishDto.fromJson,
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<String> createDish(CreateDishRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.dishes,
        data: request.toJson(),
      );

      return response.data?['id']?.toString() ?? '';
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<void> updateDish({
    required String id,
    required UpdateDishRequest request,
  }) async {
    try {
      await _dio.put<void>(ApiEndpoints.dishById(id), data: request.toJson());
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
