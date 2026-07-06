import '../../domain/entities/service_request.dart';
import '../../domain/enums/service_request_status.dart';
import '../../domain/enums/service_request_type.dart';

const _unset = Object();

class ServiceRequestsState {
  final List<ServiceRequest> requests;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final ServiceRequestStatus? statusFilter;
  final ServiceRequestType? typeFilter;
  final int pageNumber;
  final int pageSize;
  final int totalCount;

  const ServiceRequestsState({
    this.requests = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.statusFilter = ServiceRequestStatus.pending,
    this.typeFilter,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.totalCount = 0,
  });

  bool get hasNextPage => pageNumber * pageSize < totalCount;

  ServiceRequestsState copyWith({
    List<ServiceRequest>? requests,
    bool? isLoading,
    bool? isSaving,
    Object? errorMessage = _unset,
    Object? statusFilter = _unset,
    Object? typeFilter = _unset,
    int? pageNumber,
    int? pageSize,
    int? totalCount,
  }) {
    return ServiceRequestsState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      statusFilter: statusFilter == _unset
          ? this.statusFilter
          : statusFilter as ServiceRequestStatus?,
      typeFilter: typeFilter == _unset
          ? this.typeFilter
          : typeFilter as ServiceRequestType?,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}
