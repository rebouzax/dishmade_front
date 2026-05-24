import 'package:dishmade_front/features/dishes/domain/entities/dish_category.dart';
import '../../../../core/pagination/paginated_response.dart';

abstract interface class CategoryRepository {
  Future<PaginatedResponse<DishCategory>> getCategories({
    String? search,
    bool? isActive,
    int pageNumber = 1,
    int pageSize = 20,
  });
}
