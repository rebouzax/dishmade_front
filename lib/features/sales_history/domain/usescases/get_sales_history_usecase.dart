import 'package:dishmade_front/features/sales_history/data/repositories/sales_history_repository.dart';

import '../../../../core/pagination/paginated_response.dart';
import '../entities/sale_history.dart';

class GetSalesHistoryUseCase {
  final SalesHistoryRepository _repository;

  const GetSalesHistoryUseCase(this._repository);

  Future<PaginatedResponse<SaleHistory>> call({
    DateTime? startDate,
    DateTime? endDate,
    int pageNumber = 1,
    int pageSize = 20,
  }) {
    return _repository.getSalesHistory(
      startDate: startDate,
      endDate: endDate,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
