import '../../domain/entities/order_payment.dart';
import '../../domain/enums/payment_method.dart';
import '../../domain/enums/payment_status.dart';

class OrderPaymentDto {
  final String id;
  final PaymentMethod method;
  final PaymentStatus status;
  final double amount;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrderPaymentDto({
    required this.id,
    required this.method,
    required this.status,
    required this.amount,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderPaymentDto.fromJson(Map<String, dynamic> json) {
    return OrderPaymentDto(
      id: json['id']?.toString() ?? '',
      method: PaymentMethodExtension.fromApi(json['method']),
      status: PaymentStatusExtension.fromApi(json['status']),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      notes: json['notes']?.toString(),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  OrderPayment toEntity() {
    return OrderPayment(
      id: id,
      method: method,
      status: status,
      amount: amount,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
