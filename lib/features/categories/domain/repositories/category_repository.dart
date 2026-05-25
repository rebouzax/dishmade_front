import '../../../../core/pagination/paginated_response.dart';
import '../entities/dish_category.dart';

abstract interface class CategoryRepository {
  Future<PaginatedResponse<DishCategory>> getCategories({
    String? search,
    bool? isActive,
    int pageNumber = 1,
    int pageSize = 20,
  });

  Future<String> createCategory({required String name, String? description});
}
