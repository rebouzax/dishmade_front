import '../entities/order_receipt.dart';
import '../repositories/order_repository.dart';

class CloseOrderAccountUseCase {
  final OrderRepository _repository;

  const CloseOrderAccountUseCase(this._repository);

  Future<OrderReceipt> call({
    required String orderId,
    required double discountAmount,
    required double? serviceFeeAmount,
    required bool useDefaultServiceFee,
  }) {
    return _repository.closeAccount(
      orderId: orderId,
      discountAmount: discountAmount,
      serviceFeeAmount: serviceFeeAmount,
      useDefaultServiceFee: useDefaultServiceFee,
    );
  }
}
