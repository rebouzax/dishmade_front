class RestaurantTable {
  final String id;
  final int number;
  final bool isOccupied;
  final bool isMenuQrCodeEnabled;
  final DateTime? menuQrCodeEnabledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RestaurantTable({
    required this.id,
    required this.number,
    required this.isOccupied,
    required this.isMenuQrCodeEnabled,
    required this.menuQrCodeEnabledAt,
    required this.createdAt,
    required this.updatedAt,
  });
}
