import '../entities/restaurant_order.dart';
import '../repositories/order_repository.dart';

class GetOrderByIdUseCase {
  final OrderRepository _repository;

  const GetOrderByIdUseCase(this._repository);

  Future<RestaurantOrder> call(String id) {
    return _repository.getOrderById(id);
  }
}
