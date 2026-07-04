import 'package:dishmade_front/features/orders/domain/usescases/add_order_item_usecase.dart';
import 'package:dishmade_front/features/orders/domain/usescases/cancel_order_usecase.dart';
import 'package:dishmade_front/features/orders/domain/usescases/create_order_usecase.dart';
import 'package:dishmade_front/features/orders/domain/usescases/get_order_by_id_usecase.dart';
import 'package:dishmade_front/features/orders/domain/usescases/get_orders_usecase.dart';
import 'package:dishmade_front/features/orders/domain/usescases/update_order_status_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/restaurant_order.dart';
import 'orders_state.dart';

final getOrdersUseCaseProvider = Provider<GetOrdersUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return GetOrdersUseCase(repository);
});

final getOrderByIdUseCaseProvider = Provider<GetOrderByIdUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return GetOrderByIdUseCase(repository);
});

final createOrderUseCaseProvider = Provider<CreateOrderUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return CreateOrderUseCase(repository);
});

final addOrderItemUseCaseProvider = Provider<AddOrderItemUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return AddOrderItemUseCase(repository);
});

final updateOrderStatusUseCaseProvider = Provider<UpdateOrderStatusUseCase>((
  ref,
) {
  final repository = ref.watch(orderRepositoryProvider);
  return UpdateOrderStatusUseCase(repository);
});

final cancelOrderUseCaseProvider = Provider<CancelOrderUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return CancelOrderUseCase(repository);
});

final ordersViewModelProvider =
    NotifierProvider.autoDispose<OrdersViewModel, OrdersState>(
      OrdersViewModel.new,
    );

class OrdersViewModel extends Notifier<OrdersState> {
  late final GetOrdersUseCase _getOrdersUseCase;
  late final GetOrderByIdUseCase _getOrderByIdUseCase;
  late final CreateOrderUseCase _createOrderUseCase;
  late final AddOrderItemUseCase _addOrderItemUseCase;
  late final UpdateOrderStatusUseCase _updateOrderStatusUseCase;
  late final CancelOrderUseCase _cancelOrderUseCase;

  @override
  OrdersState build() {
    _getOrdersUseCase = ref.watch(getOrdersUseCaseProvider);
    _getOrderByIdUseCase = ref.watch(getOrderByIdUseCaseProvider);
    _createOrderUseCase = ref.watch(createOrderUseCaseProvider);
    _addOrderItemUseCase = ref.watch(addOrderItemUseCaseProvider);
    _updateOrderStatusUseCase = ref.watch(updateOrderStatusUseCaseProvider);
    _cancelOrderUseCase = ref.watch(cancelOrderUseCaseProvider);

    Future.microtask(loadInitial);

    return const OrdersState();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      pageNumber: 1,
      hasNextPage: false,
    );

    try {
      final response = await _getOrdersUseCase(
        status: state.status,
        pageNumber: 1,
        pageSize: state.pageSize,
      );

      if (!ref.mounted) return;

      state = state.copyWith(
        orders: response.items,
        isLoading: false,
        pageNumber: response.pageNumber,
        totalCount: response.totalCount,
        totalPages: response.totalPages,
        hasNextPage: response.hasNextPage,
      );
    } catch (error) {
      if (!ref.mounted) return;

      state = state.copyWith(isLoading: false, errorMessage: _mapError(error));
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasNextPage) {
      return;
    }

    final nextPage = state.pageNumber + 1;

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      final response = await _getOrdersUseCase(
        status: state.status,
        pageNumber: nextPage,
        pageSize: state.pageSize,
      );

      if (!ref.mounted) return;

      state = state.copyWith(
        orders: [...state.orders, ...response.items],
        isLoadingMore: false,
        pageNumber: response.pageNumber,
        totalCount: response.totalCount,
        totalPages: response.totalPages,
        hasNextPage: response.hasNextPage,
      );
    } catch (error) {
      if (!ref.mounted) return;

      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: _mapError(error),
      );
    }
  }

  Future<void> setStatusFilter(OrderStatus? status) async {
    state = state.copyWith(status: status);
    await loadInitial();
  }

  Future<bool> createOrder(String tableId) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _createOrderUseCase(tableId: tableId);

      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false);
      await loadInitial();
      return true;
    } catch (error) {
      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false, errorMessage: _mapError(error));
      return false;
    }
  }

  Future<bool> addItem({
    required String orderId,
    required String dishId,
    required int quantity,
    String? notes,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _addOrderItemUseCase(
        orderId: orderId,
        dishId: dishId,
        quantity: quantity,
        notes: notes,
      );

      final updatedOrder = await _getOrderByIdUseCase(orderId);

      if (!ref.mounted) return false;

      state = state.copyWith(
        isSaving: false,
        orders: _replaceOrder(updatedOrder),
      );

      return true;
    } catch (error) {
      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false, errorMessage: _mapError(error));
      return false;
    }
  }

  Future<bool> updateStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _updateOrderStatusUseCase(orderId: orderId, status: status);

      await loadInitial();

      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false);
      return true;
    } catch (error) {
      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false, errorMessage: _mapError(error));
      return false;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _cancelOrderUseCase(orderId: orderId);

      await loadInitial();

      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false);
      return true;
    } catch (error) {
      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false, errorMessage: _mapError(error));
      return false;
    }
  }

  List<RestaurantOrder> _replaceOrder(RestaurantOrder updatedOrder) {
    return state.orders.map((order) {
      if (order.id == updatedOrder.id) {
        return updatedOrder;
      }

      return order;
    }).toList();
  }

  String _mapError(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Não foi possível processar o pedido.';
  }
}
