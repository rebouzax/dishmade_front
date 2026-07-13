import 'order_receipt_item_option.dart';

class OrderReceiptItem {
  final String id;
  final String dishId;
  final String dishName;
  final int quantity;
  final double unitPrice;
  final double optionsTotal;
  final double total;
  final String? notes;
  final List<OrderReceiptItemOption> options;

  const OrderReceiptItem({
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
}
