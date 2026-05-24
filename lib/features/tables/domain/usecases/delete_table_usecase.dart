import '../repositories/table_repository.dart';

class DeleteTableUseCase {
  final TableRepository _repository;

  const DeleteTableUseCase(this._repository);

  Future<void> call({required String id}) {
    return _repository.deleteTable(id: id);
  }
}
