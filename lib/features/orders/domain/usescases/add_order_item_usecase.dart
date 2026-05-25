import '../repositories/order_repository.dart';

class AddOrderItemUseCase {
  final OrderRepository _repository;

  const AddOrderItemUseCase(this._repository);

  Future<void> call({
    required String orderId,
    required String dishId,
    required int quantity,
  }) {
    return _repository.addItem(
      orderId: orderId,
      dishId: dishId,
      quantity: quantity,
    );
  }
}
