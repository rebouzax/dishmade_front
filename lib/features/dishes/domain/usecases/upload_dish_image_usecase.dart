import 'dart:typed_data';

import '../repositories/dish_repository.dart';

class UploadDishImageUseCase {
  final DishRepository _repository;

  const UploadDishImageUseCase(this._repository);

  Future<void> call({
    required String dishId,
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) {
    return _repository.uploadDishImage(
      dishId: dishId,
      bytes: bytes,
      fileName: fileName,
      contentType: contentType,
    );
  }
}
