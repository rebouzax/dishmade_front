import '../../domain/entities/order_item.dart';
import '../../domain/entities/order_item_status.dart';
import 'order_item_option_dto.dart';

class OrderItemDto {
  final String id;
  final String dishId;
  final String dishName;
  final int quantity;
  final double unitPrice;
  final double optionsTotal;
  final double total;
  final String? notes;
  final OrderItemStatus status;
  final List<OrderItemOptionDto> options;

  const OrderItemDto({
    required this.id,
    required this.dishId,
    required this.dishName,
    required this.quantity,
    required this.unitPrice,
    required this.optionsTotal,
    required this.total,
    required this.notes,
    required this.status,
    required this.options,
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];

    return OrderItemDto(
      id: json['id']?.toString() ?? '',
      dishId: json['dishId']?.toString() ?? '',
      dishName: json['dishName']?.toString() ?? '',
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      optionsTotal: (json['optionsTotal'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      notes: json['notes']?.toString(),
      status: OrderItemStatusExtension.fromApi(json['status']),
      options: rawOptions is List
          ? rawOptions
                .whereType<Map>()
                .map(
                  (option) => OrderItemOptionDto.fromJson(
                    option.map((key, value) => MapEntry(key.toString(), value)),
                  ),
                )
                .toList()
          : const [],
    );
  }

  OrderItem toEntity() {
    return OrderItem(
      id: id,
      dishId: dishId,
      dishName: dishName,
      quantity: quantity,
      unitPrice: unitPrice,
      optionsTotal: optionsTotal,
      total: total,
      notes: notes,
      status: status,
      options: options.map((option) => option.toEntity()).toList(),
    );
  }
}
