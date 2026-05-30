import 'dart:typed_data';

import '../repositories/dish_repository.dart';

class GetDishImageBytesUseCase {
  final DishRepository _repository;

  const GetDishImageBytesUseCase(this._repository);

  Future<Uint8List> call({required String dishId}) {
    return _repository.getDishImageBytes(dishId: dishId);
  }
}
