import 'dart:typed_data';
import 'package:dishmade_front/core/errors/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/dish_repository_impl.dart';
import '../../domain/usecases/get_dishes_usecase.dart';
import '../../domain/usecases/delete_dish_image_usecase.dart';
import '../../domain/usecases/upload_dish_image_usecase.dart';
import 'dishes_state.dart';

final getDishesUseCaseProvider = Provider<GetDishesUseCase>((ref) {
  final repository = ref.watch(dishRepositoryProvider);
  return GetDishesUseCase(repository);
});

final uploadDishImageUseCaseProvider = Provider<UploadDishImageUseCase>((ref) {
  final repository = ref.watch(dishRepositoryProvider);
  return UploadDishImageUseCase(repository);
});

final deleteDishImageUseCaseProvider = Provider<DeleteDishImageUseCase>((ref) {
  final repository = ref.watch(dishRepositoryProvider);
  return DeleteDishImageUseCase(repository);
});

final dishesViewModelProvider =
    NotifierProvider.autoDispose<DishesViewModel, DishesState>(
      DishesViewModel.new,
    );

class DishesViewModel extends Notifier<DishesState> {
  late final GetDishesUseCase _getDishesUseCase;
  late final UploadDishImageUseCase _uploadDishImageUseCase;
  late final DeleteDishImageUseCase _deleteDishImageUseCase;

  @override
  DishesState build() {
    _getDishesUseCase = ref.watch(getDishesUseCaseProvider);
    _uploadDishImageUseCase = ref.watch(uploadDishImageUseCaseProvider);
    _deleteDishImageUseCase = ref.watch(deleteDishImageUseCaseProvider);

    Future.microtask(loadInitial);

    return const DishesState();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      pageNumber: 1,
      hasNextPage: false,
    );

    try {
      final response = await _getDishesUseCase(
        search: state.search,
        categoryId: state.categoryId,
        isAvailable: state.isAvailable,
        pageNumber: 1,
        pageSize: state.pageSize,
      );

      if (!ref.mounted) return;

      state = state.copyWith(
        dishes: response.items,
        isLoading: false,
        pageNumber: response.pageNumber,
        totalCount: response.totalCount,
        totalPages: response.totalPages,
        hasNextPage: response.hasNextPage,
      );
    } catch (error) {
      if (!ref.mounted) return;

      state = state.copyWith(isLoading: false, errorMessage: _mapError(error));
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasNextPage) {
      return;
    }

    final nextPage = state.pageNumber + 1;

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      final response = await _getDishesUseCase(
        search: state.search,
        categoryId: state.categoryId,
        isAvailable: state.isAvailable,
        pageNumber: nextPage,
        pageSize: state.pageSize,
      );

      if (!ref.mounted) return;

      state = state.copyWith(
        dishes: [...state.dishes, ...response.items],
        isLoadingMore: false,
        pageNumber: response.pageNumber,
        totalCount: response.totalCount,
        totalPages: response.totalPages,
        hasNextPage: response.hasNextPage,
      );
    } catch (error) {
      if (!ref.mounted) return;

      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: _mapError(error),
      );
    }
  }

  Future<void> setSearch(String value) async {
    state = state.copyWith(search: value.trim());
    await loadInitial();
  }

  Future<void> setCategory(String? categoryId) async {
    state = state.copyWith(categoryId: categoryId);
    await loadInitial();
  }

  Future<void> setAvailability(bool? isAvailable) async {
    state = state.copyWith(isAvailable: isAvailable);
    await loadInitial();
  }

  Future<bool> uploadDishImage({
    required String dishId,
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _uploadDishImageUseCase(
        dishId: dishId,
        bytes: bytes,
        fileName: fileName,
        contentType: contentType,
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

  Future<bool> deleteDishImage(String dishId) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _deleteDishImageUseCase(dishId: dishId);

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

    return 'Não foi possível carregar os pratos.';
  }
}
