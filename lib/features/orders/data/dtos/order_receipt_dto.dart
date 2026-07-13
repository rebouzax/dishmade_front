import '../../domain/entities/order_receipt.dart';
import '../../domain/enums/order_status.dart';
import '../../domain/enums/payment_status.dart';
import 'order_payment_dto.dart';
import 'order_receipt_item_dto.dart';

class OrderReceiptDto {
  final String orderId;
  final String restaurantId;
  final String tableId;
  final int tableNumber;
  final OrderStatus orderStatus;
  final PaymentStatus paymentStatus;
  final double subtotal;
  final double discountAmount;
  final double serviceFeeAmount;
  final double finalTotal;
  final double paidAmount;
  final double remainingAmount;
  final DateTime? closedAt;
  final DateTime? paidAt;
  final DateTime createdAt;
  final List<OrderReceiptItemDto> items;
  final List<OrderPaymentDto> payments;

  const OrderReceiptDto({
    required this.orderId,
    required this.restaurantId,
    required this.tableId,
    required this.tableNumber,
    required this.orderStatus,
    required this.paymentStatus,
    required this.subtotal,
    required this.discountAmount,
    required this.serviceFeeAmount,
    required this.finalTotal,
    required this.paidAmount,
    required this.remainingAmount,
    required this.closedAt,
    required this.paidAt,
    required this.createdAt,
    required this.items,
    required this.payments,
  });

  factory OrderReceiptDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final rawPayments = json['payments'];

    return OrderReceiptDto(
      orderId: json['orderId']?.toString() ?? '',
      restaurantId: json['restaurantId']?.toString() ?? '',
      tableId: json['tableId']?.toString() ?? '',
      tableNumber: json['tableNumber'] as int? ?? 0,
      orderStatus: OrderStatusExtension.fromApi(json['orderStatus']),
      paymentStatus: PaymentStatusExtension.fromApi(json['paymentStatus']),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      serviceFeeAmount: (json['serviceFeeAmount'] as num?)?.toDouble() ?? 0,
      finalTotal: (json['finalTotal'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0,
      closedAt: DateTime.tryParse(json['closedAt']?.toString() ?? ''),
      paidAt: DateTime.tryParse(json['paidAt']?.toString() ?? ''),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(OrderReceiptItemDto.fromJson)
                .toList()
          : const [],
      payments: rawPayments is List
          ? rawPayments
                .whereType<Map<String, dynamic>>()
                .map(OrderPaymentDto.fromJson)
                .toList()
          : const [],
    );
  }

  OrderReceipt toEntity() {
    return OrderReceipt(
      orderId: orderId,
      restaurantId: restaurantId,
      tableId: tableId,
      tableNumber: tableNumber,
      orderStatus: orderStatus,
      paymentStatus: paymentStatus,
      subtotal: subtotal,
      discountAmount: discountAmount,
      serviceFeeAmount: serviceFeeAmount,
      finalTotal: finalTotal,
      paidAmount: paidAmount,
      remainingAmount: remainingAmount,
      closedAt: closedAt,
      paidAt: paidAt,
      createdAt: createdAt,
      items: items.map((item) => item.toEntity()).toList(),
      payments: payments.map((payment) => payment.toEntity()).toList(),
    );
  }
}
