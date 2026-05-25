import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/pagination/paginated_response.dart';
import '../../domain/entities/dish_category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';
import '../dtos/create_category_request.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final remoteDataSource = ref.watch(categoryRemoteDataSourceProvider);
  return CategoryRepositoryImpl(remoteDataSource);
});

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;

  const CategoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<PaginatedResponse<DishCategory>> getCategories({
    String? search,
    bool? isActive,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final response = await _remoteDataSource.getCategories(
      search: search,
      isActive: isActive,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    return PaginatedResponse<DishCategory>(
      items: response.items.map((dto) => dto.toEntity()).toList(),
      pageNumber: response.pageNumber,
      pageSize: response.pageSize,
      totalCount: response.totalCount,
      totalPages: response.totalPages,
      hasPreviousPage: response.hasPreviousPage,
      hasNextPage: response.hasNextPage,
    );
  }

  @override
  Future<String> createCategory({required String name, String? description}) {
    return _remoteDataSource.createCategory(
      CreateCategoryRequest(name: name, description: description),
    );
  }
}
