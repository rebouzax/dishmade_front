import '../../domain/entities/public_order.dart';

const _unset = Object();

class PublicOrderState {
  final PublicOrder? order;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  const PublicOrderState({
    this.order,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  bool get hasOrder => order != null;

  PublicOrderState copyWith({
    Object? order = _unset,
    bool? isLoading,
    bool? isSaving,
    Object? errorMessage = _unset,
  }) {
    return PublicOrderState(
      order: order == _unset ? this.order : order as PublicOrder?,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
