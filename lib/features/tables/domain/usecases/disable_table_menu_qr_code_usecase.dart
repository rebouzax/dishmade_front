import '../repositories/table_repository.dart';

class DisableTableMenuQrCodeUseCase {
  final TableRepository _repository;

  const DisableTableMenuQrCodeUseCase(this._repository);

  Future call({required String id}) {
    return _repository.disableMenuQrCode(id: id);
  }
}
