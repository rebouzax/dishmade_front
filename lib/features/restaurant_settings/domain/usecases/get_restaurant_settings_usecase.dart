import '../entities/restaurant_settings.dart';
import '../repositories/restaurant_settings_repository.dart';

class GetRestaurantSettingsUseCase {
  final RestaurantSettingsRepository _repository;

  const GetRestaurantSettingsUseCase(this._repository);

  Future<RestaurantSettings> call() {
    return _repository.getSettings();
  }
}
