import '../repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository _repository;

  const CreateOrderUseCase(this._repository);

  Future<String> call({required String tableId}) {
    return _repository.createOrder(tableId: tableId);
  }
}
