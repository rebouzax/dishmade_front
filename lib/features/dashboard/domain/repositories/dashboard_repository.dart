import 'package:dishmade_front/features/dashboard/domain/entities/dashboard_summary.dart';

abstract interface class DashboardRepository {
  Future<DashboardSummary> getDashboard({
    DateTime? startDate,
    DateTime? endDate,
  });
}
