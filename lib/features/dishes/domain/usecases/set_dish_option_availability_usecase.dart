import '../entities/dish_option.dart';
import '../repositories/dish_repository.dart';

class SetDishOptionAvailabilityUseCase {
  final DishRepository _repository;

  const SetDishOptionAvailabilityUseCase(this._repository);

  Future<DishOption> call({
    required String dishId,
    required String groupId,
    required String optionId,
    required bool isAvailable,
  }) {
    return _repository.setOptionAvailability(
      dishId: dishId,
      groupId: groupId,
      optionId: optionId,
      isAvailable: isAvailable,
    );
  }
}
