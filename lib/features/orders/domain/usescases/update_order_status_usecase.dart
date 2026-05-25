import '../entities/order_status.dart';
import '../repositories/order_repository.dart';

class UpdateOrderStatusUseCase {
  final OrderRepository _repository;

  const UpdateOrderStatusUseCase(this._repository);

  Future<void> call({required String orderId, required OrderStatus status}) {
    return _repository.updateStatus(orderId: orderId, status: status);
  }
}
