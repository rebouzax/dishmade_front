class KitchenRealtimeEvents {
  const KitchenRealtimeEvents._();

  static const orderCreated = 'KitchenOrderCreated';
  static const orderItemAdded = 'KitchenOrderItemAdded';
  static const orderStatusChanged = 'KitchenOrderStatusChanged';
  static const orderCanceled = 'KitchenOrderCanceled';
  static const orderDelivered = 'KitchenOrderDelivered';
  static const serviceRequestCreated = 'KitchenServiceRequestCreated';
  static const serviceRequestUpdated = 'KitchenServiceRequestUpdated';

  static const all = [
    orderCreated,
    orderItemAdded,
    orderStatusChanged,
    orderCanceled,
    orderDelivered,
    serviceRequestCreated,
    serviceRequestUpdated,
  ];
}
