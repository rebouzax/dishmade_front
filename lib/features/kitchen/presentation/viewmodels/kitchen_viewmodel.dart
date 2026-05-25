import 'package:dishmade_front/features/orders/domain/usescases/get_orders_usecase.dart';
import 'package:dishmade_front/features/orders/domain/usescases/update_order_status_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../orders/data/repositories/order_repository_impl.dart';
import '../../../orders/domain/entities/order_status.dart';
import '../../../orders/domain/entities/restaurant_order.dart';
import 'kitchen_state.dart';

final kitchenGetOrdersUseCaseProvider = Provider<GetOrdersUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return GetOrdersUseCase(repository);
});

final kitchenUpdateOrderStatusUseCaseProvider =
    Provider<UpdateOrderStatusUseCase>((ref) {
      final repository = ref.watch(orderRepositoryProvider);
      return UpdateOrderStatusUseCase(repository);
    });

final kitchenViewModelProvider =
    NotifierProvider.autoDispose<KitchenViewModel, KitchenState>(
      KitchenViewModel.new,
    );

class KitchenViewModel extends Notifier<KitchenState> {
  late final GetOrdersUseCase _getOrdersUseCase;
  late final UpdateOrderStatusUseCase _updateOrderStatusUseCase;

  @override
  KitchenState build() {
    _getOrdersUseCase = ref.watch(kitchenGetOrdersUseCaseProvider);
    _updateOrderStatusUseCase = ref.watch(
      kitchenUpdateOrderStatusUseCaseProvider,
    );

    Future.microtask(loadInitial);

    return const KitchenState();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final responses = await Future.wait([
        _getOrdersUseCase(
          status: OrderStatus.created,
          pageNumber: 1,
          pageSize: 50,
        ),
        _getOrdersUseCase(
          status: OrderStatus.inPreparation,
          pageNumber: 1,
          pageSize: 50,
        ),
        _getOrdersUseCase(
          status: OrderStatus.ready,
          pageNumber: 1,
          pageSize: 50,
        ),
      ]);

      if (!ref.mounted) return;

      state = state.copyWith(
        createdOrders: responses[0].items,
        inPreparationOrders: responses[1].items,
        readyOrders: responses[2].items,
        isLoading: false,
        lastUpdatedAt: DateTime.now(),
      );
    } catch (error) {
      if (!ref.mounted) return;

      state = state.copyWith(isLoading: false, errorMessage: _mapError(error));
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  Future<bool> advanceOrder(RestaurantOrder order) async {
    final nextStatus = order.status.nextStatus;

    if (nextStatus == null) {
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      processingOrderId: order.id,
      errorMessage: null,
    );

    try {
      await _updateOrderStatusUseCase(orderId: order.id, status: nextStatus);

      await loadInitial();

      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false, processingOrderId: null);

      return true;
    } catch (error) {
      if (!ref.mounted) return false;

      state = state.copyWith(
        isSaving: false,
        processingOrderId: null,
        errorMessage: _mapError(error),
      );

      return false;
    }
  }

  String _mapError(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Não foi possível atualizar a cozinha.';
  }
}
