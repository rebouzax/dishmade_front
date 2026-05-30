import 'dart:typed_data';

import 'package:dishmade_front/core/errors/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/dish_repository_impl.dart';
import '../../domain/usecases/get_dish_image_bytes_usecase.dart';

final getDishImageBytesUseCaseProvider = Provider<GetDishImageBytesUseCase>((
  ref,
) {
  final repository = ref.watch(dishRepositoryProvider);
  return GetDishImageBytesUseCase(repository);
});

final dishImageBytesProvider = FutureProvider.autoDispose
    .family<Uint8List?, String>((ref, dishId) async {
      final useCase = ref.watch(getDishImageBytesUseCaseProvider);

      try {
        return await useCase(dishId: dishId);
      } catch (error) {
        if (error is ApiException && error.statusCode == 404) {
          return null;
        }

        rethrow;
      }
    });
