import '../repositories/table_repository.dart';

class OccupyTableUseCase {
  final TableRepository _repository;

  const OccupyTableUseCase(this._repository);

  Future<void> call({required String id}) {
    return _repository.occupyTable(id: id);
  }
}
