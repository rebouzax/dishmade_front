import 'package:dishmade_front/features/dashboard/domain/repositories/dashboard_repository.dart';

import '../entities/dashboard_summary.dart';

class GetDashboardUseCase {
  final DashboardRepository _repository;

  const GetDashboardUseCase(this._repository);

  Future<DashboardSummary> call({DateTime? startDate, DateTime? endDate}) {
    return _repository.getDashboard(startDate: startDate, endDate: endDate);
  }
}
