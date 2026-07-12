import 'package:dio/dio.dart';
import 'package:dishmade_front/core/errors/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/public_dio_provider.dart';
import '../dtos/add_public_order_item_request.dart';
import '../dtos/create_public_order_request.dart';
import '../dtos/open_or_create_public_order_request.dart';
import '../dtos/public_order_dto.dart';
import '../dtos/public_order_open_session_dto.dart';

final publicOrderRemoteDataSourceProvider =
    Provider<PublicOrderRemoteDataSource>((ref) {
      final dio = ref.watch(publicDioProvider);
      return PublicOrderRemoteDataSourceImpl(dio);
    });

abstract interface class PublicOrderRemoteDataSource {
  Future<PublicOrderDto> createOrder(CreatePublicOrderRequest request);

  Future<PublicOrderOpenSessionDto> openOrCreate({
    required OpenOrCreatePublicOrderRequest request,
  });

  Future<PublicOrderDto> getCurrentOrderByTable({
    required String slug,
    required int tableNumber,
    required String accessCode,
  });

  Future<PublicOrderDto> addItem({
    required String orderId,
    required AddPublicOrderItemRequest request,
  });

  Future<PublicOrderDto> getOrder({
    required String orderId,
    required String accessCode,
  });
}

class PublicOrderRemoteDataSourceImpl implements PublicOrderRemoteDataSource {
  final Dio _dio;

  const PublicOrderRemoteDataSourceImpl(this._dio);

  @override
  Future<PublicOrderDto> createOrder(CreatePublicOrderRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.publicOrders,
        data: request.toJson(),
      );

      return PublicOrderDto.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<PublicOrderOpenSessionDto> openOrCreate({
    required OpenOrCreatePublicOrderRequest request,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.publicOrdersOpenOrCreate,
        data: request.toJson(),
      );

      return PublicOrderOpenSessionDto.fromJson(
        response.data ?? <String, dynamic>{},
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<PublicOrderDto> getCurrentOrderByTable({
    required String slug,
    required int tableNumber,
    required String accessCode,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.publicCurrentOrderByTable(
          slug: slug,
          tableNumber: tableNumber,
        ),
        queryParameters: {'accessCode': accessCode},
      );

      return PublicOrderDto.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<PublicOrderDto> addItem({
    required String orderId,
    required AddPublicOrderItemRequest request,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.publicOrderItems(orderId),
        data: request.toJson(),
      );

      return PublicOrderDto.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<PublicOrderDto> getOrder({
    required String orderId,
    required String accessCode,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.publicOrderById(orderId),
        queryParameters: {'accessCode': accessCode},
      );

      return PublicOrderDto.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
