import '../entities/dish_option_group.dart';
import '../repositories/dish_repository.dart';

class UpdateDishOptionGroupUseCase {
  final DishRepository _repository;

  const UpdateDishOptionGroupUseCase(this._repository);

  Future<DishOptionGroup> call({
    required String dishId,
    required String groupId,
    required String name,
    required bool isRequired,
    required int minSelection,
    required int maxSelection,
  }) {
    return _repository.updateOptionGroup(
      dishId: dishId,
      groupId: groupId,
      name: name,
      isRequired: isRequired,
      minSelection: minSelection,
      maxSelection: maxSelection,
    );
  }
}
