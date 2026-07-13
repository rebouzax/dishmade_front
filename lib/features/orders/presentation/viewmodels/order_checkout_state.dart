import '../../domain/entities/order_receipt.dart';

const _unset = Object();

class OrderCheckoutState {
  final OrderReceipt? receipt;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  const OrderCheckoutState({
    this.receipt,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  OrderCheckoutState copyWith({
    Object? receipt = _unset,
    bool? isLoading,
    bool? isSaving,
    Object? errorMessage = _unset,
  }) {
    return OrderCheckoutState(
      receipt: receipt == _unset ? this.receipt : receipt as OrderReceipt?,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
