import '../repositories/table_repository.dart';

class EnableTableMenuQrCodeUseCase {
  final TableRepository _repository;

  const EnableTableMenuQrCodeUseCase(this._repository);

  Future call({required String id}) {
    return _repository.enableMenuQrCode(id: id);
  }
}
