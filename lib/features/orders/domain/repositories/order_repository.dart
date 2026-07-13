import 'package:dishmade_front/features/orders/domain/entities/order_receipt.dart';
import 'package:dishmade_front/features/orders/domain/entities/order_status.dart';
import 'package:dishmade_front/features/orders/domain/entities/restaurant_order.dart';
import 'package:dishmade_front/features/orders/domain/enums/payment_method.dart';

import '../../../../core/pagination/paginated_response.dart';

abstract interface class OrderRepository {
  Future<PaginatedResponse<RestaurantOrder>> getOrders({
    OrderStatus? status,
    String? tableId,
    DateTime? startDate,
    DateTime? endDate,
    int pageNumber = 1,
    int pageSize = 20,
  });

  Future<RestaurantOrder> getOrderById(String id);

  Future<String> createOrder({required String tableId});

  Future<void> addItem({
    required String orderId,
    required String dishId,
    required int quantity,
    String? notes,
  });

  Future<void> updateStatus({
    required String orderId,
    required OrderStatus status,
  });

  Future<void> cancelOrder({required String orderId});

  Future<OrderReceipt> closeAccount({
    required String orderId,
    required double discountAmount,
    required double serviceFeeAmount,
  });

  Future<OrderReceipt> registerPayment({
    required String orderId,
    required PaymentMethod method,
    required double amount,
    String? notes,
  });

  Future<OrderReceipt> getReceipt({required String orderId});
}
