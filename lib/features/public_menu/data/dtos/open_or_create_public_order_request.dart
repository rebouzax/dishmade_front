class OpenOrCreatePublicOrderRequest {
  final String restaurantSlug;
  final int tableNumber;
  final String? accessCode;

  const OpenOrCreatePublicOrderRequest({
    required this.restaurantSlug,
    required this.tableNumber,
    this.accessCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'restaurantSlug': restaurantSlug,
      'tableNumber': tableNumber,
      'accessCode': accessCode,
    };
  }
}
