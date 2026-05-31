import '../entities/public_order.dart';
import '../repositories/public_order_repository.dart';

class GetPublicOrderUseCase {
  final PublicOrderRepository _repository;

  const GetPublicOrderUseCase(this._repository);

  Future<PublicOrder> call({
    required String orderId,
    required String accessCode,
  }) {
    return _repository.getOrder(orderId: orderId, accessCode: accessCode);
  }
}
