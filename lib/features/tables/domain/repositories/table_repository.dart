import '../../../../core/pagination/paginated_response.dart';
import '../entities/restaurant_table.dart';

abstract interface class TableRepository {
  Future<PaginatedResponse<RestaurantTable>> getTables({
    int? number,
    bool? isOccupied,
    int pageNumber = 1,
    int pageSize = 20,
  });

  Future<String> createTable({required int number});

  Future<void> updateTable({required String id, required int number});

  Future<void> occupyTable({required String id});

  Future<void> releaseTable({required String id});

  Future<void> deleteTable({required String id});
}
