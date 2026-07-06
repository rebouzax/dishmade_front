import '../entities/service_request.dart';
import '../repositories/service_request_repository.dart';

class ResolveServiceRequestUseCase {
  final ServiceRequestRepository _repository;

  const ResolveServiceRequestUseCase(this._repository);

  Future<ServiceRequest> call({required String id}) {
    return _repository.resolve(id: id);
  }
}
