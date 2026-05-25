import '../repositories/order_repository.dart';

class CancelOrderUseCase {
  final OrderRepository _repository;

  const CancelOrderUseCase(this._repository);

  Future<void> call({required String orderId}) {
    return _repository.cancelOrder(orderId: orderId);
  }
}
