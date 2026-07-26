import 'package:dishmade_front/features/orders/domain/entities/order_item_option.dart';

import 'order_item_status.dart';

class OrderItem {
  final String id;
  final String dishId;
  final String dishName;
  final int quantity;
  final double unitPrice;
  final double optionsTotal;
  final double total;
  final String? notes;
  final OrderItemStatus status;
  final List<OrderItemOption> options;

  const OrderItem({
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
}
