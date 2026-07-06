import 'package:dishmade_front/core/errors/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/dish_repository_impl.dart';
import '../../domain/usecases/create_dish_option_group_usecase.dart';
import '../../domain/usecases/create_dish_option_usecase.dart';
import '../../domain/usecases/delete_dish_option_group_usecase.dart';
import '../../domain/usecases/delete_dish_option_usecase.dart';
import '../../domain/usecases/get_dish_option_groups_usecase.dart';
import '../../domain/usecases/set_dish_option_availability_usecase.dart';
import '../../domain/usecases/update_dish_option_group_usecase.dart';
import '../../domain/usecases/update_dish_option_usecase.dart';
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

final updateDishOptionGroupUseCaseProvider =
    Provider<UpdateDishOptionGroupUseCase>((ref) {
      final repository = ref.watch(dishRepositoryProvider);
      return UpdateDishOptionGroupUseCase(repository);
    });

final deleteDishOptionGroupUseCaseProvider =
    Provider<DeleteDishOptionGroupUseCase>((ref) {
      final repository = ref.watch(dishRepositoryProvider);
      return DeleteDishOptionGroupUseCase(repository);
    });

final updateDishOptionUseCaseProvider = Provider<UpdateDishOptionUseCase>((
  ref,
) {
  final repository = ref.watch(dishRepositoryProvider);
  return UpdateDishOptionUseCase(repository);
});

final setDishOptionAvailabilityUseCaseProvider =
    Provider<SetDishOptionAvailabilityUseCase>((ref) {
      final repository = ref.watch(dishRepositoryProvider);
      return SetDishOptionAvailabilityUseCase(repository);
    });

final deleteDishOptionUseCaseProvider = Provider<DeleteDishOptionUseCase>((
  ref,
) {
  final repository = ref.watch(dishRepositoryProvider);
  return DeleteDishOptionUseCase(repository);
});

final dishOptionsViewModelProvider =
    NotifierProvider.autoDispose<DishOptionsViewModel, DishOptionsState>(
      DishOptionsViewModel.new,
    );

class DishOptionsViewModel extends Notifier<DishOptionsState> {
  late final GetDishOptionGroupsUseCase _getGroupsUseCase;
  late final CreateDishOptionGroupUseCase _createGroupUseCase;
  late final CreateDishOptionUseCase _createOptionUseCase;
  late final UpdateDishOptionGroupUseCase _updateGroupUseCase;
  late final DeleteDishOptionGroupUseCase _deleteGroupUseCase;
  late final UpdateDishOptionUseCase _updateOptionUseCase;
  late final SetDishOptionAvailabilityUseCase _setOptionAvailabilityUseCase;
  late final DeleteDishOptionUseCase _deleteOptionUseCase;

  @override
  DishOptionsState build() {
    _getGroupsUseCase = ref.watch(getDishOptionGroupsUseCaseProvider);
    _createGroupUseCase = ref.watch(createDishOptionGroupUseCaseProvider);
    _createOptionUseCase = ref.watch(createDishOptionUseCaseProvider);
    _updateGroupUseCase = ref.watch(updateDishOptionGroupUseCaseProvider);
    _deleteGroupUseCase = ref.watch(deleteDishOptionGroupUseCaseProvider);
    _updateOptionUseCase = ref.watch(updateDishOptionUseCaseProvider);
    _setOptionAvailabilityUseCase = ref.watch(
      setDishOptionAvailabilityUseCaseProvider,
    );
    _deleteOptionUseCase = ref.watch(deleteDishOptionUseCaseProvider);
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

  Future<bool> updateGroup({
    required String dishId,
    required String groupId,
    required String name,
    required bool isRequired,
    required int minSelection,
    required int maxSelection,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _updateGroupUseCase(
        dishId: dishId,
        groupId: groupId,
        name: name.trim(),
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

  Future<bool> deleteGroup({
    required String dishId,
    required String groupId,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _deleteGroupUseCase(dishId: dishId, groupId: groupId);

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

  Future<bool> updateOption({
    required String dishId,
    required String groupId,
    required String optionId,
    required String name,
    required double additionalPrice,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _updateOptionUseCase(
        dishId: dishId,
        groupId: groupId,
        optionId: optionId,
        name: name.trim(),
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

  Future<bool> setOptionAvailability({
    required String dishId,
    required String groupId,
    required String optionId,
    required bool isAvailable,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _setOptionAvailabilityUseCase(
        dishId: dishId,
        groupId: groupId,
        optionId: optionId,
        isAvailable: isAvailable,
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

  Future<bool> deleteOption({
    required String dishId,
    required String groupId,
    required String optionId,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _deleteOptionUseCase(
        dishId: dishId,
        groupId: groupId,
        optionId: optionId,
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
