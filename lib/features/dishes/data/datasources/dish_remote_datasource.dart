import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/pagination/paginated_response.dart';
import '../dtos/create_dish_option_group_request.dart';
import '../dtos/create_dish_option_request.dart';
import '../dtos/create_dish_request.dart';
import '../dtos/dish_dto.dart';
import '../dtos/dish_option_dto.dart';
import '../dtos/dish_option_group_dto.dart';
import '../dtos/update_dish_option_group_request.dart';
import '../dtos/update_dish_option_request.dart';
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

  Future<void> uploadDishImage({
    required String dishId,
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  });

  Future<Uint8List> getDishImageBytes({required String dishId});

  Future<void> deleteDishImage({required String dishId});

  Future<List<DishOptionGroupDto>> getOptionGroups({required String dishId});

  Future<DishOptionGroupDto> createOptionGroup({
    required String dishId,
    required CreateDishOptionGroupRequest request,
  });

  Future<DishOptionDto> createOption({
    required String dishId,
    required String optionGroupId,
    required CreateDishOptionRequest request,
  });

  Future<DishOptionGroupDto> updateOptionGroup({
    required String dishId,
    required String groupId,
    required UpdateDishOptionGroupRequest request,
  });

  Future<void> deleteOptionGroup({
    required String dishId,
    required String groupId,
  });

  Future<DishOptionDto> updateOption({
    required String dishId,
    required String groupId,
    required String optionId,
    required UpdateDishOptionRequest request,
  });

  Future<DishOptionDto> setOptionAvailability({
    required String dishId,
    required String groupId,
    required String optionId,
    required bool isAvailable,
  });

  Future<void> deleteOption({
    required String dishId,
    required String groupId,
    required String optionId,
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

  @override
  Future<void> uploadDishImage({
    required String dishId,
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: DioMediaType.parse(contentType),
        ),
      });

      await _dio.post<void>(
        ApiEndpoints.dishImage(dishId),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<Uint8List> getDishImageBytes({required String dishId}) async {
    try {
      final response = await _dio.get<List<int>>(
        ApiEndpoints.dishImage(dishId),
        options: Options(responseType: ResponseType.bytes),
      );

      return Uint8List.fromList(response.data ?? const []);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<void> deleteDishImage({required String dishId}) async {
    try {
      await _dio.delete<void>(ApiEndpoints.dishImage(dishId));
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<List<DishOptionGroupDto>> getOptionGroups({
    required String dishId,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiEndpoints.dishOptionGroups(dishId),
      );
      final data = response.data ?? const [];

      return data
          .whereType<Map<String, dynamic>>()
          .map(DishOptionGroupDto.fromJson)
          .toList();
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<DishOptionGroupDto> createOptionGroup({
    required String dishId,
    required CreateDishOptionGroupRequest request,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.dishOptionGroups(dishId),
        data: request.toJson(),
      );

      return DishOptionGroupDto.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<DishOptionDto> createOption({
    required String dishId,
    required String optionGroupId,
    required CreateDishOptionRequest request,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.dishOptionGroupOptions(
          dishId: dishId,
          optionGroupId: optionGroupId,
        ),
        data: request.toJson(),
      );

      return DishOptionDto.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<DishOptionGroupDto> updateOptionGroup({
    required String dishId,
    required String groupId,
    required UpdateDishOptionGroupRequest request,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.dishOptionGroupById(dishId: dishId, groupId: groupId),
        data: request.toJson(),
      );

      return DishOptionGroupDto.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<void> deleteOptionGroup({
    required String dishId,
    required String groupId,
  }) async {
    try {
      await _dio.delete<void>(
        ApiEndpoints.dishOptionGroupById(dishId: dishId, groupId: groupId),
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<DishOptionDto> updateOption({
    required String dishId,
    required String groupId,
    required String optionId,
    required UpdateDishOptionRequest request,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.dishOptionById(
          dishId: dishId,
          groupId: groupId,
          optionId: optionId,
        ),
        data: request.toJson(),
      );

      return DishOptionDto.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<DishOptionDto> setOptionAvailability({
    required String dishId,
    required String groupId,
    required String optionId,
    required bool isAvailable,
  }) async {
    try {
      final endpoint = isAvailable
          ? ApiEndpoints.dishOptionAvailable(
              dishId: dishId,
              groupId: groupId,
              optionId: optionId,
            )
          : ApiEndpoints.dishOptionUnavailable(
              dishId: dishId,
              groupId: groupId,
              optionId: optionId,
            );
      final response = await _dio.patch<Map<String, dynamic>>(endpoint);

      return DishOptionDto.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<void> deleteOption({
    required String dishId,
    required String groupId,
    required String optionId,
  }) async {
    try {
      await _dio.delete<void>(
        ApiEndpoints.dishOptionById(
          dishId: dishId,
          groupId: groupId,
          optionId: optionId,
        ),
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
