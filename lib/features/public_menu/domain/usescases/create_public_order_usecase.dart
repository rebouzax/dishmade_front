import '../entities/public_order.dart';
import '../repositories/public_order_repository.dart';

class CreatePublicOrderUseCase {
  final PublicOrderRepository _repository;

  const CreatePublicOrderUseCase(this._repository);

  Future<PublicOrder> call({
    required String restaurantSlug,
    required int tableNumber,
  }) {
    return _repository.createOrder(
      restaurantSlug: restaurantSlug,
      tableNumber: tableNumber,
    );
  }
}
