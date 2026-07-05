import '../entities/dish_option.dart';
import '../repositories/dish_repository.dart';

class CreateDishOptionUseCase {
  final DishRepository _repository;

  const CreateDishOptionUseCase(this._repository);

  Future<DishOption> call({
    required String dishId,
    required String optionGroupId,
    required String name,
    required double additionalPrice,
  }) {
    return _repository.createOption(
      dishId: dishId,
      optionGroupId: optionGroupId,
      name: name,
      additionalPrice: additionalPrice,
    );
  }
}
