import '../repositories/table_repository.dart';

class GetTableMenuQrCodeUseCase {
  final TableRepository _repository;

  const GetTableMenuQrCodeUseCase(this._repository);

  Future call({required String id}) {
    return _repository.getMenuQrCode(id: id);
  }
}
