import '../entities/public_order.dart';
import '../repositories/public_order_repository.dart';

class GetCurrentPublicOrderByTableUseCase {
  final PublicOrderRepository _repository;

  const GetCurrentPublicOrderByTableUseCase(this._repository);

  Future<PublicOrder> call({
    required String slug,
    required int tableNumber,
    required String accessCode,
  }) {
    return _repository.getCurrentOrderByTable(
      slug: slug,
      tableNumber: tableNumber,
      accessCode: accessCode,
    );
  }
}
