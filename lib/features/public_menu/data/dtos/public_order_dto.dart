import '../../domain/entities/public_order.dart';
import 'public_order_item_dto.dart';

class PublicOrderDto {
  final String orderId;
  final String accessCode;
  final String restaurantId;
  final String restaurantName;
  final String tableId;
  final int tableNumber;
  final String status;
  final double total;
  final List<PublicOrderItemDto> items;
  final DateTime? createdAt;

  const PublicOrderDto({
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

  factory PublicOrderDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    return PublicOrderDto(
      orderId: json['orderId']?.toString() ?? '',
      accessCode: json['accessCode']?.toString() ?? '',
      restaurantId: json['restaurantId']?.toString() ?? '',
      restaurantName: json['restaurantName']?.toString() ?? '',
      tableId: json['tableId']?.toString() ?? '',
      tableNumber: json['tableNumber'] as int? ?? 0,
      status: json['status']?.toString() ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0,
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(PublicOrderItemDto.fromJson)
                .toList()
          : const [],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  PublicOrder toEntity() {
    return PublicOrder(
      orderId: orderId,
      accessCode: accessCode,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      tableId: tableId,
      tableNumber: tableNumber,
      status: status,
      total: total,
      items: items.map((item) => item.toEntity()).toList(),
      createdAt: createdAt,
    );
  }
}
