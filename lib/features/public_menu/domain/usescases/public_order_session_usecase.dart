import '../entities/public_order_session.dart';
import '../repositories/public_order_repository.dart';

class SavePublicOrderSessionUseCase {
  final PublicOrderRepository _repository;

  const SavePublicOrderSessionUseCase(this._repository);

  Future<void> call(PublicOrderSession session) {
    return _repository.saveSession(session);
  }
}

class GetPublicOrderSessionUseCase {
  final PublicOrderRepository _repository;

  const GetPublicOrderSessionUseCase(this._repository);

  Future<PublicOrderSession?> call(String slug) {
    return _repository.getSession(slug);
  }
}

class ClearPublicOrderSessionUseCase {
  final PublicOrderRepository _repository;

  const ClearPublicOrderSessionUseCase(this._repository);

  Future<void> call(String slug) {
    return _repository.clearSession(slug);
  }
}
