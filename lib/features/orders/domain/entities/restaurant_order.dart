import 'order_item.dart';
import 'order_status.dart';

class RestaurantOrder {
  final String id;
  final String tableId;
  final int tableNumber;
  final OrderStatus status;
  final double total;
  final List<OrderItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;

  const RestaurantOrder({
    required this.id,
    required this.tableId,
    required this.tableNumber,
    required this.status,
    required this.total,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    required this.deliveredAt,
  });
}
