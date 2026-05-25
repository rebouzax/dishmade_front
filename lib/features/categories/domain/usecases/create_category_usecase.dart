import '../repositories/category_repository.dart';

class CreateCategoryUseCase {
  final CategoryRepository _repository;

  const CreateCategoryUseCase(this._repository);

  Future<String> call({required String name, String? description}) {
    return _repository.createCategory(name: name, description: description);
  }
}
