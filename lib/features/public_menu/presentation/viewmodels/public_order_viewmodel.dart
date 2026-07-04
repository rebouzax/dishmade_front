import 'package:dishmade_front/core/errors/app_exception.dart';
import 'package:dishmade_front/features/public_menu/domain/usescases/add_public_order_item_usecase.dart';
import 'package:dishmade_front/features/public_menu/domain/usescases/create_public_order_usecase.dart';
import 'package:dishmade_front/features/public_menu/domain/usescases/get_public_order_usecase.dart';
import 'package:dishmade_front/features/public_menu/domain/usescases/public_order_session_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/public_order_repository_impl.dart';
import '../../domain/entities/public_order_session.dart';
import 'public_order_state.dart';

final createPublicOrderUseCaseProvider = Provider<CreatePublicOrderUseCase>((
  ref,
) {
  final repository = ref.watch(publicOrderRepositoryProvider);
  return CreatePublicOrderUseCase(repository);
});

final addPublicOrderItemUseCaseProvider = Provider<AddPublicOrderItemUseCase>((
  ref,
) {
  final repository = ref.watch(publicOrderRepositoryProvider);
  return AddPublicOrderItemUseCase(repository);
});

final getPublicOrderUseCaseProvider = Provider<GetPublicOrderUseCase>((ref) {
  final repository = ref.watch(publicOrderRepositoryProvider);
  return GetPublicOrderUseCase(repository);
});

final savePublicOrderSessionUseCaseProvider =
    Provider<SavePublicOrderSessionUseCase>((ref) {
      final repository = ref.watch(publicOrderRepositoryProvider);
      return SavePublicOrderSessionUseCase(repository);
    });

final getPublicOrderSessionUseCaseProvider =
    Provider<GetPublicOrderSessionUseCase>((ref) {
      final repository = ref.watch(publicOrderRepositoryProvider);
      return GetPublicOrderSessionUseCase(repository);
    });

final clearPublicOrderSessionUseCaseProvider =
    Provider<ClearPublicOrderSessionUseCase>((ref) {
      final repository = ref.watch(publicOrderRepositoryProvider);
      return ClearPublicOrderSessionUseCase(repository);
    });

final publicOrderViewModelProvider =
    NotifierProvider.autoDispose<PublicOrderViewModel, PublicOrderState>(
      PublicOrderViewModel.new,
    );

class PublicOrderViewModel extends Notifier<PublicOrderState> {
  late final CreatePublicOrderUseCase _createOrderUseCase;
  late final AddPublicOrderItemUseCase _addItemUseCase;
  late final GetPublicOrderUseCase _getOrderUseCase;
  late final SavePublicOrderSessionUseCase _saveSessionUseCase;
  late final GetPublicOrderSessionUseCase _getSessionUseCase;
  late final ClearPublicOrderSessionUseCase _clearSessionUseCase;

  @override
  PublicOrderState build() {
    _createOrderUseCase = ref.watch(createPublicOrderUseCaseProvider);
    _addItemUseCase = ref.watch(addPublicOrderItemUseCaseProvider);
    _getOrderUseCase = ref.watch(getPublicOrderUseCaseProvider);
    _saveSessionUseCase = ref.watch(savePublicOrderSessionUseCaseProvider);
    _getSessionUseCase = ref.watch(getPublicOrderSessionUseCaseProvider);
    _clearSessionUseCase = ref.watch(clearPublicOrderSessionUseCaseProvider);

    return const PublicOrderState();
  }

  Future<void> restoreOrder(String slug) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final session = await _getSessionUseCase(slug);

      if (session == null) {
        if (!ref.mounted) return;
        state = state.copyWith(isLoading: false);
        return;
      }

      final order = await _getOrderUseCase(
        orderId: session.orderId,
        accessCode: session.accessCode,
      );

      if (!ref.mounted) return;

      if (order.isFinished) {
        await _clearSessionUseCase(slug);
        state = state.copyWith(order: null, isLoading: false);
        return;
      }

      state = state.copyWith(order: order, isLoading: false);
    } catch (_) {
      await _clearSessionUseCase(slug);

      if (!ref.mounted) return;

      state = state.copyWith(order: null, isLoading: false);
    }
  }

  Future<bool> createOrder({
    required String restaurantSlug,
    required int tableNumber,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final order = await _createOrderUseCase(
        restaurantSlug: restaurantSlug,
        tableNumber: tableNumber,
      );

      await _saveSessionUseCase(
        PublicOrderSession(
          restaurantSlug: restaurantSlug,
          orderId: order.orderId,
          accessCode: order.accessCode,
          tableNumber: order.tableNumber,
        ),
      );

      if (!ref.mounted) return false;

      state = state.copyWith(order: order, isSaving: false);

      return true;
    } catch (error) {
      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false, errorMessage: _mapError(error));

      return false;
    }
  }

  Future<bool> addItem({
    required String dishId,
    required int quantity,
    String? notes,
  }) async {
    final currentOrder = state.order;

    if (currentOrder == null) {
      state = state.copyWith(
        errorMessage: 'Crie o pedido antes de adicionar itens.',
      );
      return false;
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final updatedOrder = await _addItemUseCase(
        orderId: currentOrder.orderId,
        accessCode: currentOrder.accessCode,
        dishId: dishId,
        quantity: quantity,
        notes: notes,
      );

      if (!ref.mounted) return false;

      state = state.copyWith(order: updatedOrder, isSaving: false);

      return true;
    } catch (error) {
      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false, errorMessage: _mapError(error));

      return false;
    }
  }

  Future<void> refreshOrder() async {
    final currentOrder = state.order;

    if (currentOrder == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updatedOrder = await _getOrderUseCase(
        orderId: currentOrder.orderId,
        accessCode: currentOrder.accessCode,
      );

      if (!ref.mounted) return;

      state = state.copyWith(order: updatedOrder, isLoading: false);
    } catch (error) {
      if (!ref.mounted) return;

      state = state.copyWith(isLoading: false, errorMessage: _mapError(error));
    }
  }

  Future<void> clearOrder(String slug) async {
    await _clearSessionUseCase(slug);

    if (!ref.mounted) return;

    state = state.copyWith(order: null);
  }

  String _mapError(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Não foi possível processar o pedido.';
  }
}
