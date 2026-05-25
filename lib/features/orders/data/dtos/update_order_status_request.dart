import '../../domain/entities/order_status.dart';

class UpdateOrderStatusRequest {
  final OrderStatus status;

  const UpdateOrderStatusRequest({required this.status});

  Map<String, dynamic> toJson() {
    return {'status': status.value};
  }
}
