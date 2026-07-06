import '../entities/service_request.dart';
import '../repositories/service_request_repository.dart';

class CancelServiceRequestUseCase {
  final ServiceRequestRepository _repository;

  const CancelServiceRequestUseCase(this._repository);

  Future<ServiceRequest> call({required String id}) {
    return _repository.cancel(id: id);
  }
}
