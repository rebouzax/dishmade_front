import '../entities/restaurant_settings.dart';
import '../repositories/restaurant_settings_repository.dart';

class UpdateRestaurantSettingsUseCase {
  final RestaurantSettingsRepository _repository;

  const UpdateRestaurantSettingsUseCase(this._repository);

  Future<RestaurantSettings> call({
    required double defaultServiceFeePercentage,
    required bool acceptsQrCodeOrders,
    required bool acceptsWaiterCall,
  }) {
    return _repository.updateSettings(
      defaultServiceFeePercentage: defaultServiceFeePercentage,
      acceptsQrCodeOrders: acceptsQrCodeOrders,
      acceptsWaiterCall: acceptsWaiterCall,
    );
  }
}
