import '../entities/order_receipt.dart';
import '../repositories/order_repository.dart';

class GetOrderReceiptUseCase {
  final OrderRepository _repository;

  const GetOrderReceiptUseCase(this._repository);

  Future<OrderReceipt> call({required String orderId}) {
    return _repository.getReceipt(orderId: orderId);
  }
}
