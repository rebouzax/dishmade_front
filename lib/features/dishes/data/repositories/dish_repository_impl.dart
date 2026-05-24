import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/pagination/paginated_response.dart';
import '../../domain/entities/dish.dart';
import '../../domain/repositories/dish_repository.dart';
import '../datasources/dish_remote_datasource.dart';

final dishRepositoryProvider = Provider<DishRepository>((ref) {
  final remoteDataSource = ref.watch(dishRemoteDataSourceProvider);
  return DishRepositoryImpl(remoteDataSource);
});

class DishRepositoryImpl implements DishRepository {
  final DishRemoteDataSource _remoteDataSource;

  const DishRepositoryImpl(this._remoteDataSource);

  @override
  Future<PaginatedResponse<Dish>> getDishes({
    String? search,
    String? categoryId,
    bool? isAvailable,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final response = await _remoteDataSource.getDishes(
      search: search,
      categoryId: categoryId,
      isAvailable: isAvailable,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    return PaginatedResponse<Dish>(
      items: response.items.map((dto) => dto.toEntity()).toList(),
      pageNumber: response.pageNumber,
      pageSize: response.pageSize,
      totalCount: response.totalCount,
      totalPages: response.totalPages,
      hasPreviousPage: response.hasPreviousPage,
      hasNextPage: response.hasNextPage,
    );
  }
}
