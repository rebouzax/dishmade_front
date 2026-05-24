import '../../../../core/pagination/paginated_response.dart';
import '../entities/dish.dart';
import '../repositories/dish_repository.dart';

class GetDishesUseCase {
  final DishRepository _repository;

  const GetDishesUseCase(this._repository);

  Future<PaginatedResponse<Dish>> call({
    String? search,
    String? categoryId,
    bool? isAvailable,
    int pageNumber = 1,
    int pageSize = 20,
  }) {
    return _repository.getDishes(
      search: search,
      categoryId: categoryId,
      isAvailable: isAvailable,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
