import '../entities/order_item_status.dart';
import '../entities/restaurant_order.dart';
import '../repositories/order_repository.dart';

class UpdateOrderItemStatusUseCase {
  final OrderRepository _repository;

  const UpdateOrderItemStatusUseCase(this._repository);

  Future<RestaurantOrder> call({
    required String orderId,
    required String itemId,
    required OrderItemStatus status,
  }) {
    return _repository.updateItemStatus(
      orderId: orderId,
      itemId: itemId,
      status: status,
    );
  }
}
