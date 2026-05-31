import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/public_order.dart';
import '../../domain/entities/public_order_session.dart';
import '../../domain/repositories/public_order_repository.dart';
import '../datasources/public_order_remote_datasource.dart';
import '../dtos/add_public_order_item_request.dart';
import '../dtos/create_public_order_request.dart';
import '../storage/public_order_storage.dart';

final publicOrderRepositoryProvider = Provider<PublicOrderRepository>((ref) {
  final remoteDataSource = ref.watch(publicOrderRemoteDataSourceProvider);
  final storage = ref.watch(publicOrderStorageProvider);

  return PublicOrderRepositoryImpl(
    remoteDataSource: remoteDataSource,
    storage: storage,
  );
});

class PublicOrderRepositoryImpl implements PublicOrderRepository {
  final PublicOrderRemoteDataSource _remoteDataSource;
  final PublicOrderStorage _storage;

  const PublicOrderRepositoryImpl({
    required PublicOrderRemoteDataSource remoteDataSource,
    required PublicOrderStorage storage,
  }) : _remoteDataSource = remoteDataSource,
       _storage = storage;

  @override
  Future<PublicOrder> createOrder({
    required String restaurantSlug,
    required int tableNumber,
  }) async {
    final response = await _remoteDataSource.createOrder(
      CreatePublicOrderRequest(
        restaurantSlug: restaurantSlug,
        tableNumber: tableNumber,
      ),
    );

    return response.toEntity();
  }

  @override
  Future<PublicOrder> addItem({
    required String orderId,
    required String accessCode,
    required String dishId,
    required int quantity,
  }) async {
    final response = await _remoteDataSource.addItem(
      orderId: orderId,
      request: AddPublicOrderItemRequest(
        accessCode: accessCode,
        dishId: dishId,
        quantity: quantity,
      ),
    );

    return response.toEntity();
  }

  @override
  Future<PublicOrder> getOrder({
    required String orderId,
    required String accessCode,
  }) async {
    final response = await _remoteDataSource.getOrder(
      orderId: orderId,
      accessCode: accessCode,
    );

    return response.toEntity();
  }

  @override
  Future<void> saveSession(PublicOrderSession session) {
    return _storage.saveSession(session);
  }

  @override
  Future<PublicOrderSession?> getSession(String slug) {
    return _storage.getSession(slug);
  }

  @override
  Future<void> clearSession(String slug) {
    return _storage.clearSession(slug);
  }
}
