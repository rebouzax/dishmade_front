import '../../domain/enums/payment_method.dart';

class RegisterOrderPaymentRequest {
  final PaymentMethod method;
  final double amount;
  final String? notes;

  const RegisterOrderPaymentRequest({
    required this.method,
    required this.amount,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'method': method.apiValue,
      'amount': amount,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    };
  }
}
