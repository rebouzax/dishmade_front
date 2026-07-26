enum OrderItemStatus { created, inPreparation, ready, delivered, canceled }

extension OrderItemStatusExtension on OrderItemStatus {
  String get apiValue {
    switch (this) {
      case OrderItemStatus.created:
        return 'Created';
      case OrderItemStatus.inPreparation:
        return 'InPreparation';
      case OrderItemStatus.ready:
        return 'Ready';
      case OrderItemStatus.delivered:
        return 'Delivered';
      case OrderItemStatus.canceled:
        return 'Canceled';
    }
  }

  String get label {
    switch (this) {
      case OrderItemStatus.created:
        return 'Criado';
      case OrderItemStatus.inPreparation:
        return 'Em preparo';
      case OrderItemStatus.ready:
        return 'Pronto';
      case OrderItemStatus.delivered:
        return 'Entregue';
      case OrderItemStatus.canceled:
        return 'Cancelado';
    }
  }

  bool get canStartPreparation => this == OrderItemStatus.created;

  bool get canMarkAsReady {
    return this == OrderItemStatus.created ||
        this == OrderItemStatus.inPreparation;
  }

  bool get canMarkAsDelivered => this == OrderItemStatus.ready;

  bool get canCancel {
    return this == OrderItemStatus.created ||
        this == OrderItemStatus.inPreparation ||
        this == OrderItemStatus.ready;
  }

  static OrderItemStatus fromApi(dynamic value) {
    final text = value?.toString();

    switch (text) {
      case '1':
      case 'Created':
        return OrderItemStatus.created;
      case '2':
      case 'InPreparation':
        return OrderItemStatus.inPreparation;
      case '3':
      case 'Ready':
        return OrderItemStatus.ready;
      case '4':
      case 'Delivered':
        return OrderItemStatus.delivered;
      case '5':
      case 'Canceled':
        return OrderItemStatus.canceled;
      default:
        return OrderItemStatus.created;
    }
  }
}
