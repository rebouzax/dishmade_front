import '../../domain/entities/restaurant_settings.dart';

const _unset = Object();

class RestaurantSettingsState {
  final RestaurantSettings? settings;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  const RestaurantSettingsState({
    this.settings,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  RestaurantSettingsState copyWith({
    Object? settings = _unset,
    bool? isLoading,
    bool? isSaving,
    Object? errorMessage = _unset,
  }) {
    return RestaurantSettingsState(
      settings: settings == _unset
          ? this.settings
          : settings as RestaurantSettings?,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
