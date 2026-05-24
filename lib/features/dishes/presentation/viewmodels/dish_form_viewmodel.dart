import 'package:dishmade_front/core/errors/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/dish_repository_impl.dart';
import '../../domain/usecases/create_dish_usecase.dart';
import '../../domain/usecases/update_dish_usecase.dart';
import 'dish_form_state.dart';

final createDishUseCaseProvider = Provider<CreateDishUseCase>((ref) {
  final repository = ref.watch(dishRepositoryProvider);
  return CreateDishUseCase(repository);
});

final updateDishUseCaseProvider = Provider<UpdateDishUseCase>((ref) {
  final repository = ref.watch(dishRepositoryProvider);
  return UpdateDishUseCase(repository);
});

final dishFormViewModelProvider =
    NotifierProvider.autoDispose<DishFormViewModel, DishFormState>(
      DishFormViewModel.new,
    );

class DishFormViewModel extends Notifier<DishFormState> {
  late final CreateDishUseCase _createDishUseCase;
  late final UpdateDishUseCase _updateDishUseCase;

  @override
  DishFormState build() {
    _createDishUseCase = ref.watch(createDishUseCaseProvider);
    _updateDishUseCase = ref.watch(updateDishUseCaseProvider);

    return const DishFormState();
  }

  Future<bool> createDish({
    required String name,
    required String description,
    required double price,
    required String categoryId,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _createDishUseCase(
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
      );

      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false);
      return true;
    } catch (error) {
      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false, errorMessage: _mapError(error));
      return false;
    }
  }

  Future<bool> updateDish({
    required String id,
    required String name,
    required String description,
    required double price,
    required String categoryId,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _updateDishUseCase(
        id: id,
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
      );

      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false);
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

    return 'Não foi possível salvar o prato.';
  }
}
