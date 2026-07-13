import '../enums/payment_method.dart';
import '../enums/payment_status.dart';

class OrderPayment {
  final String id;
  final PaymentMethod method;
  final PaymentStatus status;
  final double amount;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrderPayment({
    required this.id,
    required this.method,
    required this.status,
    required this.amount,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
}
