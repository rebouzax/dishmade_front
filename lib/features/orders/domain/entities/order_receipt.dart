import '../enums/order_status.dart';
import '../enums/payment_status.dart';
import 'order_payment.dart';
import 'order_receipt_item.dart';

class OrderReceipt {
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
  final List<OrderReceiptItem> items;
  final List<OrderPayment> payments;

  const OrderReceipt({
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
}
