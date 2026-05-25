import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/pagination/paginated_response.dart';
import '../../domain/entities/order_status.dart';
import '../dtos/add_order_item_request.dart';
import '../dtos/create_order_request.dart';
import '../dtos/order_dto.dart';
import '../dtos/update_order_status_request.dart';

final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return OrderRemoteDataSourceImpl(dio);
});

abstract interface class OrderRemoteDataSource {
  Future<PaginatedResponse<OrderDto>> getOrders({
    OrderStatus? status,
    String? tableId,
    DateTime? startDate,
    DateTime? endDate,
    int pageNumber = 1,
    int pageSize = 20,
  });

  Future<OrderDto> getOrderById(String id);

  Future<String> createOrder(CreateOrderRequest request);

  Future<void> addItem({
    required String orderId,
    required AddOrderItemRequest request,
  });

  Future<void> updateStatus({
    required String orderId,
    required UpdateOrderStatusRequest request,
  });

  Future<void> cancelOrder({required String orderId});
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio _dio;

  const OrderRemoteDataSourceImpl(this._dio);

  @override
  Future<PaginatedResponse<OrderDto>> getOrders({
    OrderStatus? status,
    String? tableId,
    DateTime? startDate,
    DateTime? endDate,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.orders,
        queryParameters: {
          if (status != null) 'status': status.value,
          if (tableId != null && tableId.trim().isNotEmpty) 'tableId': tableId,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      return PaginatedResponse.fromJson(
        response.data ?? <String, dynamic>{},
        OrderDto.fromJson,
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<OrderDto> getOrderById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.orderById(id),
      );

      return OrderDto.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<String> createOrder(CreateOrderRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.orders,
        data: request.toJson(),
      );

      return response.data?['id']?.toString() ?? '';
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<void> addItem({
    required String orderId,
    required AddOrderItemRequest request,
  }) async {
    try {
      await _dio.post<void>(
        ApiEndpoints.addOrderItem(orderId),
        data: request.toJson(),
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<void> updateStatus({
    required String orderId,
    required UpdateOrderStatusRequest request,
  }) async {
    try {
      await _dio.patch<void>(
        ApiEndpoints.updateOrderStatus(orderId),
        data: request.toJson(),
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<void> cancelOrder({required String orderId}) async {
    try {
      await _dio.patch<void>(ApiEndpoints.cancelOrder(orderId));
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
