import '../../domain/entities/dashboard_summary.dart';

const _unset = Object();

class DashboardState {
  final DashboardSummary summary;
  final bool isLoading;
  final String? errorMessage;

  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? lastUpdatedAt;

  const DashboardState({
    this.summary = const DashboardSummary.empty(),
    this.isLoading = false,
    this.errorMessage,
    this.startDate,
    this.endDate,
    this.lastUpdatedAt,
  });

  DashboardState copyWith({
    DashboardSummary? summary,
    bool? isLoading,
    Object? errorMessage = _unset,
    Object? startDate = _unset,
    Object? endDate = _unset,
    Object? lastUpdatedAt = _unset,
  }) {
    return DashboardState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      startDate: startDate == _unset ? this.startDate : startDate as DateTime?,
      endDate: endDate == _unset ? this.endDate : endDate as DateTime?,
      lastUpdatedAt: lastUpdatedAt == _unset
          ? this.lastUpdatedAt
          : lastUpdatedAt as DateTime?,
    );
  }
}
