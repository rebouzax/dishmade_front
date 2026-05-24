import '../repositories/dish_repository.dart';

class UpdateDishUseCase {
  final DishRepository _repository;

  const UpdateDishUseCase(this._repository);

  Future<void> call({
    required String id,
    required String name,
    required String description,
    required double price,
    required String categoryId,
  }) {
    return _repository.updateDish(
      id: id,
      name: name,
      description: description,
      price: price,
      categoryId: categoryId,
    );
  }
}
