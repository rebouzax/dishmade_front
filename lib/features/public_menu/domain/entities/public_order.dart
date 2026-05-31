import 'public_order_item.dart';

class PublicOrder {
  final String orderId;
  final String accessCode;
  final String restaurantId;
  final String restaurantName;
  final String tableId;
  final int tableNumber;
  final String status;
  final double total;
  final List<PublicOrderItem> items;
  final DateTime? createdAt;

  const PublicOrder({
    required this.orderId,
    required this.accessCode,
    required this.restaurantId,
    required this.restaurantName,
    required this.tableId,
    required this.tableNumber,
    required this.status,
    required this.total,
    required this.items,
    required this.createdAt,
  });

  int get totalItems {
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  bool get isFinished {
    return status == 'Delivered' || status == 'Canceled';
  }
}
