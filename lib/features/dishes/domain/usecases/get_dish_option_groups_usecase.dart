import '../entities/dish_option_group.dart';
import '../repositories/dish_repository.dart';

class GetDishOptionGroupsUseCase {
  final DishRepository _repository;

  const GetDishOptionGroupsUseCase(this._repository);

  Future<List<DishOptionGroup>> call({required String dishId}) {
    return _repository.getOptionGroups(dishId: dishId);
  }
}
