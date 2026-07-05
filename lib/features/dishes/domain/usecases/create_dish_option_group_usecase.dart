import '../entities/dish_option_group.dart';
import '../repositories/dish_repository.dart';

class CreateDishOptionGroupUseCase {
  final DishRepository _repository;

  const CreateDishOptionGroupUseCase(this._repository);

  Future<DishOptionGroup> call({
    required String dishId,
    required String name,
    required bool isRequired,
    required int minSelection,
    required int maxSelection,
  }) {
    return _repository.createOptionGroup(
      dishId: dishId,
      name: name,
      isRequired: isRequired,
      minSelection: minSelection,
      maxSelection: maxSelection,
    );
  }
}
