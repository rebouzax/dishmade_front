import 'package:dio/dio.dart';
import 'package:dishmade_front/core/errors/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/public_dio_provider.dart';
import '../dtos/public_menu_dto.dart';

final publicMenuRemoteDataSourceProvider =
    Provider<PublicMenuRemoteDataSource>((ref) {
  final dio = ref.watch(publicDioProvider);
  return PublicMenuRemoteDataSourceImpl(dio);
});

abstract interface class PublicMenuRemoteDataSource {
  Future<PublicMenuDto> getMenu(String slug);
}

class PublicMenuRemoteDataSourceImpl implements PublicMenuRemoteDataSource {
  final Dio _dio;

  const PublicMenuRemoteDataSourceImpl(this._dio);

  @override
  Future<PublicMenuDto> getMenu(String slug) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.publicMenu(slug),
      );

      return PublicMenuDto.fromJson(
        response.data ?? <String, dynamic>{},
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}