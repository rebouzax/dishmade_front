import '../../domain/entities/order_status.dart';
import '../../domain/entities/restaurant_order.dart';
import 'order_item_dto.dart';

class OrderDto {
  final String id;
  final String tableId;
  final int tableNumber;
  final OrderStatus status;
  final double total;
  final List<OrderItemDto> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;

  const OrderDto({
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

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    return OrderDto(
      id: json['id']?.toString() ?? '',
      tableId: json['tableId']?.toString() ?? '',
      tableNumber: json['tableNumber'] as int? ?? 0,
      status: OrderStatus.fromString(json['status']?.toString()),
      total: (json['total'] as num?)?.toDouble() ?? 0,
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(OrderItemDto.fromJson)
                .toList()
          : const [],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
      deliveredAt: DateTime.tryParse(json['deliveredAt']?.toString() ?? ''),
    );
  }

  RestaurantOrder toEntity() {
    return RestaurantOrder(
      id: id,
      tableId: tableId,
      tableNumber: tableNumber,
      status: status,
      total: total,
      items: items.map((item) => item.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      deliveredAt: deliveredAt,
    );
  }
}
