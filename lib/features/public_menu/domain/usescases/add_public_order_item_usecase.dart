import '../entities/public_order.dart';
import '../repositories/public_order_repository.dart';

class AddPublicOrderItemUseCase {
  final PublicOrderRepository _repository;

  const AddPublicOrderItemUseCase(this._repository);

  Future<PublicOrder> call({
    required String orderId,
    required String accessCode,
    required String dishId,
    required int quantity,
    String? notes,
    List<String> optionIds = const [],
  }) {
    return _repository.addItem(
      orderId: orderId,
      accessCode: accessCode,
      dishId: dishId,
      quantity: quantity,
      notes: notes,
      optionIds: optionIds,
    );
  }
}
