import '../../domain/entities/order_item_option.dart';

class OrderItemOptionDto {
  final String dishOptionId;
  final String name;
  final double additionalPrice;

  const OrderItemOptionDto({
    required this.dishOptionId,
    required this.name,
    required this.additionalPrice,
  });

  factory OrderItemOptionDto.fromJson(Map<String, dynamic> json) {
    return OrderItemOptionDto(
      dishOptionId: json['dishOptionId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      additionalPrice: (json['additionalPrice'] as num?)?.toDouble() ?? 0,
    );
  }

  OrderItemOption toEntity() {
    return OrderItemOption(
      dishOptionId: dishOptionId,
      name: name,
      additionalPrice: additionalPrice,
    );
  }
}
