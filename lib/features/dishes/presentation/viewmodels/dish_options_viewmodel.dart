import 'package:dishmade_front/core/errors/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/dish_repository_impl.dart';
import '../../domain/usecases/create_dish_option_group_usecase.dart';
import '../../domain/usecases/create_dish_option_usecase.dart';
import '../../domain/usecases/get_dish_option_groups_usecase.dart';
import 'dish_options_state.dart';

final getDishOptionGroupsUseCaseProvider = Provider<GetDishOptionGroupsUseCase>(
  (ref) {
    final repository = ref.watch(dishRepositoryProvider);
    return GetDishOptionGroupsUseCase(repository);
  },
);

final createDishOptionGroupUseCaseProvider =
    Provider<CreateDishOptionGroupUseCase>((ref) {
      final repository = ref.watch(dishRepositoryProvider);
      return CreateDishOptionGroupUseCase(repository);
    });

final createDishOptionUseCaseProvider = Provider<CreateDishOptionUseCase>((
  ref,
) {
  final repository = ref.watch(dishRepositoryProvider);
  return CreateDishOptionUseCase(repository);
});

final dishOptionsViewModelProvider =
    NotifierProvider.autoDispose<DishOptionsViewModel, DishOptionsState>(
      DishOptionsViewModel.new,
    );

class DishOptionsViewModel extends Notifier<DishOptionsState> {
  late final GetDishOptionGroupsUseCase _getGroupsUseCase;
  late final CreateDishOptionGroupUseCase _createGroupUseCase;
  late final CreateDishOptionUseCase _createOptionUseCase;

  @override
  DishOptionsState build() {
    _getGroupsUseCase = ref.watch(getDishOptionGroupsUseCaseProvider);
    _createGroupUseCase = ref.watch(createDishOptionGroupUseCaseProvider);
    _createOptionUseCase = ref.watch(createDishOptionUseCaseProvider);
    return const DishOptionsState();
  }

  Future<void> loadGroups(String dishId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final groups = await _getGroupsUseCase(dishId: dishId);

      if (!ref.mounted) return;

      state = state.copyWith(groups: groups, isLoading: false);
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: _mapError(error));
    }
  }

  Future<bool> createGroup({
    required String dishId,
    required String name,
    required bool isRequired,
    required int minSelection,
    required int maxSelection,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _createGroupUseCase(
        dishId: dishId,
        name: name,
        isRequired: isRequired,
        minSelection: minSelection,
        maxSelection: maxSelection,
      );

      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false);
      await loadGroups(dishId);
      return true;
    } catch (error) {
      if (!ref.mounted) return false;
      state = state.copyWith(isSaving: false, errorMessage: _mapError(error));
      return false;
    }
  }

  Future<bool> createOption({
    required String dishId,
    required String optionGroupId,
    required String name,
    required double additionalPrice,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _createOptionUseCase(
        dishId: dishId,
        optionGroupId: optionGroupId,
        name: name,
        additionalPrice: additionalPrice,
      );

      if (!ref.mounted) return false;

      state = state.copyWith(isSaving: false);
      await loadGroups(dishId);
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
    return 'Não foi possível processar os adicionais do prato.';
  }
}
