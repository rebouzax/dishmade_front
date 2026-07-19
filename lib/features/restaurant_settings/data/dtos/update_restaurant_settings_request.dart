class UpdateRestaurantSettingsRequest {
  final double defaultServiceFeePercentage;
  final bool acceptsQrCodeOrders;
  final bool acceptsWaiterCall;

  const UpdateRestaurantSettingsRequest({
    required this.defaultServiceFeePercentage,
    required this.acceptsQrCodeOrders,
    required this.acceptsWaiterCall,
  });

  Map<String, dynamic> toJson() {
    return {
      'defaultServiceFeePercentage': defaultServiceFeePercentage,
      'acceptsQrCodeOrders': acceptsQrCodeOrders,
      'acceptsWaiterCall': acceptsWaiterCall,
    };
  }
}
