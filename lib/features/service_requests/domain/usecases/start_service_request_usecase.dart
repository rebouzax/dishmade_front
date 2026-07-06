import '../entities/service_request.dart';
import '../repositories/service_request_repository.dart';

class StartServiceRequestUseCase {
  final ServiceRequestRepository _repository;

  const StartServiceRequestUseCase(this._repository);

  Future<ServiceRequest> call({required String id}) {
    return _repository.start(id: id);
  }
}
