import '../entities/restaurant_settings.dart';

abstract interface class RestaurantSettingsRepository {
  Future<RestaurantSettings> getSettings();

  Future<RestaurantSettings> updateSettings({
    required double defaultServiceFeePercentage,
    required bool acceptsQrCodeOrders,
    required bool acceptsWaiterCall,
  });
}
