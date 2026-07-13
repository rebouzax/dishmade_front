import '../../domain/entities/order_receipt_item_option.dart';

class OrderReceiptItemOptionDto {
  final String dishOptionId;
  final String name;
  final double additionalPrice;

  const OrderReceiptItemOptionDto({
    required this.dishOptionId,
    required this.name,
    required this.additionalPrice,
  });

  factory OrderReceiptItemOptionDto.fromJson(Map<String, dynamic> json) {
    return OrderReceiptItemOptionDto(
      dishOptionId: json['dishOptionId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      additionalPrice: (json['additionalPrice'] as num?)?.toDouble() ?? 0,
    );
  }

  OrderReceiptItemOption toEntity() {
    return OrderReceiptItemOption(
      dishOptionId: dishOptionId,
      name: name,
      additionalPrice: additionalPrice,
    );
  }
}
