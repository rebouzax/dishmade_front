import 'package:dishmade_front/core/errors/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/service_request_repository_impl.dart';
import '../../domain/enums/service_request_type.dart';
import '../../domain/usecases/create_public_service_request_usecase.dart';
import 'public_service_request_state.dart';

final createPublicServiceRequestUseCaseProvider =
    Provider<CreatePublicServiceRequestUseCase>((ref) {
      final repository = ref.watch(serviceRequestRepositoryProvider);
      return CreatePublicServiceRequestUseCase(repository);
    });

final publicServiceRequestViewModelProvider =
    NotifierProvider.autoDispose<
      PublicServiceRequestViewModel,
      PublicServiceRequestState
    >(PublicServiceRequestViewModel.new);

class PublicServiceRequestViewModel
    extends Notifier<PublicServiceRequestState> {
  late final CreatePublicServiceRequestUseCase _createUseCase;

  @override
  PublicServiceRequestState build() {
    _createUseCase = ref.watch(createPublicServiceRequestUseCaseProvider);
    return const PublicServiceRequestState();
  }

  Future<bool> sendRequest({
    required String restaurantSlug,
    required int tableNumber,
    required ServiceRequestType type,
    String? message,
  }) async {
    state = state.copyWith(isSending: true, errorMessage: null);

    try {
      await _createUseCase(
        restaurantSlug: restaurantSlug,
        tableNumber: tableNumber,
        type: type,
        message: message,
      );

      if (!ref.mounted) return false;

      state = state.copyWith(isSending: false);
      return true;
    } catch (error) {
      if (!ref.mounted) return false;

      state = state.copyWith(isSending: false, errorMessage: _mapError(error));

      return false;
    }
  }

  String _mapError(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Erro ao enviar solicitação.';
  }
}
