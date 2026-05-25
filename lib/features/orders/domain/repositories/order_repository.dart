import 'package:dishmade_front/features/orders/domain/entities/order_status.dart';
import 'package:dishmade_front/features/orders/domain/entities/restaurant_order.dart';

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
  });

  Future<void> updateStatus({
    required String orderId,
    required OrderStatus status,
  });

  Future<void> cancelOrder({required String orderId});
}
