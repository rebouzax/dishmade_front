import '../entities/order_receipt.dart';
import '../enums/payment_method.dart';
import '../repositories/order_repository.dart';

class RegisterOrderPaymentUseCase {
  final OrderRepository _repository;

  const RegisterOrderPaymentUseCase(this._repository);

  Future<OrderReceipt> call({
    required String orderId,
    required PaymentMethod method,
    required double amount,
    String? notes,
  }) {
    return _repository.registerPayment(
      orderId: orderId,
      method: method,
      amount: amount,
      notes: notes,
    );
  }
}
