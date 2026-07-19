import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/app_exception.dart';
import '../dtos/restaurant_settings_dto.dart';
import '../dtos/update_restaurant_settings_request.dart';

abstract interface class RestaurantSettingsRemoteDataSource {
  Future<RestaurantSettingsDto> getSettings();

  Future<RestaurantSettingsDto> updateSettings({
    required UpdateRestaurantSettingsRequest request,
  });
}

class RestaurantSettingsRemoteDataSourceImpl
    implements RestaurantSettingsRemoteDataSource {
  final Dio _dio;

  const RestaurantSettingsRemoteDataSourceImpl(this._dio);

  @override
  Future<RestaurantSettingsDto> getSettings() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.restaurantSettings,
      );

      return RestaurantSettingsDto.fromJson(
        response.data ?? <String, dynamic>{},
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<RestaurantSettingsDto> updateSettings({
    required UpdateRestaurantSettingsRequest request,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.restaurantSettings,
        data: request.toJson(),
      );

      return RestaurantSettingsDto.fromJson(
        response.data ?? <String, dynamic>{},
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
