enum OrderStatus { created, inPreparation, ready, delivered, canceled }

extension OrderStatusExtension on OrderStatus {
  String get apiValue {
    switch (this) {
      case OrderStatus.created:
        return 'Created';
      case OrderStatus.inPreparation:
        return 'InPreparation';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.canceled:
        return 'Canceled';
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.created:
        return 'Criado';
      case OrderStatus.inPreparation:
        return 'Em preparo';
      case OrderStatus.ready:
        return 'Pronto';
      case OrderStatus.delivered:
        return 'Entregue';
      case OrderStatus.canceled:
        return 'Cancelado';
    }
  }

  static OrderStatus fromApi(dynamic value) {
    final text = value?.toString();

    switch (text) {
      case '1':
      case 'Created':
        return OrderStatus.created;
      case '2':
      case 'InPreparation':
        return OrderStatus.inPreparation;
      case '3':
      case 'Ready':
        return OrderStatus.ready;
      case '4':
      case 'Delivered':
        return OrderStatus.delivered;
      case '5':
      case 'Canceled':
        return OrderStatus.canceled;
      default:
        return OrderStatus.created;
    }
  }
}
