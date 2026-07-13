import '../../domain/entities/order_receipt_item.dart';
import 'order_receipt_item_option_dto.dart';

class OrderReceiptItemDto {
  final String id;
  final String dishId;
  final String dishName;
  final int quantity;
  final double unitPrice;
  final double optionsTotal;
  final double total;
  final String? notes;
  final List<OrderReceiptItemOptionDto> options;

  const OrderReceiptItemDto({
    required this.id,
    required this.dishId,
    required this.dishName,
    required this.quantity,
    required this.unitPrice,
    required this.optionsTotal,
    required this.total,
    required this.notes,
    required this.options,
  });

  factory OrderReceiptItemDto.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];

    return OrderReceiptItemDto(
      id: json['id']?.toString() ?? '',
      dishId: json['dishId']?.toString() ?? '',
      dishName: json['dishName']?.toString() ?? '',
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      optionsTotal: (json['optionsTotal'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      notes: json['notes']?.toString(),
      options: rawOptions is List
          ? rawOptions
                .whereType<Map<String, dynamic>>()
                .map(OrderReceiptItemOptionDto.fromJson)
                .toList()
          : const [],
    );
  }

  OrderReceiptItem toEntity() {
    return OrderReceiptItem(
      id: id,
      dishId: dishId,
      dishName: dishName,
      quantity: quantity,
      unitPrice: unitPrice,
      optionsTotal: optionsTotal,
      total: total,
      notes: notes,
      options: options.map((option) => option.toEntity()).toList(),
    );
  }
}
