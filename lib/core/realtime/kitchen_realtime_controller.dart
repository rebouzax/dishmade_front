import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/viewmodels/auth_controller.dart';
import '../../features/kitchen/presentation/viewmodels/kitchen_viewmodel.dart';
import '../../features/orders/presentation/viewmodels/orders_viewmodel.dart';
import '../../features/service_requests/presentation/viewmodels/service_requests_viewmodel.dart';
import 'kitchen_realtime_events.dart';
import 'kitchen_signalr_provider.dart';

final kitchenRealtimeControllerProvider =
    NotifierProvider<KitchenRealtimeController, bool>(
      KitchenRealtimeController.new,
    );

class KitchenRealtimeController extends Notifier<bool> {
  @override
  bool build() {
    ref.onDispose(() {
      ref.read(kitchenSignalRServiceProvider).disconnect();
    });

    return false;
  }

  Future<void> connect() async {
    if (state) return;

    final session = ref.read(authControllerProvider).session;

    if (session == null || !session.isValid) return;

    final token = session.accessToken;

    await ref
        .read(kitchenSignalRServiceProvider)
        .connect(accessTokenFactory: () async => token, onEvent: _handleEvent);

    state = true;
  }

  Future<void> disconnect() async {
    await ref.read(kitchenSignalRServiceProvider).disconnect();

    state = false;
  }

  void _handleEvent(String eventName, Map<String, dynamic> payload) {
    switch (eventName) {
      case KitchenRealtimeEvents.orderCreated:
      case KitchenRealtimeEvents.orderItemAdded:
      case KitchenRealtimeEvents.orderStatusChanged:
      case KitchenRealtimeEvents.orderCanceled:
      case KitchenRealtimeEvents.orderDelivered:
        _refreshKitchenAndOrders();
        break;

      case KitchenRealtimeEvents.serviceRequestCreated:
      case KitchenRealtimeEvents.serviceRequestUpdated:
        _refreshServiceRequests();
        break;
    }
  }

  void _refreshKitchenAndOrders() {
    ref.read(kitchenViewModelProvider.notifier).refresh();
    ref.read(ordersViewModelProvider.notifier).refresh();
  }

  void _refreshServiceRequests() {
    ref.read(serviceRequestsViewModelProvider.notifier).loadInitial();
  }
}
