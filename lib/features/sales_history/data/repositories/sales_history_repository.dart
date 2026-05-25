import 'package:dishmade_front/features/sales_history/domain/entities/sale_history.dart';

import '../../../../core/pagination/paginated_response.dart';

abstract interface class SalesHistoryRepository {
  Future<PaginatedResponse<SaleHistory>> getSalesHistory({
    DateTime? startDate,
    DateTime? endDate,
    int pageNumber = 1,
    int pageSize = 20,
  });
}
