import '../entities/public_menu.dart';
import '../repositories/public_menu_repository.dart';

class GetPublicMenuUseCase {
  final PublicMenuRepository _repository;

  const GetPublicMenuUseCase(this._repository);

  Future<PublicMenu> call(String slug) {
    return _repository.getMenu(slug);
  }
}
