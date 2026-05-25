enum OrderStatus {
  created('Created', 'Criado'),
  inPreparation('InPreparation', 'Em preparo'),
  ready('Ready', 'Pronto'),
  delivered('Delivered', 'Entregue'),
  canceled('Canceled', 'Cancelado');

  final String value;
  final String label;

  const OrderStatus(this.value, this.label);

  static OrderStatus fromString(String? value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.created,
    );
  }

  bool get canAddItems {
    return this != OrderStatus.delivered && this != OrderStatus.canceled;
  }

  bool get canCancel {
    return this == OrderStatus.created ||
        this == OrderStatus.inPreparation ||
        this == OrderStatus.ready;
  }

  OrderStatus? get nextStatus {
    return switch (this) {
      OrderStatus.created => OrderStatus.inPreparation,
      OrderStatus.inPreparation => OrderStatus.ready,
      OrderStatus.ready => OrderStatus.delivered,
      _ => null,
    };
  }

  String? get nextStatusLabel {
    return switch (this) {
      OrderStatus.created => 'Iniciar preparo',
      OrderStatus.inPreparation => 'Marcar pronto',
      OrderStatus.ready => 'Entregar',
      _ => null,
    };
  }
}
