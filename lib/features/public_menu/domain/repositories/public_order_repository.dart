import '../entities/public_order.dart';
import '../entities/public_order_session.dart';

abstract interface class PublicOrderRepository {
  Future<PublicOrder> createOrder({
    required String restaurantSlug,
    required int tableNumber,
  });

  Future<PublicOrder> addItem({
    required String orderId,
    required String accessCode,
    required String dishId,
    required int quantity,
    String? notes,
    List<String> optionIds = const [],
  });

  Future<PublicOrder> getOrder({
    required String orderId,
    required String accessCode,
  });

  Future<void> saveSession(PublicOrderSession session);

  Future<PublicOrderSession?> getSession(String slug);

  Future<void> clearSession(String slug);
}
