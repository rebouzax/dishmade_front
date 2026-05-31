import '../../domain/entities/public_order_item.dart';

class PublicOrderItemDto {
  final String id;
  final String dishId;
  final String dishName;
  final int quantity;
  final double unitPrice;
  final double total;

  const PublicOrderItemDto({
    required this.id,
    required this.dishId,
    required this.dishName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory PublicOrderItemDto.fromJson(Map<String, dynamic> json) {
    return PublicOrderItemDto(
      id: json['id']?.toString() ?? '',
      dishId: json['dishId']?.toString() ?? '',
      dishName: json['dishName']?.toString() ?? '',
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }

  PublicOrderItem toEntity() {
    return PublicOrderItem(
      id: id,
      dishId: dishId,
      dishName: dishName,
      quantity: quantity,
      unitPrice: unitPrice,
      total: total,
    );
  }
}
