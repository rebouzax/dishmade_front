import '../enums/service_request_status.dart';
import '../enums/service_request_type.dart';
import '../repositories/service_request_repository.dart';

class GetServiceRequestsUseCase {
  final ServiceRequestRepository _repository;

  const GetServiceRequestsUseCase(this._repository);

  Future<ServiceRequestPage> call({
    ServiceRequestStatus? status,
    ServiceRequestType? type,
    String? tableId,
    required int pageNumber,
    required int pageSize,
  }) {
    return _repository.getAll(
      status: status,
      type: type,
      tableId: tableId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
