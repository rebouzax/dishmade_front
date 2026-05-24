import '../repositories/dish_repository.dart';

class CreateDishUseCase {
  final DishRepository _repository;

  const CreateDishUseCase(this._repository);

  Future<String> call({
    required String name,
    required String description,
    required double price,
    required String categoryId,
  }) {
    return _repository.createDish(
      name: name,
      description: description,
      price: price,
      categoryId: categoryId,
    );
  }
}
