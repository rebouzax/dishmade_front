class TableMenuQrCode {
  final String tableId;
  final int tableNumber;
  final String restaurantId;
  final String restaurantName;
  final String restaurantSlug;
  final bool isEnabled;
  final String? menuUrl;
  final String? qrCodeImageUrl;

  const TableMenuQrCode({
    required this.tableId,
    required this.tableNumber,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantSlug,
    required this.isEnabled,
    required this.menuUrl,
    required this.qrCodeImageUrl,
  });
}
