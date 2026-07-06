import '../entities/service_request.dart';
import '../enums/service_request_type.dart';
import '../repositories/service_request_repository.dart';

class CreatePublicServiceRequestUseCase {
  final ServiceRequestRepository _repository;

  const CreatePublicServiceRequestUseCase(this._repository);

  Future<ServiceRequest> call({
    required String restaurantSlug,
    required int tableNumber,
    required ServiceRequestType type,
    String? message,
  }) {
    return _repository.createPublic(
      restaurantSlug: restaurantSlug,
      tableNumber: tableNumber,
      type: type,
      message: message,
    );
  }
}
