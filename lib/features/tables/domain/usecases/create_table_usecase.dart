import '../repositories/table_repository.dart';

class CreateTableUseCase {
  final TableRepository _repository;

  const CreateTableUseCase(this._repository);

  Future<String> call({required int number}) {
    return _repository.createTable(number: number);
  }
}
