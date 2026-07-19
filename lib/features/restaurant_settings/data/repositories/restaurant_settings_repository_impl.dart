import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../domain/entities/restaurant_settings.dart';
import '../../domain/repositories/restaurant_settings_repository.dart';
import '../datasources/restaurant_settings_remote_datasource.dart';
import '../dtos/update_restaurant_settings_request.dart';

final restaurantSettingsRemoteDataSourceProvider =
    Provider<RestaurantSettingsRemoteDataSource>((ref) {
      final dio = ref.watch(dioProvider);
      return RestaurantSettingsRemoteDataSourceImpl(dio);
    });

final restaurantSettingsRepositoryProvider =
    Provider<RestaurantSettingsRepository>((ref) {
      final remoteDataSource = ref.watch(
        restaurantSettingsRemoteDataSourceProvider,
      );

      return RestaurantSettingsRepositoryImpl(remoteDataSource);
    });

class RestaurantSettingsRepositoryImpl implements RestaurantSettingsRepository {
  final RestaurantSettingsRemoteDataSource _remoteDataSource;

  const RestaurantSettingsRepositoryImpl(this._remoteDataSource);

  @override
  Future<RestaurantSettings> getSettings() async {
    final response = await _remoteDataSource.getSettings();
    return response.toEntity();
  }

  @override
  Future<RestaurantSettings> updateSettings({
    required double defaultServiceFeePercentage,
    required bool acceptsQrCodeOrders,
    required bool acceptsWaiterCall,
  }) async {
    final response = await _remoteDataSource.updateSettings(
      request: UpdateRestaurantSettingsRequest(
        defaultServiceFeePercentage: defaultServiceFeePercentage,
        acceptsQrCodeOrders: acceptsQrCodeOrders,
        acceptsWaiterCall: acceptsWaiterCall,
      ),
    );

    return response.toEntity();
  }
}
