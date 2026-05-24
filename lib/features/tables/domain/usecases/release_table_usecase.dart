import '../repositories/table_repository.dart';

class ReleaseTableUseCase {
  final TableRepository _repository;

  const ReleaseTableUseCase(this._repository);

  Future<void> call({required String id}) {
    return _repository.releaseTable(id: id);
  }
}
