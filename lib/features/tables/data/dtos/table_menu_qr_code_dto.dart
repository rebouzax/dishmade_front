import '../../domain/entities/table_menu_qr_code.dart';

class TableMenuQrCodeDto {
  final String tableId;
  final int tableNumber;
  final String restaurantId;
  final String restaurantName;
  final String restaurantSlug;
  final bool isEnabled;
  final String? menuUrl;
  final String? qrCodeImageUrl;

  const TableMenuQrCodeDto({
    required this.tableId,
    required this.tableNumber,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantSlug,
    required this.isEnabled,
    required this.menuUrl,
    required this.qrCodeImageUrl,
  });

  factory TableMenuQrCodeDto.fromJson(Map<String, dynamic> json) {
    return TableMenuQrCodeDto(
      tableId: json['tableId']?.toString() ?? '',
      tableNumber: json['tableNumber'] as int? ?? 0,
      restaurantId: json['restaurantId']?.toString() ?? '',
      restaurantName: json['restaurantName']?.toString() ?? '',
      restaurantSlug: json['restaurantSlug']?.toString() ?? '',
      isEnabled: json['isEnabled'] as bool? ?? false,
      menuUrl: json['menuUrl']?.toString(),
      qrCodeImageUrl: json['qrCodeImageUrl']?.toString(),
    );
  }

  TableMenuQrCode toEntity() {
    return TableMenuQrCode(
      tableId: tableId,
      tableNumber: tableNumber,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      restaurantSlug: restaurantSlug,
      isEnabled: isEnabled,
      menuUrl: menuUrl,
      qrCodeImageUrl: qrCodeImageUrl,
    );
  }
}
