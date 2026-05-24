import '../../../../core/pagination/paginated_response.dart';
import '../entities/dish.dart';

abstract interface class DishRepository {
  Future<PaginatedResponse<Dish>> getDishes({
    String? search,
    String? categoryId,
    bool? isAvailable,
    int pageNumber = 1,
    int pageSize = 20,
  });
}
