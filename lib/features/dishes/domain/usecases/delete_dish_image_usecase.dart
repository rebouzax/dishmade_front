import '../repositories/dish_repository.dart';

class DeleteDishImageUseCase {
  final DishRepository _repository;

  const DeleteDishImageUseCase(this._repository);

  Future<void> call({required String dishId}) {
    return _repository.deleteDishImage(dishId: dishId);
  }
}
