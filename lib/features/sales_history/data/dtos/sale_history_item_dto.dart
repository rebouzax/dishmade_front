import '../../domain/entities/sale_history_item.dart';

class SaleHistoryItemDto {
  final String dishId;
  final String dishName;
  final int quantity;
  final double unitPrice;
  final double total;

  const SaleHistoryItemDto({
    required this.dishId,
    required this.dishName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory SaleHistoryItemDto.fromJson(Map<String, dynamic> json) {
    return SaleHistoryItemDto(
      dishId: json['dishId']?.toString() ?? '',
      dishName: json['dishName']?.toString() ?? '',
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }

  SaleHistoryItem toEntity() {
    return SaleHistoryItem(
      dishId: dishId,
      dishName: dishName,
      quantity: quantity,
      unitPrice: unitPrice,
      total: total,
    );
  }
}
