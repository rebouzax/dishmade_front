import '../repositories/dish_repository.dart';

class DeleteDishOptionGroupUseCase {
  final DishRepository _repository;

  const DeleteDishOptionGroupUseCase(this._repository);

  Future<void> call({required String dishId, required String groupId}) {
    return _repository.deleteOptionGroup(dishId: dishId, groupId: groupId);
  }
}
