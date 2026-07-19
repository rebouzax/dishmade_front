import 'package:dishmade_front/core/errors/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/restaurant_settings_repository_impl.dart';
import '../../domain/usecases/get_restaurant_settings_usecase.dart';
import '../../domain/usecases/update_restaurant_settings_usecase.dart';
import 'restaurant_settings_state.dart';

final getRestaurantSettingsUseCaseProvider =
    Provider<GetRestaurantSettingsUseCase>((ref) {
      final repository = ref.watch(restaurantSettingsRepositoryProvider);
      return GetRestaurantSettingsUseCase(repository);
    });

final updateRestaurantSettingsUseCaseProvider =
    Provider<UpdateRestaurantSettingsUseCase>((ref) {
      final repository = ref.watch(restaurantSettingsRepositoryProvider);
      return UpdateRestaurantSettingsUseCase(repository);
    });

final restaurantSettingsViewModelProvider =
    NotifierProvider.autoDispose<
      RestaurantSettingsViewModel,
      RestaurantSettingsState
    >(RestaurantSettingsViewModel.new);

class RestaurantSettingsViewModel extends Notifier<RestaurantSettingsState> {
  late final GetRestaurantSettingsUseCase _getUseCase;
  late final UpdateRestaurantSettingsUseCase _updateUseCase;

  @override
  RestaurantSettingsState build() {
    _getUseCase = ref.watch(getRestaurantSettingsUseCaseProvider);
    _updateUseCase = ref.watch(updateRestaurantSettingsUseCaseProvider);

    return const RestaurantSettingsState();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final settings = await _getUseCase();

      if (!ref.mounted) return;

      state = state.copyWith(settings: settings, isLoading: false);
    } catch (error) {
      if (!ref.mounted) return;

      state = state.copyWith(isLoading: false, errorMessage: _mapError(error));
    }
  }

  Future<bool> update({
    required double defaultServiceFeePercentage,
    required bool acceptsQrCodeOrders,
    required bool acceptsWaiterCall,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final settings = await _updateUseCase(
        defaultServiceFeePercentage: defaultServiceFeePercentage,
        acceptsQrCodeOrders: acceptsQrCodeOrders,
        acceptsWaiterCall: acceptsWaiterCall,
      );

      if (!ref.mounted) return false;

      state = state.copyWith(settings: settings, isSaving: false);

      return true;
    } catch (error) {
      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false, errorMessage: _mapError(error));

      return false;
    }
  }

  String _mapError(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Não foi possível carregar as configurações.';
  }
}
