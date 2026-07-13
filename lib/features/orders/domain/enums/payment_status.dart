enum PaymentStatus { pending, partiallyPaid, paid, refunded, canceled }

extension PaymentStatusExtension on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pendente';
      case PaymentStatus.partiallyPaid:
        return 'Parcialmente pago';
      case PaymentStatus.paid:
        return 'Pago';
      case PaymentStatus.refunded:
        return 'Estornado';
      case PaymentStatus.canceled:
        return 'Cancelado';
    }
  }

  bool get isPaid => this == PaymentStatus.paid;

  static PaymentStatus fromApi(dynamic value) {
    final text = value?.toString();

    switch (text) {
      case '1':
      case 'Pending':
        return PaymentStatus.pending;
      case '2':
      case 'PartiallyPaid':
        return PaymentStatus.partiallyPaid;
      case '3':
      case 'Paid':
        return PaymentStatus.paid;
      case '4':
      case 'Refunded':
        return PaymentStatus.refunded;
      case '5':
      case 'Canceled':
        return PaymentStatus.canceled;
      default:
        return PaymentStatus.pending;
    }
  }
}
