import 'package:dishmade_front/core/errors/app_exception.dart';
import 'package:dishmade_front/features/public_menu/domain/usescases/get_public_menu_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/public_menu_repository_impl.dart';
import 'public_menu_state.dart';

final getPublicMenuUseCaseProvider = Provider<GetPublicMenuUseCase>((ref) {
  final repository = ref.watch(publicMenuRepositoryProvider);
  return GetPublicMenuUseCase(repository);
});

final publicMenuViewModelProvider =
    NotifierProvider.autoDispose<PublicMenuViewModel, PublicMenuState>(
      PublicMenuViewModel.new,
    );

class PublicMenuViewModel extends Notifier<PublicMenuState> {
  late final GetPublicMenuUseCase _getPublicMenuUseCase;

  @override
  PublicMenuState build() {
    _getPublicMenuUseCase = ref.watch(getPublicMenuUseCaseProvider);
    return const PublicMenuState();
  }

  Future<void> loadMenu(String slug) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      selectedCategoryId: null,
    );

    try {
      final response = await _getPublicMenuUseCase(slug);

      if (!ref.mounted) return;

      state = state.copyWith(menu: response, isLoading: false);
    } catch (error) {
      if (!ref.mounted) return;

      state = state.copyWith(isLoading: false, errorMessage: _mapError(error));
    }
  }

  void selectCategory(String? categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
  }

  String _mapError(Object error) {
    if (error is ApiException) {
      if (error.statusCode == 404) {
        return 'Restaurante não encontrado ou indisponível.';
      }

      return error.message;
    }

    return 'Não foi possível carregar o cardápio.';
  }
}
