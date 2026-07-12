import '../entities/public_order_open_session.dart';
import '../repositories/public_order_repository.dart';

class OpenOrCreatePublicOrderUseCase {
  final PublicOrderRepository _repository;

  const OpenOrCreatePublicOrderUseCase(this._repository);

  Future<PublicOrderOpenSession> call({
    required String restaurantSlug,
    required int tableNumber,
    String? accessCode,
  }) {
    return _repository.openOrCreate(
      restaurantSlug: restaurantSlug,
      tableNumber: tableNumber,
      accessCode: accessCode,
    );
  }
}
