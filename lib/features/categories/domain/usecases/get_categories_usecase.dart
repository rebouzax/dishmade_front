import 'package:dishmade_front/features/dishes/domain/entities/dish_category.dart';
import '../../../../core/pagination/paginated_response.dart';
import '../repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository _repository;

  const GetCategoriesUseCase(this._repository);

  Future<PaginatedResponse<DishCategory>> call({
    String? search,
    bool? isActive,
    int pageNumber = 1,
    int pageSize = 20,
  }) {
    return _repository.getCategories(
      search: search,
      isActive: isActive,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
