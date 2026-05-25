import '../../../orders/domain/entities/restaurant_order.dart';

const _unset = Object();

class KitchenState {
  final List<RestaurantOrder> createdOrders;
  final List<RestaurantOrder> inPreparationOrders;
  final List<RestaurantOrder> readyOrders;

  final bool isLoading;
  final bool isSaving;
  final String? processingOrderId;
  final String? errorMessage;
  final DateTime? lastUpdatedAt;

  const KitchenState({
    this.createdOrders = const [],
    this.inPreparationOrders = const [],
    this.readyOrders = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.processingOrderId,
    this.errorMessage,
    this.lastUpdatedAt,
  });

  int get totalOrders {
    return createdOrders.length +
        inPreparationOrders.length +
        readyOrders.length;
  }

  bool get isEmpty {
    return createdOrders.isEmpty &&
        inPreparationOrders.isEmpty &&
        readyOrders.isEmpty;
  }

  KitchenState copyWith({
    List<RestaurantOrder>? createdOrders,
    List<RestaurantOrder>? inPreparationOrders,
    List<RestaurantOrder>? readyOrders,
    bool? isLoading,
    bool? isSaving,
    Object? processingOrderId = _unset,
    Object? errorMessage = _unset,
    DateTime? lastUpdatedAt,
  }) {
    return KitchenState(
      createdOrders: createdOrders ?? this.createdOrders,
      inPreparationOrders: inPreparationOrders ?? this.inPreparationOrders,
      readyOrders: readyOrders ?? this.readyOrders,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      processingOrderId: processingOrderId == _unset
          ? this.processingOrderId
          : processingOrderId as String?,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}
