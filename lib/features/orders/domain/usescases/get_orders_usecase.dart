import '../../../../core/pagination/paginated_response.dart';
import '../entities/order_status.dart';
import '../entities/restaurant_order.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository _repository;

  const GetOrdersUseCase(this._repository);

  Future<PaginatedResponse<RestaurantOrder>> call({
    OrderStatus? status,
    String? tableId,
    DateTime? startDate,
    DateTime? endDate,
    int pageNumber = 1,
    int pageSize = 20,
  }) {
    return _repository.getOrders(
      status: status,
      tableId: tableId,
      startDate: startDate,
      endDate: endDate,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
