class RestaurantSettings {
  final String restaurantId;
  final String restaurantName;
  final String restaurantSlug;
  final double defaultServiceFeePercentage;
  final bool acceptsQrCodeOrders;
  final bool acceptsWaiterCall;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RestaurantSettings({
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantSlug,
    required this.defaultServiceFeePercentage,
    required this.acceptsQrCodeOrders,
    required this.acceptsWaiterCall,
    required this.createdAt,
    required this.updatedAt,
  });
}
