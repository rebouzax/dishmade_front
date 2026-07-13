enum PaymentMethod { cash, creditCard, debitCard, pix, other }

extension PaymentMethodExtension on PaymentMethod {
  String get apiValue {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.creditCard:
        return 'CreditCard';
      case PaymentMethod.debitCard:
        return 'DebitCard';
      case PaymentMethod.pix:
        return 'Pix';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Dinheiro';
      case PaymentMethod.creditCard:
        return 'Cartão de crédito';
      case PaymentMethod.debitCard:
        return 'Cartão de débito';
      case PaymentMethod.pix:
        return 'Pix';
      case PaymentMethod.other:
        return 'Outro';
    }
  }

  static PaymentMethod fromApi(dynamic value) {
    final text = value?.toString();

    switch (text) {
      case '1':
      case 'Cash':
        return PaymentMethod.cash;
      case '2':
      case 'CreditCard':
        return PaymentMethod.creditCard;
      case '3':
      case 'DebitCard':
        return PaymentMethod.debitCard;
      case '4':
      case 'Pix':
        return PaymentMethod.pix;
      case '5':
      case 'Other':
        return PaymentMethod.other;
      default:
        return PaymentMethod.other;
    }
  }
}
