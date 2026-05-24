import '../../../../core/pagination/paginated_response.dart';
import '../entities/restaurant_table.dart';
import '../repositories/table_repository.dart';

class GetTablesUseCase {
  final TableRepository _repository;

  const GetTablesUseCase(this._repository);

  Future<PaginatedResponse<RestaurantTable>> call({
    int? number,
    bool? isOccupied,
    int pageNumber = 1,
    int pageSize = 20,
  }) {
    return _repository.getTables(
      number: number,
      isOccupied: isOccupied,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
