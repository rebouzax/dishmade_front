import '../repositories/table_repository.dart';

class UpdateTableUseCase {
  final TableRepository _repository;

  const UpdateTableUseCase(this._repository);

  Future<void> call({required String id, required int number}) {
    return _repository.updateTable(id: id, number: number);
  }
}
