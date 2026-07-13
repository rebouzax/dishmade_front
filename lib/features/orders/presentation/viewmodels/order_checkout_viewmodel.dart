import 'package:dishmade_front/core/errors/app_exception.dart';
import 'package:dishmade_front/features/orders/domain/usescases/close_order_account_usecase.dart';
import 'package:dishmade_front/features/orders/domain/usescases/get_order_receipt_usecase.dart';
import 'package:dishmade_front/features/orders/domain/usescases/register_order_payment_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/order_repository_impl.dart';
import '../../domain/enums/payment_method.dart';
import 'order_checkout_state.dart';

final closeOrderAccountUseCaseProvider = Provider<CloseOrderAccountUseCase>((
  ref,
) {
  final repository = ref.watch(orderRepositoryProvider);
  return CloseOrderAccountUseCase(repository);
});

final registerOrderPaymentUseCaseProvider =
    Provider<RegisterOrderPaymentUseCase>((ref) {
      final repository = ref.watch(orderRepositoryProvider);
      return RegisterOrderPaymentUseCase(repository);
    });

final getOrderReceiptUseCaseProvider = Provider<GetOrderReceiptUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return GetOrderReceiptUseCase(repository);
});

final orderCheckoutViewModelProvider =
    NotifierProvider.autoDispose<OrderCheckoutViewModel, OrderCheckoutState>(
      OrderCheckoutViewModel.new,
    );

class OrderCheckoutViewModel extends Notifier<OrderCheckoutState> {
  late final CloseOrderAccountUseCase _closeUseCase;
  late final RegisterOrderPaymentUseCase _paymentUseCase;
  late final GetOrderReceiptUseCase _receiptUseCase;

  @override
  OrderCheckoutState build() {
    _closeUseCase = ref.watch(closeOrderAccountUseCaseProvider);
    _paymentUseCase = ref.watch(registerOrderPaymentUseCaseProvider);
    _receiptUseCase = ref.watch(getOrderReceiptUseCaseProvider);

    return const OrderCheckoutState();
  }

  Future<void> loadReceipt(String orderId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final receipt = await _receiptUseCase(orderId: orderId);

      if (!ref.mounted) return;

      state = state.copyWith(receipt: receipt, isLoading: false);
    } catch (error) {
      if (!ref.mounted) return;

      state = state.copyWith(isLoading: false, errorMessage: _mapError(error));
    }
  }

  Future<bool> closeAccount({
    required String orderId,
    required double discountAmount,
    required double serviceFeeAmount,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final receipt = await _closeUseCase(
        orderId: orderId,
        discountAmount: discountAmount,
        serviceFeeAmount: serviceFeeAmount,
      );

      if (!ref.mounted) return false;

      state = state.copyWith(receipt: receipt, isSaving: false);

      return true;
    } catch (error) {
      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false, errorMessage: _mapError(error));

      return false;
    }
  }

  Future<bool> registerPayment({
    required String orderId,
    required PaymentMethod method,
    required double amount,
    String? notes,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final receipt = await _paymentUseCase(
        orderId: orderId,
        method: method,
        amount: amount,
        notes: notes,
      );

      if (!ref.mounted) return false;

      state = state.copyWith(receipt: receipt, isSaving: false);

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

    return 'Não foi possível processar o fechamento da conta.';
  }
}
