import '../../domain/entities/order_item_status.dart';

class UpdateOrderItemStatusRequest {
  final OrderItemStatus status;

  const UpdateOrderItemStatusRequest({required this.status});

  Map<String, dynamic> toJson() {
    return {'status': status.apiValue};
  }
}
