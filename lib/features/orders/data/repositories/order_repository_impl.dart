import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/pagination/paginated_response.dart';
import '../../domain/entities/order_receipt.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/restaurant_order.dart';
import '../../domain/enums/payment_method.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';
import '../dtos/add_order_item_request.dart';
import '../dtos/close_order_account_request.dart';
import '../dtos/create_order_request.dart';
import '../dtos/register_order_payment_request.dart';
import '../dtos/update_order_status_request.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final remoteDataSource = ref.watch(orderRemoteDataSourceProvider);
  return OrderRepositoryImpl(remoteDataSource);
});

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  const OrderRepositoryImpl(this._remoteDataSource);

  @override
  Future<PaginatedResponse<RestaurantOrder>> getOrders({
    OrderStatus? status,
    String? tableId,
    DateTime? startDate,
    DateTime? endDate,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final response = await _remoteDataSource.getOrders(
      status: status,
      tableId: tableId,
      startDate: startDate,
      endDate: endDate,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    return PaginatedResponse<RestaurantOrder>(
      items: response.items.map((dto) => dto.toEntity()).toList(),
      pageNumber: response.pageNumber,
      pageSize: response.pageSize,
      totalCount: response.totalCount,
      totalPages: response.totalPages,
      hasPreviousPage: response.hasPreviousPage,
      hasNextPage: response.hasNextPage,
    );
  }

  @override
  Future<RestaurantOrder> getOrderById(String id) async {
    final response = await _remoteDataSource.getOrderById(id);
    return response.toEntity();
  }

  @override
  Future<String> createOrder({required String tableId}) {
    return _remoteDataSource.createOrder(CreateOrderRequest(tableId: tableId));
  }

  @override
  Future<void> addItem({
    required String orderId,
    required String dishId,
    required int quantity,
    String? notes,
  }) {
    return _remoteDataSource.addItem(
      orderId: orderId,
      request: AddOrderItemRequest(
        dishId: dishId,
        quantity: quantity,
        notes: notes,
      ),
    );
  }

  @override
  Future<void> updateStatus({
    required String orderId,
    required OrderStatus status,
  }) {
    return _remoteDataSource.updateStatus(
      orderId: orderId,
      request: UpdateOrderStatusRequest(status: status),
    );
  }

  @override
  Future<void> cancelOrder({required String orderId}) {
    return _remoteDataSource.cancelOrder(orderId: orderId);
  }

  @override
  Future<OrderReceipt> closeAccount({
    required String orderId,
    required double discountAmount,
    required double serviceFeeAmount,
  }) async {
    final response = await _remoteDataSource.closeAccount(
      orderId: orderId,
      request: CloseOrderAccountRequest(
        discountAmount: discountAmount,
        serviceFeeAmount: serviceFeeAmount,
      ),
    );

    return response.toEntity();
  }

  @override
  Future<OrderReceipt> registerPayment({
    required String orderId,
    required PaymentMethod method,
    required double amount,
    String? notes,
  }) async {
    final response = await _remoteDataSource.registerPayment(
      orderId: orderId,
      request: RegisterOrderPaymentRequest(
        method: method,
        amount: amount,
        notes: notes,
      ),
    );

    return response.toEntity();
  }

  @override
  Future<OrderReceipt> getReceipt({required String orderId}) async {
    final response = await _remoteDataSource.getReceipt(orderId: orderId);
    return response.toEntity();
  }
}
