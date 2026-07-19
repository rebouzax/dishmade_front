import '../../domain/entities/restaurant_settings.dart';

class RestaurantSettingsDto {
  final String restaurantId;
  final String restaurantName;
  final String restaurantSlug;
  final double defaultServiceFeePercentage;
  final bool acceptsQrCodeOrders;
  final bool acceptsWaiterCall;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RestaurantSettingsDto({
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantSlug,
    required this.defaultServiceFeePercentage,
    required this.acceptsQrCodeOrders,
    required this.acceptsWaiterCall,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RestaurantSettingsDto.fromJson(Map<String, dynamic> json) {
    return RestaurantSettingsDto(
      restaurantId: json['restaurantId']?.toString() ?? '',
      restaurantName: json['restaurantName']?.toString() ?? '',
      restaurantSlug: json['restaurantSlug']?.toString() ?? '',
      defaultServiceFeePercentage:
          (json['defaultServiceFeePercentage'] as num?)?.toDouble() ?? 0,
      acceptsQrCodeOrders: json['acceptsQrCodeOrders'] as bool? ?? true,
      acceptsWaiterCall: json['acceptsWaiterCall'] as bool? ?? true,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  RestaurantSettings toEntity() {
    return RestaurantSettings(
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      restaurantSlug: restaurantSlug,
      defaultServiceFeePercentage: defaultServiceFeePercentage,
      acceptsQrCodeOrders: acceptsQrCodeOrders,
      acceptsWaiterCall: acceptsWaiterCall,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
