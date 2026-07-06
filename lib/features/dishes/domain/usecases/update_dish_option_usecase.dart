import '../entities/dish_option.dart';
import '../repositories/dish_repository.dart';

class UpdateDishOptionUseCase {
  final DishRepository _repository;

  const UpdateDishOptionUseCase(this._repository);

  Future<DishOption> call({
    required String dishId,
    required String groupId,
    required String optionId,
    required String name,
    required double additionalPrice,
  }) {
    return _repository.updateOption(
      dishId: dishId,
      groupId: groupId,
      optionId: optionId,
      name: name,
      additionalPrice: additionalPrice,
    );
  }
}
