import '../repositories/dish_repository.dart';

class DeleteDishOptionUseCase {
  final DishRepository _repository;

  const DeleteDishOptionUseCase(this._repository);

  Future<void> call({
    required String dishId,
    required String groupId,
    required String optionId,
  }) {
    return _repository.deleteOption(
      dishId: dishId,
      groupId: groupId,
      optionId: optionId,
    );
  }
}
